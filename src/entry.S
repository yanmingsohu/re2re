; Disassembled by yanming.J
; SPDX-License-Identifier: MIT
; https://github.com/yanmingsohu/


ALIGN 4
__EntryPoint PROC
            push EBP
            mov EBP,ESP
            push -1
            push OFFSET $L_517758
            push OFFSET $L_50f140
            mov EAX,DWORD PTR FS:[0]
            push EAX
            mov DWORD PTR FS:[0],ESP
            sub ESP,88
            push EBX
            push ESI
            push EDI
            mov DWORD PTR [EBP-24],ESP
            call DWORD PTR __imp__GetVersion@0

            xor EDX,EDX
            mov DL,AH
            mov DWORD PTR [$L_689fbc],EDX
            mov ECX,EAX
            and ECX,255
            mov DWORD PTR [$L_689fb8],ECX
            shl ECX,8
            add ECX,EDX
            mov DWORD PTR [$L_689fb4],ECX
            shr EAX,16
            mov DWORD PTR [$L_689fb0],EAX
            xor ESI,ESI
            push ESI
            call FUN_510d14

            pop ECX
            test EAX,EAX
            jne $L_50d950

            push 28
            call FUN_50d9ff

            pop ECX
$L_50d950::

            mov DWORD PTR [EBP-4],ESI
            call FUN_5103aa

            call DWORD PTR __imp__GetCommandLineA@0

            mov DWORD PTR [$L_99edf4],EAX
            call FUN_512612

            mov DWORD PTR [$L_689f78],EAX
            call FUN_5123c5

            call FUN_51230c

            call FUN_50f86f

            mov DWORD PTR [EBP-48],ESI
            lea EAX,DWORD PTR [EBP-92]
            push EAX
            call DWORD PTR __imp__GetStartupInfoA@4

            call FUN_5122b4

            mov DWORD PTR [EBP-100],EAX
            test BYTE PTR [EBP-48],1
            je $L_50d99d

            movzx EAX,WORD PTR [EBP-44]
            jmp $L_50d9a0
$L_50d99d::

            push 10
            pop EAX
$L_50d9a0::

            push EAX
            push DWORD PTR [EBP-100]
            push ESI
            push ESI
            call DWORD PTR __imp__GetModuleHandleA@4

            ; 这里打开窗口
            push EAX
            call FUN_441e60

            mov DWORD PTR [EBP-96],EAX
            push EAX
            call FUN_50f89c
$L_50d9bb::

            mov EAX,DWORD PTR [EBP-20]
            mov ECX,DWORD PTR [EAX]
            mov ECX,DWORD PTR [ECX]
            mov DWORD PTR [EBP-104],ECX
            push EAX
            push ECX
            call FUN_512130

            pop ECX
            pop ECX
            ret 
__EntryPoint ENDP