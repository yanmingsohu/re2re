; Disassembled by yanming.J
; SPDX-License-Identifier: MIT
; https://github.com/yanmingsohu/

ExpC MACRO asm_label, c_label
    c_label DWORD asm_label
    public c_label
ENDM


; Exports for C
ExpC $L_99ce20      , _pt_99ce20     
ExpC $L_99ce34      , _pt_99ce34     
ExpC $L_99ce38      , _pt_99ce38     
ExpC $L_99ce3c      , _pt_99ce3c     
ExpC $L_517438      , _pt_scr_h_width
ExpC $L_51743c      , _pt_scr_h_height
ExpC $L_526210      , _pt_z_scale 
ExpC $L_8c83f4      , _pt_draw_object
ExpC $L_680528      , _pt_hInstance  
ExpC $L_68051c      , _pt_hWnd 
ExpC $win_width     , _pt_win_w
ExpC $win_height    , _pt_win_h
ExpC $L_4419c0      , _pt_win_proc_fn


; 这个方法 c 没法调用 不要导出
; ExpC _truncate_d, truncate_d