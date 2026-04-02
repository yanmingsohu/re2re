import re
import sys

def parse_byte_line(line):
    """
    从类似 '          BYTE 044H' 的行中提取字节值（整数）。
    返回整数，如果无法解析则返回 None。
    """
    # 匹配模式：可选空格 + BYTE + 空格 + 十六进制数（可选H后缀）
    # 支持 044H、0x44、44h 等常见格式
    m = re.search(r'\bBYTE\s+([0-9A-Fa-f]+)H?\b', line)
    if m:
        hex_str = m.group(1)
        # 转换为整数
        return int(hex_str, 16)
    return None

def find_byte_sequence(file_path, target_bytes):
    """
    在汇编文件中搜索连续的字节序列。
    :param file_path: .asm 文件路径
    :param target_bytes: 目标字节列表，如 [0x44, 0x94, 0x04]
    :return: 匹配的行号列表（起始行号，1-based），未找到返回空列表
    """
    with open(file_path, 'r', encoding='utf-8', errors='ignore') as f:
        lines = f.readlines()

    # 将每一行转换为字节值（如果不是 BYTE 行则为 None）
    byte_values = []
    line_numbers = []  # 记录每个字节值对应的原始行号
    for idx, line in enumerate(lines, start=1):
        val = parse_byte_line(line)
        if val is not None:
            byte_values.append(val)
            line_numbers.append(idx)

    #print(len(byte_values), len(line_numbers))
    # 在 byte_values 中搜索目标序列
    target_len = len(target_bytes)
    matches = []
    for i in range(len(byte_values) - target_len + 1):
        if byte_values[i:i+target_len] == target_bytes:
            # 记录匹配的起始行号（原始文件中的行号）
            start_line = line_numbers[i]
            end_line = line_numbers[i+target_len-1]
            matches.append((start_line, end_line))

    return matches

def main():
    # 示例：要查找的字节序列（0x44, 0x94, 0x04）
    #target = [0x44, 0x94, 0x04]
    target = [0x91, 0xA2]

    if len(sys.argv) != 2:
        print("用法: python find_byte_seq.py <asm文件>")
        sys.exit(1)

    asm_file = sys.argv[1]
    matches = find_byte_sequence(asm_file, target)

    if matches:
        print(f"找到 {len(matches)} 处匹配：")
        for start, end in matches:
            print(f"  行 {start} - 行 {end}")
    else:
        print("未找到匹配的字节序列。")

if __name__ == "__main__":
    main()