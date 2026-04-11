; Disassembled by yanming.J
; SPDX-License-Identifier: MIT
; https://github.com/yanmingsohu/

$win_width  DWORD 640 ;窗口高度和宽度
$win_height DWORD 480

res165              db 32 dup(0)
BIN165              db "BIN165.bin", 0
dwBytesRead         dd 0
data0069340c        DB 4 DUP(0)
data0069340a        DB 4 DUP(0)

; m00=m11=m22=4096
max_4x4_tmp word 4096, 0000, 0000, 0000
            word 0000, 4096, 0000, 0000
            word 0000, 0000, 4096, 0000
            word 0000, 0000, 0000, 0000