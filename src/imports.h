#include <stdint.h>

extern void* pt_99ce20;
extern float* pt_scr_h_width;
extern float* pt_scr_h_height;
extern int32_t* pt_z_scale;


typedef struct {
    int16_t R[3][3];  // 12.4 fixed
    int16_t pad;
    int32_t T[3];     // 高精度平移
} MATRIX;

// windows.h
extern int __stdcall MulDiv(int a, int b, int x);