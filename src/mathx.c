// Disassembled by yanming.J
// SPDX-License-Identifier: MIT
// https://github.com/yanmingsohu/
#define _USE_MATH_DEFINES
#include <stdint.h>
#include <string.h>
#include <fenv.h>
#include <math.h>
#include "imports.h"


// 试图用浮点数重写
void __cdecl mat_3x3_fmul(int16_t* vec, int16_t* mat, int16_t* out) {
  float m0 = mat[0] / 16.0f, m1 = mat[1] / 16.0f, m2 = mat[2] / 16.0f;
  float m3 = mat[3] / 16.0f, m4 = mat[4] / 16.0f, m5 = mat[5] / 16.0f;
  float m6 = mat[6] / 16.0f, m7 = mat[7] / 16.0f, m8 = mat[8] / 16.0f;

  float v0 = vec[0] / 16.0f, v1 = vec[1] / 16.0f, v2 = vec[2] / 16.0f;
  float v3 = vec[3] / 16.0f, v4 = vec[4] / 16.0f, v5 = vec[5] / 16.0f;
  float v6 = vec[6] / 16.0f, v7 = vec[7] / 16.0f, v8 = vec[8] / 16.0f;

  int16_t r00 = ((m0*v0 + m3*v1 + m6*v2) * 16.0f);
  int16_t r01 = ((m1*v0 + m4*v1 + m7*v2) * 16.0f);
  int16_t r02 = ((m2*v0 + m5*v1 + m8*v2) * 16.0f);

  int16_t r10 = ((m0*v3 + m3*v4 + m6*v5) * 16.0f);
  int16_t r11 = ((m1*v3 + m4*v4 + m7*v5) * 16.0f);
  int16_t r12 = ((m2*v3 + m5*v4 + m8*v5) * 16.0f);

  int16_t r20 = ((m0*v6 + m3*v7 + m6*v8) * 16.0f);
  int16_t r21 = ((m1*v6 + m4*v7 + m7*v8) * 16.0f);
  int16_t r22 = ((m2*v6 + m5*v7 + m8*v8) * 16.0f);

  *(int32_t*)(&out[0]) = ((int32_t)(uint16_t)r01 << 16) | (uint16_t)r00;
  *(int32_t*)(&out[2]) = ((int32_t)(uint16_t)r10 << 16) | (uint16_t)r02;
  *(int32_t*)(&out[4]) = ((int32_t)(uint16_t)r12 << 16) | (uint16_t)r11;
  *(int32_t*)(&out[6]) = ((int32_t)(uint16_t)r21 << 16) | (uint16_t)r20;
  out[8] = r22;
}


// FUN_450af0
void __cdecl mat_3x3_mul(int16_t* vec, int16_t* mat, int16_t* out) {
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
void __cdecl mat_3x3_vec_mul(int16_t* mat, int32_t* vec, int32_t* out) {
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


// FUN_450ca0
void __cdecl mat3x3_mul_inplace(int16_t *mat, int16_t* vec) {
  mat_3x3_mul(mat, vec, mat);
}


// FUN_450cc0
void __cdecl mat3x3_to_vector_inplace(int16_t* mat, int16_t* vec) {
    mat_3x3_mul(mat, vec, vec);
}


// FUN_450ce0
void __cdecl mat_rot_tran(MATRIX* m1, MATRIX* m2, MATRIX* out) {
    MATRIX tmp;
    int32_t temp_vec[3];

    // R = R1 * R2
    mat_3x3_mul((int16_t*)m1, (int16_t*)m2, (int16_t*)tmp.R);

    // temp_vec = R1 * T2
    mat_3x3_vec_mul(
        (int16_t*)m1,
        m2->T,
        temp_vec
    );

    // temp_vec += T1
    temp_vec[0] += m1->T[0];
    temp_vec[1] += m1->T[1];
    temp_vec[2] += m1->T[2];

    // 写入 tmp
    tmp.T[0] = temp_vec[0];
    tmp.T[1] = temp_vec[1];
    tmp.T[2] = temp_vec[2];

    // ✔ 写到 out（不是 m2）
    memcpy(out, &tmp, sizeof(MATRIX));
    //printf("\r%d %d %d", out->R[0], out->R[1], out->R[2]);
}


// FUN_450d50
void __cdecl mat_dot_mul(int32_t* v1, int32_t* v2, int32_t* out) {
    out[0] = v2[2] * v1[1] - v2[1] * v1[2];
    out[1] = v2[0] * v1[2] - v1[0] * v2[2];
    out[2] = v1[0] * v2[1] - v2[0] * v1[1];
    // 附带写入（副作用）
    out[3] = (int32_t)v2;
}


// FUN_4509d0
void __cdecl fp_vec_norm(int16_t* base, int16_t* __, int index) {
    int16_t* v = base + index * 3;

    // ---- 1. fixed → float ----
    const double SCALE_IN  = 1.0 / 4096.0;
    const double SCALE_OUT = 4096.0;

    double fx = v[0] * SCALE_IN;
    double fy = v[1] * SCALE_IN;
    double fz = v[2] * SCALE_IN;

    // ---- 2. length ----
    double len = sqrt(fx*fx + fy*fy + fz*fz);

    // ---- 3. 防止除0（对应 fcom/jp 分支）----
    if (!(len > 0.0))   // NaN 或 0
        len = 1.0;

    // ---- 4. normalize ----
    double inv = 1.0 / len;

    // ---- 5. 写回 fixed ----
    v[0] = (int16_t)(fx * inv * SCALE_OUT);
    v[1] = (int16_t)(fy * inv * SCALE_OUT);
    v[2] = (int16_t)(fz * inv * SCALE_OUT);
}


// FUN_450a90
void __cdecl fp_vec_norm2(int16_t* dst, int16_t* src) {
    fp_vec_norm(dst, src, 0);
    fp_vec_norm(dst, src, 1);
}


// FUN_450ac0
void __cdecl fp_vec_norm02(int16_t* base, int16_t* auxiliary) {
    fp_vec_norm(base, auxiliary, 0);
    fp_vec_norm(base, auxiliary, 2);
}


// FUN_450960
uint16_t __cdecl pack_uv(int32_t a, int32_t b) {
    // a / 16（向0取整）
    int32_t q = (a + ((a < 0) ? 15 : 0)) >> 4;
    // 低6位
    int32_t part_a = q & 0x3F;
    // b 取低10位再左移6位
    int32_t part_b = (b & 0x3FF) << 6;
    return (uint16_t)(part_b + part_a);
}


// FUN_450990
uint16_t __cdecl fp_coor_cps(int a, int b, int c, int d) {
    // 前两个参数低2bit
    int t = (a & 3) + ((b & 3) << 2);   // ECX = b&3 + (a&3)*4
    // 第三个参数：带符号 /256
    int t2 = (d + ((d >> 31) & 255)) >> 8;
    t = t2 + t * 2;
    // 第四个参数：带符号 /64
    int t3 = (c + ((c >> 31) & 63)) >> 6;
    t = (t << 4) + t3;
    return (uint16_t)t;
}


// FUN_450820
void __cdecl mat_vec_mul_n(int16_t* mat, int16_t* vec, int32_t* out) {
    int x = vec[0];
    int y = vec[1];
    int z = vec[2];
    // 第一行
    out[0] = (mat[0] * x + mat[1] * y + mat[2] * z) >> 12;
    // 第二行
    out[1] = (mat[3] * x + mat[4] * y + mat[5] * z) >> 12;
    // 第三行
    out[2] = (mat[6] * x + mat[7] * y + mat[8] * z) >> 12;
}


// FUN_4508a0
void __cdecl mat_vec_mul_cut(int16_t* mat, int16_t* vec, int16_t* out) {
    int32_t tmp[3];
    // 3x3 矩阵 × 向量（Q12）
    mat_vec_mul_n(mat, vec, tmp);
    // 截断为 16 位
    out[0] = (int16_t)tmp[0];
    out[1] = (int16_t)tmp[1];
    out[2] = (int16_t)tmp[2];
}


// FUN_4515e0
int32_t __cdecl fp_sin(uint32_t x) {
    int sign = (x & 0x800) ? -1 : 1;
    uint32_t idx = x & 0x7FF;
    double angle = (double)idx * (2.0 * M_PI / 4096.0);
    double val = fabs(sin(angle));
    return (int32_t)(val * 4096.0) * sign;
}


// FUN_451630
int32_t fp_cos(uint32_t x) {
    return fp_sin(x + 1024);
}


// FUN_451530
void __cdecl blend_vec(const int16_t* a, const int16_t* b, 
               int16_t scaleA, int16_t scaleB, int16_t* out) {
    out[0] = (int16_t)(
            MulDiv(a[0], scaleA, 4096) +
            MulDiv(b[0], scaleB, 4096) );
    out[1] = (int16_t)(
            MulDiv(a[1], scaleA, 4096) +
            MulDiv(b[1], scaleB, 4096) );
    out[2] = (int16_t)(
            MulDiv(a[2], scaleA, 4096) +
            MulDiv(b[2], scaleB, 4096) );
}


// FUN_450ff0
int16_t* __cdecl rotate_z(uint32_t angle, int16_t* mat) {
    int16_t sinv = (int16_t)fp_sin(angle);
    int16_t cosv = (int16_t)fp_cos(angle);
    MATRIX rot = {
      cosv, -sinv, 0,
      sinv, cosv,  0,
      0,    0,     4096,
    };
    mat_3x3_mul((int16_t*)&rot, mat, mat);
    return mat;  // ← 汇编里的 EAX = ESI
}


// FUN_450f80
int16_t* __cdecl rotate_y(uint32_t angle, int16_t* mat) {
    int16_t sinv = (int16_t)fp_sin(angle);
    int16_t cosv = (int16_t)fp_cos(angle);
    MATRIX rot = {
         cosv, 0,    sinv,
         0,    4096, 0,
        -sinv, 0,    cosv
    };
    // mat = rot × mat（左乘）
    mat_3x3_mul((int16_t*)&rot, mat, mat);
    return mat;
}


// FUN_450f10
int16_t* __cdecl rotate_x(uint32_t angle, int16_t* mat) {
    int16_t sinv = (int16_t)fp_sin(angle);
    int16_t cosv = (int16_t)fp_cos(angle);
    // 这会实现很有趣的效果
    // MATRIX rot = {
    //     4096, 0,     0,
    //     0,    cosv,  sinv,
    //     0,   -sinv,  cosv
    // };
    // mat = rot × mat（左乘）
    MATRIX rot = {
        4096, 0,     0,
        0,    cosv,  -sinv,
        0,    sinv,  cosv
    };
    mat_3x3_mul((int16_t*)&rot, mat, mat);
    return mat;
}


// FUN_450ea0
int16_t* __cdecl rotate_yxz(int16_t* angles, int16_t* mat) {
  printf("\rrotate_yxz");
    // 初始化单位矩阵（4096 = 1.0）
    mat[0] = 4096; mat[1] = 0;    mat[2] = 0;
    mat[3] = 0;    mat[4] = 4096; mat[5] = 0;
    mat[6] = 0;    mat[7] = 0;    mat[8] = 4096;
    // 按汇编顺序调用
    rotate_z(angles[2], mat); // Z
    rotate_x(angles[0], mat); // X
    rotate_y(angles[1], mat); // Y
    return mat;
}


// FUN_450e30
int16_t* __cdecl rotate_xyz(int16_t* angles, int16_t* mat) {
    //printf("\rrotate_xyz");
    // 初始化单位矩阵（4096 = 1.0）
    mat[0] = 4096; mat[1] = 0;    mat[2] = 0;
    mat[3] = 0;    mat[4] = 4096; mat[5] = 0;
    mat[6] = 0;    mat[7] = 0;    mat[8] = 4096;
    // 按汇编顺序调用
    rotate_z((int32_t)angles[2], mat); // Z
    rotate_y((int32_t)angles[1], mat); // Y
    rotate_x((int32_t)angles[0], mat); // X
    return mat;
}


static inline int32_t truncate_d(double v) {
    return (int32_t)(int64_t)v;
}


// FUN_451060
// 文档/特效贴花 投影
int __cdecl proj_2D_tile(int16_t* vec, int32_t* x, int32_t* y, int32_t *z) {
  const int SCALE = *pt_z_scale;
  const int Type = 2;
  
  int32_t lvec[4]; // 对应汇编中的 [ESP+4], [ESP+8], [ESP+12]
  MATRIX *mat = (MATRIX*)pt_99ce20;
  
  // 汇编：push [ESP+20](arg0), push OFFSET $L_99ce20
  mat_vec_mul_n((int16_t*)mat, vec, lvec);

  lvec[0] += mat->T[0];
  lvec[1] += mat->T[1];
  lvec[2] += mat->T[2];

  // 3. Z轴边界检查
  if (lvec[2] == 0) {
      lvec[2] = 1; // 防止除以零
  }

  int32_t outX, outY;
  double invZ;
  
  // $L_526214
  switch (Type) {
  case 2: // $L_451184 之后的逻辑
    // 简单的比例缩放
    outX = ((double)lvec[0] * SCALE / lvec[2] + 160.0);
    outY = ((double)lvec[1] * SCALE / lvec[2] + 120.0);        
    break;

  case 1: // $L_451108
    invZ = 1.0 / lvec[2];
    outX = ((double)SCALE * invZ * lvec[0] + 200.0);
    outY = ((double)SCALE * invZ * lvec[1] + 120.0);
    break;

  case 0: // $L_451146
    invZ = 1.0 / lvec[2];
    outX = ((double)lvec[0] * invZ * SCALE + 200.0);
    outY = ((double)lvec[1] * invZ * SCALE + 120.0);
    break;

  default: // 其他情况 (汇编 $L_451184 直接赋值)
    outX = lvec[0];
    outY = lvec[1];
    break;
  }
  
  *x = (outY << 16) + (outX & 0xFFFF);
  // 汇编末尾：mov EAX, EDI(posZ); sar EAX, 2;
  // 这个函数返回的不是“坐标”，而是：深度值（用于排序）
  return lvec[2] >> 2;
}


static inline int16_t fix_mul_shift12(int16_t a, int32_t b) {
    int32_t t = (int32_t)a * b;
    t = (t + ((t >> 31) & 0xFFF)) >> 12;
    return (int16_t)t;
}


// FUN_4511b0 未测试
int16_t* mat3_scale_cols_q12(int16_t* mat, const int32_t* scale) {
    // 共 9 个元素（0~16 每隔2字节）
    mat[0] = fix_mul_shift12(mat[0], scale[0]);
    mat[1] = fix_mul_shift12(mat[1], scale[1]);
    mat[2] = fix_mul_shift12(mat[2], scale[2]);

    mat[3] = fix_mul_shift12(mat[3], scale[0]);
    mat[4] = fix_mul_shift12(mat[4], scale[1]);
    mat[5] = fix_mul_shift12(mat[5], scale[2]);

    mat[6] = fix_mul_shift12(mat[6], scale[0]);
    mat[7] = fix_mul_shift12(mat[7], scale[1]);
    mat[8] = fix_mul_shift12(mat[8], scale[2]);
    printf("mat3_scale_cols_q12 %x %x\r", mat, scale);
    return mat;
}