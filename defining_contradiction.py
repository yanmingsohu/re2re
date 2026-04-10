import re
import sys
from dataclasses import dataclass, field
from typing import Literal, Final
import pefile  # pip install pefile
from tqdm import tqdm
from rich.tree import Tree
from rich import print as rprint
from rich.console import Group
from rich.panel import Panel

from utils import \
  read_bytes_from_exe, pe_va_scope, show_pe_info, \
  get_section_name, read_all_files, readfile, isnum, \
  numtype, is_ok, num, has_args, MMessages, err, filter_sum, \
  asm_string_len, parse_data

from asm_parser import \
  what_code, tname, show_code, hh, dword, make_label, \
  create_data_label, find_function, \
  _WAIT, _PROGRAM, _DATA, _NO_CHG, \
  _END_PROC, _NEW_LABEL, _NORM_CODE, _SKIP, _DEFINE_DATA, \
  _REG_MAP



def make_label_chain(lines):
  label_map = { -1:{'next':-1, 'cmd':"NONE", 'file':'NONE', 'no':-1} }
  last_addr = -1
  print("正则构建标签库", file=sys.stderr)
  for code, comm, filename, no in tqdm(lines):
    ok, label, cmd, args, ctype, test_st = what_code(code, f"{filename}:{no}")
    if ctype == _NEW_LABEL:
      # print(label)
      addr = num(label)
      label_map[addr] = {
        'next': last_addr, 
        'cmd' : label, 
        'file': filename, 
        'no'  : no,
        'code': code,
      }
      label_map[last_addr]['next'] = addr
      last_addr = addr
  return label_map


def show_fix(data, st_label, label_map, comm_map={}):
  insert = create_data_label(st_label)
  for j in range(0, len(data), 4):
    x = dword(data[j:j+4])
    comm = comm_map.get(x, '')
    if x in label_map:
      insert(label_map[x]['cmd'], comm)
    else:
      insert(hh(x), comm)

def skip_label_notalign(st_label, last_log):
  lnum = num(st_label)
  if not lnum or lnum%4 != 0:
    last_log.append(f" - 警告: 标签地址不是4字节对齐, 忽略 {st_label}")
    return True
  return False


def check_misplaced_tokens(lines, _fix_mix=True, not_limit=False):
  status = _WAIT
  st_label = None
  st_label_index = 0
  last_err_label = None
  last_err_line = 0
  ref_var = 0
  const_var = 0
  donot_msg = 0
  last_log = []
  label_map = make_label_chain(lines)
  limit = 100

  exefile = 'bio2.exe' 
  pe = pefile.PE(exefile, fast_load=True)
  # 需要区分 rdata 只读地址段, pe_ed需要重新计算
  show_pe_info(pe)


  def fix_mixed_data():
    print("尝试修正混合定义:")
    st_index = num(st_label)
    if st_index in label_map:
      next_index = label_map[st_index]['next']
      count = next_index - st_index
      data = read_bytes_from_exe(exefile, st_index, count, pe)
      # print("read", hex(st_index), hex(next_index), data)
      show_fix(data, st_label, label_map)
    else:
      print("找不到结束标签", st_label)

  def try_fixed_ref(lines, i):
    st_index = num(st_label)
    mayberef = []
    data = None
    if st_index in label_map:
      _code = label_map[st_index]['code']
      if _DB_STRING.match(_code):
        last_log.append(f"跳过明确的字符串定义 {_code}")
        return
      next_index = label_map[st_index]['next']
      if not (next_index and st_index):
        print(f" -- 标签 {st_label}:{st_index} 没有 next 索引 {label_map[st_index]} 跳过")
        return
      # print('>', next_index, st_index)
      count = next_index - st_index
      # print("read", hex(st_index), hex(next_index), get_section_name(pe, st_index))
      data = read_bytes_from_exe(exefile, st_index, count, pe)
      for j in range(0, len(data), 4):
        x = dword(data[j:j+4])
        sn = get_section_name(pe, x)
        if sn in _SECTION_MP and x%4==0:
          xaddr = hex(st_index + j)
          mayberef.append((xaddr, x, _SECTION_MP[sn]))
    
    if len(mayberef) != ref_var:
      section()
      comm_map = {}
      # print(ref_var, mayberef)
      for o, v, t in mayberef:
        print(f" !- | 注意: 在PE偏移 {o} 上, 这个整数值 {hex(v)} 可能是 {t}")
        if ol := label_map.get(v, None):
          msg = f"在文件 {ol['file']}:{ol['no']} 找到这个标签定义: {ol['cmd']}"
          comm_map[v] = " <- "
        elif v%4 != 0:
          msg = f'地址不能整除4, 不是地址引用'
          comm_map[v] = " <- "+ msg
        else:
          vl = make_label(v)
          msg = f"找不到标签定义: {vl}"
          comm_map[v] = " <- "+ msg
        print(f"    | {msg}")

      print(f'{filename}:{no}:[{st_label}]')
      show_code(lines, st_label_index)
      if data:
        print("尝试修正地址引用:")
        show_fix(data, st_label, label_map, comm_map)

  def check_duplicate_output():
    nonlocal last_err_label, last_err_line, limit
    # 同一个标签只报告一次
    if st_label == last_err_label:
      return True
    # 临近的行不要重复报告
    if i <= last_err_line:
      return True
    if donot_msg:
      last_log.append(f" -- 标注完成 {filename}:{no}")
      return True
    last_err_label = label
    last_err_line = i + 10
    limit -= 1
    if limit < 0 and not not_limit:
      raise OSError(" !! 还有更多修正未完成, 在以上修正完成后继续...")
    return False

  print("正则检查汇编代码", file=sys.stderr)
  for i, (code, comm, filename, no) in enumerate(tqdm(lines)):
    ok, label, cmd, args, ctype, test_st = what_code(code)
    if not ok:
      continue

    def msg(s, cb=None):
      if check_duplicate_output():
        return
      section()
      print(s, f'\n{filename}:{no}:[{st_label}]')
      if skip_label_notalign(st_label, last_log):
        return
      show_code(lines, i)
      if cb != None:
        cb()

    # print(no, '|', label, comma, cmd, "|", tname(ctype), tname(test_st))
    if ctype == _SKIP:
      continue
    if ctype == _NEW_LABEL:
      # 尝试修复之前数据标签的外部引用
      if status == _DATA and not donot_msg and not skip_label_notalign(st_label, last_log):
        try_fixed_ref(lines, i)

      status = test_st
      st_label = label
      st_label_index = i
      last_err_line = i
      last_err_label = None
      ref_var = 0
      const_var = 0
      donot_msg = comm.find(ok_comm) >= 0
      # print("new label", label, check_duplicate_output(), donot_msg, comm)
    if ctype == _END_PROC:
      status = _WAIT
      st_label = None
      continue

    if status == _WAIT:
      if test_st == _NO_CHG and ctype == _NORM_CODE:
        msg(' -- 警告: 在函数外检测到代码')

    elif status == _PROGRAM:
      if test_st == _DATA:
        if not '090H' in args:
          msg(" -- 错误: 在函数中检测到数据定义")

    elif status == _DATA:
      if test_st == _PROGRAM:
        msg(" -- 错误: 在数据标签中检测到代码")
      n, r = numtype(args)
      ref_var += r
      const_var += n
      
      # print(n, r, ref_var, const_var, args)
      if ref_var>0 and const_var>0:
        if _fix_mix:
          msg(" -- 警告: 在数据标签中同时定义常量和地址引用", fix_mixed_data)
        else:
          last_log.append(f"数据标签中同时定义常量和地址引用 {filename}:{no}:[{st_label}]")

    else:
      raise Error("无效状态")
  section()
  print("调试信息")
  print('\n'.join(last_log))


def section():
  print()
  print('='*80)


def find_floating_code(lines):
  print("正则检查悬空代码", file=sys.stderr)
  ct_label = None
  status = None

  for i, (code, comm, filename, no) in enumerate(tqdm(lines)):
    ok, label, cmd, args, act, _t = what_code(code)
    if not ok:
      continue

    def check():
      if ct_label == None and status == _PROGRAM:
        section()
        print(f" - 错误: 在文件 {filename}:{no} 代码段结束, 但代码没有对应的标签")
        show_code(lines, i)

    if act == _NEW_LABEL:
    #   if status == _PROGRAM:
    #     check()
      if _t == _PROGRAM:
        status = _PROGRAM
        ct_label = label
      if _t == _DATA:
        status = _SKIP
        ct_label = None

    # if act == _END_PROC:
    #   check()

    if act == _NORM_CODE:
      if cmd == 'jmp':
        check()
        ct_label = None


def show_function_chain(lines, fn, useAI=False):
  func_map, call_chain = find_function(lines)
  print(" * 表示没有在源代码中定义, 可能是外部导入")
  ext = {} # 只用于计数
  x = []
  comments = {}

  def process():
    print(f"\r正在创建树: ..{''.join(x)}", end="", file=sys.stderr, flush=True)
    if len(x) > 60:
      x.clear()
    x.append('.')

  def find_func(f):
    if not f in func_map:
      ext[f] = 1
      return False, f +" (*)"
    i = func_map[f]['st']
    return lines[i], False

  def func_code(f):
    buf = []
    fi = func_map[f]
    for i in range(fi['st'], fi['ed'], 1):
      code, comm, filename, no = lines[i]
      if comm:
        buf.append(comm)
      buf.append(code)
    return '\n'.join(buf)

  def make_comment_ai(f):
    msg = MMessages(f)
    if c := msg.get_cache():
      return c
    code = func_code(f)
    msg.add(f'这是函数的源代码:\n{code}')

    if f in call_chain:
      for d in call_chain[f]:
        ff, ext = find_func(d)
        if ext:
          continue
        # 因为是按照依赖顺序调用, 所以一定会有
        if comm := msg.get_cache(d):
          comm = filter_sum(comm)  
        else:
          comm = comments.get(d, None)
          t = filter_sum(comm)
          if t:
            comm = t
        msg.add(f"这是依赖项 {d} 的说明:\n{comm}")
        # err("!"*80, d, ext, '\n', comm)
        # err(f' - debug {d} - {note}')
    return msg.call_ai()

  def make_tree_info(f):
    ff, ext = find_func(f)
    if ext:
      return ext
    __, _, filename, no = ff
    p = [Panel(comments[f])] if f in comments else []
    return Group(f"{f} ({filename}:{no})", *(p))

  def _child(skip, r, f):
    t = r.add(make_tree_info(f))
    if f in call_chain:
      if f in skip:
        return
      skip[f] = 1
      for chf in call_chain[f]:
        _child(skip, t, chf)
    # return t

  def get_comment_from_code(f):
    ff, ext = find_func(f)
    if ext:
      return ext
    code, comm, filename, no = ff
    comm = ''.join(comm)
    if comm:
      comments[f] = comm
    return comm

  def make_order(skip, f, o):
    c = get_comment_from_code(f)
    if f in call_chain:
      if f in skip:
        return
      skip[f] = 1
      for chf in call_chain[f]:
        make_order(skip, chf, o)
    o.append(f)

  order = []
  make_order({}, fn, order)
  print(f" - {len(ext)} 个外部定义函数")
  print('\n按依赖顺序\n\t', '\n\t'.join(order))

  if useAI:
    i = 0
    for f in order:
      i += 1
      # print(f, '??', (not f in comments), (f in func_map))
      if (not f in comments) and (f in func_map):
        err(f' - 从 AI 构建说明 {f} - ({i}/{len(order)})')
        comments[f] = make_comment_ai(f)
  
  root = Tree('ROOT')
  _child({}, root, fn)
  print('\n依赖树')
  rprint(root)


def show_function_all(lines):
  func_map, call_chain = find_function(lines)
  for f, v in func_map.items():
    i = v['st']
    code, comm, filename, no = lines[i]
    print(f'{f} ({i}). {filename}:{no})')
    if f in call_chain:
      for ch in call_chain[f]:
        print(f"  |-- {ch}")


def find_bad_data_addr(lines):
  dl = []
  currlb = None
  nextlb = None
  currll = 0

  print("分析数据地址")
  for i, (code, comm, filename, no) in enumerate(tqdm(lines)):
    ok, label, cmd, args, act, _t = what_code(code)
    if not ok:
      continue
    if _t == _DATA:
      if act == _NEW_LABEL:
        addr = num(label)
        if not addr:
          print(f" !- 标签不含地址 {label}")
          continue
        if nextlb != None and nextlb != addr:
          print(f"地址不连续或覆盖: ({filename}:{no}) {label}, {currll}字节")
          if addr < nextlb:
            x = nextlb - addr
            print(f" -- 标签 {label} 覆盖了前一个标签 {currlb}, {x} 个字节")
            print(f"    {hex(nextlb)} {hex(addr)}")
          else:
            x = addr - nextlb
            print(f" -- 前一个标签 {currlb} 缺少 {x} 个字节")
        currlb = label
        nextlb = addr
        currll = 0
      db = parse_data(cmd, args, f"{filename}:{no}")
      currll += db
      nextlb += db
      continue
    if act == _SKIP:
      continue
    print(f'无效的代码: ({filename}:{no}) {code} - {act},{_t}')


def main():
  if i := has_args('-bd'):
    lines = []
    for j in range(i+1, len(sys.argv), 1):
      readfile(sys.argv[j], lines, True)
    find_bad_data_addr(lines)
    return

  lines = read_all_files(structured=True) 
  if has_args('-j'):
    find_floating_code(lines)
  if i := has_args('-f2'):
    if i+1 < len(sys.argv):
      fn = sys.argv[i+1]
      show_function_chain(lines, fn, has_args('-ai'))
    else:
      show_function_all(lines)
  else:
    fix_mix = has_args('-f1')
    not_limit = has_args('-nl')
    check_misplaced_tokens(lines, fix_mix, not_limit) 


if __name__ == '__main__':
  main()
