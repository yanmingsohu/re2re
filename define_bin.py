import sys



def db_writer():
    # 每16个字节一行
    chunks = [bytes_list[i:i+8] for i in range(0, len(bytes_list), 8)]
    total = 0
    for i, chunk in enumerate(chunks):
        formatted = ','.join(f'0{b}h' for b in chunk)
        addr = base_addr + i * 8
        total += len(chunk)
        comment = f'; {hex(addr)} ({total} bytes)'
        if i == 0:
            print(f'$L_{addr_hex} DB {formatted} {comment}')
        else:
            print(f'{indent} DB {formatted} {comment}')


def ref_writer():
    chunks = [bytes_list[i:i+4] for i in range(0, len(bytes_list), 4)]
    total = 0
    for i, chunk in enumerate(chunks):
        formatted = int(chunk[0], 16) + (int(chunk[1], 16)<<8) \
                  + (int(chunk[2], 16)<<16) + (int(chunk[3], 16)<<24)
        formatted = f'$L_{hex(formatted)}'.replace('0x', '')
        addr = base_addr + i * 4
        total += len(chunk)
        comment = f'; case{i} | {",".join(chunk)} ({total} bytes)'

        if i == 0:
            print(f'$L_{addr_hex} DWORD {formatted} {comment}')
        else:
            print(f'{indent} DWORD {formatted} {comment}')


if __name__ == '__main__':
    if len(sys.argv) < 3:
        print("用法: python3 script.py <Label> <hexstring>")
        sys.exit(1)
    
    label = sys.argv[1]
    hexstr = sys.argv[2].upper()
    
    if len(hexstr) % 2 != 0:
        print("错误: 十六进制字符串长度必须是偶数")
        sys.exit(1)
    
    # 从标签提取基础地址, 比如 $L_44b258 -> 0x44b258
    addr_hex = label.replace('$L_', '').replace('L_', '')
    base_addr = int(addr_hex, 16)
    # 每两个字符一个字节
    bytes_list = [hexstr[i:i+2] for i in range(0, len(hexstr), 2)]
    # 每16个字节一行
    chunks = [bytes_list[i:i+8] for i in range(0, len(bytes_list), 8)]
    indent = ' ' * len(label)
    
    writer = db_writer
    for a in sys.argv:
        if a == '-r':
            writer = ref_writer
            break
    writer()