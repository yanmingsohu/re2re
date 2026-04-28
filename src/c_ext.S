; Disassembled by yanming.J
; SPDX-License-Identifier: MIT
; https://github.com/yanmingsohu/

Cfunc MACRO name
    EXTERN _&name:PROC
    name TEXTEQU <_&name>
ENDM

; -- event.c
Cfunc on_winmain_call
Cfunc on_before_window_show

; -- common.c
Cfunc debug
Cfunc stack
Cfunc memInfo@20

; -- mathx.c
Cfunc mat_3x3_mul                    
Cfunc mat_3x3_vec_mul                
Cfunc mat3x3_mul_inplace             
Cfunc mat3x3_to_vector_inplace       
Cfunc mat_rot_tran                   
Cfunc mat_dot_mul                    
Cfunc fp_vec_norm                    
Cfunc fp_vec_norm2                   
Cfunc pack_uv                        
Cfunc fp_coor_cps                    
Cfunc fp_vec_norm02                  
Cfunc mat_vec_mul_n                  
Cfunc mat_vec_mul_cut
Cfunc fp_sin
Cfunc fp_cos
Cfunc blend_vec
Cfunc rotate_z
Cfunc rotate_y
Cfunc rotate_x
Cfunc rotate_yxz
Cfunc rotate_xyz
Cfunc proj_2D_tile
Cfunc mat3_scale_cols_q12
Cfunc debug_math

; -- draw.c
Cfunc InitDirectDrawDisplay
; Cfunc printx

; -- sys.c
Cfunc create_window

; -- script.c
Cfunc vm_nop
Cfunc vm_vib_fade_set
Cfunc vm_vib_set0
Cfunc vm_vib_set1
Cfunc vm_jump
Cfunc vm_end
Cfunc vm_kill
Cfunc vm_return
Cfunc vm_call
Cfunc vm_yield