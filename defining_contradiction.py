import re
import sys
from dataclasses import dataclass, field
from typing import Literal, Final
import pefile  # pip install pefile
from utils import \
  read_bytes_from_exe, pe_va_scope, show_pe_info, \
  get_section_name, read_all_files, readfile, isnum, \
  numtype, is_ok, num, has_args, Messages, err
from tqdm import tqdm
from rich.tree import Tree
from rich import print as rprint
from rich.console import Group
from rich.panel import Panel


line_re = re.compile(
  r'\s*(?P<label>[_$a-zA-Z0-9]+)(?P<comma>\:*)\s*(?P<command>.*)?' )

find_sum = re.compile(r"<b\b[^>]*>(.*?)</b>", re.DOTALL)

_DATA_DIRECTIVES = {
  "db", "dw", "dd", "dq", "dt", "real4", "real8", "real10",
  'dword', 'byte', 
}
_KEYWORD = {
  'assume', '.model', '.xmm', '.686p', 'include', 'extern', 'public',
  'segment', 'align', 'includelib', 'textequ', 'comment'
}
_MNEMONICS = {
    "mov", "movsx", "movzx", "movs", "movsb", "movsw", "movsd",
    "push", "pop", "pusha", "popa", "pushad", "popad",
    "add", "sub", "mul", "imul", "div", "idiv",
    "and", "or", "xor", "not", "neg", "shl", "shr", "sal", "sar",
    "inc", "dec", "lea", "xchg", "cmp", "test",
    "jmp", "je", "jne", "jz", "jnz", "jg", "jge", "jl", "jle",
    "ja", "jae", "jb", "jbe", "jc", "jnc", "js", "jns",
    "call", "ret", "retn", "retf", "iret",
    "nop", "hlt", "int", "into", "sti", "cli", "cld", "std",
    "rep", "repe", "repne", "repz", "repnz",
    "lods", "lodsb", "lodsw", "lodsd",
    "stos", "stosb", "stosw", "stosd",
    "cmps", "cmpsb", "cmpsw", "cmpsd",
    "scas", "scasb", "scasw", "scasd",
    "rol", "ror", "rcl", "rcr",
    "enter", "leave",
    "fld", "fst", "fstp", "fadd", "fsub", "fmul", "fdiv",
    "in", "out", "ins", "outs",
    "wait", "lock", "bound",
    "adc", "sbb",
    "cbw", "cwde", "cwd", "cdq",
    "xlat", "xlatb",
    "lahf", "sahf", "pushf", "popf", "pushfd", "popfd",
}
_REG_MAP = {
    # --- General Purpose Registers (32-bit / 64-bit) ---
    "EAX": "Accumulator",          "RAX": "64-bit Accumulator",
    "EBX": "Base Index",           "RBX": "64-bit Base Index",
    "ECX": "Counter",              "RCX": "64-bit Counter",
    "EDX": "Data Register",        "RDX": "64-bit Data Register",
    "ESI": "Source Index",         "RSI": "64-bit Source Index",
    "EDI": "Destination Index",    "RDI": "64-bit Destination Index",
    "EBP": "Base Pointer",         "RBP": "64-bit Base Pointer",
    "ESP": "Stack Pointer",        "RSP": "64-bit Stack Pointer",

    # --- Segment Registers ---
    "CS":  "Code Segment",         "DS":  "Data Segment",
    "SS":  "Stack Segment",        "ES":  "Extra Segment",
    "FS":  "FS Segment (Thread Local)", "GS": "GS Segment (Kernel/TLS)",

    # --- Special / Control Registers ---
    "EIP": "Instruction Pointer",  "RIP": "64-bit Instruction Pointer",
    "EFLAGS": "Status Flags",      "RFLAGS": "64-bit Status Flags",

    # --- Floating Point / SIMD (Commonly used in Games/Graphics) ---
    "ST(0)": "FPU Stack 0",        "XMM0": "SIMD Register 0",
    "XMM1": "SIMD Register 1",     "XMM2": "SIMD Register 2",
}

_LABEL_FIRST = { "$", "F", "L",  }
ok_comm = '=='

_WAIT     : Final = 0
_PROGRAM  : Final = 1
_DATA     : Final = 2
_NO_CHG   : Final = 3

_END_PROC     : Final = 4
_NEW_LABEL    : Final = 5
_NORM_CODE    : Final = 6
_SKIP         : Final = 7
_DEFINE_DATA  : Final = 8

_NAME_MAP: dict[int, str] = {
    _WAIT:       'wait',
    _PROGRAM:    'program',
    _DATA:       'data',
    _NO_CHG:     'no-chg',
    _END_PROC:   'end-proc',
    _NEW_LABEL:  'new-label',
    _NORM_CODE:  'norm-code',
    _SKIP:       'skip',
    _DEFINE_DATA:'define-data',
}
_SECTION_MP = { '.text':'程序段', '.rdata':'常量', '.data':'全局变量'}
_DB_STRING = re.compile(r".*DB\s+'.*'")


def tname(i: int) -> str:
  return _NAME_MAP.get(i, f'unknown({i})')


def what_code(code, lineInf=""):
  rlabel = None
  cmd = None
  args = None
  act = _SKIP
  _type = _NO_CHG
  ok = False
  
  while code:
    st = line_re.match(code)
    if not st:
      break
    d = st.groupdict()
    rlabel = d['label'] 
    label = rlabel.lower()
    cmds = d['command']
    comma = d['comma']
    sp = cmds.split(' ')
    cmd = sp[0].lower()
    args = sp[1:]
    ok = True
    if label in _KEYWORD or cmd in _KEYWORD:
      act = _SKIP
      _type = _NO_CHG
      break
    if cmd == 'proc':
      act = _NEW_LABEL
      _type = _PROGRAM
      break
    if cmd == 'endp':
      act = _END_PROC
      _type = _WAIT
      break
    if comma == ':' or comma == '::':
      act = _NEW_LABEL
      _type = _PROGRAM
      break
    if cmd in _MNEMONICS:
      act = _NORM_CODE
      _type = _PROGRAM
      break
    if label in _MNEMONICS:
      act = _NORM_CODE
      _type = _NO_CHG
      args = cmds.split(' ')
      cmd = label
      break
    if cmd in _DATA_DIRECTIVES:
      act = _NEW_LABEL
      _type = _DATA
      break 
    if label in _DATA_DIRECTIVES:
      act = _DEFINE_DATA
      _type = _DATA
      args = cmd.split(' ')
      cmd = rlabel
      break
    # raise OSError(f"未知的代码: {code}, {lineInf}")
    break
  return ok, rlabel, cmd, args, act, _type


def show_code(lines, i):
  for j in range(i-5, i+6, 1):
    if j >= len(lines)-1:
      break
    lcode, lcomm, lfilename, lno = lines[j]
    num = str(lno)
    numst = ' ' * (8-len(num))
    commst = ''
    if lcomm:
      commst = ' '* (40 - len(lcode)) +';'
    thisline = ' '
    if j == i:
      thisline = '>'
    print(f"{thisline} {num} |{numst}{lcode}{commst}{lcomm}")


def hh(n):
  return f'{n:09X}h'


def dword(d):
  r = 0
  length = len(d)
  if length >= 4:
      r += d[3] << 24
  if length >= 3:
      r += d[2] << 16
  if length >= 2:
      r += d[1] << 8
  if length >= 1:
      r += d[0]
  return r


def make_label(addr:int):
  return '$L_'+ hex(addr).replace('0x', '')


def create_data_label(name):
  c = 0
  ind = ' ' * len(name)
  t = 'DWORD'
  addr = num(name)
  def insert(x, ocomm=""):
    nonlocal c, addr
    if c > 0:
      addr += 4
      print(ind, t, x, ' '*(11-len(x)), f";{hex(addr)} {ocomm}")
    else:
      c = 1
      print(name, t, x, f'  ;{ok_comm} {ocomm}')
  return insert


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


def parse_call(cmd, args):
  if cmd == 'call':
    if args[0] in _REG_MAP:
      return None, args[0]
    if args[0].lower() == 'dword':
      fn = args[2]
      if fn[0] == '[':
        return None, fn
      if fn in _REG_MAP:
        return None, fn
      return fn, None
    return args[0], None
  return None, None


def find_function(lines):
  print("正在查找函数", file=sys.stderr)
  func_map = {}
  call_chain = {}
  status = _WAIT
  curr_label = None

  for i, (code, comm, filename, no) in enumerate(tqdm(lines)):
    ok, label, cmd, args, act, _t = what_code(code)
    if not ok:
      continue

    # print(f"{label} {no}")

    if status == _WAIT:
      if act == _NEW_LABEL and _t == _PROGRAM:
        if cmd == 'proc':
          status = _PROGRAM
          func_map[label] = {'st':i, 'ed':-1}
          call_chain[label] = []
          curr_label = label
          # print(f'{label} ({len(func_map)}. {filename}:{no})')
        else:
          msg = f"错误: 检测到函数外的独立代码标签" \
              + f'\n -- {code} ; ({len(func_map)}. {filename}:{no})'
          raise Exception(msg)
      continue
    if status == _PROGRAM:
      if act == _END_PROC and cmd == 'endp':
        func_map[curr_label]['ed'] = i+1
        curr_label = None
        status = _WAIT
      if act == _NEW_LABEL and cmd == 'proc':
        msg = f"错误: 禁止在函数中定义函数 {filename}:{no}:\n -- {code}"
        raise Exception(msg)
      if act == _NORM_CODE:
        fn, reg = parse_call(cmd, args)
        if fn:
          call_chain[curr_label].append(fn)
          # print(f"  |-- {fn}")
    else:
      continue

  print(f"找到 {len(func_map)} 个函数")
  return func_map, call_chain


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
    msg = Messages(f)
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
        note = []
        if comm := comments.get(d, None):
          note.append(comm)
        if comm := msg.get_cache(d):
          for m in find_sum.findall(comm):
            note.append(m)
        # print("!"*80, d, ext, '\n', comm)
        comm = '\n'.join(note)
        msg.add(f"这是依赖项 {d} 的说明:\n{comm}")
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


def main():
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
