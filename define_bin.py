import sys

def label_to_db(label, hexstr):
    # 从标签提取基础地址, 比如 $L_44b258 -> 0x44b258
    addr_hex = label.replace('$L_', '').replace('L_', '')
    base_addr = int(addr_hex, 16)
    
    # 每两个字符一个字节
    bytes_list = [hexstr[i:i+2] for i in range(0, len(hexstr), 2)]
    
    # 每16个字节一行
    chunks = [bytes_list[i:i+8] for i in range(0, len(bytes_list), 8)]
    
    indent = ' ' * len(label)
    
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

if __name__ == '__main__':
    if len(sys.argv) != 3:
        print("用法: python3 script.py <Label> <hexstring>")
        sys.exit(1)
    
    label = sys.argv[1]
    hexstr = sys.argv[2].upper()
    
    if len(hexstr) % 2 != 0:
        print("错误: 十六进制字符串长度必须是偶数")
        sys.exit(1)
    
    label_to_db(label, hexstr)