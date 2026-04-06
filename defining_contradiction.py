import re
import sys
from parse_jumptable import \
  complete_annotation, read_all_files, readfile, isnum, \
  numtype, is_ok, num
from dataclasses import dataclass, field
from typing import Literal, Final
import pefile  # pip install pefile
from extract_data_labels import \
  read_bytes_from_exe, pe_va_scope, show_pe_info


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
_LABEL_ST = { "$", "F", "L" }
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


def tname(i: int) -> str:
  return _NAME_MAP.get(i, f'unknown({i})')


def what_code(label, comma, cmd):
  if label in _KEYWORD or cmd in _KEYWORD:
    return _SKIP, _NO_CHG
  if cmd == 'proc':
    return _NEW_LABEL, _PROGRAM
  if cmd == 'endp':
    return _END_PROC, _WAIT
  if comma == ':' or comma == '::':
    return _NEW_LABEL, _PROGRAM
  if cmd in _MNEMONICS:
    return _NEW_LABEL, _PROGRAM
  if label in _MNEMONICS:
    return _NORM_CODE, _NO_CHG
  if cmd in _DATA_DIRECTIVES:
    return _NEW_LABEL, _DATA
  if label in _DATA_DIRECTIVES:
    return _DEFINE_DATA, _DATA
  return _NORM_CODE, _NO_CHG


def show_code(lines, i):
  for j in range(i-5, i+6, 1):
    if j >= len(lines)-1:
      break
    lcode, lcomm, lfilename, lno = lines[j]
    num = str(lno)
    numst = ' ' * (8-len(num))
    commst = ''
    if lcomm:
      commst = ' '* (60 - len(lcode)) +';'
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


def create_data_label(name):
  c = 0
  ind = ' ' * len(name)
  t = 'DWORD'
  addr = num(name)
  def write(x):
    nonlocal c, addr
    if c > 0:
      addr += 4
      print(ind, t, x, ' '*(11-len(x)), f";{hex(addr)}")
    else:
      c = 1
      print(name, t, x, '  ;'+ok_comm)
  return write


def check_misplaced_tokens(lines):
  status = _WAIT
  st_label = None
  last_err_label = None
  last_err_line = 0
  ref_var = 0
  const_var = 0
  donot_msg = 0
  last_log = []
  label_map = { -1:(-1, 'none') }
  last_addr = -1
  limit = 100

  for i, (code, comm, filename, no) in enumerate(lines):
    cmd = code.split(' ')[0]
    if not cmd or not cmd[0]:
      continue
    if cmd[0] in _LABEL_ST:
      cmd = cmd.replace(':', '')
      addr = num(cmd)
      label_map[addr] = (last_addr, cmd)
      _, llabel = label_map[last_addr]
      label_map[last_addr] = (addr, llabel)
      last_addr = addr

  exefile = 'bio2.exe' 
  pe = pefile.PE(exefile, fast_load=True)
  pe_st, pe_ed = pe_va_scope(pe)
  # 需要区分 rdata 只读地址段, pe_ed需要重新计算
  show_pe_info(pe)

  def show_fix(data):
    insert = create_data_label(st_label)
    for j in range(0, len(data), 4):
      x = dword(data[j:j+4])
      if x in label_map:
        _, tlabel = label_map[x]
        insert(tlabel)
      else:
        insert(hh(x))

  def fix_data():
    print("尝试修正:")
    st_index = num(st_label)
    if st_index in label_map:
      next_index, _ = label_map[st_index]
      count = next_index - st_index
      data = read_bytes_from_exe(exefile, st_index, count, pe)
      show_fix(data)
    else:
      print("找不到结束标签", st_label)

  def try_fixed_ref(lines, i):
    st_index = num(st_label)
    li = i
    filename = "?"
    for j in range(i, 0, -1):
      code = lines[j][0]
      filename = lines[j][2]
      if code.lower().find(st_label)>=0:
        li = j
        break

    mayberef = []
    data = None
    if st_index in label_map:
      next_index, _ = label_map[st_index]
      count = next_index - st_index
      data = read_bytes_from_exe(exefile, st_index, count, pe)
      for j in range(0, len(data), 4):
        x = dword(data[j:j+4])
        if x >= pe_st and x <= pe_ed:
          xaddr = hex(st_index + j)
          mayberef.append((xaddr, hex(x)))
    
    if len(mayberef) != ref_var:
      print('='*80)
      # print(ref_var, mayberef)
      for o, v in mayberef:
        print(f" !- 注意: 在偏移 {o} 上, 这个整数值 {v} 可能是地址引用")
      print(f'{filename}:{no}:[{st_label}]')
      show_code(lines, li)
      if data:
        print("尝试修正:")
        show_fix(data)

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
    if limit < 0:
      raise Error(" !! 还有更多修正未完成, 在以上修正完成后继续...")
    return False

  for i, (code, comm, filename, no) in enumerate(lines):
    if not code:
      continue
    st = line_re.match(code)
    if not st:
      continue

    def msg(s, cb=None):
      if check_duplicate_output():
        return
      print()
      print('='*80)
      print(s, f'\n{filename}:{no}:[{st_label}]')
      show_code(lines, i)
      if cb != None:
        cb()

    d = st.groupdict()
    label = d['label'].lower()
    comma = d['comma']
    cmds = d['command']
    sp = cmds.split(' ')
    cmd = sp[0].lower()
    args = sp[1:]

    ctype, test_st = what_code(label, comma, cmd)
    # print(no, '|', label, comma, cmd, "|", tname(ctype), tname(test_st))
    if ctype == _SKIP:
      continue
    if ctype == _NEW_LABEL:
      # 尝试修复之前数据标签的外部引用
      if status == _DATA and not donot_msg:
        try_fixed_ref(lines, i)
      status = test_st
      st_label = label
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
    if ctype == _DEFINE_DATA:
      args = cmd.split(' ')

    if status == _WAIT:
      if test_st == _NO_CHG and ctype == _NORM_CODE:
        msg(' -- 警告: 在函数外检测到代码')

    elif status == _PROGRAM:
      if test_st == _DATA:
        if not '090H' in sp:
          msg(" -- 错误: 在函数中检测到数据定义")

    elif status == _DATA:
      if test_st == _PROGRAM:
        msg(" -- 错误: 在数据标签中检测到代码")
      n, r = numtype(args)
      ref_var += r
      const_var += n
      # print(ref_var, const_var, '----')
      if ref_var>0 and const_var>0:
        msg(" -- 警告: 在数据标签中同时定义常量和地址引用", fix_data)

    else:
      raise Error("无效状态")
  print('\n'.join(last_log))


if __name__ == '__main__':
  if len(sys.argv) > 1:
    lines = []
    readfile(sys.argv[1], lines, True)
  else:
    lines = read_all_files(structured=True) 

  check_misplaced_tokens(lines) 
