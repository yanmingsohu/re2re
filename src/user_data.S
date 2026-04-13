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


; 随意定义了一些数据, 完整长度应该有 4M
$L_c800fa DB 0B3h,01Ch,0FFh,0FCh,045h,07Ah,043h,005h ; 0xc800fa (8 bytes)
          DB 0F6h,0BCh,0A1h,034h,0D6h,005h,02Dh,059h ; 0xc80102 (16 bytes)
          DB 07Bh,0C0h,045h,0CBh,0E2h,04Eh,0C7h,041h ; 0xc8010a (24 bytes)
          DB 098h,0B1h,0A1h,035h,011h,0C8h,0FBh,0D4h ; 0xc80112 (32 bytes)
          DB 081h,07Bh,07Fh,099h,0F4h,0C2h,0CCh,027h ; 0xc8011a (40 bytes)
          DB 055h,0A9h,0A1h,035h,099h,0A0h,031h,077h ; 0xc80122 (48 bytes)
          DB 00Bh,0F3h,0E5h,0B5h,0C4h,054h,047h,009h ; 0xc8012a (56 bytes)
          DB 0A3h,0DFh,0A1h,035h,0A2h,0C6h,03Fh,0EAh ; 0xc80132 (64 bytes)
          DB 060h,03Eh,00Ch,0ACh,0D6h,010h,0D8h,01Fh ; 0xc8013a (72 bytes)
          DB 0D4h,08Dh,0A1h,035h,0B9h,0D2h,014h,051h ; 0xc80142 (80 bytes)
          DB 0C6h,058h,010h,015h,00Fh,0C1h,0F1h,036h ; 0xc8014a (88 bytes)
          DB 02Ah,025h,0A1h,035h,0FAh,023h,00Eh,064h ; 0xc80152 (96 bytes)
          DB 0B7h,0D9h,0D2h,0A5h,0B5h,01Ch,065h,053h ; 0xc8015a (104 bytes)
          DB 0F8h,0ADh,0A1h,036h,007h,0C6h,0DCh,0F7h ; 0xc80162 (112 bytes)
          DB 0F7h,0E5h,099h,05Bh,002h,026h,05Fh,0E0h ; 0xc8016a (120 bytes)
          DB 000h,0FFh,0A1h,036h,018h,0B8h,063h,0C2h ; 0xc80172 (128 bytes)
          DB 01Ch,02Eh,0C9h,08Dh,0A3h,000h,068h,0B0h ; 0xc8017a (136 bytes)
          DB 0E6h,0CEh,0A1h,036h,024h,0A1h,06Bh,0F4h ; 0xc80182 (144 bytes)
          DB 0E7h,036h,0CBh,05Fh,049h,029h,07Ah,08Fh ; 0xc8018a (152 bytes)
          DB 090h,04Fh,0A1h,036h,03Dh,06Eh,073h,091h ; 0xc80192 (160 bytes)
          DB 08Bh,052h,091h,05Bh,06Fh,0F3h,021h,071h ; 0xc8019a (168 bytes)
          DB 009h,0BBh,0A1h,036h,044h,07Bh,08Eh,0F8h ; 0xc801a2 (176 bytes)
          DB 0E5h,027h,0F3h,0D6h,056h,0B7h,0CCh,023h ; 0xc801aa (184 bytes)
          DB 053h,093h,0A1h,036h,072h,01Fh,0EBh,073h ; 0xc801b2 (192 bytes)
          DB 047h,05Fh,0D4h,0D6h,09Eh,0A2h,01Ah,0AEh ; 0xc801ba (200 bytes)
          DB 056h,045h,0A1h,036h,09Fh,0B5h,0E2h,0FCh ; 0xc801c2 (208 bytes)
          DB 073h,081h,026h,029h,042h,0A3h,023h,02Dh ; 0xc801ca (216 bytes)
          DB 0ECh,083h,0A1h,036h,0A2h,0CEh,0F4h,02Ah ; 0xc801d2 (224 bytes)
          DB 00Bh,094h,005h,010h,0F4h,0F9h,068h,091h ; 0xc801da (232 bytes)
          DB 0FAh,090h,0A1h,036h,0D4h,04Bh,0E8h,0BAh ; 0xc801e2 (240 bytes)
          DB 0AFh,001h,09Ch,031h,043h,079h,0B3h,08Ah ; 0xc801ea (248 bytes)
          DB 0A9h,091h,0A1h,036h,0E3h,0E2h,03Eh,0CAh ; 0xc801f2 (256 bytes)
          DB 024h,0F4h,06Ah,0A8h,085h,045h,018h,02Ah ; 0xc801fa (264 bytes)
          DB 0F2h,031h,0A1h,037h,00Eh,00Bh,01Ah,07Ah ; 0xc80202 (272 bytes)
          DB 020h,082h,082h,007h,015h,0A4h,08Ah,0B0h ; 0xc8020a (280 bytes)
          DB 046h,00Dh,0A1h,037h,059h,07Eh,05Eh,059h ; 0xc80212 (288 bytes)
          DB 079h,0D2h,099h,05Eh,011h,034h,07Ah,07Ch ; 0xc8021a (296 bytes)
          DB 09Ah,0B6h,0A1h,037h,061h,0EEh,0EFh,0C0h ; 0xc80222 (304 bytes)
          DB 0D1h,0D0h,0CEh,08Eh,0CAh,078h,012h,016h ; 0xc8022a (312 bytes)
          DB 023h,0B2h,0A1h,037h,067h,08Fh,070h,024h ; 0xc80232 (320 bytes)
$L_0b40020 DB 4 DUP(0)
