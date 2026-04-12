// Disassembled by yanming.J
// SPDX-License-Identifier: MIT
// https://github.com/yanmingsohu/


#include <stdint.h>

// FUN_450af0
void __cdecl mat_3x3_mul(const int16_t* vec, const int16_t* mat, int16_t* out)
{
  int32_t m0 = mat[0], m1 = mat[1], m2 = mat[2];
  int32_t m3 = mat[3], m4 = mat[4], m5 = mat[5];
  int32_t m6 = mat[6], m7 = mat[7], m8 = mat[8];

  int32_t v0 = vec[0], v1 = vec[1], v2 = vec[2];
  int32_t v3 = vec[3], v4 = vec[4], v5 = vec[5];
  int32_t v6 = vec[6], v7 = vec[7], v8 = vec[8];

  int16_t r00 = (int16_t)((m0*v0 + m3*v1 + m6*v2) >> 12);
  int16_t r01 = (int16_t)((m1*v0 + m4*v1 + m7*v2) >> 12);
  int16_t r02 = (int16_t)((m2*v0 + m5*v1 + m8*v2) >> 12);

  int16_t r10 = (int16_t)((m0*v3 + m3*v4 + m6*v5) >> 12);
  int16_t r11 = (int16_t)((m1*v3 + m4*v4 + m7*v5) >> 12);
  int16_t r12 = (int16_t)((m2*v3 + m5*v4 + m8*v5) >> 12);

  int16_t r20 = (int16_t)((m0*v6 + m3*v7 + m6*v8) >> 12);
  int16_t r21 = (int16_t)((m1*v6 + m4*v7 + m7*v8) >> 12);
  int16_t r22 = (int16_t)((m2*v6 + m5*v7 + m8*v8) >> 12);

  // DWORD写入，每次打包两个word
  // 低地址word在低16位，高地址word在高16位
  *(int32_t*)(&out[0]) = ((int32_t)(uint16_t)r01 << 16) | (uint16_t)r00;
  *(int32_t*)(&out[2]) = ((int32_t)(uint16_t)r10 << 16) | (uint16_t)r02;
  *(int32_t*)(&out[4]) = ((int32_t)(uint16_t)r12 << 16) | (uint16_t)r11;
  *(int32_t*)(&out[6]) = ((int32_t)(uint16_t)r21 << 16) | (uint16_t)r20;
  out[8] = r22;
}


// FUN_4508e0
// mat: int16[9]，行优先
// vec: int32[3]
// out: int32[3]
void __cdecl mat_3x3_vec_mul(const int16_t* mat, const int32_t* vec, int32_t* out)
{
    int32_t v0 = vec[0];
    int32_t v1 = vec[1];
    int32_t v2 = vec[2];

    // 行0点积
    out[0] = ((int32_t)mat[0]*v0 + (int32_t)mat[1]*v1 + (int32_t)mat[2]*v2) >> 12;

    // 行1点积
    out[1] = ((int32_t)mat[3]*v0 + (int32_t)mat[4]*v1 + (int32_t)mat[5]*v2) >> 12;

    // 行2点积
    out[2] = ((int32_t)mat[6]*v0 + (int32_t)mat[7]*v1 + (int32_t)mat[8]*v2) >> 12;
}