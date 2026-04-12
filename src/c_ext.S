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
Extern _mat3x3_mul_inplace : Proc
Extern _mat3x3_to_vector_inplace : Proc
Extern _mat_rot_tran : Proc
Extern _mat_dot_mul : Proc
Extern _fp_vec_norm : Proc
Extern _fp_vec_norm2 : Proc
Extern _pack_uv : Proc
Extern _fp_coor_cps : Proc
Extern _fp_vec_norm02 : Proc
Extern _mat_vec_mul_n : Proc
Extern _mat_vec_mul_cut : Proc
Extern _fp_sin : Proc
Extern _fp_cos : Proc
Extern _blend_vec : Proc
Extern _rotate_z : Proc
Extern _rotate_y : Proc
Extern _rotate_x : Proc
Extern _rotate_yxz : Proc
Extern _rotate_xyz : Proc