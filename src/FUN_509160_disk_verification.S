; Disassembled by yanming.J
; SPDX-License-Identifier: MIT
; https://github.com/yanmingsohu/


; 扫描所有逻辑驱动器并读取某个特定文件（可能是磁盘 ID 或序列号相关文件）
ALIGN 16
FUN_509160 PROC
            push -1
            push OFFSET $L_5161d6
            mov EAX,DWORD PTR FS:[0]
            push EAX
            mov DWORD PTR FS:[0],ESP
            sub ESP,284
            push EBX
            push EBP
            push ESI
            push EDI
            lea ECX,DWORD PTR [ESP+24]
            call FUN_50ba50

            xor EBP,EBP
            mov DWORD PTR [ESP+308],EBP
            call DWORD PTR __imp__GetLogicalDrives@0

            mov DWORD PTR [ESP+40],EAX
            mov DWORD PTR [ESP+16],EBP
$L_50919f:

            mov EAX,1
            mov ECX,EBP
            shl EAX,CL
            mov ECX,DWORD PTR [ESP+40]
            test ECX,EAX
            je $L_5092a9

            lea EDX,DWORD PTR [EBP+65] ; EBP+65 = 'A'+n，即驱动器字母
            lea EAX,DWORD PTR [ESP+44] ; 格式字符串，大概是 "%c:\\<某固定文件名>"
            push EDX
            push OFFSET $L_540ac8      ; '%c:\disc.id'
            push EAX
            call FUN_50c6c0 ; sprintf 类函数，构造路径

            mov EBX,DWORD PTR __imp__SetErrorMode@4
            add ESP,12
            push 32769
            call EBX

            push 0
            push 0
            push 3
            push 0
            push 1
            lea ECX,DWORD PTR [ESP+64]
            push 2147483648
            push ECX
            mov EDI,EAX
            call DWORD PTR __imp__CreateFileA@28

            push EDI
            mov ESI,EAX
            call EBX

            cmp ESI,-1
            je $L_5092a9

            push 0
            push ESI
            call DWORD PTR __imp__GetFileSize@8

            mov EBX,EAX
            test EBX,EBX
            je $L_5092a2

            lea EDI,DWORD PTR [EBX+1]
            push EDI
            call FUN_50d7e5

            mov ECX,EDI
            mov EBP,EAX
            mov EDX,ECX
            xor EAX,EAX
            mov EDI,EBP
            add ESP,4
            shr ECX,2

            rep stosd DWORD PTR ES:[EDI]

            mov ECX,EDX
            push 0
            and ECX,3

            rep stosb BYTE PTR ES:[EDI]

            lea EAX,DWORD PTR [ESP+24]
            mov DWORD PTR [ESP+24],0
            push EAX
            push EBX
            push EBP
            push ESI
            call DWORD PTR __imp__ReadFile@20

            test EAX,EAX
            je $L_509295

            cmp EBX,DWORD PTR [ESP+20]
            jne $L_509295

            push EBP
            lea ECX,DWORD PTR [ESP+36]
            call FUN_50ba70

            lea ECX,DWORD PTR [ESP+32]
            mov BYTE PTR [ESP+308],1
            call FUN_50c0a0

            push OFFSET $L_540aac ; 某个特征字符串（可能是 "disk.id" 的标记格式）
                                  ; 'bio2.658b45ea117473d4.disc'
            lea ECX,DWORD PTR [ESP+36]
            call FUN_50c480       ; 字符串搜索/比较函数

            test AL,AL
            jne $L_5092b9         ; 匹配成功则跳转

            lea ECX,DWORD PTR [ESP+32]
            mov BYTE PTR [ESP+308],AL
            call FUN_50bab0
$L_509295:

            push EBP
            call FUN_50d77c

            mov EBP,DWORD PTR [ESP+20]
            add ESP,4
$L_5092a2:

            push ESI
            call DWORD PTR __imp__CloseHandle@4
$L_5092a9:

            inc EBP
            cmp EBP,32
            mov DWORD PTR [ESP+16],EBP
            jb $L_50919f
            jmp $L_5092f2
            
$L_5092b9: ; 匹配成功
            mov ECX,DWORD PTR [ESP+16]
            lea EDX,DWORD PTR [ESP+44]
            add ECX,65
            push ECX
            push OFFSET $L_540aa4
            push EDX
            call FUN_50c6c0

            add ESP,12
            lea EAX,DWORD PTR [ESP+44]
            lea ECX,DWORD PTR [ESP+24]
            push EAX
            call FUN_50c2e0 ; 构造类似 "%c:\\" 的路径（驱动器字母）

            lea ECX,DWORD PTR [ESP+32]
            mov BYTE PTR [ESP+308],0
            call FUN_50bab0
$L_5092f2:

            push OFFSET $L_689ee4
            lea ECX,DWORD PTR [ESP+28]
            call FUN_50c460

            test AL,AL
            je $L_50933a

            lea ECX,DWORD PTR [ESP+24]
            push ECX
            mov ECX,OFFSET $L_689ee4
            call FUN_50c2c0

            mov ECX,OFFSET $L_689ee4
            call FUN_50bbd0

            test EAX,EAX
            lea ECX,DWORD PTR [ESP+24]
            mov DWORD PTR [ESP+308],4294967295
            setg BL
            call FUN_50bab0

            mov AL,BL
            jmp $L_509350
$L_50933a:

            lea ECX,DWORD PTR [ESP+24]
            mov DWORD PTR [ESP+308],4294967295
            call FUN_50bab0

            xor AL,AL
$L_509350:
            mov ECX,DWORD PTR [ESP+300]
            pop EDI
            pop ESI
            pop EBP
            pop EBX
            mov DWORD PTR FS:[0],ECX
            add ESP,296
            ret 
FUN_509160 ENDP