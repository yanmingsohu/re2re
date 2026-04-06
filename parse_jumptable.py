import re
import sys
from pathlib import Path


# 找所有 jmp DWORD PTR [REG*4+$L_xxxxxx] 指令
jmp_pattern = re.compile(
    r'jmp\s+DWORD\s+PTR\s+\[(\w+)(?:\*[0-9a-fA-F])\+(\$L_[0-9a-fA-F]+)\]', re.IGNORECASE)
case_reg_re = re.compile(
    r'\s*cmp\s+(\w+)\s*,\s*(E.+)(?:\s*;.*)', re.IGNORECASE)

# 找标签定义: $L_xxxxxx:: 或 $L_xxxxxx DWORD ...
label_pattern = re.compile(r'(\$L_[0-9a-fA-F]+)')
end_label = re.compile(r'\s*(\$L_[0-9a-fA-F]+)(?::|[\s])')
# 模糊的找到跳转指令
callor_re = re.compile(r'\s*(jmp|call)\s+.*')

start_proc = re.compile(
    r'^\s*([a-zA-Z$_][0-9a-zA-Z$_]*)\s+(PROC|ENDP)\s*', 
    re.IGNORECASE)
dword = re.compile(r'\s*.*\s*DWORD\s+([0-9][0-9a-fA-F]+H*)+', 
    re.IGNORECASE)
dword_ref = re.compile(
    r'\s*.*\s*DWORD\s+([a-zA-Z$_][0-9a-zA-Z$_]*)+', 
    re.IGNORECASE)
byte_re = re.compile(r'\s*.*\s*BYTE\s+([0-9a-fA-F]+H*)', 
    re.IGNORECASE)
db_re = re.compile(r'\s*.*\s*DB\s+([0-9a-fA-F]+H*)(\s+DUP.+)?', 
    re.IGNORECASE)
nop_re = re.compile(r'\s*.*\s*nop.*', re.IGNORECASE)

complete_annotation = ';++'


def numH(n):
    if n.lower().endswith('h'):
        return int(n[:-1], 16)
    return int(n)


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


# 找 switch 可能的数量
def find_case_num(lines, st, reg):
    find_re = re.compile(
        fr'\s*cmp\s+({reg})\s*,\s*([0-9][0-9a-fA-F]*H?)', re.IGNORECASE)
    one_re = re.compile(
        fr'\s*xor\s+{reg}\s*,\s*{reg}', re.IGNORECASE)    
    case_buf = []
    treg = None
    num = -2

    for i in range(st-1, 0, -1):
        ln = lines[i]

        one = one_re.match(ln)
        if one:
            num = 0
            show_code_btw(case_buf, ln, lines[st])
            break

        case_num = find_re.match(ln)
        if case_num:
            num = numH(case_num.group(2))
            show_code_btw(case_buf, ln, lines[st])
            if treg and treg != case_num.group(1):
                case_buf.append(f" -- 警告: {treg}!={case_num.group(1)}")
            break

        case_reg = case_reg_re.match(ln)
        if case_reg:
            case_buf.append(ln)
            treg = case_reg.group(2)
            find_re = re.compile(
                fr'\s*mov\s+({treg})\s*,\s*([0-9a-fA-F]+H*)', 
                re.IGNORECASE)

        if label_pattern.match(ln):
            break
        if start_proc.match(ln):
            break
        if callor_re.match(ln):
            break
    # 跳转表从 0 开始
    return num+1, '\n'.join(case_buf)


def not_empty_code(s):
    x = s.split(';')
    if len(x) > 1:
        x = x[0]
    else:
        x = s
    return x.strip()


def parse_asm_file(lines):
    # 建立标签 -> 行号 的索引
    id = 0
    last_log = []
    label_lines = {}
    skip_label = {}
    
    for i, line in enumerate(lines):
        m = end_label.match(line)
        if m:
            label = m.group(1)            
            if complete_annotation in line: #忽略特殊标记
              skip_label[label] = i 
              last_log.append(f"-- 明确标记完成的标签 {label}")
            if label not in label_lines:
                label_lines[label] = i

    # 找所有跳转表引用
    jmp_targets = []
    for i, line in enumerate(lines):
        m = jmp_pattern.search(line)
        if m:
            reg = m.group(1)
            label = m.group(2)
            case_num, case_str = find_case_num(lines, i, reg)
            jmp_targets.append((i + 1, label, line, case_num, case_str))

    if not jmp_targets:
        print("没有找到跳转表指令")
        return

    
    for lineno, label, sline, case_num, case_str in jmp_targets:
        if label in skip_label:
          continue
        
        log = []
        log.append(f"\n{'='*60}")
        log.append(f"找到跳转表引用: \n{sline}")

        if label not in label_lines:
            log.append(f"  !! 找不到标签 {label} 的定义")
            continue

        start = label_lines[label]
        log.append(f"标签 {label} 定义")
        log.append(f"{'-'*60}")
        dword_ct = 0
        dword_ref_ct = 0
        byte_ct = 0
        other_ct = []
        nop_ct = 0
        print_full_log = 0
        empty_ct = 0
        mem_size = 0
        checknot_allref = 0

        # 从标签行开始，读到下一个 $L_ 标签为止
        for j in range(start, len(lines)):
            line = lines[j]
            # 跳过起始标签行本身的标签头，但要输出内容
            if j > start:
                # 如果遇到新标签定义，停止
                m2 = end_label.match(line)
                if m2 and m2.group(1) != label:
                    log.append(f" -- 到达下一个标签 {m2.group(1)}，停止")
                    break
                m3 = start_proc.match(line)
                if m3:
                    log.append(f" --到达下一个函数开始/结尾 {m3.group(1)}，停止")
                    break

            if dword.match(line):
                dword_ct += 1
                mem_size += 4
            elif dword_ref.match(line):
                dword_ref_ct += 1
                mem_size += 4
            elif x := byte_re.match(line):
                mem_size += 1
                b = numH(x.group(1))
                if b != 0x90: #nop
                    byte_ct += 1
            elif x := db_re.match(line):
                n = numH(x.group(1))
                mem_size += n
                byte_ct += 1
            elif nop_re.match(line):
                mem_size += 1
                nop_ct += 1
            elif j != start:
                if line.startswith('ALIGN'):
                    empty_ct += 1
                elif not_empty_code(line):
                    other_ct.append(line)
            log.append(f"{line}")

        if case_num <= 0:
            log.append(" !- 警告, 未找到 switch 的数量")    
            print_full_log += 1

            if dword_ref_ct == 0:
                log.append(" !! 错误, 未找到有效的地址引用用于跳转")
                print_full_log += 1
            elif dword_ref_ct == 1:
                log.append(" !- 警告, 只有 1 个跳转引用了外部地址")
                print_full_log += 1
            else:
                checknot_allref += 1
        else: 
            log.append(f' -- CASE:\n{case_str}')
            if case_num != dword_ref_ct:
                if nop_ct>0 or dword_ct>0 or byte_ct>0 or len(other_ct)>0:
                    print_full_log += 1
                    log.append(f" !! 错误, 跳转表数量 {dword_ref_ct} != 检测到的 case:{case_num}")
                else:
                    checknot_allref += 1

        if (dword_ct) > 0:
            log.append(f" !- 警告,  多个 dword 定义 {mem_size}bytes")
            print_full_log += 1
        if byte_ct > 0:
            log.append(f" !- 警告, 多个 byte 定义 {mem_size}bytes")
            print_full_log += 1
        if len(other_ct) > 0:
            log.append(" !- 警告, 找到非数据定义语句")
            log.extend(other_ct)
            print_full_log += 1
        if nop_ct > 0:
            log.append(" -- 多个 nop 定义")

        if print_full_log > 0:
            print("\n".join(log))
        elif checknot_allref > 0:
            # "\n{sline}" 回显代码
            last_log.append(f'-- 标签 {label} 无法检测 switch数量, 跳转表全是地址引用')
        else:
            last_log.append(f'-- 标签没有明显问题 {label}')

    print('='*80)
    print("\n".join(last_log))


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


if __name__ == '__main__':
    mainfile = sys.argv[1] if len(sys.argv) > 1 else 'main.S'
    lines = read_all_files(mainfile)    
    parse_asm_file(lines)