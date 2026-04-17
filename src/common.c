// Disassembled by yanming.J
// SPDX-License-Identifier: MIT
// https://github.com/yanmingsohu/
#include "windows.h"
#include "stdio.h"
#include "stdint.h"


void __cdecl debug() {
  unsigned int _eax, _ebx, _ecx, _edx, _esi, _edi, _ebp, _esp, _eflags;
  static int i = 0;
  static char c[] = "-/|\\";

  __asm {
      // 1. 保存当前所有通用寄存器到栈 (EAX, ECX, EDX, EBX, ESP, EBP, ESI, EDI)
      pushad 
      // 2. 保存标志寄存器
      pushfd
      pop _eflags

      // 3. 从栈中提取刚才保存的值（注意 pushad 的压栈顺序）
      // pushad 压栈顺序: EAX, ECX, EDX, EBX, original ESP, EBP, ESI, EDI
      mov eax, [esp + 28] // EAX 是第一个压进去的，在最高处
      mov _eax, eax
      mov eax, [esp + 24] // ECX
      mov _ecx, eax
      mov eax, [esp + 20] // EDX
      mov _edx, eax
      mov eax, [esp + 16] // EBX
      mov _ebx, eax
      mov eax, [esp + 12] // ESP
      mov _esp, eax
      mov eax, [esp + 8]  // EBP
      mov _ebp, eax
      mov eax, [esp + 4]  // ESI
      mov _esi, eax
      mov eax, [esp]      // EDI
      mov _edi, eax

      // 4. 恢复栈指针（刚才 pushad 压了 8 个 DWORD）
      popad
  }

  // 打印所有寄存器，不换行 (末尾使用空格分隔)
  printf("\r%c EAX=%08X EBX=%08X ECX=%08X EDX=%08X ESI=%08X EDI=%08X EBP=%08X ESP=%08X EFL=%08X", 
          c[i++&3], _eax, _ebx, _ecx, _edx, _esi, _edi, _ebp, _esp, _eflags);
}


void __cdecl stack() {
    unsigned int esp_val;
    __asm { mov esp_val, esp } // 只用汇编抓取当前的栈顶位置

    unsigned int* ptr = (unsigned int*)esp_val; // 转为指针

    printf(" Current ESP: 0x%08X\n", esp_val);
    printf("---------------------------\n");

    for (int i = 0; i < 10; i++) {
        printf(" [%p] -> 0x%08X\n", &ptr[i], ptr[i]);
    }
}


void __cdecl open_console() {
  AllocConsole();

  // 把控制台窗口推到最后面
  // HWND hConsole = GetConsoleWindow();
  // SetWindowPos(hConsole, HWND_BOTTOM, 0, 0, 0, 0,
  //               SWP_NOMOVE | SWP_NOSIZE | SWP_NOACTIVATE);
  
  FILE* fp;
  freopen_s(&fp, "CONOUT$", "w", stdout);
  freopen_s(&fp, "CONOUT$", "w", stderr);
  freopen_s(&fp, "CONIN$",  "r", stdin);

  SetConsoleTitle("RE2 Debug Console");
  
  printf(" - Disassembled by yanming.J\n");
  printf(" - SPDX-License-Identifier: MIT\n");
  printf(" - https://github.com/yanmingsohu\n\n");
  // stack();
  // debug();
}


void __cdecl __printx(char* a, char* b) {
    printf(" P -- %x -- %x\r", (uint32_t)a, (uint32_t)b);
    // if (b == 0xFFFF0000) {
    //     printf(" 1:: %x\n", a);
    //     return;
    // }
    // if (b == 0x40000000) {
    //     printf(" 2:: %x\n", a);
    //     return;
    // }
    // if (a == 0xA0 || b == 0x78) {
    //     printf(" 3:: %x %x\n", a, b);
    //     return;
    // }
    // if (a) puts(a);
    // if (b) puts(b);
}


void __stdcall memInfo(int bytes, uint32_t a, uint32_t hb, uint32_t hp, int id) {
    if (id & 0xF00) {
        printf(" @ Req(%3d) mem %8d Bytes addr:%08xH heapBase:%08x SaveTo:%08xH\n", 
            id, bytes, a, hb, hp);
    } else {
        printf(" @ Req(%3d) mem %8d Bytes addr:%08xH heapBase:%08x heapPtr:%08xH\n", 
            id, bytes, a, hb, hp);
    }
}