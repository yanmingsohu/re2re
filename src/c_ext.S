; Disassembled by yanming.J
; SPDX-License-Identifier: MIT
; https://github.com/yanmingsohu/

CFunc MACRO name
    EXTERN name:PROC
ENDM

; -- event.c
CFunc _on_winmain_call
CFunc _on_before_window_show

; -- common.c
CFunc _debug
CFunc _stack

; -- mathx.c
CFunc _mat_3x3_mul                    
CFunc _mat_3x3_vec_mul                
CFunc _mat3x3_mul_inplace             
CFunc _mat3x3_to_vector_inplace       
CFunc _mat_rot_tran                   
CFunc _mat_dot_mul                    
CFunc _fp_vec_norm                    
CFunc _fp_vec_norm2                   
CFunc _pack_uv                        
CFunc _fp_coor_cps                    
CFunc _fp_vec_norm02                  
CFunc _mat_vec_mul_n                  
CFunc _mat_vec_mul_cut
CFunc _fp_sin
CFunc _fp_cos
CFunc _blend_vec
CFunc _rotate_z
CFunc _rotate_y
CFunc _rotate_x
CFunc _rotate_yxz
CFunc _rotate_xyz
CFunc _proj_2D_tile
CFunc _mat3_scale_cols_q12

; -- draw.c
CFunc _InitDirectDrawDisplay
; CFunc _printx

; -- sys.c
CFunc _create_window