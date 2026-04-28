// Disassembled by yanming.J
// SPDX-License-Identifier: MIT
// https://github.com/yanmingsohu/
#include <stdint.h>
#pragma pack(push, 1)


typedef struct {
  int16_t R[3][3];  // 12.4 fixed
  int16_t pad;
  int32_t T[3];     // 高精度平移
} MATRIX;


#pragma pack(pop)