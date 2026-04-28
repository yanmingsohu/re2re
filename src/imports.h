// Disassembled by yanming.J
// SPDX-License-Identifier: MIT
// https://github.com/yanmingsohu/
#include <stdint.h>

extern void* pt_99ce20;
extern float* pt_scr_h_width;
extern float* pt_scr_h_height;
extern int32_t* pt_z_scale;
extern void **pt_draw_object;
extern void **pt_hInstance;
extern void **pt_hWnd;
extern int32_t* pt_win_w;
extern int32_t* pt_win_h;
extern void *pt_win_proc_fn;


#pragma pack(push, 1)
typedef struct {
    int16_t R[3][3];  // 12.4 fixed
    int16_t pad;
    int32_t T[3];     // 高精度平移
} MATRIX;
#pragma pack(pop)

// windows.h
extern __declspec(dllimport) int __stdcall MulDiv(int a, int b, int x);