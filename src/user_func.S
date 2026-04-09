; Disassembled by yanming.J
; SPDX-License-Identifier: MIT
; https://github.com/yanmingsohu/


; 强制设置与分辨率相关的变量
FUN_FIX_SCREEN PROC
      push EDX
      push ECX
      mov EDX, dword ptr [$win_width]
      mov ECX, dword ptr [$win_height]
      mov dword ptr [$L_8c7eac], EDX
      mov dword ptr [$L_8c7eb0], ECX
      mov dword ptr [$L_8c832c], EDX
      mov dword ptr [$L_8c8330], ECX
      mov dword ptr [$L_8c7ed4], 1
      mov dword ptr [$L_8c7ed8], 1
      pop ECX
      pop EDX
      ret
FUN_FIX_SCREEN ENDP