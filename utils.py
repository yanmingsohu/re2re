import re
import sys
from pathlib import Path
import argparse
import os
import pefile  # pip install pefile


hexstr = '0123456789abcdefABCDEF'
decstr = '0123456789'


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
    print(f"; read {filename}")
    no = 0
    ml = 80
    comment_ret = re.compile(r'^COMMENT\s+(.?)', re.IGNORECASE)
    comment_end = None

    with open(filename, 'r', encoding='utf-8', errors='replace') as f:
        for line in f.readlines():
            no += 1
            if comment_end:
                if line == comment_end:
                    comment_end = None
                continue
            if r := comment_ret.match(line):
                comment_end = r.group(1)
                continue

            if structured:
                sp = line.split(';')
                code, comm = (sp[0], ','.join(sp[1:])) if len(sp)>1 else (sp[0], '')
                lines.append(( code.strip(), comm.strip(), filename, no ))
            else:
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