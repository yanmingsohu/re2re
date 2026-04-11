import re
import sys
from pathlib import Path
import argparse
import os
import pefile  # pip install pefile
from ai_dasm import chat_with_stream, Messages
from rich import print as rprint


hexstr = '0123456789abcdefABCDEF'
decstr = '0123456789'
base_url = 'http://127.0.0.1:7001'
api_key = 'none'
system_prompt_file = 'prompt_make_comment.txt'
cache_dir = 'comment_cache'
    

def MMessages(name, sysfile=system_prompt_file):
    return Messages(name, sysfile, base_url, cache_dir, api_key)


find_sum = re.compile(r"<\b[^>]*>(.*?)</b>", re.DOTALL)
find_call = re.compile(r"<call\b[^>]*>(.*?)</call>", re.DOTALL)

def filter_sum(txt):
    buf = []
    for m in find_sum.findall(txt):
        buf.append(m)
    for m in find_call.findall(txt):
        buf.append(m)
    return '\n'.join(buf)


def num(str):
    if len(str) < 1:
        return 0
    str = str.lower().strip()
    if str.startswith('fun_'):
        return int(str[4:], 16)
    try:
      for i, c in enumerate(str):
          if c in hexstr:
              if i>0:
                  if str.endswith('h'):
                      return int(str[:-1], 16)
                  return int(str[i:], 16)
              else:
                  if str.endswith('h'):
                      return int(str[:-1], 16)
                  return int(str, 0)
    except ValueError:
      return None
    return 0


# DD str 判断是数字还是引用
def isnum(str):
    return (str[0] in hexstr[:10]) if str else False


dup_re = re.compile(r'dup\((\d+)\)', re.IGNORECASE)

# (num-count, ref-count) 返回一个命令参数中, 常量和地址引用的数量
def numtype(arr):
    db_str = False
    nn = 0
    ref = 0
    for s in arr:
        if r := dup_re.match(s):
            nn += int(r.group(1))
            return (nn, ref)
    for s in arr:
        if isnum(s):
            nn += 1
        elif s.find("'")>=0 or s.find('"')>=0 or db_str:
            nn += len(s) #很粗糙的计算
            db_str = True
        else:
            ref += 1
    if db_str:
        nn -= 2
    return (nn, ref)


def is_ok(line, ca: '++'):
    if type(line) == str:
        return line.find(complete_annotation) >= 0
    elif type(line) == tuple:
        return line[1].find(complete_annotation) >= 0 if comm[1] else -1


def has_args(what):
    for i, a in enumerate(sys.argv):
        if a == what:
            return i
    return False


def show_code_btw(buf, a, b):
    def ln(x):
        x = x.split(';')
        if x and len(x)>1:
            x = x[1].split(':')
            if x and len(x)>1:
                return int(x[1])
        return 0
    buf.append(a)
    x = ln(a)
    y = ln(b)
    n = y - x
    leading_spaces = len(a) - len(a.lstrip())
    buf.append((' ')*leading_spaces + f"...(n)")
    buf.append(b)


def readfile(filename, lines, structured):
    if not sys.stdout.isatty():
        print(f"; read {filename}")
    err(f" - 读取文件 {filename}")
    no = 0
    ml = 80
    comment_ret = re.compile(r'^COMMENT\s+(.?)', re.IGNORECASE)
    comment_end = None
    last_multi_comment = []

    def parse_line(line):
        instr = False
        for i in range(len(line)-1, 0, -1):
            if line[i] == "'" or line[i] == '"':
                instr = not instr
            if instr:
                continue
            if line[i] == ';':
                return line[0:i], line[i+1:]
        return line, ''

    with open(filename, 'r', encoding='utf-8', errors='replace') as f:
        for line in f.readlines():
            no += 1
            if comment_end:
                if line.strip() == comment_end:
                    comment_end = None
                last_multi_comment.append(line.strip())
                continue
            if r := comment_ret.match(line):
                comment_end = r.group(1)
                continue

            if structured:
                # sp = line.split(';')
                # code, comm = (sp[0], ','.join(sp[1:])) if len(sp)>1 else (sp[0], '')
                code, comm = parse_line(line)
                code = code.strip()
                comm = comm.strip()
                if not code:
                    last_multi_comment.append(comm)
                    continue
                elif last_multi_comment:
                    comm = ';'.join(last_multi_comment + ([comm] if comm else []))
                    last_multi_comment = []
                lines.append(( code, comm, filename, no ))
            else:
                # 非结构方法废弃, 不合并多行注释
                comm = f"; {filename}:{no}"
                indent = ' ' * (ml - len(line) - len(comm))
                nline = line.replace('\n', '') + indent + comm
                lines.append(nline)


def read_all_files(mainfile="main.S", srcdir='./src', structured=False):
    lines = []
    readfile(mainfile, lines, structured)
    for file in Path(srcdir).rglob('*.S'):
        if file.is_file():
            readfile(file, lines, structured)
    return lines    


def read_bytes_from_exe(exe_path: str, va: int, count: int, pe: pefile.PE) -> bytes | None:
    """将虚拟地址转换为文件偏移，读取 count 字节。"""
    rva = va - pe.OPTIONAL_HEADER.ImageBase
    section = pe.get_section_by_rva(rva)
    if not section:
        raise ValueError(f"RVA 0x{rva:X} 不属于任何 section")

    offset_in_sec = rva - section.VirtualAddress
    # 超出磁盘实际数据 → 全0（和 Loader 行为一致）
    if offset_in_sec >= section.SizeOfRawData:
        return b'\x00' * count

    can_read = section.SizeOfRawData - offset_in_sec
    read_len = min(count, can_read)
        
    data = pe.get_data(rva, read_len)
    if len(data) < count:
        data += b'\x00' * (count - len(data))
    # if len(data) != count:
    #   raise Exception(f"数据不足 {len(data)} 预期 {count}, 读取 {hex(va)}")
    return data 

def pe_va_scope(pe):
    return pe.OPTIONAL_HEADER.ImageBase, pe.OPTIONAL_HEADER.SizeOfImage


def show_pe_info(pe):
    image_base = pe.OPTIONAL_HEADER.ImageBase
    size_of_image = pe.OPTIONAL_HEADER.SizeOfImage
    print(f" - 整体VA范围: {image_base:#010x} ~ {image_base + size_of_image:#010x}")
    for section in pe.sections:
        name = section.Name.rstrip(b'\x00').decode()
        va_start = image_base + section.VirtualAddress
        va_end   = va_start + section.Misc_VirtualSize
        print(f" - {name:<10} {va_start:#010x} ~ {va_end:#010x}  ({section.Misc_VirtualSize:#x} bytes)")

def get_section_name(pe, addr):
    _st = pe.OPTIONAL_HEADER.ImageBase
    _ed = pe.OPTIONAL_HEADER.ImageBase + pe.OPTIONAL_HEADER.SizeOfImage
    if addr < _st or addr > _ed:
        return None
    for section in pe.sections:
        va_start = _st + section.VirtualAddress
        va_end   = va_start + section.Misc_VirtualSize
        if addr >= va_start and addr < va_end:
            return section.Name.rstrip(b'\x00').decode()
    return None


def open_pe(file):
  try:
      return pefile.PE(file, fast_load=False)
  except Exception as e:
      print(f"错误: 无法解析 PE 文件: {e}", file=sys.stderr)
      sys.exit(1)


def err(s):
    print(s, file=sys.stderr)


def asm_string_len(s: str) -> int:
    """
    计算 MASM 字符串长度（支持 ' 和 "，支持 '' / "" 转义）
    只处理一个字符串字面量
    """
    s = s.strip()
    if not s:
        return 0

    quote = s[0]
    if quote not in ("'", '"'):
        raise ValueError("不是合法的 asm 字符串")

    if s[-1] != quote:
        raise ValueError("字符串未正确闭合")

    i = 1
    n = 0
    end = len(s) - 1

    while i < end:
        # 处理 '' 或 ""
        if i + 1 < end and s[i] == quote and s[i + 1] == quote:
            n += 1
            i += 2
        else:
            n += 1
            i += 1
    return n


db_str = re.compile(r"'(.+)'")
db_dup = re.compile(r"([0-9]+)\s+DUP(\(.+\))")
db_mul = re.compile(r"([0-9][0-9a-hA-H]+h?),?")

def parse_data(cmd, args, msg):
  cmd = cmd.upper()
  if cmd == 'BYTE':
    return 1
  if cmd == 'DWORD':
    return 4
  if cmd == 'DB':
    arg = ' '.join(args)
    if a := db_str.match(arg):
      return asm_string_len(arg)
    if a := db_dup.match(arg):
      return num(a.group(1))
    if a := db_mul.findall(arg):
      return len(a)
  raise Exception(f"无效命令: {cmd} / {args}, {msg}")