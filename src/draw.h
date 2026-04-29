// Disassembled by yanming.J
// SPDX-License-Identifier: MIT
// https://github.com/yanmingsohu/
#include <ddraw.h>
#include <d3d.h>


typedef struct {
    // === 0x0000: 基础渲染控制区域 ===
    DWORD           unknown_0;          // +0x00, 未知标志
    BYTE            unknown_1;          // +0x04, 未知标志
    BYTE            unknown_2;         // +0x05, 未知标志
    WORD            padding_0;          // +0x06, 对齐填充
    DWORD           buffer_index;      // +0x08, 缓冲区索引 (双缓冲切换)
    DWORD           unknown_3;         // +0x0C, 未知
    DWORD           unknown_4;         // +0x10, 未知
    
    // 渲染对象列表 (每个20字节, 共5个)
    BYTE            render_list_0[20];  // +0x14, 渲染对象 #0
    BYTE            render_list_1[20];  // +0x28, 渲染对象 #1
    BYTE            render_list_2[20];  // +0x3C, 渲染对象 #2
    BYTE            render_list_3[20];  // +0x50, 渲染对象 #3
    BYTE            render_list_4[20];  // +0x64, 渲染对象 #4
    
    // === 0x0078: 渲染数据区域 ===
    BYTE            render_data[252];   // +0x78, 渲染数据
    
    // === 0x0184: Direct3D 区域 ===
    BYTE            d3d_device_state[132];  // +0x184, D3D设备状态
    BYTE            viewport_state[120];     // +0x0208, 视口状态
    BYTE            unknown_d3d[108];       // +0x0280, 未知D3D区域
    
    // === 0x0300: DirectDraw 核心接口 ===
    IDirectDraw*    ddraw_object;           // +0x0300, IDirectDraw接口
    DWORD           ddraw_mode;             // +0x0304, DD模式标志
    BYTE            surface_info[72];       // +0x0308, 表面信息
    
    // === 0x0350: 资源管理区域 ===
    DWORD*          resource_array;         // +0x0350, 资源指针数组
    DWORD           resource_count;        // +0x0354, 资源数量
    DWORD           resource_table[128];    // +0x0358, 资源表
    
    // === 0x0500: DirectDraw Surface 接口 ===
    IDirectDrawSurface* primary_surface;    // +0x0500, 主显示表面
    IDirectDrawSurface* back_surface;       // +0x0504, 后备表面
    IDirectDraw*    ddraw_interface;        // +0x0508, DirectDraw接口
    
    // === 0x0510: 渲染队列 ===
    BYTE            render_queue_0[20];     // +0x0510, 渲染队列 #0
    BYTE            render_queue_1[20];     // +0x0524, 渲染队列 #1
    BYTE            render_queue_2[20];     // +0x0538, 渲染队列 #2
    BYTE            render_queue_3[20];     // +0x054C, 渲染队列 #3
    BYTE            render_queue_4[20];     // +0x0560, 渲染队列 #4
    
    // === 0x0574: 配置与状态区域 ===
    DWORD           unknown_10;             // +0x0574
    DWORD           unknown_11;             // +0x0578
    DWORD           unknown_12;             // +0x057C
    DWORD           unknown_13;             // +0x0580
    DWORD           unknown_14;             // +0x0584
    DWORD           unknown_15;             // +0x0588
    DWORD           unknown_16;             // +0x058C
    DWORD           unknown_17;             // +0x0590
    DWORD           unknown_18;             // +0x0594
    DWORD           unknown_19;             // +0x0598
    DWORD           unknown_20;             // +0x059C
    DWORD           unknown_21;             // +0x05A0
    
    // === 0x05A4: 标志位 ===
    BYTE            flag_0;                 // +0x05A4, 标志位
    BYTE            flag_1;                 // +0x05A5, 标志位
    BYTE            flag_2[2];              // +0x05A6, 标志位
    
    // === 0x05A8: 窗口与接口句柄 ===
    HWND            hwnd;                   // +0x05A8, 窗口句柄
    DWORD           dd_global;              // +0x05AC, DirectDraw全局接口
    DWORD           d3d_global;             // +0x05B0, Direct3D全局接口
    
    // === 0x05B4: Surface 相关 ===
    IDirectDrawSurface* primary_surface2;   // +0x05B4, 主表面 (重复?)
    IDirectDrawClipper* ddraw_clipper;      // +0x05B8, 裁剪器
    HWND            hwnd_parent;             // +0x05BC, 父窗口句柄
    DWORD           default_width;          // +0x05C0, 默认宽度 (320)
    DWORD           default_height;         // +0x05C4, 默认高度 (240)
    DWORD           unknown_25;             // +0x05C8
    DWORD           unknown_26;             // +0x05CC
    DWORD           unknown_27;             // +0x05D0
    DWORD           unknown_28;             // +0x05D4
    DWORD           unknown_29;             // +0x05D8
    DWORD           unknown_30;             // +0x05DC
    
    // === 0x05E0: 缩放与显示参数 ===
    WORD            scale_x;                // +0x05E0, X缩放值
    WORD            scale_y;                // +0x05E2, Y缩放值
    float           scale_x_float;          // +0x05E4, X缩放 (浮点)
    float           scale_y_float;          // +0x05E8, Y缩放 (浮点)
    DWORD           unknown_32;             // +0x05EC
    DWORD           pause_flag;             // +0x05F0, 暂停标志
    DWORD           unknown_33;             // +0x05F4
    DWORD           unknown_34;             // +0x05F8
    DWORD           screen_width;           // +0x05FC, 屏幕宽度
    DWORD           screen_height;          // +0x0600, 屏幕高度
    DWORD           pitch;                  // +0x0604, 显存行跨度
    DWORD*          resolution_array;       // +0x0608, 分辨率数组指针
    DWORD           unknown_35;             // +0x060C
    DWORD           unknown_36;             // +0x0610
    DWORD           fullscreen_flags[58];   // +0x0614, 全屏标志数组
    
    // === 0x0700: DirectDraw 标志与接口 ===
    DWORD           ddraw_flags;            // +0x0700, DirectDraw标志位
    DWORD           window_offset_x;        // +0x0704, 窗口X偏移
    DWORD           window_offset_y;        // +0x0708, 窗口Y偏移
    IDirectDrawSurface* unknown_surface;    // +0x070C, 未知表面
    DWORD           frame_counter;          // +0x0710, 帧计数器
    
    // === 0x0714: Flip 队列与裁剪 ===
    DWORD           flip_queue[2];           // +0x0714, Flip队列
    RECT            clip_rect;              // +0x071C, 裁剪矩形
    IDirect3DViewport* d3d_viewport;       // +0x072C, D3D视口
    
} Renderer;