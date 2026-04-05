# BioHazard PC 1997 Reverse engineering

Objective: To compile the assembly code so that it can run.

![screen](screen/1.png)
![screen](screen/2.png)


Current status: |>>------------------| 10%
* Able to enter the first scene
* The moving animation is strange
* open menu
* cannot shot


# Depends 

* vs2022 or h
* ddisasm - https://github.com/GrammaTech/ddisasm


# Compiling

Open the `cmd` command line to make the above tool `link/ddisasm` executable.

Run `set > env.txt` in the project directory.

`make` compiles and generates `bio2game/bio2re.exe`.

Other targets in `make` are used to disassemble and generate `main.S`; this is the initial workflow.


# Tool

安装依赖
`pip install angr pefile`

检查数据定义标签与源程序二进制一致性
`python extract_data_labels.py main.S bio2.exe > data_label.txt`
`python extract_data_labels.py src/data.S bio2.exe > data2_label.txt`

跳转表 switch 结构检查报告
`python parse_jumptable.py main.S > jumptable.txt`

二级制转换为 asm 中的常量定义
`python define_bin.py $L_403df8 01020304`

二级制转换为 asm 中的变量引用
`python define_bin.py $L_403df8 01020304 -r`

反汇编程序中的片段
`python dasm.py bio2.exe 0x466350 0x4663d6`