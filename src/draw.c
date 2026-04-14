// Disassembled by yanming.J
// SPDX-License-Identifier: MIT
// https://github.com/yanmingsohu/
#include <windows.h>
#include <ddraw.h>
#include "imports.h"


int __stdcall find3ddev(GUID *guid, LPSTR lpDesc, 
  LPSTR lpName, IDirectDraw **ppOutDirectDraw)
{
    printf("   > InitDirectDraw callback %s %s", lpDesc, lpName);
    IDirectDraw *pDD = NULL;

    if (guid == NULL)
        return DDENUMRET_OK;

    // DirectDrawCreate(pDirectDraw, &pDD, NULL)
    // 第一参数作为 GUID* 传入
    if (DirectDrawCreate(guid, &pDD, NULL) != DD_OK)
        return DDENUMRET_OK;

    // 两个 DDSURFACEDESC 结构体，各380字节，清零
    DDCAPS ddDriverCaps;
    DDCAPS ddHELCaps;
    memset(&ddDriverCaps, 0, sizeof(DDCAPS)); // 380 bytes
    memset(&ddHELCaps,    0, sizeof(DDCAPS)); // 380 bytes
    ddDriverCaps.dwSize = sizeof(DDCAPS);     // = 380
    ddHELCaps.dwSize    = sizeof(DDCAPS);     // = 380

    // 调用 IDirectDraw::GetDisplayMode(vtable[44/4] = vtable[11])
    // vtable offset 44 = 第11个函数指针 = GetDisplayMode
    HRESULT hr = pDD->lpVtbl->GetCaps(pDD,  &ddDriverCaps, &ddHELCaps);

    if (hr != DD_OK)
        goto cleanup;

    // 检查 ddsd1 首字节的 bit0（dwFlags & 1）
    // dwCaps2 ? dwCaps ?
    if (!(ddDriverCaps.dwCaps2 & DDCAPS_3D))
        goto cleanup;

    *ppOutDirectDraw = pDD;
    return DDENUMRET_CANCEL;

cleanup:
    // 调用 IDirectDraw::Release（vtable offset 8 = vtable[2]）
    pDD->lpVtbl->Release(pDD);
    return DDENUMRET_OK;
}


int __cdecl InitDirectDrawDisplay(
    GUID *pGUID, IDirectDraw **ppOutDD, int *pIsDefault)
{
    printf("InitDirectDrawDisplay GUID:%x\n", pGUID);
    IDirectDraw *pDD = NULL;
    if (pGUID != NULL) {
        puts(" - Enumerate");
        // 枚举与指定GUID匹配的DirectDraw设备
        // 回调InitDirectDraw会在找到时调用DirectDrawCreate并写入pDD
        HRESULT hr = DirectDrawEnumerateA(find3ddev, &pDD);
        if (hr != DD_OK) {
            puts(" ! Direct3D::MDDCreateDirect3D->DirectDrawEnumerateA fail");
            return hr;
        }
        if (pDD != NULL) {
            puts(" - ok");
            // 枚举成功找到设备
            *pIsDefault = 0;
            *ppOutDD = pDD;
            return DD_OK;
        }
    }
    // 直接创建默认DirectDraw设备（GUID=NULL）
    HRESULT hr = DirectDrawCreate(NULL, &pDD, NULL);
    if (hr != DD_OK) {
        puts(" ! Direct3D::MDDCreateDirect3D->DirectDrawCreate fail");
        return hr;
    }
    printf(" - default %x\n", pDD);
    *pIsDefault = 1;
    *ppOutDD = pDD;
    return DD_OK;
}