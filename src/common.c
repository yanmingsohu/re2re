// Disassembled by yanming.J
// SPDX-License-Identifier: MIT
// https://github.com/yanmingsohu/
#include "windows.h"
#include "stdio.h"


void open_console() {
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
  printf(" - https://github.com/yanmingsohu\n");
}


void on_winmain_call() {
  open_console();
}