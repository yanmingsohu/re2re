; Disassembled by yanming.J
; SPDX-License-Identifier: MIT
; https://github.com/yanmingsohu/

ExpC MACRO asm_label, c_label
    _&c_label DWORD asm_label
    public _&c_label
ENDM


; Exports for C
ExpC $L_99ce20      , pt_99ce20     
ExpC $L_99ce34      , pt_99ce34     
ExpC $L_99ce38      , pt_99ce38     
ExpC $L_99ce3c      , pt_99ce3c     
ExpC $L_517438      , pt_scr_h_width
ExpC $L_51743c      , pt_scr_h_height
ExpC $L_526210      , pt_z_scale 
ExpC $L_8c83f4      , pt_draw_object
ExpC $L_680528      , pt_hInstance  
ExpC $L_68051c      , pt_hWnd 
ExpC $win_width     , pt_win_w
ExpC $win_height    , pt_win_h
ExpC $L_4419c0      , pt_win_proc_fn
ExpC $L_6949a1      , pt_vm_slot_flag
ExpC $L_695dfc      , pt_vm_base


; 这个方法 c 没法调用 不要导出
; ExpC _truncate_d, truncate_d