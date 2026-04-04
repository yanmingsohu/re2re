#!/usr/bin/env python3
"""
从 .s 汇编文件中找到 $L_xxx BYTE 标签定义，
计算字节数量，从 .exe 文件中读取对应地址的字节，
并以指定格式打印输出。

用法:
    python extract_data_labels.py <file.s> <file.exe> [--imagebase 0x400000]

标签格式示例（.s 文件中）:
    $L_00401234 BYTE 0x41, 0x42, 0x00
                BYTE 0x43
"""

import re
import sys
import struct
import argparse
import os
import pefile  # pip install pefile


# ── 正则 ──────────────────────────────────────────────────────────────────────

# 匹配 $L_<hex> BYTE ...（标签行，也可能是 $L_<hex>: BYTE ...）
LABEL_BYTE_RE = re.compile(
    r"^\s*\$L_([0-9A-Fa-f]+):?\s+(?:BYTE|DB)\s+(.+)$", re.IGNORECASE
)

# 匹配续行：只有 BYTE（没有标签前缀）
CONT_BYTE_RE = re.compile(r"^\s+(?:BYTE|DB)\s+(.+)$", re.IGNORECASE)

# 匹配任何新标签（以 $ 或 字母/下划线 开头，后跟 :）
ANY_LABEL_RE = re.compile(r"^\s*[$A-Za-z_@][A-Za-z0-9_$@.]*:?\s", re.IGNORECASE)

# 匹配函数结束关键字（ENDP / END / RET 等）
FUNC_END_RE = re.compile(r"^\s+(ENDP|END\b|RETN?\b|IRET\b)", re.IGNORECASE)

# 从 BYTE 操作数中提取每一个数值
BYTE_VAL_RE = re.compile(r"(0[Xx][0-9A-Fa-f]+|\d+|'.')")


# ── 解析字节值 ────────────────────────────────────────────────────────────────

def parse_byte_values(operand_str: str) -> list[int]:
    """从 BYTE 操作数字符串中解析所有字节值。"""
    values = []
    # 去掉注释（; 开始的部分）
    operand_str = operand_str.split(";")[0]
    values = operand_str.split(',')
    
    result = []
    for s in values:
      try:
        s = s.strip()
        if s.lower().endswith('h'):
            result.append(int(s[:-1], 16)) # 处理十六进制
        else:
            result.append(int(s))          # 处理普通十进制
      except ValueError:
        result.append(s)
            
    return result


# ── 解析 .s 文件 ──────────────────────────────────────────────────────────────

def parse_s_file(s_path: str) -> list[dict]:
    """
    返回列表，每项:
        { 'label': '$L_<hex>', 'va': int, 'count': int }
    """
    results = []

    with open(s_path, "r", encoding="utf-8", errors="replace") as f:
        lines = f.readlines()

    i = 0
    while i < len(lines):
        line = lines[i]
        m = LABEL_BYTE_RE.match(line)
        if m:
            hex_addr = m.group(1)
            operand  = m.group(2)
            label    = f"$L_{hex_addr}"
            va       = int(hex_addr, 16)
            byte_vals = parse_byte_values(operand)

            # 收集后续续行
            j = i + 1
            while j < len(lines):
                next_line = lines[j]

                # 遇到新标签 → 停止
                if LABEL_BYTE_RE.match(next_line):
                    break
                if ANY_LABEL_RE.match(next_line) and not CONT_BYTE_RE.match(next_line):
                    break
                # 遇到函数结束 → 停止
                if FUNC_END_RE.match(next_line):
                    break
                # 续行 BYTE
                mc = CONT_BYTE_RE.match(next_line)
                if mc:
                    byte_vals.extend(parse_byte_values(mc.group(1)))
                    j += 1
                else:
                    # 非 BYTE 续行（空行、其他指令）→ 停止
                    break

            results.append({
                "label": label,
                "va": va,
                "byte_vals": byte_vals,
                "count": len(byte_vals),
            })
            i = j  # 跳过已处理的行
        else:
            i += 1

    return results


# ── 从 .exe 读取字节 ──────────────────────────────────────────────────────────

def read_bytes_from_exe(exe_path: str, va: int, count: int, pe: pefile.PE) -> bytes | None:
    """将虚拟地址转换为文件偏移，读取 count 字节。"""
    try:
        offset = pe.get_offset_from_rva(va - pe.OPTIONAL_HEADER.ImageBase)
        with open(exe_path, "rb") as f:
            f.seek(offset)
            data = f.read(count)
        return data if len(data) == count else None
    except Exception as e:
        return None


# ── 格式化输出 ────────────────────────────────────────────────────────────────

def format_output(label: str, va: int, data: bytes, asm: bytes) -> str:
    """
    格式：
        $L_xxxxxxxx DB 0xxh, 0xxh, ...  ; 0x<addr>(<总字节数>)
    每行最多 8 个字节，续行用 16 个空格对齐。
    """
    if list(data) == asm:
      return f"- {label} asm 定义与 pe 相同, 跳过"
    
    total = len(data)
    ed = va + total
    chunks = [data[i:i+8] for i in range(0, total, 8)]
    lines = []

    prefix = f"{label}"
    indent_db   = ' '*len(prefix)  # 续行缩进（16 空格）
    comment_end = f"  ; 0x{ed:X}({total})"

    for idx, chunk in enumerate(chunks):
        hex_vals = ", ".join(f"0{b:02X}h" for b in chunk)
        if idx == 0:
            # 对齐：标签名 + " DB " 共 ~20 字符，不足补空格
            line = f"{prefix} DB {hex_vals}"
        else:
            line = f"{indent_db} DB {hex_vals}"

        # 注释只加在最后一行
        if idx == len(chunks) - 1:
            line += comment_end

        lines.append(line)
    return "\n".join(lines)


# ── 主程序 ────────────────────────────────────────────────────────────────────

def main():
    parser = argparse.ArgumentParser(
        description="从 .s 文件提取 $L_xxx BYTE 标签，从 .exe 读取对应字节并格式化输出"
    )
    parser.add_argument("s_file",   help=".s 汇编文件路径")
    parser.add_argument("exe_file", help=".exe 可执行文件路径")
    parser.add_argument(
        "--imagebase", default=None,
        help="覆盖 ImageBase（十六进制，如 0x400000）；默认从 PE 头读取"
    )
    args = parser.parse_args()

    if not os.path.isfile(args.s_file):
        print(f"错误: 找不到文件 {args.s_file}", file=sys.stderr)
        sys.exit(1)
    if not os.path.isfile(args.exe_file):
        print(f"错误: 找不到文件 {args.exe_file}", file=sys.stderr)
        sys.exit(1)

    # 加载 PE
    try:
        pe = pefile.PE(args.exe_file, fast_load=True)
    except Exception as e:
        print(f"错误: 无法解析 PE 文件: {e}", file=sys.stderr)
        sys.exit(1)

    if args.imagebase:
        pe.OPTIONAL_HEADER.ImageBase = int(args.imagebase, 16)

    # 解析 .s
    labels = parse_s_file(args.s_file)
    if not labels:
        print("未找到任何 $L_xxx BYTE 标签。", file=sys.stderr)
        sys.exit(0)

    print(f"; 共找到 {len(labels)} 个标签\n")

    for entry in labels:
        label = entry["label"]
        va    = entry["va"]
        count = entry["count"]

        if count == 0:
            print(f"; {label}: 0 字节，跳过")
            continue

        data = read_bytes_from_exe(args.exe_file, va, count, pe)
        if data is None:
            print(f"; {label}: 无法从 0x{va:X} 读取 {count} 字节（地址超出范围？）")
            continue

        print(format_output(label, va, data, entry['byte_vals']))
        print()  # 标签之间空行


if __name__ == "__main__":
    main()