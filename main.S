; Disassembled by yanming.J
; SPDX-License-Identifier: MIT
; https://github.com/yanmingsohu/

.686p
.XMM
.MODEL FLAT
ASSUME FS:NOTHING
ASSUME GS:NOTHING

Include src/imports.S

EXTERN ___ImageBase:BYTE
PUBLIC __EntryPoint

;===================================
_TEXT SEGMENT
;===================================

Include src/FUN_401000_format_err_message.S
Include src/script.S
Include src/entry.S
Include src/unorganized.S


