import re
import sys

def parse_asm_file(filename):
    with open(filename, 'r', encoding='utf-8', errors='replace') as f:
        lines = f.readlines()

    # 找所有 jmp DWORD PTR [REG*4+$L_xxxxxx] 指令
    jmp_pattern = re.compile(r'jmp\s+DWORD\s+PTR\s+\[\w+\*4\+(\$L_[0-9a-fA-F]+)\]')
    
    # 找标签定义: $L_xxxxxx:: 或 $L_xxxxxx DWORD ...
    label_pattern = re.compile(r'(\$L_[0-9a-fA-F]+)')

    # 建立标签 -> 行号 的索引
    label_lines = {}
    for i, line in enumerate(lines):
        m = re.match(r'\s*(\$L_[0-9a-fA-F]+)(?:::|[\s])', line)
        if m:
            label = m.group(1)
            if label not in label_lines:
                label_lines[label] = i

    # 找所有跳转表引用
    jmp_targets = []
    for i, line in enumerate(lines):
        m = jmp_pattern.search(line)
        if m:
            label = m.group(1)
            jmp_targets.append((i + 1, label))

    if not jmp_targets:
        print("没有找到跳转表指令")
        return

    id = 0
    for lineno, label in jmp_targets:
        id += 1
        print(f"\n{'='*60}")
        print(f"第 {lineno} 行找到跳转表引用: jmp [REG*4+{label}] JID:{id}")

        if label not in label_lines:
            print(f"  !! 找不到标签 {label} 的定义")
            continue

        start = label_lines[label]
        print(f"标签 {label} 定义于第 {start + 1} 行，JID:{id}, 内容：")
        print(f"{'-'*60}")

        # 从标签行开始，读到下一个 $L_ 标签为止
        for j in range(start, len(lines)):
            line = lines[j]
            # 跳过起始标签行本身的标签头，但要输出内容
            if j > start:
                # 如果遇到新标签定义，停止
                m2 = re.match(r'\s*(\$L_[0-9a-fA-F]+)(?:::|[\s])', line)
                if m2 and m2.group(1) != label:
                    print(f"  (到达下一个标签 {m2.group(1)}，停止) JID:{id}")
                    break
            print(f"  {j+1:5d}: {line}", end='')

if __name__ == '__main__':
    filename = sys.argv[1] if len(sys.argv) > 1 else 'bio2.fixed.S'
    parse_asm_file(filename)