; Disassembled by yanming.J
; SPDX-License-Identifier: MIT
; https://github.com/yanmingsohu/

; -- These functions are replaced with C code.

FUN_450af0 PROC
            sub ESP,60
            mov ECX,DWORD PTR [ESP+68]
            mov EAX,DWORD PTR [ESP+64]
            push EBX
            push EBP
            movsx EBX,WORD PTR [ECX+6]
            movsx EBP,WORD PTR [ECX]
            push ESI
            push EDI
            movsx ESI,WORD PTR [ECX+12]
            movsx EDI,WORD PTR [EAX]
            mov DWORD PTR [ESP+80],ESI
            mov DWORD PTR [ESP+20],EBX
            movsx ESI,WORD PTR [EAX+2]
            mov DWORD PTR [ESP+16],EBP
            imul EBP,EDI
            imul EBX,ESI
            movsx EDX,WORD PTR [EAX+4]
            add EBP,EBX
            mov EBX,DWORD PTR [ESP+80]
            imul EBX,EDX
            add EBP,EBX
            movsx EBX,WORD PTR [ECX+14]
            sar EBP,12
            mov WORD PTR [ESP+44],BP
            mov DWORD PTR [ESP+84],EBX
            movsx EBX,WORD PTR [ECX+8]
            movsx EBP,WORD PTR [ECX+2]
            mov DWORD PTR [ESP+28],EBX
            mov DWORD PTR [ESP+24],EBP
            imul EBP,EDI
            imul EBX,ESI
            add EBP,EBX
            mov EBX,DWORD PTR [ESP+84]
            imul EBX,EDX
            add EBP,EBX
            movsx EBX,WORD PTR [ECX+16]
            sar EBP,12
            mov WORD PTR [ESP+46],BP
            mov DWORD PTR [ESP+40],EBX
            movsx EBP,WORD PTR [ECX+10]
            imul EBX,EDX
            movsx ECX,WORD PTR [ECX+4]
            mov DWORD PTR [ESP+36],EBP
            mov DWORD PTR [ESP+32],ECX
            imul ECX,EDI
            imul EBP,ESI
            movsx ESI,WORD PTR [EAX+8]
            add ECX,EBP
            add ECX,EBX
            mov EBX,ESI
            sar ECX,12
            imul EBX,DWORD PTR [ESP+20]
            mov WORD PTR [ESP+48],CX
            movsx ECX,WORD PTR [EAX+6]
            mov EDI,ECX
            imul EDI,DWORD PTR [ESP+16]
            movsx EDX,WORD PTR [EAX+10]
            add EDI,EBX
            mov EBX,EDX
            imul EBX,DWORD PTR [ESP+80]
            add EDI,EBX
            mov EBX,ECX
            imul EBX,DWORD PTR [ESP+24]
            imul ECX,DWORD PTR [ESP+32]
            sar EDI,12
            mov WORD PTR [ESP+50],DI
            mov EDI,ESI
            imul EDI,DWORD PTR [ESP+28]
            imul ESI,DWORD PTR [ESP+36]
            add EBX,EDI
            mov EDI,DWORD PTR [ESP+84]
            mov EBP,EDX
            add ECX,ESI
            mov ESI,DWORD PTR [ESP+40]
            imul EBP,EDI
            imul EDX,ESI
            add EBX,EBP
            add ECX,EDX
            sar EBX,12
            mov WORD PTR [ESP+52],BX
            sar ECX,12
            movsx EDX,WORD PTR [EAX+14]
            mov WORD PTR [ESP+54],CX
            mov EBP,EDX
            movsx ECX,WORD PTR [EAX+16]
            imul EBP,DWORD PTR [ESP+20]
            movsx EAX,WORD PTR [EAX+12]
            mov EBX,EAX
            imul EBX,DWORD PTR [ESP+16]
            add EBX,EBP
            mov EBP,ECX
            imul EBP,DWORD PTR [ESP+80]
            add EBX,EBP
            mov EBP,EDX
            imul EBP,DWORD PTR [ESP+28]
            imul EDX,DWORD PTR [ESP+36]
            sar EBX,12
            mov WORD PTR [ESP+56],BX
            mov EBX,EAX
            imul EBX,DWORD PTR [ESP+24]
            imul EAX,DWORD PTR [ESP+32]
            add EBX,EBP
            mov EBP,ECX
            imul ECX,ESI
            imul EBP,EDI
            mov ESI,DWORD PTR [ESP+44]
            add EAX,EDX
            add EAX,ECX
            mov ECX,DWORD PTR [ESP+88]
            mov EDX,ECX
            add EBX,EBP
            sar EBX,12
            mov DWORD PTR [EDX],ESI
            mov ESI,DWORD PTR [ESP+48]
            mov WORD PTR [ESP+58],BX
            pop EDI
            mov DWORD PTR [EDX+4],ESI
            mov ESI,DWORD PTR [ESP+48]
            sar EAX,12
            mov DWORD PTR [EDX+8],ESI
            mov ESI,DWORD PTR [ESP+52]
            mov DWORD PTR [EDX+12],ESI
            pop ESI
            pop EBP
            pop EBX
            mov WORD PTR [EDX+16],AX
            mov EAX,ECX
            add ESP,60
            ret 
FUN_450af0 ENDP


FUN_4508e0 PROC
        jmp _mat_3x3_vec_mul
        int 3
            mov EAX,DWORD PTR [ESP+8]
            mov ECX,DWORD PTR [ESP+4]
            push EBX
            push EBP
            mov EDX,DWORD PTR [EAX]
            push ESI
            mov ESI,DWORD PTR [EAX+4]
            push EDI
            mov EDI,DWORD PTR [EAX+8]
            movsx EBX,WORD PTR [ECX+4]
            movsx EAX,WORD PTR [ECX+2]
            imul EBX,EDI
            imul EAX,ESI
            add EBX,EAX
            movsx EAX,WORD PTR [ECX]
            imul EAX,EDX
            add EBX,EAX
            mov EAX,DWORD PTR [ESP+28]
            sar EBX,12
            mov DWORD PTR [EAX],EBX
            movsx EBX,WORD PTR [ECX+10]
            movsx EBP,WORD PTR [ECX+8]
            imul EBX,EDI
            imul EBP,ESI
            add EBX,EBP
            movsx EBP,WORD PTR [ECX+6]
            imul EBP,EDX
            add EBX,EBP
            sar EBX,12
            mov DWORD PTR [EAX+4],EBX
            movsx EBX,WORD PTR [ECX+16]
            imul EBX,EDI
            movsx EDI,WORD PTR [ECX+14]
            movsx ECX,WORD PTR [ECX+12]
            imul EDI,ESI
            imul ECX,EDX
            add EBX,EDI
            pop EDI
            add EBX,ECX
            pop ESI
            sar EBX,12
            mov DWORD PTR [EAX+8],EBX
            pop EBP
            pop EBX
            ret 
FUN_4508e0 ENDP