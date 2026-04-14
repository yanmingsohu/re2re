// Disassembled by yanming.J
// SPDX-License-Identifier: MIT
// https://github.com/yanmingsohu/
#include <windows.h>
#include "imports.h"

extern void on_before_window_show(void);

const char MainName[] = "BIOHAZARD(R) 2 PC (github.com/yanmingsohu/re2re)";


// FUN_441d50
int create_window(HINSTANCE hInstance, int isAlreadyRegistered) {
    *pt_hInstance = hInstance;

    if (isAlreadyRegistered == 0) {
        WNDCLASSA wc = {0};
        wc.style         = 11;
        wc.lpfnWndProc   = (WNDPROC)pt_win_proc_fn;  // $L_4419c0，窗口过程函数
        wc.cbClsExtra    = 0;
        wc.cbWndExtra    = 0;
        wc.hInstance     = hInstance;
        wc.hIcon         = 0;
        wc.hCursor       = LoadCursorA(NULL, IDC_ARROW);   // 32512 = IDC_ARROW
        wc.hbrBackground = (HBRUSH)GetStockObject(BLACK_BRUSH); // 4 = BLACK_BRUSH
        wc.lpszMenuName  = NULL;
        wc.lpszClassName = (LPCSTR)MainName;  // $L_524e34，窗口类名字符串

        RegisterClassA(&wc);
    }

    on_before_window_show();
    printf("Create window %x %x\n", isAlreadyRegistered, hInstance);

    // 根据客户区大小计算含边框的窗口大小
    RECT rect = {0};
    rect.left   = 0;
    rect.top    = 0;
    rect.right  = *pt_win_w;
    rect.bottom = *pt_win_h;
    AdjustWindowRect(&rect, WS_OVERLAPPEDWINDOW, FALSE); // 0x2CA0000

    int adjustedWidth  = rect.right  - rect.left;
    int adjustedHeight = rect.bottom - rect.top;

    // 创建窗口，位置居中（CW_USEDEFAULT 风格由 0x80000000 指定）
    HWND hWnd = CreateWindowExA(
        0,                          // dwExStyle
        (LPCSTR)MainName,           // lpClassName  ($L_524e34)
        (LPCSTR)MainName,           // lpWindowName ($L_524e34，同类名，可能共用)
        0x2CA0000,                  // dwStyle (WS_OVERLAPPEDWINDOW 相关)
        0x80000000,                 // x      (CW_USEDEFAULT)
        0x80000000,                 // y      (CW_USEDEFAULT)
        adjustedWidth,              // nWidth
        adjustedHeight,             // nHeight
        NULL,                       // hWndParent
        NULL,                       // hMenu
        hInstance,                  // hInstance
        NULL                        // lpParam
    ); 

    *pt_hWnd = hWnd;

    ShowWindow(hWnd, SW_SHOWNORMAL);
    SetForegroundWindow(hWnd);
    UpdateWindow(hWnd);

    return 1;
}