import re

def parse_export_txt(export_file):
    """解析 export.txt，返回字典 {函数名: 参数字节数}，函数名形如 '_AdjustWindowRect'"""
    pattern = re.compile(r'_(\w+)@(\d+)')  # 匹配 _FunctionName@Number
    export_map = {}
    with open(export_file, 'r', encoding='utf-8', errors='ignore') as f:
        for line in f:
            matches = pattern.findall(line)
            for name, size in matches:
                full_name = '_' + name
                export_map[full_name] = int(size)
    return export_map

def process_asm_file(asm_file, export_map, output_file):
    """处理 bio2.S，生成 fix.asm"""
    pattern = re.compile(r'EXTERN\s+__imp__(\w+):PROC')  # 匹配 EXTERN __imp_FunctionName:PROC
    output_lines = []
    extern = []
    rename = []
    with open(asm_file, 'r', encoding='utf-8', errors='ignore') as f:
        for line in f:
            match = pattern.search(line)
            if match:
                func = match.group(1)          # 例如 'ClientToScreen'
                key = '_' + func                # 键名 '_ClientToScreen'
                if key in export_map:
                    size = export_map[key]
                    extern.append(f'EXTERN __imp__{func}@{size}:PROC')
                    rename.append(f'__imp__{func} TEXTEQU <__imp__{func}@{size}>')
                    extern.append(f'EXTERN _{func}@{size}:PROC')
                    rename.append(f'_{func} TEXTEQU <_{func}@{size}>')
                else:
                    # 未找到对应项，输出注释提醒
                    extern.append(f'; WARNING: no entry found for {key}@Num')
                    extern.append(f'EXTERN __imp__{func}:PROC')
                    extern.append(f'EXTERN _{func}:PROC')
    
    # 去重（保留首次出现的顺序）
    """
    seen = set()
    unique_output = []
    for line in output_lines:
        if line not in seen:
            seen.add(line)
            unique_output.append(line)"""
    
    with open(output_file, 'w', encoding='utf-8') as f:
        f.write('\n'.join(extern))
        f.write('\n\n')
        f.write('\n'.join(rename))
        f.write('\n\n')
    print(f"Generated {output_file} with {len(extern)+len(rename)} lines.")

if __name__ == '__main__':
    export_map = parse_export_txt('export.txt')
    process_asm_file('bio2.S', export_map, 'fix.asm')