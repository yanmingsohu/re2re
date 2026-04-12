; Disassembled by yanming.J
; SPDX-License-Identifier: MIT
; https://github.com/yanmingsohu/

.686p
.XMM
.MODEL FLAT
ASSUME FS:NOTHING
ASSUME GS:NOTHING

Include src/imports.S
Include src/c_ext.S

EXTERN ___ImageBase:BYTE
PUBLIC __EntryPoint

;===================================
_TEXT SEGMENT 'TEXT'


  Include src/FUN_401000_format_err_message.S
  Include src/script.S
  Include src/entry.S
  Include src/unorganized.S
  Include src/user_func.S


_TEXT ENDS
;===================================
_RDATA SEGMENT READ 'DATA' 


  Include src/rdata.S


_RDATA ENDS
;===================================
_DATA SEGMENT 'RDATA'


  Include src/data.S
  Include src/user_data.S
  Include src/exports.S


_DATA ENDS
;===================================
END