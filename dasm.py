#!/usr/bin/env python3
"""
dasm.py - PE文件反汇编工具 (基于 angr/capstone)
用法: python dasm.py <exe文件> <起始偏移> <结束偏移>

偏移格式支持:
  十进制: 4096
  十六进制: 0x1000

示例:
  python dasm.py target.exe 0x1000 0x1100
  python dasm.py target.exe 4096 4352
"""

import sys
import os
import struct
import argparse

def parse_offset(s: str) -> int:
    """解析十进制或十六进制偏移量"""
    s = s.strip()
    if s.lower().startswith("0x"):
        return int(s, 16)
    return int(s)


def read_pe_header(data: bytes):
    """
    解析 PE 头，返回 (image_base, sections) 元组。
    sections: list of dict {name, vaddr, vsize, raw_offset, raw_size}
    """
    # DOS header
    if data[:2] != b'MZ':
        raise ValueError("不是有效的 MZ/PE 文件")
    e_lfanew = struct.unpack_from('<I', data, 0x3C)[0]

    # PE signature
    if data[e_lfanew:e_lfanew+4] != b'PE\x00\x00':
        raise ValueError("找不到 PE 签名")

    coff_offset = e_lfanew + 4
    machine      = struct.unpack_from('<H', data, coff_offset)[0]
    num_sections = struct.unpack_from('<H', data, coff_offset + 2)[0]
    opt_hdr_size = struct.unpack_from('<H', data, coff_offset + 16)[0]

    opt_offset = coff_offset + 20
    magic      = struct.unpack_from('<H', data, opt_offset)[0]

    if magic == 0x10B:          # PE32
        bits = 32
        image_base = struct.unpack_from('<I', data, opt_offset + 28)[0]
    elif magic == 0x20B:        # PE32+
        bits = 64
        image_base = struct.unpack_from('<Q', data, opt_offset + 24)[0]
    else:
        raise ValueError(f"未知的 Optional Header magic: {magic:#x}")

    # Section table
    sec_table_offset = opt_offset + opt_hdr_size
    sections = []
    for i in range(num_sections):
        sec_off = sec_table_offset + i * 40
        name       = data[sec_off:sec_off+8].rstrip(b'\x00').decode('latin-1')
        vsize      = struct.unpack_from('<I', data, sec_off + 8)[0]
        vaddr      = struct.unpack_from('<I', data, sec_off + 12)[0]
        raw_size   = struct.unpack_from('<I', data, sec_off + 16)[0]
        raw_offset = struct.unpack_from('<I', data, sec_off + 20)[0]
        sections.append({
            'name':       name,
            'vaddr':      vaddr,
            'vsize':      vsize,
            'raw_offset': raw_offset,
            'raw_size':   raw_size,
        })

    return image_base, bits, sections


def file_offset_to_va(file_offset: int, image_base: int, sections: list) -> int:
    """将文件原始偏移转换为虚拟地址 (VA)"""
    for sec in sections:
        raw_start = sec['raw_offset']
        raw_end   = raw_start + sec['raw_size']
        if raw_start <= file_offset < raw_end:
            rva = sec['vaddr'] + (file_offset - raw_start)
            return image_base + rva
    raise ValueError(
        f"文件偏移 {file_offset:#x} 不在任何节区范围内\n"
        f"可用节区:\n" +
        "\n".join(f"  {s['name']:8s}  raw=[{s['raw_offset']:#010x}, {s['raw_offset']+s['raw_size']:#010x})"
                  for s in sections)
    )


def disassemble_with_angr(pe_path: str, start_offset: int, end_offset: int):
    """主反汇编逻辑"""
    try:
        import angr
        import capstone
    except ImportError as e:
        print(f"[错误] 缺少依赖库: {e}")
        print("请安装: pip install angr capstone")
        sys.exit(1)

    if not os.path.isfile(pe_path):
        print(f"[错误] 文件不存在: {pe_path}")
        sys.exit(1)

    if start_offset >= end_offset:
        print(f"[错误] 起始偏移 ({start_offset:#x}) 必须小于结束偏移 ({end_offset:#x})")
        sys.exit(1)

    print(f"[*] 加载文件: {pe_path}")
    print(f"[*] 文件偏移范围: {start_offset:#010x} - {end_offset:#010x}  ({end_offset - start_offset} 字节)")

    # 读取原始文件
    with open(pe_path, 'rb') as f:
        raw_data = f.read()

    # 解析 PE 头
    try:
        image_base, bits, sections = read_pe_header(raw_data)
    except ValueError as e:
        print(f"[错误] PE 解析失败: {e}")
        sys.exit(1)

    print(f"[*] ImageBase : {image_base:#x}")
    print(f"[*] 架构位数  : {bits}-bit")
    print(f"[*] 节区数量  : {len(sections)}")
    for sec in sections:
        print(f"    {sec['name']:10s}  VA={image_base + sec['vaddr']:#010x}"
              f"  raw=[{sec['raw_offset']:#010x}, {sec['raw_offset']+sec['raw_size']:#010x})")

    # 将文件偏移 → 虚拟地址
    try:
        #start_va = file_offset_to_va(start_offset, image_base, sections)
        start_va = start_offset
        # end_offset 只用来确定字节数，不需要单独转换
    except ValueError as e:
        print(f"[错误] 偏移转换失败: {e}")
        sys.exit(1)

    code_bytes = raw_data[start_offset:end_offset]
    if not code_bytes:
        print("[错误] 指定范围内没有数据")
        sys.exit(1)

    print(f"[*] 起始 VA   : {start_va:#x}")
    print(f"[*] 字节数    : {len(code_bytes)}")
    print()

    # 用 angr 加载 PE（自动处理重定位、节区映射）
    print("[*] 使用 angr 加载 PE ...")
    try:
        proj = angr.Project(
            pe_path,
            auto_load_libs=False,
            load_options={'main_opts': {'base_addr': image_base}}
        )
    except Exception as e:
        print(f"[警告] angr.Project 加载失败，回退到纯 capstone 模式: {e}")
        proj = None

    # 选择 capstone 参数
    if bits == 64:
        cs_arch = capstone.CS_ARCH_X86
        cs_mode = capstone.CS_MODE_64
        arch_name = "x86-64"
    else:
        cs_arch = capstone.CS_ARCH_X86
        cs_mode = capstone.CS_MODE_32
        arch_name = "x86-32"

    # 如果 angr 成功加载，用 proj.factory.block 辅助确定基本块边界；
    # 否则直接用 capstone 线性扫描。
    md = capstone.Cs(cs_arch, cs_mode)
    md.detail = True
    md.skipdata = True      # 遇到无法解码的字节跳过，而非中断

    print(f"[*] 架构: {arch_name}")
    print(f"[*] 反汇编结果:")
    print("-" * 72)
    print(f"{'地址':>12}  {'字节':22}  {'指令'}")
    print("-" * 72)

    insn_count = 0

    if proj is not None:
        # angr 模式：逐基本块反汇编，保持与 angr IR 的一致性
        addr = start_va
        end_va = start_va + len(code_bytes)
        visited = set()

        while addr < end_va and addr not in visited:
            visited.add(addr)
            try:
                block = proj.factory.block(addr)
                for insn in block.capstone.insns:
                    if insn.address >= end_va:
                        break
                    hex_bytes = ' '.join(f'{b:02x}' for b in insn.bytes)
                    print(f"  {insn.address:#010x}  {hex_bytes:22s}  {insn.mnemonic} {insn.op_str}")
                    insn_count += 1

                # 下一块：跳到本块结尾
                next_addr = block.addr + block.size
                if next_addr == addr:   # 防止死循环
                    break
                addr = next_addr
            except Exception:
                # 某些地址 angr 无法建块，退回 capstone 单步
                chunk = raw_data[
                    start_offset + (addr - start_va):
                    start_offset + (addr - start_va) + 16
                ]
                for insn in md.disasm(chunk, addr):
                    if insn.address >= end_va:
                        break
                    hex_bytes = ' '.join(f'{b:02x}' for b in insn.bytes)
                    print(f"  {insn.address:#010x}  {hex_bytes:22s}  {insn.mnemonic} {insn.op_str}")
                    insn_count += 1
                    addr = insn.address + insn.size
                    break
                else:
                    addr += 1   # 完全跳过
    else:
        # 纯 capstone 线性扫描模式
        for insn in md.disasm(code_bytes, start_va):
            hex_bytes = ' '.join(f'{b:02x}' for b in insn.bytes)
            print(f"  {insn.address:#010x}  {hex_bytes:22s}  {insn.mnemonic} {insn.op_str}")
            insn_count += 1

    print("-" * 72)
    print(f"[*] 共反汇编 {insn_count} 条指令")


def main():
    parser = argparse.ArgumentParser(
        description="PE 文件区段反汇编工具 (angr + capstone)",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog=__doc__
    )
    parser.add_argument("exe",        help="PE 可执行文件路径")
    parser.add_argument("startpos",   help="起始文件偏移 (十进制或 0x 十六进制)")
    parser.add_argument("endpos",     help="结束文件偏移 (十进制或 0x 十六进制，不含)")

    args = parser.parse_args()

    try:
        start = parse_offset(args.startpos)
        end   = parse_offset(args.endpos)
    except ValueError as e:
        print(f"[错误] 偏移量格式无效: {e}")
        sys.exit(1)

    disassemble_with_angr(args.exe, start, end)


if __name__ == "__main__":
    main()