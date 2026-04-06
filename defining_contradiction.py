import re
import sys
from parse_jumptable import \
  complete_annotation, read_all_files, readfile
from dataclasses import dataclass, field
from typing import Literal, Final


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
    thisline = ' '
    if lcomm:
      commst = ' '* (80 - len(lcomm)) +';'
    if j == i:
      thisline = '>'
    print(f"{thisline} {num} |{numst}{lcode}{commst}{lcomm}")


def check_misplaced_tokens(lines):
  status = _WAIT
  st_label = None
  last_err_line = -10

  for i, (code, comm, filename, no) in enumerate(lines):
    if not code:
      continue
    st = line_re.match(code)
    if not st:
      continue

    def msg(s):
      nonlocal last_err_line
      if i-5 < last_err_line:
        return
      last_err_line = i
      print(s, f'\n{filename}:{no}:')
      show_code(lines, i)

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
      status = test_st
      st_label = label
      continue
    if ctype == _END_PROC:
      status = _WAIT
      st_label = None
      continue

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

    else:
      raise Error("无效状态")


if __name__ == '__main__':
  if len(sys.argv) > 1:
    lines = []
    readfile(sys.argv[1], lines, True)
  else:
    lines = read_all_files(structured=True) 

  check_misplaced_tokens(lines) 
