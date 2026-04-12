; Disassembled by yanming.J
; SPDX-License-Identifier: MIT
; https://github.com/yanmingsohu/

; -- event.c
Extern _on_winmain_call : Proc
Extern _on_before_window_show : Proc

; -- common.c
Extern _debug : Proc
Extern _stack : Proc

; -- mathx.c
Extern _mat_3x3_mul : Proc
Extern _mat_3x3_vec_mul : Proc