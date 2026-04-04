; Disassembled by yanming.J
; SPDX-License-Identifier: MIT
; https://github.com/yanmingsohu/

INCLUDELIB KERNEL32.lib
INCLUDELIB USER32.lib
INCLUDELIB GDI32.lib 
INCLUDELIB ADVAPI32.lib
INCLUDELIB ole32.lib
INCLUDELIB WINMM.lib
INCLUDELIB DDRAW.lib
INCLUDELIB DSOUND.lib
INCLUDELIB MSACM32.lib
INCLUDELIB IMM32.lib

EXTERN __imp__AdjustWindowRect@12:PROC
EXTERN _AdjustWindowRect@12:PROC
EXTERN __imp__AdjustWindowRectEx@16:PROC
EXTERN _AdjustWindowRectEx@16:PROC
EXTERN __imp__ClientToScreen@8:PROC
EXTERN _ClientToScreen@8:PROC
EXTERN __imp__CloseHandle@4:PROC
EXTERN _CloseHandle@4:PROC
EXTERN __imp__CoCreateInstance@20:PROC
EXTERN _CoCreateInstance@20:PROC
EXTERN __imp__CoInitialize@4:PROC
EXTERN _CoInitialize@4:PROC
EXTERN __imp__CoUninitialize@0:PROC
EXTERN _CoUninitialize@0:PROC
EXTERN __imp__CreateDirectoryA@8:PROC
EXTERN _CreateDirectoryA@8:PROC
EXTERN __imp__CreateFileA@28:PROC
EXTERN _CreateFileA@28:PROC
EXTERN __imp__CreateFontA@56:PROC
EXTERN _CreateFontA@56:PROC
EXTERN __imp__CreateMutexA@12:PROC
EXTERN _CreateMutexA@12:PROC
EXTERN __imp__CreateWindowExA@48:PROC
EXTERN _CreateWindowExA@48:PROC
EXTERN __imp__DefWindowProcA@16:PROC
EXTERN _DefWindowProcA@16:PROC
EXTERN __imp__DeleteFileA@4:PROC
EXTERN _DeleteFileA@4:PROC
EXTERN __imp__DeleteObject@4:PROC
EXTERN _DeleteObject@4:PROC
EXTERN __imp__DestroyWindow@4:PROC
EXTERN _DestroyWindow@4:PROC
EXTERN __imp__DialogBoxParamA@20:PROC
EXTERN _DialogBoxParamA@20:PROC
EXTERN __imp__DirectDrawCreate@12:PROC
EXTERN _DirectDrawCreate@12:PROC
EXTERN __imp__DirectDrawEnumerateA@8:PROC
EXTERN _DirectDrawEnumerateA@8:PROC
EXTERN __imp__DispatchMessageA@4:PROC
EXTERN _DispatchMessageA@4:PROC
EXTERN __imp__EndDialog@8:PROC
EXTERN _EndDialog@8:PROC
EXTERN __imp__ExitProcess@4:PROC
EXTERN _ExitProcess@4:PROC
EXTERN __imp__ExtTextOutA@32:PROC
EXTERN _ExtTextOutA@32:PROC
EXTERN __imp__FindClose@4:PROC
EXTERN _FindClose@4:PROC
EXTERN __imp__FindFirstFileA@8:PROC
EXTERN _FindFirstFileA@8:PROC
EXTERN __imp__FindNextFileA@8:PROC
EXTERN _FindNextFileA@8:PROC
EXTERN __imp__FindResourceA@12:PROC
EXTERN _FindResourceA@12:PROC
EXTERN __imp__FlushFileBuffers@4:PROC
EXTERN _FlushFileBuffers@4:PROC
EXTERN __imp__FreeEnvironmentStringsA@4:PROC
EXTERN _FreeEnvironmentStringsA@4:PROC
EXTERN __imp__FreeEnvironmentStringsW@4:PROC
EXTERN _FreeEnvironmentStringsW@4:PROC
EXTERN __imp__GetACP@0:PROC
EXTERN _GetACP@0:PROC
EXTERN __imp__GetCPInfo@8:PROC
EXTERN _GetCPInfo@8:PROC
EXTERN __imp__GetCommandLineA@0:PROC
EXTERN _GetCommandLineA@0:PROC
EXTERN __imp__GetCurrentProcess@0:PROC
EXTERN _GetCurrentProcess@0:PROC
EXTERN __imp__GetDC@4:PROC
EXTERN _GetDC@4:PROC
EXTERN __imp__GetDeviceCaps@8:PROC
EXTERN _GetDeviceCaps@8:PROC
EXTERN __imp__GetDlgItem@8:PROC
EXTERN _GetDlgItem@8:PROC
EXTERN __imp__GetEnvironmentStrings@0:PROC
EXTERN _GetEnvironmentStrings@0:PROC
EXTERN __imp__GetEnvironmentStringsW@0:PROC
EXTERN _GetEnvironmentStringsW@0:PROC
EXTERN __imp__GetEnvironmentVariableA@12:PROC
EXTERN _GetEnvironmentVariableA@12:PROC
EXTERN __imp__GetFileSize@8:PROC
EXTERN _GetFileSize@8:PROC
EXTERN __imp__GetFileTime@16:PROC
EXTERN _GetFileTime@16:PROC
EXTERN __imp__GetFileType@4:PROC
EXTERN _GetFileType@4:PROC
EXTERN __imp__GetKeyboardState@4:PROC
EXTERN _GetKeyboardState@4:PROC
EXTERN __imp__GetLastError@0:PROC
EXTERN _GetLastError@0:PROC
EXTERN __imp__GetLogicalDrives@0:PROC
EXTERN _GetLogicalDrives@0:PROC
EXTERN __imp__GetMenu@4:PROC
EXTERN _GetMenu@4:PROC
EXTERN __imp__GetModuleFileNameA@12:PROC
EXTERN _GetModuleFileNameA@12:PROC
EXTERN __imp__GetModuleHandleA@4:PROC
EXTERN _GetModuleHandleA@4:PROC
EXTERN __imp__GetOEMCP@0:PROC
EXTERN _GetOEMCP@0:PROC
EXTERN __imp__GetParent@4:PROC
EXTERN _GetParent@4:PROC
EXTERN __imp__GetProcAddress@8:PROC
EXTERN _GetProcAddress@8:PROC
EXTERN __imp__GetStartupInfoA@4:PROC
EXTERN _GetStartupInfoA@4:PROC
EXTERN __imp__GetStdHandle@4:PROC
EXTERN _GetStdHandle@4:PROC
EXTERN __imp__GetStockObject@4:PROC
EXTERN _GetStockObject@4:PROC
EXTERN __imp__GetStringTypeA@20:PROC
EXTERN _GetStringTypeA@20:PROC
EXTERN __imp__GetStringTypeW@16:PROC
EXTERN _GetStringTypeW@16:PROC
EXTERN __imp__GetSystemMetrics@4:PROC
EXTERN _GetSystemMetrics@4:PROC
EXTERN __imp__GetSystemTimeAsFileTime@4:PROC
EXTERN _GetSystemTimeAsFileTime@4:PROC
EXTERN __imp__GetTextExtentPoint32A@16:PROC
EXTERN _GetTextExtentPoint32A@16:PROC
EXTERN __imp__GetVersion@0:PROC
EXTERN _GetVersion@0:PROC
EXTERN __imp__GetVersionExA@4:PROC
EXTERN _GetVersionExA@4:PROC
EXTERN __imp__GetWindowLongA@8:PROC
EXTERN _GetWindowLongA@8:PROC
EXTERN __imp__GetWindowRect@8:PROC
EXTERN _GetWindowRect@8:PROC
EXTERN __imp__GlobalAlloc@8:PROC
EXTERN _GlobalAlloc@8:PROC
EXTERN __imp__GlobalFree@4:PROC
EXTERN _GlobalFree@4:PROC
EXTERN __imp__GlobalHandle@4:PROC
EXTERN _GlobalHandle@4:PROC
EXTERN __imp__GlobalLock@4:PROC
EXTERN _GlobalLock@4:PROC
EXTERN __imp__GlobalUnlock@4:PROC
EXTERN _GlobalUnlock@4:PROC
EXTERN __imp__HeapAlloc@12:PROC
EXTERN _HeapAlloc@12:PROC
EXTERN __imp__HeapCreate@12:PROC
EXTERN _HeapCreate@12:PROC
EXTERN __imp__HeapDestroy@4:PROC
EXTERN _HeapDestroy@4:PROC
EXTERN __imp__HeapFree@12:PROC
EXTERN _HeapFree@12:PROC
EXTERN __imp__HeapReAlloc@16:PROC
EXTERN _HeapReAlloc@16:PROC
EXTERN __imp__HeapSize@12:PROC
EXTERN _HeapSize@12:PROC
EXTERN __imp__ImmAssociateContext@8:PROC
EXTERN _ImmAssociateContext@8:PROC
EXTERN __imp__InvalidateRect@12:PROC
EXTERN _InvalidateRect@12:PROC
EXTERN __imp__IsBadCodePtr@4:PROC
EXTERN _IsBadCodePtr@4:PROC
EXTERN __imp__IsBadReadPtr@8:PROC
EXTERN _IsBadReadPtr@8:PROC
EXTERN __imp__IsBadWritePtr@8:PROC
EXTERN _IsBadWritePtr@8:PROC
EXTERN __imp__IsIconic@4:PROC
EXTERN _IsIconic@4:PROC
EXTERN __imp__LCMapStringA@24:PROC
EXTERN _LCMapStringA@24:PROC
EXTERN __imp__LCMapStringW@24:PROC
EXTERN _LCMapStringW@24:PROC
EXTERN __imp__LoadCursorA@8:PROC
EXTERN _LoadCursorA@8:PROC
EXTERN __imp__LoadIconA@8:PROC
EXTERN _LoadIconA@8:PROC
EXTERN __imp__LoadLibraryA@4:PROC
EXTERN _LoadLibraryA@4:PROC
EXTERN __imp__LoadResource@8:PROC
EXTERN _LoadResource@8:PROC
EXTERN __imp__LockResource@4:PROC
EXTERN _LockResource@4:PROC
EXTERN __imp__MessageBoxA@16:PROC
EXTERN _MessageBoxA@16:PROC
EXTERN __imp__MulDiv@12:PROC
EXTERN _MulDiv@12:PROC
EXTERN __imp__MultiByteToWideChar@24:PROC
EXTERN _MultiByteToWideChar@24:PROC
EXTERN __imp__OpenMutexA@12:PROC
EXTERN _OpenMutexA@12:PROC
EXTERN __imp__PeekMessageA@20:PROC
EXTERN _PeekMessageA@20:PROC
EXTERN __imp__PostQuitMessage@4:PROC
EXTERN _PostQuitMessage@4:PROC
EXTERN __imp__RaiseException@16:PROC
EXTERN _RaiseException@16:PROC
EXTERN __imp__ReadFile@20:PROC
EXTERN _ReadFile@20:PROC
EXTERN __imp__RegCloseKey@4:PROC
EXTERN _RegCloseKey@4:PROC
EXTERN __imp__RegCreateKeyExA@36:PROC
EXTERN _RegCreateKeyExA@36:PROC
EXTERN __imp__RegQueryValueExA@24:PROC
EXTERN _RegQueryValueExA@24:PROC
EXTERN __imp__RegSetValueExA@24:PROC
EXTERN _RegSetValueExA@24:PROC
EXTERN __imp__RegisterClassA@4:PROC
EXTERN _RegisterClassA@4:PROC
EXTERN __imp__ReleaseDC@8:PROC
EXTERN _ReleaseDC@8:PROC
EXTERN __imp__RtlUnwind@16:PROC
EXTERN _RtlUnwind@16:PROC
EXTERN __imp__SelectObject@8:PROC
EXTERN _SelectObject@8:PROC
EXTERN __imp__SetBkMode@8:PROC
EXTERN _SetBkMode@8:PROC
EXTERN __imp__SetEndOfFile@4:PROC
EXTERN _SetEndOfFile@4:PROC
EXTERN __imp__SetErrorMode@4:PROC
EXTERN _SetErrorMode@4:PROC
EXTERN __imp__SetFilePointer@16:PROC
EXTERN _SetFilePointer@16:PROC
EXTERN __imp__SetFocus@4:PROC
EXTERN _SetFocus@4:PROC
EXTERN __imp__SetForegroundWindow@4:PROC
EXTERN _SetForegroundWindow@4:PROC
EXTERN __imp__SetHandleCount@4:PROC
EXTERN _SetHandleCount@4:PROC
EXTERN __imp__SetRect@20:PROC
EXTERN _SetRect@20:PROC
EXTERN __imp__SetStdHandle@8:PROC
EXTERN _SetStdHandle@8:PROC
EXTERN __imp__SetTextColor@8:PROC
EXTERN _SetTextColor@8:PROC
EXTERN __imp__SetUnhandledExceptionFilter@4:PROC
EXTERN _SetUnhandledExceptionFilter@4:PROC
EXTERN __imp__SetWindowLongA@12:PROC
EXTERN _SetWindowLongA@12:PROC
EXTERN __imp__SetWindowPos@28:PROC
EXTERN _SetWindowPos@28:PROC
EXTERN __imp__ShowCursor@4:PROC
EXTERN _ShowCursor@4:PROC
EXTERN __imp__ShowWindow@8:PROC
EXTERN _ShowWindow@8:PROC
EXTERN __imp__SystemParametersInfoA@16:PROC
EXTERN _SystemParametersInfoA@16:PROC
EXTERN __imp__TerminateProcess@8:PROC
EXTERN _TerminateProcess@8:PROC
EXTERN __imp__TextOutA@20:PROC
EXTERN _TextOutA@20:PROC
EXTERN __imp__TranslateMessage@4:PROC
EXTERN _TranslateMessage@4:PROC
EXTERN __imp__UnhandledExceptionFilter@4:PROC
EXTERN _UnhandledExceptionFilter@4:PROC
EXTERN __imp__UpdateWindow@4:PROC
EXTERN _UpdateWindow@4:PROC
EXTERN __imp__VirtualAlloc@16:PROC
EXTERN _VirtualAlloc@16:PROC
EXTERN __imp__VirtualFree@12:PROC
EXTERN _VirtualFree@12:PROC
EXTERN __imp__WideCharToMultiByte@32:PROC
EXTERN _WideCharToMultiByte@32:PROC
EXTERN __imp__WriteFile@20:PROC
EXTERN _WriteFile@20:PROC
EXTERN __imp__acmDriverClose@8:PROC
EXTERN _acmDriverClose@8:PROC
EXTERN __imp__acmDriverDetailsA@12:PROC
EXTERN _acmDriverDetailsA@12:PROC
EXTERN __imp__acmDriverEnum@12:PROC
EXTERN _acmDriverEnum@12:PROC
EXTERN __imp__acmDriverOpen@12:PROC
EXTERN _acmDriverOpen@12:PROC
EXTERN __imp__acmFormatSuggest@20:PROC
EXTERN _acmFormatSuggest@20:PROC
EXTERN __imp__acmMetrics@12:PROC
EXTERN _acmMetrics@12:PROC
EXTERN __imp__acmStreamClose@8:PROC
EXTERN _acmStreamClose@8:PROC
EXTERN __imp__acmStreamConvert@12:PROC
EXTERN _acmStreamConvert@12:PROC
EXTERN __imp__acmStreamOpen@32:PROC
EXTERN _acmStreamOpen@32:PROC
EXTERN __imp__acmStreamPrepareHeader@12:PROC
EXTERN _acmStreamPrepareHeader@12:PROC
EXTERN __imp__acmStreamSize@16:PROC
EXTERN _acmStreamSize@16:PROC
EXTERN __imp__acmStreamUnprepareHeader@12:PROC
EXTERN _acmStreamUnprepareHeader@12:PROC
EXTERN __imp__joyGetDevCapsA@12:PROC
EXTERN _joyGetDevCapsA@12:PROC
EXTERN __imp__joyGetNumDevs@0:PROC
EXTERN _joyGetNumDevs@0:PROC
EXTERN __imp__joyGetPosEx@8:PROC
EXTERN _joyGetPosEx@8:PROC
EXTERN __imp__mmioAscend@12:PROC
EXTERN _mmioAscend@12:PROC
EXTERN __imp__mmioClose@8:PROC
EXTERN _mmioClose@8:PROC
EXTERN __imp__mmioDescend@16:PROC
EXTERN _mmioDescend@16:PROC
EXTERN __imp__mmioOpenA@12:PROC
EXTERN _mmioOpenA@12:PROC
EXTERN __imp__mmioRead@12:PROC
EXTERN _mmioRead@12:PROC
EXTERN __imp__timeGetTime@0:PROC
EXTERN _timeGetTime@0:PROC
; WARNING: no entry found for _wsprintfA@Num
EXTERN __imp__wsprintfA:PROC
EXTERN _wsprintfA:PROC

EXTERN __imp__DirectDrawCreate@12:PROC
EXTERN _DirectDrawCreate@12:PROC
EXTERN __imp__DirectSoundCreate@12:PROC
EXTERN _DirectSoundCreate@12:PROC

__imp__AdjustWindowRect TEXTEQU <__imp__AdjustWindowRect@12>
_AdjustWindowRect TEXTEQU <_AdjustWindowRect@12>
__imp__AdjustWindowRectEx TEXTEQU <__imp__AdjustWindowRectEx@16>
_AdjustWindowRectEx TEXTEQU <_AdjustWindowRectEx@16>
__imp__ClientToScreen TEXTEQU <__imp__ClientToScreen@8>
_ClientToScreen TEXTEQU <_ClientToScreen@8>
__imp__CloseHandle TEXTEQU <__imp__CloseHandle@4>
_CloseHandle TEXTEQU <_CloseHandle@4>
__imp__CoCreateInstance TEXTEQU <__imp__CoCreateInstance@20>
_CoCreateInstance TEXTEQU <_CoCreateInstance@20>
__imp__CoInitialize TEXTEQU <__imp__CoInitialize@4>
_CoInitialize TEXTEQU <_CoInitialize@4>
__imp__CoUninitialize TEXTEQU <__imp__CoUninitialize@0>
_CoUninitialize TEXTEQU <_CoUninitialize@0>
__imp__CreateDirectoryA TEXTEQU <__imp__CreateDirectoryA@8>
_CreateDirectoryA TEXTEQU <_CreateDirectoryA@8>
__imp__CreateFileA TEXTEQU <__imp__CreateFileA@28>
_CreateFileA TEXTEQU <_CreateFileA@28>
__imp__CreateFontA TEXTEQU <__imp__CreateFontA@56>
_CreateFontA TEXTEQU <_CreateFontA@56>
__imp__CreateMutexA TEXTEQU <__imp__CreateMutexA@12>
_CreateMutexA TEXTEQU <_CreateMutexA@12>
__imp__CreateWindowExA TEXTEQU <__imp__CreateWindowExA@48>
_CreateWindowExA TEXTEQU <_CreateWindowExA@48>
__imp__DefWindowProcA TEXTEQU <__imp__DefWindowProcA@16>
_DefWindowProcA TEXTEQU <_DefWindowProcA@16>
__imp__DeleteFileA TEXTEQU <__imp__DeleteFileA@4>
_DeleteFileA TEXTEQU <_DeleteFileA@4>
__imp__DeleteObject TEXTEQU <__imp__DeleteObject@4>
_DeleteObject TEXTEQU <_DeleteObject@4>
__imp__DestroyWindow TEXTEQU <__imp__DestroyWindow@4>
_DestroyWindow TEXTEQU <_DestroyWindow@4>
__imp__DialogBoxParamA TEXTEQU <__imp__DialogBoxParamA@20>
_DialogBoxParamA TEXTEQU <_DialogBoxParamA@20>
__imp__DirectDrawCreate TEXTEQU <__imp__DirectDrawCreate@12>
_DirectDrawCreate TEXTEQU <_DirectDrawCreate@12>
__imp__DirectDrawEnumerateA TEXTEQU <__imp__DirectDrawEnumerateA@8>
_DirectDrawEnumerateA TEXTEQU <_DirectDrawEnumerateA@8>
__imp__DispatchMessageA TEXTEQU <__imp__DispatchMessageA@4>
_DispatchMessageA TEXTEQU <_DispatchMessageA@4>
__imp__EndDialog TEXTEQU <__imp__EndDialog@8>
_EndDialog TEXTEQU <_EndDialog@8>
__imp__ExitProcess TEXTEQU <__imp__ExitProcess@4>
_ExitProcess TEXTEQU <_ExitProcess@4>
__imp__ExtTextOutA TEXTEQU <__imp__ExtTextOutA@32>
_ExtTextOutA TEXTEQU <_ExtTextOutA@32>
__imp__FindClose TEXTEQU <__imp__FindClose@4>
_FindClose TEXTEQU <_FindClose@4>
__imp__FindFirstFileA TEXTEQU <__imp__FindFirstFileA@8>
_FindFirstFileA TEXTEQU <_FindFirstFileA@8>
__imp__FindNextFileA TEXTEQU <__imp__FindNextFileA@8>
_FindNextFileA TEXTEQU <_FindNextFileA@8>
__imp__FindResourceA TEXTEQU <__imp__FindResourceA@12>
_FindResourceA TEXTEQU <_FindResourceA@12>
__imp__FlushFileBuffers TEXTEQU <__imp__FlushFileBuffers@4>
_FlushFileBuffers TEXTEQU <_FlushFileBuffers@4>
__imp__FreeEnvironmentStringsA TEXTEQU <__imp__FreeEnvironmentStringsA@4>
_FreeEnvironmentStringsA TEXTEQU <_FreeEnvironmentStringsA@4>
__imp__FreeEnvironmentStringsW TEXTEQU <__imp__FreeEnvironmentStringsW@4>
_FreeEnvironmentStringsW TEXTEQU <_FreeEnvironmentStringsW@4>
__imp__GetACP TEXTEQU <__imp__GetACP@0>
_GetACP TEXTEQU <_GetACP@0>
__imp__GetCPInfo TEXTEQU <__imp__GetCPInfo@8>
_GetCPInfo TEXTEQU <_GetCPInfo@8>
__imp__GetCommandLineA TEXTEQU <__imp__GetCommandLineA@0>
_GetCommandLineA TEXTEQU <_GetCommandLineA@0>
__imp__GetCurrentProcess TEXTEQU <__imp__GetCurrentProcess@0>
_GetCurrentProcess TEXTEQU <_GetCurrentProcess@0>
__imp__GetDC TEXTEQU <__imp__GetDC@4>
_GetDC TEXTEQU <_GetDC@4>
__imp__GetDeviceCaps TEXTEQU <__imp__GetDeviceCaps@8>
_GetDeviceCaps TEXTEQU <_GetDeviceCaps@8>
__imp__GetDlgItem TEXTEQU <__imp__GetDlgItem@8>
_GetDlgItem TEXTEQU <_GetDlgItem@8>
__imp__GetEnvironmentStrings TEXTEQU <__imp__GetEnvironmentStrings@0>
_GetEnvironmentStrings TEXTEQU <_GetEnvironmentStrings@0>
__imp__GetEnvironmentStringsW TEXTEQU <__imp__GetEnvironmentStringsW@0>
_GetEnvironmentStringsW TEXTEQU <_GetEnvironmentStringsW@0>
__imp__GetEnvironmentVariableA TEXTEQU <__imp__GetEnvironmentVariableA@12>
_GetEnvironmentVariableA TEXTEQU <_GetEnvironmentVariableA@12>
__imp__GetFileSize TEXTEQU <__imp__GetFileSize@8>
_GetFileSize TEXTEQU <_GetFileSize@8>
__imp__GetFileTime TEXTEQU <__imp__GetFileTime@16>
_GetFileTime TEXTEQU <_GetFileTime@16>
__imp__GetFileType TEXTEQU <__imp__GetFileType@4>
_GetFileType TEXTEQU <_GetFileType@4>
__imp__GetKeyboardState TEXTEQU <__imp__GetKeyboardState@4>
_GetKeyboardState TEXTEQU <_GetKeyboardState@4>
__imp__GetLastError TEXTEQU <__imp__GetLastError@0>
_GetLastError TEXTEQU <_GetLastError@0>
__imp__GetLogicalDrives TEXTEQU <__imp__GetLogicalDrives@0>
_GetLogicalDrives TEXTEQU <_GetLogicalDrives@0>
__imp__GetMenu TEXTEQU <__imp__GetMenu@4>
_GetMenu TEXTEQU <_GetMenu@4>
__imp__GetModuleFileNameA TEXTEQU <__imp__GetModuleFileNameA@12>
_GetModuleFileNameA TEXTEQU <_GetModuleFileNameA@12>
__imp__GetModuleHandleA TEXTEQU <__imp__GetModuleHandleA@4>
_GetModuleHandleA TEXTEQU <_GetModuleHandleA@4>
__imp__GetOEMCP TEXTEQU <__imp__GetOEMCP@0>
_GetOEMCP TEXTEQU <_GetOEMCP@0>
__imp__GetParent TEXTEQU <__imp__GetParent@4>
_GetParent TEXTEQU <_GetParent@4>
__imp__GetProcAddress TEXTEQU <__imp__GetProcAddress@8>
_GetProcAddress TEXTEQU <_GetProcAddress@8>
__imp__GetStartupInfoA TEXTEQU <__imp__GetStartupInfoA@4>
_GetStartupInfoA TEXTEQU <_GetStartupInfoA@4>
__imp__GetStdHandle TEXTEQU <__imp__GetStdHandle@4>
_GetStdHandle TEXTEQU <_GetStdHandle@4>
__imp__GetStockObject TEXTEQU <__imp__GetStockObject@4>
_GetStockObject TEXTEQU <_GetStockObject@4>
__imp__GetStringTypeA TEXTEQU <__imp__GetStringTypeA@20>
_GetStringTypeA TEXTEQU <_GetStringTypeA@20>
__imp__GetStringTypeW TEXTEQU <__imp__GetStringTypeW@16>
_GetStringTypeW TEXTEQU <_GetStringTypeW@16>
__imp__GetSystemMetrics TEXTEQU <__imp__GetSystemMetrics@4>
_GetSystemMetrics TEXTEQU <_GetSystemMetrics@4>
__imp__GetSystemTimeAsFileTime TEXTEQU <__imp__GetSystemTimeAsFileTime@4>
_GetSystemTimeAsFileTime TEXTEQU <_GetSystemTimeAsFileTime@4>
__imp__GetTextExtentPoint32A TEXTEQU <__imp__GetTextExtentPoint32A@16>
_GetTextExtentPoint32A TEXTEQU <_GetTextExtentPoint32A@16>
__imp__GetVersion TEXTEQU <__imp__GetVersion@0>
_GetVersion TEXTEQU <_GetVersion@0>
__imp__GetVersionExA TEXTEQU <__imp__GetVersionExA@4>
_GetVersionExA TEXTEQU <_GetVersionExA@4>
__imp__GetWindowLongA TEXTEQU <__imp__GetWindowLongA@8>
_GetWindowLongA TEXTEQU <_GetWindowLongA@8>
__imp__GetWindowRect TEXTEQU <__imp__GetWindowRect@8>
_GetWindowRect TEXTEQU <_GetWindowRect@8>
__imp__GlobalAlloc TEXTEQU <__imp__GlobalAlloc@8>
_GlobalAlloc TEXTEQU <_GlobalAlloc@8>
__imp__GlobalFree TEXTEQU <__imp__GlobalFree@4>
_GlobalFree TEXTEQU <_GlobalFree@4>
__imp__GlobalHandle TEXTEQU <__imp__GlobalHandle@4>
_GlobalHandle TEXTEQU <_GlobalHandle@4>
__imp__GlobalLock TEXTEQU <__imp__GlobalLock@4>
_GlobalLock TEXTEQU <_GlobalLock@4>
__imp__GlobalUnlock TEXTEQU <__imp__GlobalUnlock@4>
_GlobalUnlock TEXTEQU <_GlobalUnlock@4>
__imp__HeapAlloc TEXTEQU <__imp__HeapAlloc@12>
_HeapAlloc TEXTEQU <_HeapAlloc@12>
__imp__HeapCreate TEXTEQU <__imp__HeapCreate@12>
_HeapCreate TEXTEQU <_HeapCreate@12>
__imp__HeapDestroy TEXTEQU <__imp__HeapDestroy@4>
_HeapDestroy TEXTEQU <_HeapDestroy@4>
__imp__HeapFree TEXTEQU <__imp__HeapFree@12>
_HeapFree TEXTEQU <_HeapFree@12>
__imp__HeapReAlloc TEXTEQU <__imp__HeapReAlloc@16>
_HeapReAlloc TEXTEQU <_HeapReAlloc@16>
__imp__HeapSize TEXTEQU <__imp__HeapSize@12>
_HeapSize TEXTEQU <_HeapSize@12>
__imp__ImmAssociateContext TEXTEQU <__imp__ImmAssociateContext@8>
_ImmAssociateContext TEXTEQU <_ImmAssociateContext@8>
__imp__InvalidateRect TEXTEQU <__imp__InvalidateRect@12>
_InvalidateRect TEXTEQU <_InvalidateRect@12>
__imp__IsBadCodePtr TEXTEQU <__imp__IsBadCodePtr@4>
_IsBadCodePtr TEXTEQU <_IsBadCodePtr@4>
__imp__IsBadReadPtr TEXTEQU <__imp__IsBadReadPtr@8>
_IsBadReadPtr TEXTEQU <_IsBadReadPtr@8>
__imp__IsBadWritePtr TEXTEQU <__imp__IsBadWritePtr@8>
_IsBadWritePtr TEXTEQU <_IsBadWritePtr@8>
__imp__IsIconic TEXTEQU <__imp__IsIconic@4>
_IsIconic TEXTEQU <_IsIconic@4>
__imp__LCMapStringA TEXTEQU <__imp__LCMapStringA@24>
_LCMapStringA TEXTEQU <_LCMapStringA@24>
__imp__LCMapStringW TEXTEQU <__imp__LCMapStringW@24>
_LCMapStringW TEXTEQU <_LCMapStringW@24>
__imp__LoadCursorA TEXTEQU <__imp__LoadCursorA@8>
_LoadCursorA TEXTEQU <_LoadCursorA@8>
__imp__LoadIconA TEXTEQU <__imp__LoadIconA@8>
_LoadIconA TEXTEQU <_LoadIconA@8>
__imp__LoadLibraryA TEXTEQU <__imp__LoadLibraryA@4>
_LoadLibraryA TEXTEQU <_LoadLibraryA@4>
__imp__LoadResource TEXTEQU <__imp__LoadResource@8>
_LoadResource TEXTEQU <_LoadResource@8>
__imp__LockResource TEXTEQU <__imp__LockResource@4>
_LockResource TEXTEQU <_LockResource@4>
__imp__MessageBoxA TEXTEQU <__imp__MessageBoxA@16>
_MessageBoxA TEXTEQU <_MessageBoxA@16>
__imp__MulDiv TEXTEQU <__imp__MulDiv@12>
_MulDiv TEXTEQU <_MulDiv@12>
__imp__MultiByteToWideChar TEXTEQU <__imp__MultiByteToWideChar@24>
_MultiByteToWideChar TEXTEQU <_MultiByteToWideChar@24>
__imp__OpenMutexA TEXTEQU <__imp__OpenMutexA@12>
_OpenMutexA TEXTEQU <_OpenMutexA@12>
__imp__PeekMessageA TEXTEQU <__imp__PeekMessageA@20>
_PeekMessageA TEXTEQU <_PeekMessageA@20>
__imp__PostQuitMessage TEXTEQU <__imp__PostQuitMessage@4>
_PostQuitMessage TEXTEQU <_PostQuitMessage@4>
__imp__RaiseException TEXTEQU <__imp__RaiseException@16>
_RaiseException TEXTEQU <_RaiseException@16>
__imp__ReadFile TEXTEQU <__imp__ReadFile@20>
_ReadFile TEXTEQU <_ReadFile@20>
__imp__RegCloseKey TEXTEQU <__imp__RegCloseKey@4>
_RegCloseKey TEXTEQU <_RegCloseKey@4>
__imp__RegCreateKeyExA TEXTEQU <__imp__RegCreateKeyExA@36>
_RegCreateKeyExA TEXTEQU <_RegCreateKeyExA@36>
__imp__RegQueryValueExA TEXTEQU <__imp__RegQueryValueExA@24>
_RegQueryValueExA TEXTEQU <_RegQueryValueExA@24>
__imp__RegSetValueExA TEXTEQU <__imp__RegSetValueExA@24>
_RegSetValueExA TEXTEQU <_RegSetValueExA@24>
__imp__RegisterClassA TEXTEQU <__imp__RegisterClassA@4>
_RegisterClassA TEXTEQU <_RegisterClassA@4>
__imp__ReleaseDC TEXTEQU <__imp__ReleaseDC@8>
_ReleaseDC TEXTEQU <_ReleaseDC@8>
__imp__RtlUnwind TEXTEQU <__imp__RtlUnwind@16>
_RtlUnwind TEXTEQU <_RtlUnwind@16>
__imp__SelectObject TEXTEQU <__imp__SelectObject@8>
_SelectObject TEXTEQU <_SelectObject@8>
__imp__SetBkMode TEXTEQU <__imp__SetBkMode@8>
_SetBkMode TEXTEQU <_SetBkMode@8>
__imp__SetEndOfFile TEXTEQU <__imp__SetEndOfFile@4>
_SetEndOfFile TEXTEQU <_SetEndOfFile@4>
__imp__SetErrorMode TEXTEQU <__imp__SetErrorMode@4>
_SetErrorMode TEXTEQU <_SetErrorMode@4>
__imp__SetFilePointer TEXTEQU <__imp__SetFilePointer@16>
_SetFilePointer TEXTEQU <_SetFilePointer@16>
__imp__SetFocus TEXTEQU <__imp__SetFocus@4>
_SetFocus TEXTEQU <_SetFocus@4>
__imp__SetForegroundWindow TEXTEQU <__imp__SetForegroundWindow@4>
_SetForegroundWindow TEXTEQU <_SetForegroundWindow@4>
__imp__SetHandleCount TEXTEQU <__imp__SetHandleCount@4>
_SetHandleCount TEXTEQU <_SetHandleCount@4>
__imp__SetRect TEXTEQU <__imp__SetRect@20>
_SetRect TEXTEQU <_SetRect@20>
__imp__SetStdHandle TEXTEQU <__imp__SetStdHandle@8>
_SetStdHandle TEXTEQU <_SetStdHandle@8>
__imp__SetTextColor TEXTEQU <__imp__SetTextColor@8>
_SetTextColor TEXTEQU <_SetTextColor@8>
__imp__SetUnhandledExceptionFilter TEXTEQU <__imp__SetUnhandledExceptionFilter@4>
_SetUnhandledExceptionFilter TEXTEQU <_SetUnhandledExceptionFilter@4>
__imp__SetWindowLongA TEXTEQU <__imp__SetWindowLongA@12>
_SetWindowLongA TEXTEQU <_SetWindowLongA@12>
__imp__SetWindowPos TEXTEQU <__imp__SetWindowPos@28>
_SetWindowPos TEXTEQU <_SetWindowPos@28>
__imp__ShowCursor TEXTEQU <__imp__ShowCursor@4>
_ShowCursor TEXTEQU <_ShowCursor@4>
__imp__ShowWindow TEXTEQU <__imp__ShowWindow@8>
_ShowWindow TEXTEQU <_ShowWindow@8>
__imp__SystemParametersInfoA TEXTEQU <__imp__SystemParametersInfoA@16>
_SystemParametersInfoA TEXTEQU <_SystemParametersInfoA@16>
__imp__TerminateProcess TEXTEQU <__imp__TerminateProcess@8>
_TerminateProcess TEXTEQU <_TerminateProcess@8>
__imp__TextOutA TEXTEQU <__imp__TextOutA@20>
_TextOutA TEXTEQU <_TextOutA@20>
__imp__TranslateMessage TEXTEQU <__imp__TranslateMessage@4>
_TranslateMessage TEXTEQU <_TranslateMessage@4>
__imp__UnhandledExceptionFilter TEXTEQU <__imp__UnhandledExceptionFilter@4>
_UnhandledExceptionFilter TEXTEQU <_UnhandledExceptionFilter@4>
__imp__UpdateWindow TEXTEQU <__imp__UpdateWindow@4>
_UpdateWindow TEXTEQU <_UpdateWindow@4>
__imp__VirtualAlloc TEXTEQU <__imp__VirtualAlloc@16>
_VirtualAlloc TEXTEQU <_VirtualAlloc@16>
__imp__VirtualFree TEXTEQU <__imp__VirtualFree@12>
_VirtualFree TEXTEQU <_VirtualFree@12>
__imp__WideCharToMultiByte TEXTEQU <__imp__WideCharToMultiByte@32>
_WideCharToMultiByte TEXTEQU <_WideCharToMultiByte@32>
__imp__WriteFile TEXTEQU <__imp__WriteFile@20>
_WriteFile TEXTEQU <_WriteFile@20>
__imp__acmDriverClose TEXTEQU <__imp__acmDriverClose@8>
_acmDriverClose TEXTEQU <_acmDriverClose@8>
__imp__acmDriverDetailsA TEXTEQU <__imp__acmDriverDetailsA@12>
_acmDriverDetailsA TEXTEQU <_acmDriverDetailsA@12>
__imp__acmDriverEnum TEXTEQU <__imp__acmDriverEnum@12>
_acmDriverEnum TEXTEQU <_acmDriverEnum@12>
__imp__acmDriverOpen TEXTEQU <__imp__acmDriverOpen@12>
_acmDriverOpen TEXTEQU <_acmDriverOpen@12>
__imp__acmFormatSuggest TEXTEQU <__imp__acmFormatSuggest@20>
_acmFormatSuggest TEXTEQU <_acmFormatSuggest@20>
__imp__acmMetrics TEXTEQU <__imp__acmMetrics@12>
_acmMetrics TEXTEQU <_acmMetrics@12>
__imp__acmStreamClose TEXTEQU <__imp__acmStreamClose@8>
_acmStreamClose TEXTEQU <_acmStreamClose@8>
__imp__acmStreamConvert TEXTEQU <__imp__acmStreamConvert@12>
_acmStreamConvert TEXTEQU <_acmStreamConvert@12>
__imp__acmStreamOpen TEXTEQU <__imp__acmStreamOpen@32>
_acmStreamOpen TEXTEQU <_acmStreamOpen@32>
__imp__acmStreamPrepareHeader TEXTEQU <__imp__acmStreamPrepareHeader@12>
_acmStreamPrepareHeader TEXTEQU <_acmStreamPrepareHeader@12>
__imp__acmStreamSize TEXTEQU <__imp__acmStreamSize@16>
_acmStreamSize TEXTEQU <_acmStreamSize@16>
__imp__acmStreamUnprepareHeader TEXTEQU <__imp__acmStreamUnprepareHeader@12>
_acmStreamUnprepareHeader TEXTEQU <_acmStreamUnprepareHeader@12>
__imp__joyGetDevCapsA TEXTEQU <__imp__joyGetDevCapsA@12>
_joyGetDevCapsA TEXTEQU <_joyGetDevCapsA@12>
__imp__joyGetNumDevs TEXTEQU <__imp__joyGetNumDevs@0>
_joyGetNumDevs TEXTEQU <_joyGetNumDevs@0>
__imp__joyGetPosEx TEXTEQU <__imp__joyGetPosEx@8>
_joyGetPosEx TEXTEQU <_joyGetPosEx@8>
__imp__mmioAscend TEXTEQU <__imp__mmioAscend@12>
_mmioAscend TEXTEQU <_mmioAscend@12>
__imp__mmioClose TEXTEQU <__imp__mmioClose@8>
_mmioClose TEXTEQU <_mmioClose@8>
__imp__mmioDescend TEXTEQU <__imp__mmioDescend@16>
_mmioDescend TEXTEQU <_mmioDescend@16>
__imp__mmioOpenA TEXTEQU <__imp__mmioOpenA@12>
_mmioOpenA TEXTEQU <_mmioOpenA@12>
__imp__mmioRead TEXTEQU <__imp__mmioRead@12>
_mmioRead TEXTEQU <_mmioRead@12>
__imp__timeGetTime TEXTEQU <__imp__timeGetTime@0>
_timeGetTime TEXTEQU <_timeGetTime@0>
