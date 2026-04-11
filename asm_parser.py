import sys
from dataclasses import dataclass, field
from typing import Literal, Final
import pefile  # pip install pefile
import re
from tqdm import tqdm

from utils import \
  read_bytes_from_exe, pe_va_scope, show_pe_info, \
  get_section_name, read_all_files, readfile, isnum, \
  numtype, is_ok, num, has_args, MMessages, err, filter_sum, \
  asm_string_len, parse_data


line_re = re.compile(
  r'\s*(?P<label>[_$a-zA-Z0-9]+)(?P<comma>\:*)\s*(?P<command>.*)?' )


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
      args = sp
      cmd = label
      break
    if cmd in _DATA_DIRECTIVES:
      act = _NEW_LABEL
      _type = _DATA
      break 
    if label in _DATA_DIRECTIVES:
      act = _DEFINE_DATA
      _type = _DATA
      args = sp
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


def find_all_label(lines):
  label_addr = {}
  for i, (code, comm, filename, no) in enumerate(tqdm(lines)):
    ok, label, cmd, args, act, _t = what_code(code)
    if not ok:
      continue
    if act == _NEW_LABEL:
      try:
        label_addr[num(label)] = label
      except ValueError:
        print(f" -- 警告: 标签不是虚拟地址: {label}")
  return label_addr