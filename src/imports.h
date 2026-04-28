// Disassembled by yanming.J
// SPDX-License-Identifier: MIT
// https://github.com/yanmingsohu/
#include <stdint.h>


// windows.h
extern __declspec(dllimport) int __stdcall MulDiv(int a, int b, int x);
// common.c
void msgc(char* str);
// script.h
typedef struct VMStatusSlot VMStatusSlot;


// 汇编导出
extern void*            pt_99ce20;
extern float*           pt_scr_h_width;
extern float*           pt_scr_h_height;
extern int32_t*         pt_z_scale;
extern void**           pt_draw_object;
extern void**           pt_hInstance;
extern void**           pt_hWnd;
extern int32_t*         pt_win_w;
extern int32_t*         pt_win_h;
extern void*            pt_win_proc_fn;
extern VMStatusSlot*    pt_vm_slot_flag;  // $L_6949a1 
extern uint16_t**       pt_vm_base;       // $L_695dfc