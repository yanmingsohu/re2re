; Disassembled by yanming.J
; SPDX-License-Identifier: MIT
; https://github.com/yanmingsohu/
; 与游戏脚本系统 (vm) 相关代码

call_c_vm MACRO func_name
  jmp func_name
ENDM


COMMENT #
  脚本执行主循环(Script Dispatcher)整体结构初始化全局状态
      ↓
  遍历实体数组(EBX: 3720→5208,步长372)
      ↓
    每个实体：取脚本指针 → 派发指令 → 处理返回值
      ↓
    返回1=继续, 2=跳出, 其他=切换指令

  实体数组布局推断：
    $L_695829:
      [+0]       实体基址 (ESI)
      [+27]      active标志 (AL检查处)
      [+28]      EDI基准点
      [+28]      当前脚本指令指针 (DWORD PTR [EDI])
      [+30]      ESI+2  = 某索引字节
      [+320]     链表/栈指针
      步长 = 372字节/实体
    范围 3720→5208,步长372 → (5208-3720)/372 = 4个实体槽位

  这是一个脚本调用栈机制：[ESI+320] 维护一个栈,支持脚本子程序的调用与返回,
  计数器归零前可重复跳转(类似循环次数控制)。

  这是RE2脚本系统的每帧主调度循环,遍历4个活跃实体槽,对每个实体连续派发脚本
  指令直到挂起或结束。配合调用栈支持子程序跳转,配合全局中断标志支持紧急退出,
  是整个脚本引擎的心脏。
#
ALIGN 16
FUN_450100 PROC
            push EBX
            push EBP
            push ESI
            push EDI
            ; 脚本系统运行标志 = 活跃
            mov BYTE PTR [$L_695e08],1 
            ; 全局指令表基址
            mov DWORD PTR [$L_695dfc],OFFSET $L_8c6828 
            ; 第一个实体数据区(+27)
            mov EDI,OFFSET $L_695829+27
            ; 当前偏移计数器
            mov EBX,3720
            ; EBP = -4 (DWORD步退量)
            mov EBP, 0FFFFFFFCh
$L_450124::
            ; entity->active 标志 (偏移-27处)
            mov AL,BYTE PTR [EDI-27]
            ; ESI = 实体基址 (EDI-28)
            lea ESI,DWORD PTR [EDI-28]
            test AL,AL
            ; active==0 → 跳过此实体
            je $L_450182
$L_45012e::
            ; EAX = 当前脚本指令指针
            mov EAX,DWORD PTR [EDI]
            xor ECX,ECX
            ; 压入实体指针作为参数
            push ESI
            ; CL  = 操作码 (第一字节)
            mov CL,BYTE PTR [EAX]
            ; 查操作码跳转表,调用处理函数
            call DWORD PTR [ECX*4+$L_53adb8]

            mov EDX,DWORD PTR [$L_68a1b4]
            add ESP,4
            mov CL,BYTE PTR [EDX+19]
            test CL,CL
            ; 全局中断标志置位 → 立即退出整个循环
            jne $L_450196

            cmp EAX,1
            ; 返回1 → 继续执行下一条指令(同一实体)
            je $L_45012e

            cmp EAX,2
            ; 返回2 → 此实体本帧结束,处理下一实体
            je $L_450182
            ; 跳转偏移索引
            movsx EAX,BYTE PTR [ESI+2]
            ; 目标指令计数器
            mov CL,BYTE PTR [EAX+ESI*1+4]
            ; EAX = 目标指令槽地址
            lea EAX,DWORD PTR [EAX+ESI*1+4]
            test CL,CL
            ; 计数器<0 → 结束
            jl $L_450182
            ; 取栈/链表当前指针
            mov EDX,DWORD PTR [ESI+320]
            ; EDX -= 4 (弹出一级)
            add EDX,EBP
            mov ECX,EDX
$L_450170::
            ; 更新栈指针
            mov DWORD PTR [ESI+320],EDX
            ; 取栈顶值
            mov ECX,DWORD PTR [ECX]
            ; 写回脚本指令指针(跳转)
            mov DWORD PTR [EDI],ECX
            mov CL,BYTE PTR [EAX]
            dec CL
            ; 目标计数器--
            mov BYTE PTR [EAX],CL
            ; 继续执行新指令
            jmp $L_45012e
$L_450182::

            add EBX,372
            add EDI,372
            cmp EBX,5208
            jb $L_450124
$L_450196::

            pop EDI
            pop ESI
            pop EBP
            pop EBX
            ret 
FUN_450100 ENDP


; 这是一个游戏逻辑 tick 函数,每帧驱动最多10个实体的有限状态机,
; 每个元素大小为 372 字节,共 10 个元素(3720 / 372 = 10)。
; 每个实体通过虚函数表执行当前状态行为,支持状态转移和提前中断。
; VMContext ctx[10];
ALIGN 16
FUN_4e41e0 PROC
            push EBX
            push EBP
            push ESI
            push EDI
            mov EDI,OFFSET $L_6949a1+27
            xor EBX,EBX
            mov EBP,0FFFFFFFCh
$L_4e41f0::

            mov AL,BYTE PTR [EDI-27]
            lea ESI,DWORD PTR [EDI-28]
            test AL,AL
            je $L_4e424e
$L_4e41fa::

            mov EAX,DWORD PTR [EDI]
            xor ECX,ECX
            push ESI
            mov CL,BYTE PTR [EAX]
            call DWORD PTR [ECX*4+$L_53adb8]

            mov EDX,DWORD PTR [$L_68a1b4]
            add ESP,4
            mov CL,BYTE PTR [EDX+19]
            test CL,CL
            jne $L_4e4270

            cmp EAX,1
            je $L_4e41fa ; continue

            cmp EAX,2
            je $L_4e424e ; break

            movsx EAX,BYTE PTR [ESI+2]
            mov CL,BYTE PTR [EAX+ESI*1+4]
            lea EAX,DWORD PTR [EAX+ESI*1+4]
            test CL,CL
            jl $L_4e424e

            mov EDX,DWORD PTR [ESI+320]
            add EDX,EBP
            mov ECX,EDX
            mov DWORD PTR [ESI+320],EDX
            mov ECX,DWORD PTR [ECX]
            mov DWORD PTR [EDI],ECX
            mov CL,BYTE PTR [EAX]
            dec CL
            mov BYTE PTR [EAX],CL
            jmp $L_4e41fa
$L_4e424e::

            add EBX,372
            add EDI,372
            cmp EBX,3720
            jb $L_4e41f0

            call FUN_4e3c70

            pop EDI
            pop ESI
            pop EBP
            pop EBX
            jmp $L_4e3cb0
$L_4e4270::

            pop EDI
            pop ESI
            pop EBP
            pop EBX
            ret 
FUN_4e41e0 ENDP


; 虚拟机指令集里的一个 NOP 或者对齐跳过指令
FUN_4e4280 PROC
    call_c_vm vm_nop
            mov EAX,DWORD PTR [ESP+4]
            mov ECX,DWORD PTR [EAX+28]
            inc ECX
            mov DWORD PTR [EAX+28],ECX
            mov EAX,1
            ret 
FUN_4e4280 ENDP


$L_4e42a0 PROC
    call_c_vm vm_jump
            mov EAX,DWORD PTR [ESP+4]
            movsx ECX,BYTE PTR [EAX+2]
            test ECX,ECX
            je $L_4e42d7

            movsx EDX,BYTE PTR [ECX+EAX*1+3]
            dec ECX
            push ESI
            mov ESI,DWORD PTR [EAX+ECX*4+324]
            lea EDX,DWORD PTR [EDX+ECX*8]
            mov DWORD PTR [EAX+28],ESI
            mov BYTE PTR [EAX+2],CL
            lea EDX,DWORD PTR [EAX+EDX*4+196]
            pop ESI
            mov DWORD PTR [EAX+320],EDX
            mov EAX,1
            ret 
$L_4e42d7::
            mov BYTE PTR [EAX+1],0
            mov EAX,2
            ret 
$L_4e42a0 ENDP


$L_4e42f0 PROC
    call_c_vm vm_end
            mov EAX,DWORD PTR [ESP+4]
            mov ECX,DWORD PTR [EAX+28]
            inc ECX
            mov DWORD PTR [EAX+28],ECX
            mov EAX,2
            ret 
$L_4e42f0 ENDP


$L_4e4310 PROC
            mov EAX,DWORD PTR [ESP+4]
            xor EDX,EDX
            mov ECX,DWORD PTR [EAX+28]
            mov DL,BYTE PTR [ECX+3]
            push EDX
            push EAX
            call FUN_4e3e30
            add ESP,8
            mov EAX,1
            ret 
$L_4e4310 ENDP


; FUN_4e3e70 垫片
$L_4e4330 PROC
            mov ECX,DWORD PTR [ESP+4]
            xor EDX,EDX
            push ESI
            mov EAX,DWORD PTR [ECX+28]
            mov DL,BYTE PTR [EAX+1]
            add EAX,4
            mov ESI,EDX
            xor EDX,EDX
            mov DL,BYTE PTR [EAX-1]
            mov DWORD PTR [ECX+28],EAX
            push EDX
            push ESI
            call FUN_4e3e70

            add ESP,8
            mov EAX,1
            pop ESI
            ret 
$L_4e4330 ENDP


; 终止指定槽位的协程,把它标记为不活跃,让槽位可以被重新分配。对应 SPAWN 的反操作。
; KILL  slot_id
$L_4e4360 PROC
    call_c_vm vm_kill
            mov ECX,DWORD PTR [ESP+4]
            xor EDX,EDX
            mov EAX,DWORD PTR [ECX+28]
            mov DL,BYTE PTR [EAX+1]
            mov EAX,EDX
            shl EAX,5
            sub EAX,EDX
            lea EDX,DWORD PTR [EAX+EAX*2]
            mov BYTE PTR [EDX*4+$L_6949a1],0
            mov EAX,DWORD PTR [ECX+28]
            add EAX,2
            mov DWORD PTR [ECX+28],EAX
            mov EAX,1
            ret 
$L_4e4360 ENDP


$L_4e4390 PROC
    call_c_vm vm_call
            mov EAX,DWORD PTR [ESP+4]
            push EBX
            push ESI
            movsx ESI,BYTE PTR [EAX+2]
            mov ECX,DWORD PTR [EAX+28]
            add ECX,4
            lea ESI,DWORD PTR [ESI+EAX*1+4]
            mov DWORD PTR [EAX+28],ECX
            mov EDX,ECX
            mov BL,BYTE PTR [ESI]
            xor ECX,ECX
            mov CX,WORD PTR [EDX-2]
            inc BL
            mov BYTE PTR [ESI],BL
            add ECX,EDX
            mov EDX,DWORD PTR [EAX+320]
            pop ESI
            pop EBX
            mov DWORD PTR [EDX],ECX
            mov ECX,DWORD PTR [EAX+320]
            add ECX,4
            mov DWORD PTR [EAX+320],ECX
            mov EAX,1
            ret 
$L_4e4390 ENDP


$L_4e43e0 PROC
    call_c_vm vm_return
            mov EAX,DWORD PTR [ESP+4]
            xor EDX,EDX
            mov ECX,DWORD PTR [EAX+320]
            add ECX,-4
            mov DWORD PTR [EAX+320],ECX
            mov ECX,DWORD PTR [EAX+28]
            mov DX,WORD PTR [ECX+2]
            add EDX,ECX
            movsx ECX,BYTE PTR [EAX+2]
            mov DWORD PTR [EAX+28],EDX
            lea EAX,DWORD PTR [ECX+EAX*1+4]
            mov CL,BYTE PTR [EAX]
            dec CL
            mov BYTE PTR [EAX],CL
            mov EAX,1
            ret 
$L_4e43e0 ENDP


$L_4e4420 PROC
    call_c_vm vm_yield
            mov EAX,DWORD PTR [ESP+4]
            mov ECX,DWORD PTR [EAX+320]
            add ECX,-4
            mov DWORD PTR [EAX+320],ECX
            mov ECX,DWORD PTR [EAX+28]
            add ECX,2
            mov DWORD PTR [EAX+28],ECX
            movsx ECX,BYTE PTR [EAX+2]
            lea EAX,DWORD PTR [ECX+EAX*1+4]
            mov CL,BYTE PTR [EAX]
            dec CL
            mov BYTE PTR [EAX],CL
            mov EAX,1
            ret 
$L_4e4420 ENDP


; 这个虚拟机用的是基于栈的求值模型,每个协程(槽位)有自己的栈空间。
; PUSH  stream[2..3]
$L_4e4450 PROC
            mov EAX,DWORD PTR [ESP+4]
            push EBX
            push ESI
            mov EDX,DWORD PTR [EAX+28]
            lea ECX,DWORD PTR [EDX+1]
            mov DWORD PTR [EAX+28],ECX
            movsx ECX,BYTE PTR [EAX+2]
            mov BL,BYTE PTR [ECX+EAX*1+8]
            inc BL
            movsx ESI,BL
            mov BYTE PTR [ECX+EAX*1+8],BL
            mov DX,WORD PTR [EDX+2]
            lea ECX,DWORD PTR [ESI+ECX*4+80]
            pop ESI
            pop EBX
            mov WORD PTR [EAX+ECX*2],DX
            mov EAX,1
            ret 
$L_4e4450 ENDP


; 这是一条循环控制指令,类似 x86 的 LOOP 指令：
COMMENT !
LOOP:
    栈顶值--
    if 栈顶值 == 0:
        弹栈
        stream += 3    // 跳过循环体,继续往后执行
    else:
        不移动stream   // 保持在循环入口,下次调度继续执行
    return 2           // yield,让出执行权
!
$L_4e4490 PROC
            mov EAX,DWORD PTR [ESP+4]
            push ESI
            movsx ECX,BYTE PTR [EAX+2]
            movsx ESI,BYTE PTR [ECX+EAX*1+8]
            lea EDX,DWORD PTR [ECX*4+80]
            add ESI,EDX
            dec WORD PTR [EAX+ESI*2]
            lea ESI,DWORD PTR [EAX+ESI*2]
            movsx ESI,BYTE PTR [ECX+EAX*1+8]
            add ESI,EDX
            cmp WORD PTR [EAX+ESI*2],0
            jne $L_4e44cf

            mov ESI,DWORD PTR [EAX+28]
            add ESI,3
            mov DWORD PTR [EAX+28],ESI
            mov DL,BYTE PTR [ECX+EAX*1+8]
            dec DL
            mov BYTE PTR [ECX+EAX*1+8],DL
$L_4e44cf::
            mov EAX,2
            pop ESI
            ret 
$L_4e4490 ENDP


; 只移动栈顶指针,不写入任何值,说明这是：
; ALLOC  在栈上预留一个空槽位
; 因为内存本来就可能是0,不需要显式写。
; 配合 LOOP 使用的话,可以先 ALLOC 占位,之后再由其他指令填值。
$L_4e44e0 PROC
            mov EAX,DWORD PTR [ESP+4]
            movsx ECX,BYTE PTR [EAX+2]
            mov DL,BYTE PTR [ECX+EAX*1+8]
            lea ECX,DWORD PTR [ECX+EAX*1+8]
            inc DL
            mov BYTE PTR [ECX],DL
            mov ECX,DWORD PTR [EAX+28]
            inc ECX
            mov DWORD PTR [EAX+28],ECX
            mov EAX,1
            ret 
$L_4e44e0 ENDP


COMMENT !
  这是一条条件性POP/等待指令：
  WAIT_AND_POP:
      if 全局状态未就绪:
          yield(不动stream,不动栈,下次再试)
      else:
          stream++
          栈顶--(弹栈)
          yield
!
$L_4e4510 PROC
            test BYTE PTR [$L_989e70],32
            jne $L_4e4533

            mov AL,BYTE PTR [$L_984fec]
            test AL,AL
            js $L_4e4533

            mov EAX,DWORD PTR [ESP+4]
            inc DWORD PTR [EAX+28]
            movsx ECX,BYTE PTR [EAX+2]
            lea EAX,DWORD PTR [ECX+EAX*1+8]
            dec BYTE PTR [EAX]
$L_4e4533::
            mov EAX,2
            ret 
$L_4e4510 ENDP


$L_4e4540 PROC
            mov EAX,DWORD PTR [ESP+4]
            mov ECX,DWORD PTR [EAX+28]
            movsx EDX,BYTE PTR [EAX+2]
            cmp WORD PTR [ECX+4],0
            je $L_4e459e

            push EBX
            mov BL,BYTE PTR [EDX+EAX*1+8]
            push EBP
            inc BL
            push ESI
            mov BYTE PTR [EDX+EAX*1+8],BL
            mov BP,WORD PTR [ECX+4]
            push EDI
            movsx EDI,WORD PTR [ECX+2]
            movsx ESI,BL
            add ECX,6
            lea EBX,DWORD PTR [ESI+EDX*4+80]
            add EDI,ECX
            mov WORD PTR [EAX+EBX*2],BP
            lea EBX,DWORD PTR [ESI+EDX*4+24]
            mov DWORD PTR [EAX+28],ECX
            mov DWORD PTR [EAX+EBX*4],EDI
            lea EDI,DWORD PTR [ESI+EDX*4+8]
            mov DWORD PTR [EAX+EDI*4],ECX
            lea ECX,DWORD PTR [ESI+EDX*4+12]
            mov DL,BYTE PTR [EDX+EAX*1+4]
            pop EDI
            pop ESI
            mov BYTE PTR [ECX+EAX*1],DL
            pop EBP
            pop EBX
            mov EAX,1
            ret 
$L_4e459e::
            movsx EDX,WORD PTR [ECX+2]
            lea ECX,DWORD PTR [EDX+ECX*1+6]
            mov DWORD PTR [EAX+28],ECX
            mov EAX,1
            ret 
$L_4e4540 ENDP


COMMENT !
  这是一条对象存在性条件跳转指令
  IF_ENTITY_EXISTS  obj_id, offset:
      查表 L_98ea84[obj_id]
      if 对象不存在:
          stream += 6 + offset    // 跳到else
      if 对象存在:
          把对象指针压栈
          stream += 6             // 进入if分支
!
$L_4e45b0 PROC
            mov EAX,DWORD PTR [ESP+4]
            xor EDX,EDX
            push ESI
            mov ECX,DWORD PTR [EAX+28]
            movsx ESI,BYTE PTR [EAX+2]
            mov DL,BYTE PTR [ECX+5]
            cmp WORD PTR [EDX*2+$L_98ea84],0
            je $L_4e4620

            push EBX
            mov BL,BYTE PTR [ESI+EAX*1+8]
            push EBP
            inc BL
            push EDI
            xor EDX,EDX
            movsx EDI,BL
            mov BYTE PTR [ESI+EAX*1+8],BL
            mov DL,BYTE PTR [ECX+5]
            movsx EBP,WORD PTR [ECX+2]
            mov DX,WORD PTR [EDX*2+$L_98ea84]
            lea EBX,DWORD PTR [EDI+ESI*4+80]
            add ECX,6
            mov WORD PTR [EAX+EBX*2],DX
            lea EDX,DWORD PTR [EDI+ESI*4+24]
            add EBP,ECX
            mov DWORD PTR [EAX+28],ECX
            mov DWORD PTR [EAX+EDX*4],EBP
            lea EDX,DWORD PTR [EDI+ESI*4+8]
            mov DWORD PTR [EAX+EDX*4],ECX
            mov DL,BYTE PTR [ESI+EAX*1+4]
            lea ECX,DWORD PTR [EDI+ESI*4+12]
            pop EDI
            pop EBP
            pop EBX
            mov BYTE PTR [ECX+EAX*1],DL
            mov EAX,1
            pop ESI
            ret 
$L_4e4620::
            movsx EDX,WORD PTR [ECX+2]
            pop ESI
            lea ECX,DWORD PTR [EDX+ECX*1+6]
            mov DWORD PTR [EAX+28],ECX
            mov EAX,1
            ret 
$L_4e45b0 ENDP


$L_4e4640 PROC
            mov EAX,DWORD PTR [ESP+4]
            push ESI
            movsx ECX,BYTE PTR [EAX+2]
            movsx ESI,BYTE PTR [ECX+EAX*1+8]
            lea EDX,DWORD PTR [ESI+ECX*4+80]
            dec WORD PTR [EAX+EDX*2]
            cmp WORD PTR [EAX+EDX*2],0
            lea EDX,DWORD PTR [EAX+EDX*2]
            je $L_4e4671

            lea ECX,DWORD PTR [ESI+ECX*4+8]
            pop ESI
            mov EDX,DWORD PTR [EAX+ECX*4]
            mov DWORD PTR [EAX+28],EDX
            mov EAX,1
            ret 
$L_4e4671::

            mov ESI,DWORD PTR [EAX+28]
            add ESI,2
            mov DWORD PTR [EAX+28],ESI
            mov DL,BYTE PTR [ECX+EAX*1+8]
            dec DL
            pop ESI
            mov BYTE PTR [ECX+EAX*1+8],DL
            mov EAX,1
            ret 
$L_4e4640 ENDP


$L_4e4690 PROC
            push EBX
            push EBP
            push ESI
            mov ESI,DWORD PTR [ESP+16]
            push EDI
            movsx ECX,BYTE PTR [ESI+2]
            mov DL,BYTE PTR [ECX+ESI*1+8]
            mov EAX,DWORD PTR [ESI+28]
            lea EDI,DWORD PTR [ECX+ESI*1+8]
            inc DL
            mov BYTE PTR [EDI],DL
            movsx EBP,WORD PTR [EAX+2]
            movsx EDX,DL
            lea EBX,DWORD PTR [EDX+ECX*4+8]
            mov DWORD PTR [ESI+EBX*4],EAX
            lea EBX,DWORD PTR [EDX+ECX*4+24]
            add EAX,4
            lea EDX,DWORD PTR [EDX+ECX*4+12]
            lea EBX,DWORD PTR [ESI+EBX*4]
            add EBP,EAX
            mov DWORD PTR [ESI+28],EAX
            mov DWORD PTR [EBX],EBP
            mov CL,BYTE PTR [ECX+ESI*1+4]
            mov BYTE PTR [EDX+ESI*1],CL
            mov DL,BYTE PTR [EAX-3]
            push EDX
            push EAX
            push ESI
            call FUN_4e47d0

            add ESP,12
            test EAX,EAX
            jne $L_4e46f2

            mov EAX,DWORD PTR [EBX]
            mov DWORD PTR [ESI+28],EAX
            mov AL,BYTE PTR [EDI]
            dec AL
            mov BYTE PTR [EDI],AL
$L_4e46f2::
            pop EDI
            pop ESI
            pop EBP
            mov EAX,1
            pop EBX
            ret 
$L_4e4690 ENDP


$L_4e4700 PROC
            mov EAX,DWORD PTR [ESP+4]
            movsx ECX,BYTE PTR [EAX+2]
            movsx EDX,BYTE PTR [ECX+EAX*1+8]
            lea EDX,DWORD PTR [EDX+ECX*4+8]
            mov EDX,DWORD PTR [EAX+EDX*4]
            mov DWORD PTR [EAX+28],EDX
            mov DL,BYTE PTR [ECX+EAX*1+8]
            dec DL
            mov BYTE PTR [ECX+EAX*1+8],DL
            mov EAX,1
            ret 
$L_4e4700 ENDP


$L_4e4730 PROC
            mov EAX,DWORD PTR [ESP+4]
            push EBX
            push ESI
            push EDI
            movsx EDX,BYTE PTR [EAX+2]
            mov ECX,DWORD PTR [EAX+28]
            mov BL,BYTE PTR [EDX+EAX*1+8]
            add ECX,4
            inc BL
            movsx ESI,BL
            mov BYTE PTR [EDX+EAX*1+8],BL
            movsx EDI,WORD PTR [ECX-2]
            lea EBX,DWORD PTR [ESI+EDX*4+8]
            mov DWORD PTR [EAX+28],ECX
            add EDI,ECX
            mov DWORD PTR [EAX+EBX*4],ECX
            lea ECX,DWORD PTR [ESI+EDX*4+24]
            mov DWORD PTR [EAX+ECX*4],EDI
            lea ECX,DWORD PTR [ESI+EDX*4+12]
            mov DL,BYTE PTR [EDX+EAX*1+4]
            pop EDI
            mov BYTE PTR [ECX+EAX*1],DL
            pop ESI
            mov EAX,1
            pop EBX
            ret 
$L_4e4730 ENDP


$L_4e4780 PROC
            push ESI
            mov ESI,DWORD PTR [ESP+8]
            push EDI
            mov EAX,DWORD PTR [ESI+28]
            movsx EDI,BYTE PTR [ESI+2]
            add EAX,2
            mov DWORD PTR [ESI+28],EAX
            mov CL,BYTE PTR [EAX-1]
            push ECX
            push EAX
            push ESI
            call FUN_4e47d0

            add ESP,12
            test EAX,EAX
            je $L_4e47bc

            movsx EDX,BYTE PTR [EDI+ESI*1+8]
            lea EAX,DWORD PTR [EDX+EDI*4+8]
            pop EDI
            mov ECX,DWORD PTR [ESI+EAX*4]
            mov EAX,1
            mov DWORD PTR [ESI+28],ECX
            pop ESI
            ret 
$L_4e47bc::

            mov AL,BYTE PTR [EDI+ESI*1+8]
            dec AL
            mov BYTE PTR [EDI+ESI*1+8],AL
            pop EDI
            mov EAX,1
            pop ESI
            ret 
$L_4e4780 ENDP


ALIGN 16
FUN_4e47d0 PROC ; int FUN_4e47d0(uint8_t* stream, int len, Context* ctx);

            mov EAX,DWORD PTR [ESP+8]
            push EBX
            mov EBX,DWORD PTR [ESP+16]
            push EBP
            push EDI
            mov EDI,DWORD PTR [ESP+16]
            xor ECX,ECX
            and EBX,255 ; 最大长度 = 255
            mov CL,BYTE PTR [EAX]
            push EDI
            add EBX,EAX
            call DWORD PTR [ECX*4+$L_53adb8]

            mov ECX,DWORD PTR [EDI+28]
            add ESP,4
            cmp ECX,EBX
            mov EBP,EAX
            je $L_4e482c

            push ESI
$L_4e4800::

            xor ESI,ESI
            xor EDX,EDX
            mov SI,WORD PTR [ECX]
            add ECX,2
            mov DWORD PTR [EDI+28],ECX
            push EDI
            mov DL,BYTE PTR [ECX]
            call DWORD PTR [EDX*4+$L_53adb8]

            mov ECX,DWORD PTR [EDI+28]
            add ESP,4
            test ESI,ESI
            je $L_4e4825

            or EBP,EAX
            jmp $L_4e4827
$L_4e4825::

            and EBP,EAX
$L_4e4827::

            cmp ECX,EBX
            jne $L_4e4800

            pop ESI
$L_4e482c::

            mov EAX,EBP
            pop EDI
            pop EBP
            pop EBX
            ret 
FUN_4e47d0 ENDP



$L_4e4840 PROC
            mov ECX,DWORD PTR [ESP+4]
            push EBX
            push EBP
            push ESI
            movsx ESI,BYTE PTR [ECX+2]
            mov EAX,DWORD PTR [ECX+28]
            mov BL,BYTE PTR [ESI+ECX*1+8]
            push EDI
            xor EDX,EDX
            mov DL,BYTE PTR [EAX+1]
            lea EDI,DWORD PTR [ESI+ECX*1+8]
            mov DWORD PTR [ESP+20],EDX
            xor EDX,EDX
            mov DX,WORD PTR [EAX+2]
            inc BL
            mov BYTE PTR [EDI],BL
            add EAX,4
            movsx EBX,BL
            add EDX,EAX
            lea EBP,DWORD PTR [EBX+ESI*4+24]
            mov DWORD PTR [ECX+EBP*4],EDX
            lea EDX,DWORD PTR [EBX+ESI*4+12]
            mov BL,BYTE PTR [ESI+ECX*1+4]
            mov BYTE PTR [EDX+ECX*1],BL
            mov EDX,DWORD PTR [ESP+20]
            movsx EBX,WORD PTR [EDX*2+$L_98ea84]
$L_4e4890::

            mov DL,BYTE PTR [EAX]
            cmp DL,21
            je $L_4e48b3

            cmp DL,22
            je $L_4e48b1

            movsx ESI,WORD PTR [EAX+4]
            xor EDX,EDX
            mov DX,WORD PTR [EAX+2]
            add EAX,6
            cmp EBX,ESI
            je $L_4e48b6

            add EAX,EDX
            jmp $L_4e4890
$L_4e48b1::

            dec BYTE PTR [EDI]
$L_4e48b3::

            add EAX,2
$L_4e48b6::

            pop EDI
            pop ESI
            mov DWORD PTR [ECX+28],EAX
            pop EBP
            mov EAX,1
            pop EBX
            ret 
$L_4e4840 ENDP


$L_4e48d0 PROC
    call_c_vm vm_vib_set0
            mov EAX,DWORD PTR [ESP+4]
            mov ECX,DWORD PTR [EAX+28]
            add ECX,6
            mov DWORD PTR [EAX+28],ECX
            mov EAX,1
            ret 
$L_4e48d0 ENDP


$L_4e48f0 PROC
            mov EAX,DWORD PTR [ESP+4]
            mov ECX,DWORD PTR [EAX+28]
            add ECX,2
            mov DWORD PTR [EAX+28],ECX
            mov EAX,1
            ret 
$L_4e48f0 ENDP


$L_4e4910 PROC
            mov EAX,DWORD PTR [ESP+4]
            movsx ECX,BYTE PTR [EAX+2]
            mov DL,BYTE PTR [ECX+EAX*1+8]
            lea ECX,DWORD PTR [ECX+EAX*1+8]
            dec DL
            mov BYTE PTR [ECX],DL
            mov ECX,DWORD PTR [EAX+28]
            add ECX,2
            mov DWORD PTR [EAX+28],ECX
            mov EAX,1
            ret 
$L_4e4910 ENDP


$L_4e4940 PROC
            mov EAX,DWORD PTR [ESP+4]
            push EBX
            push ESI
            xor EDX,EDX
            mov ECX,DWORD PTR [EAX+28]
            xor EBX,EBX
            movsx ESI,BYTE PTR [EAX+2]
            mov DL,BYTE PTR [ECX+1]
            mov BL,BYTE PTR [ECX+2]
            push EDI
            movsx EDI,WORD PTR [ECX+4]
            mov BYTE PTR [ESI+EAX*1+4],DL
            lea EDX,DWORD PTR [EDX+ESI*8]
            add EDI,ECX
            lea EDX,DWORD PTR [EAX+EDX*4+196]
            mov DWORD PTR [EAX+320],EDX
            mov BYTE PTR [ESI+EAX*1+8],BL
            mov DWORD PTR [EAX+28],EDI
            pop EDI
            pop ESI
            mov EAX,1
            pop EBX
            ret 
$L_4e4940 ENDP


; 这个函数很可能是某个字节码解释器 / 虚拟机的指令派发(dispatch)函数
ALIGN 16
$L_4e4990 PROC
            mov EAX,DWORD PTR [ESP+4]
            push ESI
            xor EDX,EDX
            push EDI
            mov ESI,DWORD PTR [EAX+28] 
            movsx ECX,BYTE PTR [EAX+2]
            mov DL,BYTE PTR [ESI+1]
            add ESI,2
            mov DWORD PTR [EAX+ECX*4+324],ESI
            mov EDI,EDX
            inc ECX
            or DL,255
            xor ESI,ESI
            mov BYTE PTR [ECX+EAX*1+4],DL
            mov BYTE PTR [ECX+EAX*1+8],DL
            lea EDX,DWORD PTR [ECX+6]
            shl EDX,5
            add EDX,EAX
            mov DWORD PTR [EAX+320],EDX
            mov EDX,DWORD PTR [$L_695dfc]
            mov SI,WORD PTR [EDX+EDI*2]
            mov BYTE PTR [EAX+2],CL
            add ESI,EDX
            pop EDI
            ; field_28 像一个 PC(程序计数器)每次 +2,像在读取指令流
            ; obj->field_28 = globalTable + globalTable[val];
            ; 用数据字节查表跳转,典型的 computed goto
            mov DWORD PTR [EAX+28],ESI
            mov EAX,1
            pop ESI
            ret 
$L_4e4990 ENDP


ALIGN 16
$L_4e49f0 PROC

            mov EAX,DWORD PTR [ESP+4]
            mov CL,BYTE PTR [EAX+2]
            dec CL
            mov BYTE PTR [EAX+2],CL
            movsx ECX,CL
            mov EDX,DWORD PTR [EAX+ECX*4+324]
            mov DWORD PTR [EAX+28],EDX
            movsx EDX,BYTE PTR [ECX+EAX*1+4]
            lea ECX,DWORD PTR [EDX+ECX*8]
            lea EDX,DWORD PTR [EAX+ECX*4+196]
            mov DWORD PTR [EAX+320],EDX
            mov EAX,1
            ret 
$L_4e49f0 ENDP


$L_4e4a30 PROC
            mov EAX,DWORD PTR [ESP+4]
            push ESI
            push EDI
            movsx ESI,BYTE PTR [EAX+2]
            movsx ECX,BYTE PTR [ESI+EAX*1+8]
            lea EDI,DWORD PTR [ESI+EAX*1+8]
            lea EDX,DWORD PTR [ECX+ESI*4+24]
            mov EDX,DWORD PTR [EAX+EDX*4]
            mov DWORD PTR [EAX+28],EDX
            lea EDX,DWORD PTR [ECX+ESI*4+12]
            dec CL
            mov DL,BYTE PTR [EDX+EAX*1]
            mov BYTE PTR [EDI],CL
            mov BYTE PTR [ESI+EAX*1+4],DL
            pop EDI
            mov EAX,1
            pop ESI
            ret 
$L_4e4a30 ENDP


; OP_SET_VAR_FROM_TABLE
$L_4e4a70 PROC
            push ESI
            push EDI
            mov EDI,DWORD PTR [ESP+12]
            xor EDX,EDX
            xor ECX,ECX
            mov EAX,DWORD PTR [EDI+28]
            mov DL,BYTE PTR [EAX+2]
            mov CL,BYTE PTR [EAX+1]
            mov ESI,EDX
            xor EDX,EDX
            mov DL,BYTE PTR [EAX+3]
            add EAX,4
            test EDX,EDX
            mov DWORD PTR [EDI+28],EAX
            je $L_4e4aa8

            mov CX,WORD PTR [ECX*2+$L_98ea84]
            pop EDI
            mov WORD PTR [ESI+EAX*1],CX
            mov EAX,1
            pop ESI
            ret 
$L_4e4aa8::
            mov DL,BYTE PTR [ECX*2+$L_98ea84]
            pop EDI
            mov BYTE PTR [ESI+EAX*1],DL
            mov EAX,1
            pop ESI
            ret 
$L_4e4a70 ENDP



$L_4e4ac0 PROC
            call FUN_4deec0

            mov EAX,DWORD PTR [ESP+4]
            mov BYTE PTR [$L_695e0f],1
            mov ECX,DWORD PTR [EAX+28]
            inc ECX
            mov DWORD PTR [EAX+28],ECX
            mov EAX,1
            ret 
$L_4e4ac0 ENDP


$L_4e4ae0 PROC
            mov ECX,DWORD PTR [ESP+4]
            xor EDX,EDX
            push ESI
            push EDI
            mov EAX,DWORD PTR [ECX+28]
            mov EDI,2147483648
            mov DL,BYTE PTR [EAX+1]
            add EAX,4
            mov ESI,EDX
            xor EDX,EDX
            mov DX,WORD PTR [EAX-2]
            mov DWORD PTR [ECX+28],EAX
            mov ESI,DWORD PTR [ESI*4+$L_53b1c0]
            mov EAX,EDX
            mov ECX,EDX
            sar EAX,5
            and ECX,31
            and EAX,7
            shr EDI,CL
            mov EAX,DWORD PTR [ESI+EAX*4]
            and EAX,EDI
            pop EDI
            neg EAX
            sbb EAX,EAX
            xor DL,DL
            neg EAX
            neg EDX
            sbb EDX,EDX
            pop ESI
            inc EDX
            xor EAX,EDX
            ret 
$L_4e4ae0 ENDP


; 虚拟机指令解释器里的一条指令处理函数,专门处理"位写"操作。
; opcode (0: 清除位 (AND NOT)) (1: 置位 (OR)) (7: 翻转位 (XOR))
ALIGN 16
$L_4e4b30 PROC
            push EBX
            push ESI
            mov ESI,DWORD PTR [ESP+12]
            xor ECX,ECX
            push EDI
            xor EBX,EBX
            mov EAX,DWORD PTR [ESI+28]
            mov CL,BYTE PTR [EAX+1] ; index
            mov BL,BYTE PTR [EAX+3] ; opcode
            mov EDI,ECX
            xor ECX,ECX
            mov CL,BYTE PTR [EAX+2] ; bitpos
            add EAX,4
            mov EDX,ECX
            mov DWORD PTR [ESI+28],EAX          ; 崩溃时 指令码是2d 错误???
            mov EAX,DWORD PTR [EDI*4+$L_53b1c0] ; 崩溃时 EDI=1f 越界访问, EAX=15003f6<-下内存写入断点
            and ECX,31
            sar EDX,5
            pop EDI
            pop ESI
            lea EDX,DWORD PTR [EAX+EDX*4]
            mov EAX,EBX
            sub EAX,0
            pop EBX
            je $L_4e4b9b

            dec EAX
            je $L_4e4b88

            sub EAX,6
            jne $L_4e4baa

            mov EAX,80000000h
            shr EAX,CL
            mov ECX,DWORD PTR [EDX]
            xor ECX,EAX
            mov EAX,1
            mov DWORD PTR [EDX],ECX
            ret 
$L_4e4b88::

            mov EAX,80000000h
            shr EAX,CL
        ;崩溃 ECX=9, EDX=98eccc 非法内存访问
            mov ECX,DWORD PTR [EDX] 
            or ECX,EAX
            mov EAX,1
            mov DWORD PTR [EDX],ECX
            ret 
$L_4e4b9b::

            mov EAX,80000000h
            shr EAX,CL
            mov ECX,DWORD PTR [EDX]
            not EAX
            and ECX,EAX
            mov DWORD PTR [EDX],ECX
$L_4e4baa::

            mov EAX,1
            ret 
$L_4e4b30 ENDP


COMMENT #
  OP_CMP_VAR  —— 比较脚本变量与立即数
  switch (cmp_op) {
      case 0: return lhs == imm;
      case 1: return lhs >  imm;
      case 2: return lhs >= imm;
      case 3: return lhs <  imm;
      case 4: return lhs <= imm;
      case 5: return lhs != imm;
      case 6: return (lhs & imm) != 0;
  }
#
ALIGN 16
$L_4e4bb0 PROC
            push ESI
            mov ESI,DWORD PTR [ESP+8]
            xor ECX,ECX
            mov EAX,DWORD PTR [ESI+28]
            mov CX,WORD PTR [EAX+2]
            movsx EDX,WORD PTR [EAX+4]
            add EAX,6
            mov DWORD PTR [ESI+28],EAX
            mov EAX,ECX
            and EAX,255
            pop ESI
            shr ECX,8
            movsx EAX,WORD PTR [EAX*2+$L_98ea84]
            cmp ECX,6
            ja $L_4e4c2b

            jmp DWORD PTR [ECX*4+$L_4e4c2c]
$L_4e4be7::

            xor ECX,ECX
            cmp EAX,EDX
            sete CL
            mov EAX,ECX
            ret 
$L_4e4bf1::

            xor ECX,ECX
            cmp EAX,EDX
            setg CL
            mov EAX,ECX
            ret 
$L_4e4bfb::

            xor ECX,ECX
            cmp EAX,EDX
            setge CL
            mov EAX,ECX
            ret 
$L_4e4c05::

            xor ECX,ECX
            cmp EAX,EDX
            setl CL
            mov EAX,ECX
            ret 
$L_4e4c0f::

            xor ECX,ECX
            cmp EAX,EDX
            setle CL
            mov EAX,ECX
            ret 
$L_4e4c19::

            xor ECX,ECX
            cmp EAX,EDX
            setne CL
            mov EAX,ECX
            ret 
$L_4e4c23::

            and EAX,EDX
            neg EAX
            sbb EAX,EAX
            neg EAX
$L_4e4c2b::

            ret 

$L_4e4c2c DWORD $L_4e4be7
          DWORD $L_4e4bf1
          DWORD $L_4e4bfb
          DWORD $L_4e4c05
          DWORD $L_4e4c0f
          DWORD $L_4e4c19
          DWORD $L_4e4c23
$L_4e4bb0 ENDP
          

COMMENT !
  uint8_t index  = ip[1];
  int16_t value  = *(int16_t*)(ip + 2);
  ip += 4;

  g_table_98ea84[index] = value;  // 直接写入变量表

  return 1;
!    
$L_4e4c50 PROC
            mov ECX,DWORD PTR [ESP+4]
            xor EDX,EDX
            push ESI
            mov EAX,DWORD PTR [ECX+28]
            mov DL,BYTE PTR [EAX+1]
            movsx ESI,WORD PTR [EAX+2]
            lea EDX,DWORD PTR [EDX*2+$L_98ea84]
            add EAX,4
            mov DWORD PTR [ECX+28],EAX
            mov EAX,1
            mov WORD PTR [EDX],SI
            pop ESI
            ret 
$L_4e4c50 ENDP

 
; 变量表内部的寄存器间传送,var[dst] = var[src]。
$L_4e4c80 PROC
            mov ECX,DWORD PTR [ESP+4]
            xor EDX,EDX
            push ESI
            mov EAX,DWORD PTR [ECX+28]
            mov DL,BYTE PTR [EAX+1]
            add EAX,3
            mov ESI,EDX
            xor EDX,EDX
            mov DL,BYTE PTR [EAX-1]
            mov DWORD PTR [ECX+28],EAX
            mov AX,WORD PTR [EDX*2+$L_98ea84]
            mov WORD PTR [ESI*2+$L_98ea84],AX
            mov EAX,1
            pop ESI
            ret 
$L_4e4c80 ENDP


$L_4e4cc0 PROC
            mov EDX,DWORD PTR [ESP+4]
            xor EAX,EAX
            push ESI
            mov ECX,DWORD PTR [EDX+28]
            mov AX,WORD PTR [ECX+2]
            movsx ESI,WORD PTR [ECX+4]
            add ECX,6
            push ESI
            mov DWORD PTR [EDX+28],ECX
            mov ECX,EAX
            shr ECX,8
            and EAX,255
            lea EDX,DWORD PTR [ECX*2+$L_98ea84]
            push EDX
            push EAX
            call FUN_4e4d50

            add ESP,12
            mov EAX,1
            pop ESI
            ret 
$L_4e4cc0 ENDP
          BYTE 090H
          BYTE 090H
          BYTE 090H
          BYTE 090H
          BYTE 090H
$L_4e4d00 PROC

            mov ECX,DWORD PTR [ESP+4]
            xor EDX,EDX
            push ESI
            push EDI
            mov EAX,DWORD PTR [ECX+28]
            mov DL,BYTE PTR [EAX+1]
            add EAX,4
            mov ESI,EDX
            xor EDX,EDX
            mov DL,BYTE PTR [EAX-1]
            movsx EDI,WORD PTR [EDX*2+$L_98ea84]
            xor EDX,EDX
            push EDI
            mov DL,BYTE PTR [EAX-2]
            mov DWORD PTR [ECX+28],EAX
            lea EDX,DWORD PTR [EDX*2+$L_98ea84]
            push EDX
            push ESI
            call FUN_4e4d50

            add ESP,12
            mov EAX,1
            pop EDI
            pop ESI
            ret 
$L_4e4d00 ENDP



ALIGN 16
FUN_4e4d50 PROC

            mov EAX,DWORD PTR [ESP+4]
            push ESI
            cmp EAX,11
            ja $L_4e4e1c

            jmp DWORD PTR [EAX*4+$L_4e4e20]
$L_4e4d65::

            mov EAX,DWORD PTR [ESP+12]
            mov CX,WORD PTR [ESP+16]
            pop ESI
            add WORD PTR [EAX],CX
            ret 
$L_4e4d73::

            mov EAX,DWORD PTR [ESP+12]
            mov DX,WORD PTR [ESP+16]
            pop ESI
            sub WORD PTR [EAX],DX
            ret 
$L_4e4d81::

            mov EAX,DWORD PTR [ESP+12]
            pop ESI
            mov CX,WORD PTR [EAX]
            imul CX,WORD PTR [ESP+12]
            mov WORD PTR [EAX],CX
            ret 
$L_4e4d93::

            mov ECX,DWORD PTR [ESP+12]
            movsx ESI,WORD PTR [ESP+16]
            movsx EAX,WORD PTR [ECX]
            cdq 
            idiv ESI
            pop ESI
            mov WORD PTR [ECX],AX
            ret 
$L_4e4da7::

            mov ECX,DWORD PTR [ESP+12]
            movsx ESI,WORD PTR [ESP+16]
            movsx EAX,WORD PTR [ECX]
            cdq 
            idiv ESI
            pop ESI
            mov WORD PTR [ECX],DX
            ret 
$L_4e4dbb::

            mov EAX,DWORD PTR [ESP+12]
            mov DX,WORD PTR [ESP+16]
            pop ESI
            or WORD PTR [EAX],DX
            ret 
$L_4e4dc9::

            mov EAX,DWORD PTR [ESP+12]
            mov CX,WORD PTR [ESP+16]
            pop ESI
            and WORD PTR [EAX],CX
            ret 
$L_4e4dd7::

            mov EAX,DWORD PTR [ESP+12]
            mov DX,WORD PTR [ESP+16]
            pop ESI
            xor WORD PTR [EAX],DX
            ret 
$L_4e4de5::

            mov EAX,DWORD PTR [ESP+12]
            pop ESI
            mov CX,WORD PTR [EAX]
            not CX
            mov WORD PTR [EAX],CX
            ret 
$L_4e4df4::

            mov EAX,DWORD PTR [ESP+12]
            mov CX,WORD PTR [ESP+16]
            pop ESI
            shl WORD PTR [EAX],CL
            ret 
$L_4e4e02::

            mov EAX,DWORD PTR [ESP+12]
            mov CX,WORD PTR [ESP+16]
            pop ESI
            shr WORD PTR [EAX],CL
            ret 
$L_4e4e10::

            mov EAX,DWORD PTR [ESP+12]
            mov CX,WORD PTR [ESP+16]
            sar WORD PTR [EAX],CL
$L_4e4e1c::

            pop ESI
            ret 
          BYTE 08bH
          BYTE 0ffH
$L_4e4e20 DWORD $L_4e4d65
          DWORD $L_4e4d73
          DWORD $L_4e4d81
          DWORD $L_4e4d93
          DWORD $L_4e4da7
          DWORD $L_4e4dbb
          DWORD $L_4e4dc9
          DWORD $L_4e4dd7
          DWORD $L_4e4de5
          DWORD $L_4e4df4
          DWORD $L_4e4e02
          DWORD $L_4e4e10
$L_4e4e50::

            mov EAX,DWORD PTR [ESP+4]
            inc DWORD PTR [EAX+28]
            call FUN_4e3aa0

            mov EAX,1
            ret 
FUN_4e4d50 ENDP


$L_4e4e70 PROC
            push EBX
            push ESI
            mov ESI,DWORD PTR [$L_989e70]
            xor EBX,EBX
            or ESI,256
            mov DWORD PTR [$L_989e70],ESI
            mov ESI,DWORD PTR [ESP+12]
            mov EAX,DWORD PTR [ESI+28]
            mov BL,BYTE PTR [EAX+1]
            mov ECX,EBX
            and ECX,127
            push ECX
            call FUN_4e4f10

            mov ECX,DWORD PTR [$L_989e70]
            add ESP,4
            or ECX,1048576
            test BL,BL
            mov DWORD PTR [$L_989e70],ECX
            jns $L_4e4ebb

            mov BYTE PTR [$L_98f01b],0
$L_4e4ebb::

            mov EAX,DWORD PTR [ESI+28]
            add EAX,2
            mov DWORD PTR [ESI+28],EAX
            pop ESI
            mov EAX,1
            pop EBX
            ret 
$L_4e4e70 ENDP


$L_4e4ed0 PROC
            xor EAX,EAX
            mov AL,BYTE PTR [$L_695e09]
            push EAX
            call FUN_4e4f10

            mov ECX,DWORD PTR [$L_989e70]
            mov EAX,DWORD PTR [ESP+8]
            and CH,254
            add ESP,4
            or ECX,1048576
            mov DWORD PTR [$L_989e70],ECX
            mov ECX,DWORD PTR [EAX+28]
            inc ECX
            mov DWORD PTR [EAX+28],ECX
            mov EAX,1
            ret 
$L_4e4ed0 ENDP


ALIGN 16
FUN_4e4f10 PROC
            mov AL,BYTE PTR [$L_98eab8]
            mov BYTE PTR [$L_98f01b],1
            mov BYTE PTR [$L_695e09],AL
            mov EAX,DWORD PTR [ESP+4]
            mov WORD PTR [$L_98eab8],AX
            mov DWORD PTR [ESP+4],EAX
            jmp FUN_4c4db0
FUN_4e4f10 ENDP


$L_4e4f40 PROC
            mov EAX,DWORD PTR [ESP+4]
            mov ECX,DWORD PTR [EAX+28]
            mov DL,BYTE PTR [ECX+1]
            cmp DL,1
            mov EDX,DWORD PTR [$L_989e70]
            jne $L_4e4f5a

            and DH,254
            jmp $L_4e4f5d
$L_4e4f5a::
            or DH,1
$L_4e4f5d::

            mov DWORD PTR [$L_989e70],EDX
            mov ECX,DWORD PTR [EAX+28]
            add ECX,2
            mov DWORD PTR [EAX+28],ECX
            mov EAX,1
            ret 
$L_4e4f40 ENDP



$L_4e4f80 PROC

            mov EAX,DWORD PTR [$L_9885bc]
            push EBX
            push ESI
            push EDI
            mov EDI,DWORD PTR [ESP+16]
            mov ESI,DWORD PTR [EAX+40]
            xor ECX,ECX
            xor EDX,EDX
            mov EAX,DWORD PTR [EDI+28]
            mov BL,BYTE PTR [ESI+2]
            cmp BL,255
            mov CL,BYTE PTR [EAX+1]
            mov DL,BYTE PTR [EAX+2]
            lea EAX,DWORD PTR [ESI+2]
            je $L_4e4fdd
$L_4e4fa7::

            xor EBX,EBX
            mov BL,BYTE PTR [EAX]
            mov ESI,EBX
            cmp ESI,ECX
            jne $L_4e4fb5

            mov BYTE PTR [EAX],DL
            jmp $L_4e4fbb
$L_4e4fb5::

            cmp ESI,EDX
            jne $L_4e4fbb

            mov BYTE PTR [EAX],CL
$L_4e4fbb::

            xor EBX,EBX
            mov BL,BYTE PTR [EAX+1]
            mov ESI,EBX
            cmp ESI,ECX
            jne $L_4e4fcb

            mov BYTE PTR [EAX+1],DL
            jmp $L_4e4fd2
$L_4e4fcb::

            cmp ESI,EDX
            jne $L_4e4fd2

            mov BYTE PTR [EAX+1],CL
$L_4e4fd2::

            mov BL,BYTE PTR [EAX+20]
            add EAX,20
            cmp BL,255
            jne $L_4e4fa7
$L_4e4fdd::

            mov ESI,DWORD PTR [$L_9885d4]
            xor EAX,EAX
            mov AL,BYTE PTR [ESI+2]
            cmp EAX,ECX
            jne $L_4e4ff5

            push EDX
            call FUN_4c4db0

            add ESP,4
$L_4e4ff5::

            mov EAX,DWORD PTR [EDI+28]
            add EAX,3
            mov DWORD PTR [EDI+28],EAX
            pop EDI
            pop ESI
            mov EAX,1
            pop EBX
            ret 
$L_4e4f80 ENDP



$L_4e5010 PROC
            mov EAX,DWORD PTR [$L_9885bc]
            push ESI
            push EDI
            mov EDI,DWORD PTR [ESP+12]
            mov EAX,DWORD PTR [EAX+40]
            xor ECX,ECX
            mov ESI,DWORD PTR [EDI+28]
            xor EDX,EDX
            mov DL,BYTE PTR [EAX+2]
            mov CL,BYTE PTR [ESI+1]
            cmp EDX,ECX
            je $L_4e503b
$L_4e502f::

            add EAX,20
            xor EDX,EDX
            mov DL,BYTE PTR [EAX+2]
            cmp EDX,ECX
            jne $L_4e502f
$L_4e503b::

            mov DL,BYTE PTR [ESI+3]
            xor ECX,ECX
            mov CL,BYTE PTR [ESI+2]
            lea ECX,DWORD PTR [ECX+ECX*4]
            mov BYTE PTR [EAX+ECX*4],DL
            mov EAX,DWORD PTR [EDI+28]
            add EAX,4
            mov DWORD PTR [EDI+28],EAX
            pop EDI
            mov EAX,1
            pop ESI
            ret 
$L_4e5010 ENDP


$L_4e5060 PROC
            mov EDX,DWORD PTR [ESP+4]
            xor ECX,ECX
            push EBX
            push ESI
            mov EAX,DWORD PTR [EDX+28]
            push EDI
            xor EBX,EBX
            mov CL,BYTE PTR [EAX+2]
            mov BL,BYTE PTR [EAX+3]
            mov EDI,ECX
            xor ECX,ECX
            mov CX,WORD PTR [EAX+4]
            add EBX,768
            mov ESI,ECX
            add EAX,6
            shl ESI,16
            push ESI
            push EDI
            push EBX
            push 0
            mov DWORD PTR [EDX+28],EAX
            call FUN_4c8902

            mov EAX,DWORD PTR [$L_989e74]
            add ESP,16
            or EAX,ESI
            pop EDI
            mov DWORD PTR [$L_989e74],EAX
            pop ESI
            mov EAX,1
            pop EBX
            ret 
$L_4e5060 ENDP



; 障碍物,检查物体时的信息,死尸,火, 触发的事件
$L_4e50b0 PROC
            mov EAX,DWORD PTR [ESP+4]
            xor EDX,EDX
            mov ECX,DWORD PTR [EAX+28]
            mov DL,BYTE PTR [ECX+1]
            mov ECX,EDX
            mov EDX,DWORD PTR [ECX*4+$L_9887f0]
            test EDX,EDX
            jne $L_4e50cf

            inc BYTE PTR [$L_98e4c8]
$L_4e50cf::

            mov EDX,DWORD PTR [EAX+28]
            add EDX,2
            mov DWORD PTR [ECX*4+$L_9887f0],EDX
            mov ECX,DWORD PTR [EAX+28]
            add ECX,20
            mov DWORD PTR [EAX+28],ECX
            mov EAX,1
            ret 
$L_4e50b0 ENDP


$L_4e50f0 PROC
            mov EAX,DWORD PTR [ESP+4]
            xor EDX,EDX
            mov ECX,DWORD PTR [EAX+28]
            mov DL,BYTE PTR [ECX+1]
            mov ECX,EDX
            mov EDX,DWORD PTR [ECX*4+$L_9887f0]
            test EDX,EDX
            jne $L_4e510f

            inc BYTE PTR [$L_98e4c8]
$L_4e510f::

            mov EDX,DWORD PTR [EAX+28]
            add EDX,2
            mov DWORD PTR [ECX*4+$L_9887f0],EDX
            mov ECX,DWORD PTR [EAX+28]
            mov DL,BYTE PTR [ECX+3]
            or DL,128
            mov BYTE PTR [ECX+3],DL
            mov ECX,DWORD PTR [EAX+28]
            add ECX,28
            mov DWORD PTR [EAX+28],ECX
            mov EAX,1
            ret 
$L_4e50f0 ENDP
          BYTE 090H
          BYTE 090H
          BYTE 090H
          BYTE 090H
          BYTE 090H
          BYTE 090H
          BYTE 090H
          BYTE 090H
          BYTE 090H
$L_4e5140 PROC

            mov EAX,DWORD PTR [ESP+4]
            xor EDX,EDX
            mov ECX,DWORD PTR [EAX+28]
            mov DL,BYTE PTR [ECX+1]
            mov ECX,EDX
            mov EDX,DWORD PTR [ECX*4+$L_9887f0]
            test EDX,EDX
            jne $L_4e515f

            inc BYTE PTR [$L_98e4c8]
$L_4e515f::

            mov EDX,DWORD PTR [EAX+28]
            add EDX,2
            mov DWORD PTR [ECX*4+$L_9887f0],EDX
            mov ECX,DWORD PTR [EAX+28]
            add ECX,32
            mov DWORD PTR [EAX+28],ECX
            mov EAX,1
            ret 
$L_4e5140 ENDP
          BYTE 090H
          BYTE 090H
          BYTE 090H
          BYTE 090H
          BYTE 090H
$L_4e5180 PROC

            mov EAX,DWORD PTR [ESP+4]
            xor EDX,EDX
            mov ECX,DWORD PTR [EAX+28]
            mov DL,BYTE PTR [ECX+1]
            mov ECX,EDX
            mov EDX,DWORD PTR [ECX*4+$L_9887f0]
            test EDX,EDX
            jne $L_4e519f

            inc BYTE PTR [$L_98e4c8]
$L_4e519f::

            mov EDX,DWORD PTR [EAX+28]
            add EDX,2
            mov DWORD PTR [ECX*4+$L_9887f0],EDX
            mov ECX,DWORD PTR [EAX+28]
            mov DL,BYTE PTR [ECX+3]
            or DL,128
            mov BYTE PTR [ECX+3],DL
            mov ECX,DWORD PTR [EAX+28]
            add ECX,40
            mov DWORD PTR [EAX+28],ECX
            mov EAX,1
            ret 
$L_4e5180 ENDP


$L_4e51d0 PROC

            mov ECX,DWORD PTR [ESP+4]
            push EBX
            push ESI
            xor EDX,EDX
            mov ESI,DWORD PTR [ECX+28]
            push EDI
            xor EAX,EAX
            xor EBX,EBX
            mov DL,BYTE PTR [ESI+20]
            mov AX,WORD PTR [ESI+18]
            mov EDI,EDX
            lea EDX,DWORD PTR [ESI+22]
            mov DWORD PTR [ECX+28],EDX
            mov BL,BYTE PTR [ESI+1]
            mov ECX,DWORD PTR [EBX*4+$L_9887f0]
            test ECX,ECX
            jne $L_4e5203

            inc BYTE PTR [$L_98e4c8]
$L_4e5203::

            lea ECX,DWORD PTR [ESI+2]
            mov DWORD PTR [EBX*4+$L_9887f0],ECX
            cmp WORD PTR [$L_98eab4],4
            mov ECX,DWORD PTR [$L_53b248]
            jge $L_4e5223

            mov ECX,DWORD PTR [$L_53b1e0]
$L_4e5223::

            push EAX
            push ECX
            call FUN_503040

            add ESP,8
            test EAX,EAX
            je $L_4e5268

            mov EDX,DWORD PTR [EBX*4+$L_9887f0]
            cmp EDI,32
            mov BYTE PTR [EDX],0
            jae $L_4e525f

            mov EAX,EDI
            shl EAX,6
            sub EAX,EDI
            lea EAX,DWORD PTR [EAX*8+$L_986480]
            mov DWORD PTR [EAX+16700],2147483648
            mov BYTE PTR [EAX+17025],0
$L_4e525f::

            mov EAX,1
$L_4e5264::

            pop EDI
            pop ESI
            pop EBX
            ret 
$L_4e5268::

            cmp EDI,32
            jae $L_4e525f

            mov ECX,EDI
            xor EAX,EAX
            mov AL,BYTE PTR [ESI+21]
            shl ECX,6
            sub ECX,EDI
            test AL,2
            lea ECX,DWORD PTR [ECX*8+$L_986480]
            mov BYTE PTR [ECX+17025],AL
            mov EAX,1
            je $L_4e5264

            pop EDI
            pop ESI
            mov DWORD PTR [ECX+16700],2147483648
            pop EBX
            ret 
$L_4e51d0 ENDP
          BYTE 090H
          BYTE 090H
          BYTE 090H
$L_4e52a0 PROC

            sub ESP,12
            mov EAX,DWORD PTR [ESP+16]
            push EBX
            push EBP
            push ESI
            mov ESI,DWORD PTR [EAX+28]
            push EDI
            xor EDI,EDI
            xor EBX,EBX
            mov DI,WORD PTR [ESI+18]
            mov BL,BYTE PTR [ESI+20]
            lea ECX,DWORD PTR [ESI+24]
            xor EDX,EDX
            mov DWORD PTR [EAX+28],ECX
            mov DL,BYTE PTR [ESI+1]
            mov EBP,EDX
            mov DWORD PTR [ESP+20],EBP
            mov EAX,DWORD PTR [EBP*4+$L_9887f0]
            test EAX,EAX
            jne $L_4e52db

            inc BYTE PTR [$L_98e4c8]
$L_4e52db::

            lea EAX,DWORD PTR [ESI+2]
            mov DWORD PTR [EBP*4+$L_9887f0],EAX
            mov AX,WORD PTR [$L_98eab4]
            cmp AX,4
            jl $L_4e52ff

            mov ECX,DWORD PTR [$L_53b248]
            mov EDX,DWORD PTR [$L_53b254]
            jmp $L_4e530b
$L_4e52ff::

            mov ECX,DWORD PTR [$L_53b1e0]
            mov EDX,DWORD PTR [$L_53b250]
$L_4e530b::

            mov DWORD PTR [ESP+32],ECX
            mov DWORD PTR [ESP+16],EDX
            movsx ECX,WORD PTR [$L_98eab6]
            movsx EDX,AX
            push ECX
            push EDX
            call FUN_4e3f10

            push EAX
            push OFFSET $L_98eba4
            call FUN_503040

            add ESP,16
            test EAX,EAX
            jne $L_4e537d

            mov AL,BYTE PTR [ESI+22]
            mov DWORD PTR [ESP+24],EAX
            call FUN_4b2960

            and EAX,255
            mov ECX,DWORD PTR [ESP+24]
            push EDI
            lea EAX,DWORD PTR [EAX+EAX*4]
            lea EAX,DWORD PTR [EAX+EAX*4]
            shl EAX,2
            cdq 
            and EDX,255
            add EAX,EDX
            sar EAX,8
            cmp EAX,ECX
            jae $L_4e536c

            mov ECX,DWORD PTR [ESP+20]
            push ECX
            jmp $L_4e5371
$L_4e536c::

            mov EDX,DWORD PTR [ESP+36]
            push EDX
$L_4e5371::

            call FUN_502ff0

            mov EBP,DWORD PTR [ESP+28]
            add ESP,8
$L_4e537d::

            mov EAX,DWORD PTR [ESP+32]
            push EDI
            push EAX
            call FUN_503040

            add ESP,8
            test EAX,EAX
            je $L_4e53ca

            mov ECX,DWORD PTR [EBP*4+$L_9887f0]
            cmp EBX,32
            mov BYTE PTR [ECX],0
            jae $L_4e53bd

            mov EDX,EBX
            shl EDX,6
            sub EDX,EBX
            lea EAX,DWORD PTR [EDX*8+$L_986480]
            mov DWORD PTR [EAX+16700],2147483648
            mov BYTE PTR [EAX+17025],0
$L_4e53bd::

            mov EAX,1
$L_4e53c2::

            pop EDI
            pop ESI
            pop EBP
            pop EBX
            add ESP,12
            ret 
$L_4e53ca::

            cmp EBX,32
            jae $L_4e53bd

            mov ECX,EBX
            xor EAX,EAX
            mov AL,BYTE PTR [ESI+21]
            shl ECX,6
            sub ECX,EBX
            test AL,2
            lea ECX,DWORD PTR [ECX*8+$L_986480]
            mov BYTE PTR [ECX+17025],AL
            mov EAX,1
            je $L_4e53c2

            pop EDI
            pop ESI
            pop EBP
            mov DWORD PTR [ECX+16700],2147483648
            pop EBX
            add ESP,12
            ret 
$L_4e52a0 ENDP
          BYTE 090H
          BYTE 090H
          BYTE 090H
          BYTE 090H
          BYTE 090H
          BYTE 090H
          BYTE 090H
          BYTE 090H
          BYTE 090H
          BYTE 090H
          BYTE 090H
          BYTE 090H
          BYTE 090H
$L_4e5410 PROC

            mov ECX,DWORD PTR [ESP+4]
            push EBX
            push ESI
            push EDI
            mov ESI,DWORD PTR [ECX+28]
            xor EAX,EAX
            xor EBX,EBX
            mov DL,BYTE PTR [ESI+3]
            mov AX,WORD PTR [ESI+26]
            or DL,128
            mov BYTE PTR [ESI+3],DL
            xor EDX,EDX
            mov DL,BYTE PTR [ESI+28]
            mov EDI,EDX
            lea EDX,DWORD PTR [ESI+30]
            mov DWORD PTR [ECX+28],EDX
            mov BL,BYTE PTR [ESI+1]
            mov ECX,DWORD PTR [EBX*4+$L_9887f0]
            test ECX,ECX
            jne $L_4e544c

            inc BYTE PTR [$L_98e4c8]
$L_4e544c::

            lea ECX,DWORD PTR [ESI+2]
            mov DWORD PTR [EBX*4+$L_9887f0],ECX
            cmp WORD PTR [$L_98eab4],4
            mov ECX,DWORD PTR [$L_53b248]
            jge $L_4e546c

            mov ECX,DWORD PTR [$L_53b1e0]
$L_4e546c::

            push EAX
            push ECX
            call FUN_503040

            add ESP,8
            test EAX,EAX
            je $L_4e54b1

            mov EDX,DWORD PTR [EBX*4+$L_9887f0]
            cmp EDI,32
            mov BYTE PTR [EDX],0
            jae $L_4e54a8

            mov EAX,EDI
            shl EAX,6
            sub EAX,EDI
            lea EAX,DWORD PTR [EAX*8+$L_986480]
            mov DWORD PTR [EAX+16700],2147483648
            mov BYTE PTR [EAX+17025],0
$L_4e54a8::

            mov EAX,1
$L_4e54ad::

            pop EDI
            pop ESI
            pop EBX
            ret 
$L_4e54b1::

            cmp EDI,32
            jae $L_4e54a8

            mov ECX,EDI
            xor EAX,EAX
            mov AL,BYTE PTR [ESI+29]
            shl ECX,6
            sub ECX,EDI
            test AL,2
            lea ECX,DWORD PTR [ECX*8+$L_986480]
            mov BYTE PTR [ECX+17025],AL
            mov EAX,1
            je $L_4e54ad

            pop EDI
            pop ESI
            mov DWORD PTR [ECX+16700],2147483648
            pop EBX
            ret 
$L_4e5410 ENDP
          BYTE 090H
          BYTE 090H
          BYTE 090H
          BYTE 090H
          BYTE 090H
          BYTE 090H
          BYTE 090H
          BYTE 090H
          BYTE 090H
          BYTE 090H
$L_4e54f0 PROC

            push EDI
            mov EDI,DWORD PTR [ESP+8]
            mov EAX,DWORD PTR [EDI+28]
            movsx ECX,BYTE PTR [EAX+1]
            mov ECX,DWORD PTR [ECX*4+$L_9887f0]
            test ECX,ECX
            je $L_4e5543

            push EBX
            mov BL,BYTE PTR [EAX+2]
            xor EDX,EDX
            mov BYTE PTR [ECX],BL
            mov DL,BYTE PTR [ECX+1]
            push ESI
            mov BL,DL
            and BL,128
            or BL,BYTE PTR [EAX+3]
            test DL,DL
            mov BYTE PTR [ECX+1],BL
            jns $L_4e5527

            add ECX,20
            jmp $L_4e552a
$L_4e5527::

            add ECX,12
$L_4e552a::

            movsx ESI,WORD PTR [EAX+8]
            movsx EDX,WORD PTR [EAX+6]
            mov BX,WORD PTR [EAX+4]
            mov WORD PTR [ECX+4],SI
            mov WORD PTR [ECX],BX
            pop ESI
            mov WORD PTR [ECX+2],DX
            pop EBX
$L_4e5543::

            add EAX,10
            mov DWORD PTR [EDI+28],EAX
            mov EAX,1
            pop EDI
            ret 
$L_4e54f0 ENDP
$L_4e5550 PROC

            push ESI
            mov ESI,DWORD PTR [ESP+8]
            xor ECX,ECX
            mov EAX,DWORD PTR [ESI+28]
            mov CL,BYTE PTR [EAX+1]
            mov EAX,DWORD PTR [ECX*4+$L_9887f0]
            mov DWORD PTR [$L_694998],EAX
            mov CL,BYTE PTR [EAX+1]
            test CL,CL
            lea ECX,DWORD PTR [EAX+20]
            js $L_4e5576

            lea ECX,DWORD PTR [EAX+12]
$L_4e5576::

            xor EDX,EDX
            push ECX
            mov DL,BYTE PTR [EAX]
            call DWORD PTR [EDX*4+$L_53b414]

            mov EAX,DWORD PTR [ESI+28]
            add ESP,4
            add EAX,2
            mov DWORD PTR [ESI+28],EAX
            mov EAX,1
            pop ESI
            ret 
$L_4e5550 ENDP


COMMENT #
  这是 RE2 关卡加载时逐条解析实体表的核心循环体,每次调用处理一个实体,
  处理完后指针后移38字节准备处理下一个。
  输入：关卡 .RDT 脚本中的原始实体数据(38字节/条目)
  输出：填充好的运行时 ENTITY_WORK 结构体(504字节),注册进游戏世界

  流程：读取原始数据 → 定位运行时槽位 → 分派模型资源
        → 写入坐标/碰撞参数 → 版本补丁 → 注册实体
#
$L_4e55a0 PROC
            sub ESP,12
            mov EAX,DWORD PTR [ESP+16]
            push EBX
            push EBP
            push ESI
            push EDI
            mov EDI,DWORD PTR [EAX+28]
            xor ECX,ECX
            xor EAX,EAX
            mov CL,BYTE PTR [EDI+1]
            mov AL,BYTE PTR [EDI+6]
            mov EBP,ECX
            xor ECX,ECX
            mov EDX,EBP
            mov CX,WORD PTR [EDI+8]
            shl EDX,6
            sub EDX,EBP
            mov DWORD PTR [ESP+24],EBP
            lea ESI,DWORD PTR [EDX*8+$L_98a5bc]
            mov DL,BYTE PTR [EDI+2]
            mov BYTE PTR [ESI+262],AL
            xor AX,AX
            mov AL,CL
            xor ECX,ECX
            mov WORD PTR [ESI+270],AX
            mov EAX,DWORD PTR [ESI]
            mov BYTE PTR [ESI+8],DL
            mov CL,BYTE PTR [EDI+7]
            test EAX,EAX
            je $L_4e55fd

            mov DWORD PTR [ESI],0
            jmp $L_4e5606
$L_4e55fd::

            movsx EDX,WORD PTR [EDI+10]
            or EDX,1
            mov DWORD PTR [ESI],EDX
$L_4e5606::

            mov EDX,DWORD PTR [$L_98e4bc]
            lea EAX,DWORD PTR [ESI+504]
            cmp EDX,EAX
            jae $L_4e561b

            mov DWORD PTR [$L_98e4bc],EAX
$L_4e561b::

            movsx EBX,WORD PTR [EDI+16]
            movsx EDX,WORD PTR [EDI+12]
            movsx EAX,WORD PTR [EDI+14]
            mov DWORD PTR [ESP+16],EBX
            mov DWORD PTR [ESP+20],EDX
            movsx EBX,WORD PTR [EDI+18]
            mov DWORD PTR [ESI+16],EDX
            mov EDX,DWORD PTR [ESP+16]
            mov DWORD PTR [ESI+56],EAX
            mov DWORD PTR [ESI+60],EDX
            mov DWORD PTR [ESI+64],EBX
            mov BL,BYTE PTR [$L_98eab6]
            movsx EDX,WORD PTR [$L_98eab4]
            inc EDX
            and EBX,255
            shl EDX,8
            or EDX,EBX
            cmp EDX,771
            jne $L_4e566f

            cmp EBP,4
            jae $L_4e566f

            add EAX,-40
            mov DWORD PTR [ESI+56],EAX
$L_4e566f::

            test BYTE PTR [ESP+20],32
            je $L_4e567c

            mov EAX,DWORD PTR [ESI]
            and AL,254
            mov DWORD PTR [ESI],EAX
$L_4e567c::

            movsx EAX,WORD PTR [EDI+22]
            movsx EDX,WORD PTR [EDI+24]
            mov BX,WORD PTR [EDI+20]
            lea EBP,DWORD PTR [ESI+116]
            mov WORD PTR [ESI+118],AX
            mov WORD PTR [ESI+120],DX
            mov WORD PTR [EBP],BX
            mov BX,WORD PTR [EDI+26]
            movsx EAX,WORD PTR [EDI+28]
            movsx EDX,WORD PTR [EDI+30]
            mov WORD PTR [ESI+148],BX
            mov WORD PTR [ESI+152],AX
            mov WORD PTR [ESI+150],DX
            mov BX,WORD PTR [EDI+32]
            movsx EAX,WORD PTR [EDI+34]
            movsx EDX,WORD PTR [EDI+36]
            mov WORD PTR [ESI+158],AX
            mov EAX,ECX
            and EAX,192
            mov WORD PTR [ESI+154],BX
            cmp EAX,192
            mov WORD PTR [ESI+156],DX
            mov DWORD PTR [ESI+332],1
            ja $L_4e573e

            xor EDX,EDX
            mov DL,BYTE PTR [EAX+$L_4e5804]
            jmp DWORD PTR [EDX*4+$L_4e57f0]
$L_4e5700::

            mov DWORD PTR [ESI+128],OFFSET $L_52d828
            jmp $L_4e573e
$L_4e570c::

            mov DWORD PTR [ESI+128],OFFSET $L_989eb4
            jmp $L_4e573e
$L_4e5718::

            and CL,63
            mov EAX,DWORD PTR [ECX*4+$L_98a0ac]
            add EAX,36
            jmp $L_4e5738
$L_4e5727::

            and CL,63
            mov EDX,ECX
            shl EDX,6
            sub EDX,ECX
            lea EAX,DWORD PTR [EDX*8+$L_98a610]
$L_4e5738::

            mov DWORD PTR [ESI+128],EAX
$L_4e573e::

            mov EDX,DWORD PTR [$L_9885bc]
            mov ECX,DWORD PTR [ESP+24]
            mov EAX,DWORD PTR [EDX+48]
            mov EAX,DWORD PTR [EAX+ECX*8+4]
            cmp EAX,EDX
            je $L_4e575f

            push EAX
            push ECX
            call FUN_4cc710

            add ESP,8
            jmp $L_4e576e
$L_4e575f::

            push ECX
            call FUN_43d540

            add ESP,4
            mov DWORD PTR [ESI],0
$L_4e576e::

            lea EBX,DWORD PTR [ESI+36]
            push EBX
            push EBP
            call _rotate_xyz

            mov EDX,DWORD PTR [ESI+128]
            lea ECX,DWORD PTR [ESI+84]
            push ECX
            push EBX
            push EDX
            call FUN_4c5070

            xor ECX,ECX
            add ESP,20
            mov CL,BYTE PTR [EDI+3]
            xor EDX,EDX
            mov DL,BYTE PTR [EDI+4]
            xor EBX,EBX
            mov BL,BYTE PTR [EDI+5]
            test CL,192
            je $L_4e57cf

            xor EAX,EAX
            mov AL,BYTE PTR [$L_98138a]
            lea EBP,DWORD PTR [EAX+EAX*8]
            lea EAX,DWORD PTR [EAX+EBP*2]
            lea EAX,DWORD PTR [EAX*4+$L_980aa0]
            mov BYTE PTR [EAX],CL
            mov BYTE PTR [EAX+2],DL
            mov BYTE PTR [EAX+3],BL
            mov BYTE PTR [EAX+1],0
            mov DWORD PTR [EAX+72],ESI
            mov AL,BYTE PTR [$L_98138a]
            inc AL
            mov BYTE PTR [$L_98138a],AL
$L_4e57cf::

            push ESI
            call FUN_4cd560

            mov ECX,DWORD PTR [ESP+36]
            add ESP,4
            add EDI,38
            mov EAX,1
            mov DWORD PTR [ECX+28],EDI
            pop EDI
            pop ESI
            pop EBP
            pop EBX
            add ESP,12
            ret 
          BYTE 090H
$L_4e57f0           DWORD $L_4e5700
$L_4e57f4           DWORD $L_4e570c
$L_4e57f8           DWORD $L_4e5718
$L_4e57fc           DWORD $L_4e5727
$L_4e5800           DWORD $L_4e573e
$L_4e5804 DB 000h, 004h, 004h, 004h, 004h, 004h, 004h, 004h
          DB 004h, 004h, 004h, 004h, 004h, 004h, 004h, 004h
          DB 004h, 004h, 004h, 004h, 004h, 004h, 004h, 004h
          DB 004h, 004h, 004h, 004h, 004h, 004h, 004h, 004h
          DB 004h, 004h, 004h, 004h, 004h, 004h, 004h, 004h
          DB 004h, 004h, 004h, 004h, 004h, 004h, 004h, 004h
          DB 004h, 004h, 004h, 004h, 004h, 004h, 004h, 004h
          DB 004h, 004h, 004h, 004h, 004h, 004h, 004h, 004h
          DB 001h, 004h, 004h, 004h, 004h, 004h, 004h, 004h
          DB 004h, 004h, 004h, 004h, 004h, 004h, 004h, 004h
          DB 004h, 004h, 004h, 004h, 004h, 004h, 004h, 004h
          DB 004h, 004h, 004h, 004h, 004h, 004h, 004h, 004h
          DB 004h, 004h, 004h, 004h, 004h, 004h, 004h, 004h
          DB 004h, 004h, 004h, 004h, 004h, 004h, 004h, 004h
          DB 004h, 004h, 004h, 004h, 004h, 004h, 004h, 004h
          DB 004h, 004h, 004h, 004h, 004h, 004h, 004h, 004h
          DB 002h, 004h, 004h, 004h, 004h, 004h, 004h, 004h
          DB 004h, 004h, 004h, 004h, 004h, 004h, 004h, 004h
          DB 004h, 004h, 004h, 004h, 004h, 004h, 004h, 004h
          DB 004h, 004h, 004h, 004h, 004h, 004h, 004h, 004h
          DB 004h, 004h, 004h, 004h, 004h, 004h, 004h, 004h
          DB 004h, 004h, 004h, 004h, 004h, 004h, 004h, 004h
          DB 004h, 004h, 004h, 004h, 004h, 004h, 004h, 004h
          DB 004h, 004h, 004h, 004h, 004h, 004h, 004h, 004h
          DB 003h  ; 0x4E58C5(193)
            nop
            nop
            nop
            nop
            nop
            nop
            nop
            nop
            nop
            nop
            nop
$L_4e55a0 ENDP


$L_4e58d0 PROC

            push EBX
            push EBP
            mov EBP,DWORD PTR [ESP+12]
            xor EAX,EAX
            push ESI
            push EDI
            mov ECX,DWORD PTR [EBP+28]
            xor EDX,EDX
            mov AL,BYTE PTR [ECX+2]
            mov DL,BYTE PTR [ECX+3]
            mov ESI,EAX
            mov EAX,DWORD PTR [EBP+340]
            mov EDI,ESI
            and EDI,192
            cmp EDI,192
            ja $L_4e5993

            xor EBX,EBX
            mov BL,BYTE PTR [EDI+$L_4e59e4]
            jmp DWORD PTR [EBX*4+$L_4e59d0]
$L_4e5910::

            mov DWORD PTR [EAX+128],OFFSET $L_52d828
            jmp $L_4e5993
$L_4e591c::

            test DL,DL
            jns $L_4e593e

            and EDX,127
            lea ESI,DWORD PTR [EDX*8]
            sub ESI,EDX
            lea ESI,DWORD PTR [ESI+ESI*2]
            lea EDX,DWORD PTR [EDX+ESI*2]
            mov ESI,DWORD PTR [$L_98a028]
            lea EDX,DWORD PTR [ESI+EDX*4+72]
            jmp $L_4e598d
$L_4e593e::

            mov DWORD PTR [EAX+128],OFFSET $L_989eb4
            jmp $L_4e5993
$L_4e594a::

            test DL,DL
            jns $L_4e5973

            mov EDI,DWORD PTR [ESI*4+$L_989eac]
            and EDX,127
            lea ESI,DWORD PTR [EDX*8]
            sub ESI,EDX
            lea ESI,DWORD PTR [ESI+ESI*2]
            lea EDX,DWORD PTR [EDX+ESI*2]
            mov ESI,DWORD PTR [EDI+408]
            lea EDX,DWORD PTR [ESI+EDX*4+72]
            jmp $L_4e598d
$L_4e5973::

            mov EDX,DWORD PTR [ESI*4+$L_989eac]
            add EDX,36
            jmp $L_4e598d
$L_4e597f::

            mov EDX,ESI
            shl EDX,6
            sub EDX,ESI
            lea EDX,DWORD PTR [EDX*8+$L_972c10]
$L_4e598d::

            mov DWORD PTR [EAX+128],EDX
$L_4e5993::

            movsx EDX,WORD PTR [ECX+6]
            movsx ESI,WORD PTR [ECX+8]
            movsx EDI,WORD PTR [ECX+4]
            mov DWORD PTR [EAX+56],EDI
            mov DWORD PTR [EAX+60],EDX
            mov DWORD PTR [EAX+64],ESI
            mov DI,WORD PTR [ECX+10]
            movsx EDX,WORD PTR [ECX+12]
            movsx ESI,WORD PTR [ECX+14]
            mov WORD PTR [EAX+116],DI
            add ECX,16
            mov WORD PTR [EAX+118],DX
            mov WORD PTR [EAX+120],SI
            pop EDI
            mov DWORD PTR [EBP+28],ECX
            pop ESI
            pop EBP
            mov EAX,1
            pop EBX
            ret 
$L_4e59d0           DWORD $L_4e5910
$L_4e59d4           DWORD $L_4e591c
$L_4e59d8           DWORD $L_4e594a
$L_4e59dc           DWORD $L_4e597f
$L_4e59e0           DWORD $L_4e5993
$L_4e59e4 DB 000h, 004h, 004h, 004h, 004h, 004h, 004h, 004h
          DB 004h, 004h, 004h, 004h, 004h, 004h, 004h, 004h
          DB 004h, 004h, 004h, 004h, 004h, 004h, 004h, 004h
          DB 004h, 004h, 004h, 004h, 004h, 004h, 004h, 004h
          DB 004h, 004h, 004h, 004h, 004h, 004h, 004h, 004h
          DB 004h, 004h, 004h, 004h, 004h, 004h, 004h, 004h
          DB 004h, 004h, 004h, 004h, 004h, 004h, 004h, 004h
          DB 004h, 004h, 004h, 004h, 004h, 004h, 004h, 004h
          DB 001h, 004h, 004h, 004h, 004h, 004h, 004h, 004h
          DB 004h, 004h, 004h, 004h, 004h, 004h, 004h, 004h
          DB 004h, 004h, 004h, 004h, 004h, 004h, 004h, 004h
          DB 004h, 004h, 004h, 004h, 004h, 004h, 004h, 004h
          DB 004h, 004h, 004h, 004h, 004h, 004h, 004h, 004h
          DB 004h, 004h, 004h, 004h, 004h, 004h, 004h, 004h
          DB 004h, 004h, 004h, 004h, 004h, 004h, 004h, 004h
          DB 004h, 004h, 004h, 004h, 004h, 004h, 004h, 004h
          DB 002h, 004h, 004h, 004h, 004h, 004h, 004h, 004h
          DB 004h, 004h, 004h, 004h, 004h, 004h, 004h, 004h
          DB 004h, 004h, 004h, 004h, 004h, 004h, 004h, 004h
          DB 004h, 004h, 004h, 004h, 004h, 004h, 004h, 004h
          DB 004h, 004h, 004h, 004h, 004h, 004h, 004h, 004h
          DB 004h, 004h, 004h, 004h, 004h, 004h, 004h, 004h
          DB 004h, 004h, 004h, 004h, 004h, 004h, 004h, 004h
          DB 004h, 004h, 004h, 004h, 004h, 004h, 004h, 004h
          DB 003h  ; 0x4E5AA5(193)
            nop
            nop
            nop
            nop
            nop
            nop
            nop
            nop
            nop
            nop
            nop
$L_4e58d0 ENDP
$L_4e5ab0 PROC

            sub ESP,80
            xor ECX,ECX
            xor EAX,EAX
            push EBP
            mov EBP,DWORD PTR [ESP+88]
            push ESI
            push EDI
            mov ESI,DWORD PTR [EBP+28]
            mov CL,BYTE PTR [ESI+2]
            mov AL,BYTE PTR [ESI+3]
            mov EDI,ECX
            and EDI,192
            cmp EDI,192
            ja $L_4e5b64

            xor EDX,EDX
            mov DL,BYTE PTR [EDI+$L_4e5c54]
            jmp DWORD PTR [EDX*4+$L_4e5c40]
$L_4e5aea::

            mov EDI,OFFSET $L_52d828
            jmp $L_4e5b68
$L_4e5af1::

            test AL,AL
            jns $L_4e5b12

            and EAX,127
            lea ECX,DWORD PTR [EAX*8]
            sub ECX,EAX
            lea ECX,DWORD PTR [ECX+ECX*2]
            lea EDX,DWORD PTR [EAX+ECX*2]
            mov EAX,DWORD PTR [$L_98a028]
            lea EDI,DWORD PTR [EAX+EDX*4+72]
            jmp $L_4e5b68
$L_4e5b12::

            mov EDI,OFFSET $L_989eb4
            jmp $L_4e5b68
$L_4e5b19::

            test AL,AL
            jns $L_4e5b42

            mov EDX,DWORD PTR [ECX*4+$L_989eac]
            and EAX,127
            lea ECX,DWORD PTR [EAX*8]
            sub ECX,EAX
            lea ECX,DWORD PTR [ECX+ECX*2]
            lea EAX,DWORD PTR [EAX+ECX*2]
            mov ECX,DWORD PTR [EDX+408]
            lea EDI,DWORD PTR [ECX+EAX*4+72]
            jmp $L_4e5b68
$L_4e5b42::

            mov EDI,DWORD PTR [ECX*4+$L_989eac]
            add EDI,36
            jmp $L_4e5b68
$L_4e5b4e::

            lea EAX,DWORD PTR [ECX-192]
            mov EDX,EAX
            shl EDX,6
            sub EDX,EAX
            lea EDI,DWORD PTR [EDX*8+$L_98a610]
            jmp $L_4e5b68
$L_4e5b64::

            mov EDI,DWORD PTR [ESP+96]
$L_4e5b68::

            movsx EAX,WORD PTR [ESI+6]
            movsx ECX,WORD PTR [ESI+8]
            movsx EDX,WORD PTR [ESI+4]
            mov DWORD PTR [ESP+48],EDX
            mov DWORD PTR [ESP+52],EAX
            mov DWORD PTR [ESP+56],ECX
            mov DX,WORD PTR [ESI+10]
            movsx EAX,WORD PTR [ESI+12]
            movsx ECX,WORD PTR [ESI+14]
            mov WORD PTR [ESP+14],AX
            mov WORD PTR [ESP+16],CX
            lea EAX,DWORD PTR [ESP+28]
            lea ECX,DWORD PTR [ESP+12]
            push EAX
            push ECX
            mov WORD PTR [ESP+20],DX
            call _rotate_xyz

            lea EDX,DWORD PTR [ESP+68]
            lea EAX,DWORD PTR [ESP+36]
            push EDX
            push EAX
            push EDI
            call FUN_4c5070

            mov EDI,DWORD PTR [EBP+340]
            mov ECX,DWORD PTR [ESP+100]
            mov DWORD PTR [EDI+56],ECX
            mov EDX,DWORD PTR [ESP+104]
            mov DWORD PTR [EDI+60],EDX
            mov EAX,DWORD PTR [ESP+108]
            mov DWORD PTR [EDI+64],EAX
            xor EAX,EAX
            lea ECX,DWORD PTR [ESP+40]
            mov WORD PTR [ESP+34],AX
            mov WORD PTR [ESP+36],AX
            lea EDX,DWORD PTR [ESP+32]
            push ECX
            lea EAX,DWORD PTR [ESP+84]
            push EDX
            push EAX
            mov WORD PTR [ESP+44],1000
            call _mat_vec_mul_cut

            lea ECX,DWORD PTR [ESP+44]
            lea EDX,DWORD PTR [ESP+52]
            push ECX
            push EDX
            call FUN_4d7c60

            mov AX,WORD PTR [ESP+52]
            add ESP,40
            mov WORD PTR [EDI+116],AX
            mov CX,WORD PTR [ESP+14]
            mov WORD PTR [EDI+118],CX
            mov EDX,DWORD PTR [ESP+16]
            add EDX,1024
            add ESI,16
            mov WORD PTR [EDI+120],DX
            mov DWORD PTR [EBP+28],ESI
            pop EDI
            pop ESI
            mov EAX,1
            pop EBP
            add ESP,80
            ret 
$L_4e5c40           DWORD $L_4e5aea
$L_4e5c44           DWORD $L_4e5af1
$L_4e5c48           DWORD $L_4e5b19
$L_4e5c4c           DWORD $L_4e5b4e
$L_4e5c50           DWORD $L_4e5b64
$L_4e5c54 DB 000h, 004h, 004h, 004h, 004h, 004h, 004h, 004h
          DB 004h, 004h, 004h, 004h, 004h, 004h, 004h, 004h
          DB 004h, 004h, 004h, 004h, 004h, 004h, 004h, 004h
          DB 004h, 004h, 004h, 004h, 004h, 004h, 004h, 004h
          DB 004h, 004h, 004h, 004h, 004h, 004h, 004h, 004h
          DB 004h, 004h, 004h, 004h, 004h, 004h, 004h, 004h
          DB 004h, 004h, 004h, 004h, 004h, 004h, 004h, 004h
          DB 004h, 004h, 004h, 004h, 004h, 004h, 004h, 004h
          DB 001h, 004h, 004h, 004h, 004h, 004h, 004h, 004h
          DB 004h, 004h, 004h, 004h, 004h, 004h, 004h, 004h
          DB 004h, 004h, 004h, 004h, 004h, 004h, 004h, 004h
          DB 004h, 004h, 004h, 004h, 004h, 004h, 004h, 004h
          DB 004h, 004h, 004h, 004h, 004h, 004h, 004h, 004h
          DB 004h, 004h, 004h, 004h, 004h, 004h, 004h, 004h
          DB 004h, 004h, 004h, 004h, 004h, 004h, 004h, 004h
          DB 004h, 004h, 004h, 004h, 004h, 004h, 004h, 004h
          DB 002h, 004h, 004h, 004h, 004h, 004h, 004h, 004h
          DB 004h, 004h, 004h, 004h, 004h, 004h, 004h, 004h
          DB 004h, 004h, 004h, 004h, 004h, 004h, 004h, 004h
          DB 004h, 004h, 004h, 004h, 004h, 004h, 004h, 004h
          DB 004h, 004h, 004h, 004h, 004h, 004h, 004h, 004h
          DB 004h, 004h, 004h, 004h, 004h, 004h, 004h, 004h
          DB 004h, 004h, 004h, 004h, 004h, 004h, 004h, 004h
          DB 004h, 004h, 004h, 004h, 004h, 004h, 004h, 004h
          DB 003h  ; 0x4E5D15(193)
            nop
            nop
            nop
            nop
            nop
            nop
            nop
            nop
            nop
            nop
            nop
$L_4e5ab0 ENDP


$L_4e5d20 PROC
            mov EDX,DWORD PTR [ESP+4]
            push EBX
            push ESI
            push EDI
            mov EAX,DWORD PTR [EDX+340]
            mov ECX,DWORD PTR [EDX+28]
            add ECX,8
            mov ESI,DWORD PTR [EAX+104]
            mov DWORD PTR [EAX+128],OFFSET $L_52d828
            mov DWORD PTR [EAX+56],ESI
            mov ESI,DWORD PTR [EAX+108]
            mov DWORD PTR [EAX+60],ESI
            mov ESI,DWORD PTR [EAX+112]
            mov DWORD PTR [EAX+64],ESI
            mov BX,WORD PTR [ECX-6]
            movsx EDI,WORD PTR [ECX-2]
            movsx ESI,WORD PTR [ECX-4]
            mov WORD PTR [EAX+120],DI
            mov WORD PTR [EAX+118],SI
            pop EDI
            mov WORD PTR [EAX+116],BX
            pop ESI
            mov DWORD PTR [EDX+28],ECX
            mov EAX,1
            pop EBX
            ret 
$L_4e5d20 ENDP


; set current work object
$L_4e5d80 PROC
            mov EAX,DWORD PTR [ESP+4]
            xor ECX,ECX
            xor EDX,EDX
            push ESI
            mov DWORD PTR [EAX+344],ECX
            mov DWORD PTR [EAX+348],ECX
            mov DWORD PTR [EAX+352],ECX
            mov DWORD PTR [EAX+356],ECX
            mov DWORD PTR [EAX+360],ECX
            mov DWORD PTR [EAX+364],ECX
            mov ECX,DWORD PTR [EAX+28]
            mov DL,BYTE PTR [ECX+1]
            add ECX,3
            mov ESI,EDX
            movsx EDX,BYTE PTR [ECX-1]
            mov DWORD PTR [EAX+28],ECX
            lea ECX,DWORD PTR [ESI-1]
            cmp ECX,4
            pop ESI
            ja $L_4e5e2d

            jmp DWORD PTR [ECX*4+$L_4e5e34]
$L_4e5dcf::

            mov ECX,DWORD PTR [$L_98a0ac]
            mov DWORD PTR [EAX+340],ECX
            mov EAX,1
            ret 
$L_4e5de1::

            mov EDX,DWORD PTR [$L_98a0b0]
            mov DWORD PTR [EAX+340],EDX
            mov EAX,1
            ret 
$L_4e5df3::

            mov ECX,DWORD PTR [EDX*4+$L_98a0b4]
            mov DWORD PTR [EAX+340],ECX
            mov EAX,1
            ret 
$L_4e5e06::

            mov ECX,EDX
            shl ECX,6
            sub ECX,EDX
            lea EDX,DWORD PTR [ECX*8+$L_98a5bc]
            mov DWORD PTR [EAX+340],EDX
            mov EAX,1
            ret 
$L_4e5e20::

            mov ECX,DWORD PTR [EDX*4+$L_99ce40]
            mov DWORD PTR [EAX+340],ECX
$L_4e5e2d::

            mov EAX,1
            ret 

$L_4e5e34 DWORD $L_4e5dcf
          DWORD $L_4e5de1
          DWORD $L_4e5df3
          DWORD $L_4e5e06
          DWORD $L_4e5e20
          BYTE 090H
          BYTE 090H
          BYTE 090H
          BYTE 090H
          BYTE 090H
          BYTE 090H
          BYTE 090H
          BYTE 090H
$L_4e5d80 ENDP


$L_4e5e50 PROC

            push ESI
            mov ESI,DWORD PTR [ESP+8]
            xor ECX,ECX
            push EDI
            mov EAX,DWORD PTR [ESI+28]
            movsx EDX,BYTE PTR [EAX+2]
            movsx EDI,BYTE PTR [EAX+3]
            mov CX,WORD PTR [EAX+4]
            lea EAX,DWORD PTR [EDX*8]
            sub EAX,EDX
            lea EAX,DWORD PTR [EAX+EAX*2]
            lea EDX,DWORD PTR [EDX+EAX*2]
            mov EAX,DWORD PTR [ESI+340]
            mov EAX,DWORD PTR [EAX+408]
            lea EAX,DWORD PTR [EAX+EDX*4]
            mov EDX,6
            cmp EDI,EDX
            ja $L_4e5ebb

            jmp DWORD PTR [EDI*4+$L_4e5f10]
$L_4e5e95::

            mov WORD PTR [EAX],CX
            jmp $L_4e5ebb
$L_4e5e9a::

            mov WORD PTR [EAX+2],CX
            jmp $L_4e5ebb
$L_4e5ea0::

            mov WORD PTR [EAX+112],CX
            jmp $L_4e5ebb
$L_4e5ea6::

            mov BYTE PTR [EAX+114],CL
            jmp $L_4e5ebb
$L_4e5eab::

            mov WORD PTR [EAX+104],CX
            jmp $L_4e5ebb
$L_4e5eb1::

            mov WORD PTR [EAX+106],CX
            jmp $L_4e5ebb
$L_4e5eb7::

            mov WORD PTR [EAX+108],CX
$L_4e5ebb::

            movsx ECX,WORD PTR [$L_98eab4]
            push EBX
            mov BL,BYTE PTR [$L_98eab6]
            inc ECX
            and EBX,255
            shl ECX,8
            or ECX,EBX
            pop EBX
            cmp ECX,1794
            jne $L_4e5f00

            sub EDI,0
            je $L_4e5efa

            dec EDI
            jne $L_4e5f00

            mov BYTE PTR [EAX+114],5
            mov EAX,DWORD PTR [ESI+28]
            add EAX,EDX
            pop EDI
            mov DWORD PTR [ESI+28],EAX
            mov EAX,1
            pop ESI
            ret 
$L_4e5efa::

            mov WORD PTR [EAX+112],1285
$L_4e5f00::

            mov EAX,DWORD PTR [ESI+28]
            pop EDI
            add EAX,EDX
            mov DWORD PTR [ESI+28],EAX
            mov EAX,1
            pop ESI
            ret 
$L_4e5f10 DWORD $L_4e5ea0 ;++
          DWORD $L_4e5ea6
          DWORD $L_4e5e95
          DWORD $L_4e5e9a
          DWORD $L_4e5eab
          DWORD $L_4e5eb1
          DWORD $L_4e5eb7
          BYTE 090H
          BYTE 090H
          BYTE 090H
          BYTE 090H
$L_4e5e50 ENDP


COMMENT #
  Speed_set 从脚本流中读取一个速度参数,写入实体的速度数组。
  int Speed_set(ENTITY_WORK *entity) {
      uint8_t  *script = entity->script_ptr;   // [EDX+28]
      int       index  = script[1];            // 分量索引
      int16_t   value  = *(int16_t*)(script+2);// 速度值

      entity->script_ptr += 4;                 // 消耗指令
      entity->speed[index] = value;            // 写入速度

      return 1;                                // 继续脚本
  }
#
$L_4e5f30 PROC
            mov EDX,DWORD PTR [ESP+4]
            xor ECX,ECX
            push ESI
            mov EAX,DWORD PTR [EDX+28]
            mov CL,BYTE PTR [EAX+1]
            add EAX,4
            mov ESI,ECX
            xor ECX,ECX
            mov CX,WORD PTR [EAX-2]
            mov DWORD PTR [EDX+28],EAX
            mov WORD PTR [EDX+ESI*2+344],CX
            mov EAX,1
            pop ESI
            ret 
$L_4e5f30 ENDP


COMMENT #
  Move_apply(速度→位置)
  经典二阶欧拉积分,RE2用脚本指令驱动物理更新,飞行的炸弹、
  滚落的障碍物、摇摆的吊灯这类需要持续运动的对象都走这套系统。
#
$L_4e5f60 PROC
            mov ECX,DWORD PTR [ESP+4]
            push EBX
            push ESI
            push EDI
            mov EAX,DWORD PTR [ECX+340]
            movsx EDI,WORD PTR [ECX+344]
            mov EBX,DWORD PTR [EAX+56]
            movsx EDX,WORD PTR [ECX+346]
            movsx ESI,WORD PTR [ECX+348]
            add EBX,EDI
            mov EDI,DWORD PTR [EAX+60]
            add EDI,EDX
            mov EDX,DWORD PTR [EAX+64]
            add EDX,ESI
            mov DWORD PTR [EAX+56],EBX
            mov DWORD PTR [EAX+60],EDI
            mov DWORD PTR [EAX+64],EDX
            movsx EDX,WORD PTR [ECX+352]
            movsx ESI,WORD PTR [ECX+354]
            mov DI,WORD PTR [ECX+350]
            add WORD PTR [EAX+118],DX
            add WORD PTR [EAX+116],DI
            add WORD PTR [EAX+120],SI
            mov EAX,DWORD PTR [ECX+28]
            pop EDI
            inc EAX
            pop ESI
            mov DWORD PTR [ECX+28],EAX
            mov EAX,1
            pop EBX
            ret 
$L_4e5f60 ENDP


; Accel_apply(加速度→速度)
$L_4e5fd0 PROC
            mov EAX,DWORD PTR [ESP+4]
            mov CX,WORD PTR [EAX+356]
            mov DX,WORD PTR [EAX+358]
            add WORD PTR [EAX+344],CX
            mov CX,WORD PTR [EAX+360]
            add WORD PTR [EAX+346],DX
            add WORD PTR [EAX+348],CX
            mov DX,WORD PTR [EAX+362]
            mov CX,WORD PTR [EAX+364]
            add WORD PTR [EAX+350],DX
            add WORD PTR [EAX+352],CX
            mov DX,WORD PTR [EAX+366]
            mov ECX,DWORD PTR [EAX+28]
            add WORD PTR [EAX+354],DX
            inc ECX
            mov DWORD PTR [EAX+28],ECX
            mov EAX,1
            ret 
$L_4e5fd0 ENDP


$L_4e6040 PROC
            mov EDX,DWORD PTR [ESP+4]
            push EBX
            push ESI
            push EDI
            mov EAX,DWORD PTR [EDX+28]
            mov ECX,DWORD PTR [EDX+340]
            movsx ESI,WORD PTR [EAX+4]
            movsx EDI,WORD PTR [EAX+6]
            movsx EBX,WORD PTR [EAX+2]
            add EAX,8
            mov DWORD PTR [ECX+56],EBX
            mov DWORD PTR [ECX+60],ESI
            mov DWORD PTR [ECX+64],EDI
            mov DWORD PTR [EDX+28],EAX
            mov BL,BYTE PTR [$L_98eab6]
            movsx EAX,WORD PTR [$L_98eab4]
            inc EAX
            and EBX,255
            shl EAX,8
            or EAX,EBX
            pop EDI
            pop ESI
            cmp EAX,771
            pop EBX
            jne $L_4e60c1

            mov EAX,DWORD PTR [ECX+56]
            test EAX,EAX
            je $L_4e60c1

            mov EDX,DWORD PTR [EDX+340]
            cmp EDX,OFFSET $L_98a5bc
            je $L_4e60bb

            cmp EDX,OFFSET $L_98a7b4
            je $L_4e60bb

            cmp EDX,OFFSET $L_98a9ac
            je $L_4e60bb

            cmp EDX,OFFSET $L_98aba4
            jne $L_4e60c1
$L_4e60bb::

            add EAX,-40
            mov DWORD PTR [ECX+56],EAX
$L_4e60c1::

            mov EAX,1
            ret 
$L_4e6040 ENDP


$L_4e60d0 PROC
            mov EDX,DWORD PTR [ESP+4]
            push EBX
            push ESI
            push EDI
            mov EAX,DWORD PTR [EDX+28]
            mov ECX,DWORD PTR [EDX+340]
            movsx EDI,WORD PTR [EAX+6]
            movsx ESI,WORD PTR [EAX+4]
            mov BX,WORD PTR [EAX+2]
            mov WORD PTR [ECX+120],DI
            add EAX,8
            mov WORD PTR [ECX+116],BX
            mov WORD PTR [ECX+118],SI
            pop EDI
            mov DWORD PTR [EDX+28],EAX
            pop ESI
            mov EAX,1
            pop EBX
            ret 
$L_4e60d0 ENDP


$L_4e6110 PROC
            push ESI
            mov ESI,DWORD PTR [ESP+8]
            xor EDX,EDX
            mov EAX,DWORD PTR [ESI+28]
            movsx ECX,WORD PTR [EAX+2]
            mov DL,BYTE PTR [EAX+1]
            mov EAX,DWORD PTR [ESI+340]
            push ECX
            push EDX
            push EAX
            call FUN_4e6190

            mov EAX,DWORD PTR [ESI+28]
            add ESP,12
            add EAX,4
            mov DWORD PTR [ESI+28],EAX
            mov EAX,1
            pop ESI
            ret 
$L_4e6110 ENDP


$L_4e6150 PROC
            push ESI
            mov ESI,DWORD PTR [ESP+8]
            xor ECX,ECX
            mov EAX,DWORD PTR [ESI+28]
            mov CL,BYTE PTR [EAX+2]
            movsx EDX,WORD PTR [ECX*2+$L_98ea84]
            xor ECX,ECX
            push EDX
            mov CL,BYTE PTR [EAX+1]
            mov EDX,DWORD PTR [ESI+340]
            push ECX
            push EDX
            call FUN_4e6190

            mov EAX,DWORD PTR [ESI+28]
            add ESP,12
            add EAX,3
            mov DWORD PTR [ESI+28],EAX
            mov EAX,1
            pop ESI
            ret 
$L_4e6150 ENDP


ALIGN 16
FUN_4e6190 PROC
            mov EAX,DWORD PTR [ESP+8]
            cmp EAX,43
            ja $L_4e6440

            jmp DWORD PTR [EAX*4+$L_4e6444]
$L_4e61a4::

            mov ECX,DWORD PTR [ESP+4]
            mov AX,WORD PTR [ESP+12]
            mov WORD PTR [ECX],AX
            ret 
$L_4e61b1::

            mov EAX,DWORD PTR [ESP+4]
            mov DX,WORD PTR [ESP+12]
            mov WORD PTR [EAX+2],DX
            ret 
$L_4e61bf::

            mov EDX,DWORD PTR [ESP+4]
            mov CL,BYTE PTR [ESP+12]
            mov BYTE PTR [EDX+4],CL
            ret 
$L_4e61cb::

            mov ECX,DWORD PTR [ESP+4]
            mov AL,BYTE PTR [ESP+12]
            mov BYTE PTR [ECX+5],AL
            ret 
$L_4e61d7::

            mov EAX,DWORD PTR [ESP+4]
            mov DL,BYTE PTR [ESP+12]
            mov BYTE PTR [EAX+6],DL
            ret 
$L_4e61e3::

            mov EDX,DWORD PTR [ESP+4]
            mov CL,BYTE PTR [ESP+12]
            mov BYTE PTR [EDX+7],CL
            ret 
$L_4e61ef::

            mov ECX,DWORD PTR [ESP+4]
            mov AL,BYTE PTR [ESP+12]
            mov BYTE PTR [ECX+8],AL
            ret 
$L_4e61fb::

            mov EAX,DWORD PTR [ESP+4]
            mov DX,WORD PTR [ESP+12]
            mov WORD PTR [EAX+270],DX
            ret 
$L_4e620c::

            mov EDX,DWORD PTR [ESP+4]
            mov CL,BYTE PTR [ESP+12]
            mov BYTE PTR [EDX+10],CL
            ret 
$L_4e6218::

            mov ECX,DWORD PTR [ESP+4]
            mov AL,BYTE PTR [ESP+12]
            mov BYTE PTR [ECX+11],AL
            ret 
$L_4e6224::

            mov EAX,DWORD PTR [ESP+4]
            mov EDX,DWORD PTR [ESP+12]
            mov DWORD PTR [EAX+16],EDX
            ret 
$L_4e6230::

            mov EDX,DWORD PTR [ESP+4]
            mov ECX,DWORD PTR [ESP+12]
            mov DWORD PTR [EDX+56],ECX
            ret 
$L_4e623c::

            mov ECX,DWORD PTR [ESP+4]
            mov EAX,DWORD PTR [ESP+12]
            mov DWORD PTR [ECX+60],EAX
            ret 
$L_4e6248::

            mov EAX,DWORD PTR [ESP+4]
            mov EDX,DWORD PTR [ESP+12]
            mov DWORD PTR [EAX+64],EDX
            ret 
$L_4e6254::

            mov EDX,DWORD PTR [ESP+4]
            mov CX,WORD PTR [ESP+12]
            mov WORD PTR [EDX+116],CX
            ret 
$L_4e6262::

            mov ECX,DWORD PTR [ESP+4]
            mov AX,WORD PTR [ESP+12]
            mov WORD PTR [ECX+118],AX
            ret 
$L_4e6270::

            mov EAX,DWORD PTR [ESP+4]
            mov DX,WORD PTR [ESP+12]
            mov WORD PTR [EAX+120],DX
            ret 
$L_4e627e::

            mov EDX,DWORD PTR [ESP+4]
            mov CL,BYTE PTR [ESP+12]
            mov BYTE PTR [EDX+262],CL
            ret 
$L_4e628d::

            mov ECX,DWORD PTR [ESP+4]
            mov AX,WORD PTR [ESP+12]
            mov WORD PTR [ECX+340],AX
            ret 
$L_4e629e::

            mov EAX,DWORD PTR [ESP+4]
            mov DX,WORD PTR [ESP+12]
            mov WORD PTR [EAX+450],DX
            ret 
$L_4e62af::

            mov EDX,DWORD PTR [ESP+4]
            mov CX,WORD PTR [ESP+12]
            mov WORD PTR [EDX+452],CX
            ret 
$L_4e62c0::

            mov ECX,DWORD PTR [ESP+4]
            mov AX,WORD PTR [ESP+12]
            mov WORD PTR [ECX+454],AX
            ret 
$L_4e62d1::

            mov EAX,DWORD PTR [ESP+4]
            mov DX,WORD PTR [ESP+12]
            mov WORD PTR [EAX+460],DX
            ret 
$L_4e62e2::

            mov EDX,DWORD PTR [ESP+4]
            mov CX,WORD PTR [ESP+12]
            mov WORD PTR [EDX+468],CX
            ret 
$L_4e62f3::

            mov ECX,DWORD PTR [ESP+4]
            mov AX,WORD PTR [ESP+12]
            mov WORD PTR [ECX+470],AX
            ret 
$L_4e6304::

            mov EAX,DWORD PTR [ESP+4]
            mov DX,WORD PTR [ESP+12]
            mov WORD PTR [EAX+472],DX
            ret 
$L_4e6315::

            mov EDX,DWORD PTR [ESP+4]
            mov CX,WORD PTR [ESP+12]
            mov WORD PTR [EDX+474],CX
            ret 
$L_4e6326::

            mov ECX,DWORD PTR [ESP+4]
            mov AL,BYTE PTR [ESP+12]
            mov BYTE PTR [ECX+324],AL
            ret 
$L_4e6335::

            mov EAX,DWORD PTR [ESP+4]
            mov DX,WORD PTR [ESP+12]
            mov WORD PTR [EAX+324],DX
            ret 
$L_4e6346::

            mov EDX,DWORD PTR [ESP+4]
            mov CX,WORD PTR [ESP+12]
            mov WORD PTR [EDX+326],CX
            ret 
$L_4e6357::

            mov ECX,DWORD PTR [ESP+4]
            mov AX,WORD PTR [ESP+12]
            mov WORD PTR [ECX+328],AX
            ret 
$L_4e6368::

            mov EAX,DWORD PTR [ESP+4]
            mov DL,BYTE PTR [ESP+12]
            mov BYTE PTR [EAX+334],DL
            ret 
$L_4e6377::

            mov EDX,DWORD PTR [ESP+4]
            mov CX,WORD PTR [ESP+12]
            mov WORD PTR [EDX+148],CX
            ret 
$L_4e6388::

            mov ECX,DWORD PTR [ESP+4]
            mov AX,WORD PTR [ESP+12]
            mov WORD PTR [ECX+152],AX
            ret 
$L_4e6399::

            mov EAX,DWORD PTR [ESP+4]
            mov DX,WORD PTR [ESP+12]
            mov WORD PTR [EAX+150],DX
            ret 
$L_4e63aa::

            mov EDX,DWORD PTR [ESP+4]
            mov CX,WORD PTR [ESP+12]
            mov WORD PTR [EDX+154],CX
            ret 
$L_4e63bb::

            mov ECX,DWORD PTR [ESP+4]
            mov AX,WORD PTR [ESP+12]
            mov WORD PTR [ECX+158],AX
            ret 
$L_4e63cc::

            mov EAX,DWORD PTR [ESP+4]
            mov DX,WORD PTR [ESP+12]
            mov WORD PTR [EAX+156],DX
            ret 
$L_4e63dd::

            mov EDX,DWORD PTR [ESP+4]
            mov CX,WORD PTR [ESP+12]
            mov WORD PTR [EDX+478],CX
            ret 
$L_4e63ee::

            mov ECX,DWORD PTR [ESP+4]
            mov AX,WORD PTR [ESP+12]
            mov WORD PTR [ECX+280],AX
            ret 
$L_4e63ff::

            mov EAX,DWORD PTR [ESP+4]
            mov DX,WORD PTR [ESP+12]
            mov WORD PTR [EAX+282],DX
            ret 
$L_4e6410::

            mov EDX,DWORD PTR [ESP+4]
            mov CX,WORD PTR [ESP+12]
            mov WORD PTR [EDX+536],CX
            ret 
$L_4e6421::

            mov ECX,DWORD PTR [ESP+4]
            mov AX,WORD PTR [ESP+12]
            mov WORD PTR [ECX+538],AX
            ret 
$L_4e6432::

            mov EAX,DWORD PTR [ESP+4]
            mov DL,BYTE PTR [ESP+12]
            mov BYTE PTR [EAX+467],DL
$L_4e6440::

            ret 
            LEA ECX, [ECX+0]
$L_4e6444 DWORD $L_4e61a4
          DWORD $L_4e61b1
          DWORD $L_4e61bf
          DWORD $L_4e61cb
          DWORD $L_4e61d7
          DWORD $L_4e61e3
          DWORD $L_4e61ef
          DWORD $L_4e61fb
          DWORD $L_4e620c
          DWORD $L_4e6218
          DWORD $L_4e6224
          DWORD $L_4e6230
          DWORD $L_4e623c
          DWORD $L_4e6248
          DWORD $L_4e6254
          DWORD $L_4e6262
          DWORD $L_4e6270
          DWORD $L_4e627e
          DWORD $L_4e628d
          DWORD $L_4e629e
          DWORD $L_4e62af
          DWORD $L_4e62c0
          DWORD $L_4e62d1
          DWORD $L_4e62e2
          DWORD $L_4e62f3
          DWORD $L_4e6304
          DWORD $L_4e6315
          DWORD $L_4e6326
          DWORD $L_4e6335
          DWORD $L_4e6346
          DWORD $L_4e6357
          DWORD $L_4e6368
          DWORD $L_4e6377
          DWORD $L_4e6388
          DWORD $L_4e6399
          DWORD $L_4e63aa
          DWORD $L_4e63bb
          DWORD $L_4e63cc
          DWORD $L_4e63dd
          DWORD $L_4e63ee
          DWORD $L_4e63ff
          DWORD $L_4e6410
          DWORD $L_4e6421
          DWORD $L_4e6432
FUN_4e6190 ENDP
          

$L_4e6500 PROC
            mov ECX,DWORD PTR [ESP+4]
            push ESI
            mov EAX,DWORD PTR [ECX+28]
            movsx ESI,BYTE PTR [EAX+1]
            movsx EDX,BYTE PTR [EAX+2]
            add EAX,3
            push EDX
            mov DWORD PTR [ECX+28],EAX
            mov EAX,DWORD PTR [ECX+340]
            push EAX
            call FUN_4e65f0

            add ESP,8
            mov WORD PTR [ESI*2+$L_98ea84],AX
            mov EAX,1
            pop ESI
            ret 
$L_4e6500 ENDP


$L_4e6540 PROC

            mov ECX,DWORD PTR [ESP+4]
            push ESI
            xor ESI,ESI
            push EDI
            mov EAX,DWORD PTR [ECX+28]
            mov SI,WORD PTR [EAX+2]
            movsx EDI,WORD PTR [EAX+4]
            add EAX,6
            mov DWORD PTR [ECX+28],EAX
            mov ECX,DWORD PTR [ECX+340]
            mov EAX,ESI
            and EAX,255
            push EAX
            push ECX
            call FUN_4e65f0

            sar ESI,8
            add ESP,8
            cmp ESI,6
            ja $L_4e65cf

            jmp DWORD PTR [ESI*4+$L_4e65d4]
$L_4e657f::

            xor EDX,EDX
            cmp EAX,EDI
            sete DL
            pop EDI
            mov EAX,EDX
            pop ESI
            ret 
$L_4e658b::

            xor ECX,ECX
            cmp EAX,EDI
            setg CL
            pop EDI
            mov EAX,ECX
            pop ESI
            ret 
$L_4e6597::

            xor EDX,EDX
            cmp EAX,EDI
            setge DL
            pop EDI
            mov EAX,EDX
            pop ESI
            ret 
$L_4e65a3::

            xor ECX,ECX
            cmp EAX,EDI
            setl CL
            pop EDI
            mov EAX,ECX
            pop ESI
            ret 
$L_4e65af::

            xor EDX,EDX
            cmp EAX,EDI
            setle DL
            pop EDI
            mov EAX,EDX
            pop ESI
            ret 
$L_4e65bb::

            xor ECX,ECX
            cmp EAX,EDI
            setne CL
            pop EDI
            mov EAX,ECX
            pop ESI
            ret 
$L_4e65c7::

            and EAX,EDI
            neg EAX
            sbb EAX,EAX
            neg EAX
$L_4e65cf::

            pop EDI
            pop ESI
            ret 
          BYTE 08bH
          BYTE 0ffH
$L_4e65d4           DWORD $L_4e657f
          DWORD $L_4e658b
          DWORD $L_4e6597
          DWORD $L_4e65a3
          DWORD $L_4e65af
          DWORD $L_4e65bb
          DWORD $L_4e65c7
$L_4e6540 ENDP


ALIGN 16
FUN_4e65f0 PROC

            mov EAX,DWORD PTR [ESP+8]
            cmp EAX,43
            ja $L_4e67fd

            jmp DWORD PTR [EAX*4+$L_4e6800]
case0:
            mov ECX,DWORD PTR [ESP+4]
            xor EAX,EAX
            mov AX,WORD PTR [ECX]
            ret 
case1:
            mov EDX,DWORD PTR [ESP+4]
            xor EAX,EAX
            mov AX,WORD PTR [EDX+2]
            ret 
case2:
            mov ECX,DWORD PTR [ESP+4]
            xor EAX,EAX
            mov AL,BYTE PTR [ECX+4]
            ret 
case3:
            mov EDX,DWORD PTR [ESP+4]
            xor EAX,EAX
            mov AL,BYTE PTR [EDX+5]
            ret 
case4:
            mov ECX,DWORD PTR [ESP+4]
            xor EAX,EAX
            mov AL,BYTE PTR [ECX+6]
            ret 
case5:
            mov EDX,DWORD PTR [ESP+4]
            xor EAX,EAX
            mov AL,BYTE PTR [EDX+7]
            ret 
case6:
            mov ECX,DWORD PTR [ESP+4]
            xor EAX,EAX
            mov AL,BYTE PTR [ECX+8]
            ret 
case7:
            mov EDX,DWORD PTR [ESP+4]
            xor EAX,EAX
            mov AX,WORD PTR [EDX+270] ;10Eh
            ret 
case8:
            mov ECX,DWORD PTR [ESP+4]
            xor EAX,EAX
            mov AL,BYTE PTR [ECX+10]
            ret 
case9:
            mov EDX,DWORD PTR [ESP+4]
            xor EAX,EAX
            mov AL,BYTE PTR [EDX+11]
            ret 
case10:
            mov EAX,DWORD PTR [ESP+4]
            mov EAX,DWORD PTR [EAX+16]
            ret 
case11:
            mov ECX,DWORD PTR [ESP+4]
            mov EAX,DWORD PTR [ECX+56]
            ret 
case12:
            mov EDX,DWORD PTR [ESP+4]
            mov EAX,DWORD PTR [EDX+60]
            ret 
case13:
            mov EAX,DWORD PTR [ESP+4]
            mov EAX,DWORD PTR [EAX+64]
            ret 
case14:
            mov ECX,DWORD PTR [ESP+4]
            movsx EAX,WORD PTR [ECX+116]
            ret 
case15:
            mov EDX,DWORD PTR [ESP+4]
            movsx EAX,WORD PTR [EDX+118]
            ret 
case16:
            mov EAX,DWORD PTR [ESP+4]
            movsx EAX,WORD PTR [EAX+120]
            ret 
case17:
            mov ECX,DWORD PTR [ESP+4]
            xor EAX,EAX
            mov AL,BYTE PTR [ECX+262]
            ret 
case18:
            mov EDX,DWORD PTR [ESP+4]
            xor EAX,EAX
            mov AX,WORD PTR [EDX+340]
            ret 
case19:
            mov EAX,DWORD PTR [ESP+4]
            movsx EAX,WORD PTR [EAX+450]
            ret 
case20:
            mov ECX,DWORD PTR [ESP+4]
            movsx EAX,WORD PTR [ECX+452]
            ret 
case21:
            mov EDX,DWORD PTR [ESP+4]
            movsx EAX,WORD PTR [EDX+454]
            ret 
case22:
            mov ECX,DWORD PTR [ESP+4]
            xor EAX,EAX
            mov AX,WORD PTR [ECX+460] ; 1CCh
            ret 
case23:
            mov EDX,DWORD PTR [ESP+4]
            movsx EAX,WORD PTR [EDX+468]
            ret 
case24:
            mov EAX,DWORD PTR [ESP+4]
            movsx EAX,WORD PTR [EAX+470]
            ret 
case25:
            mov ECX,DWORD PTR [ESP+4]
            movsx EAX,WORD PTR [ECX+472]
            ret 
case26:
            mov EDX,DWORD PTR [ESP+4]
            movsx EAX,WORD PTR [EDX+474]
            ret 
case27:
            mov ECX,DWORD PTR [ESP+4]
            xor EAX,EAX
            mov AL,BYTE PTR [ECX+324]
            ret 
case28:
            mov EDX,DWORD PTR [ESP+4]
            movsx EAX,WORD PTR [EDX+324]
            ret 
case29:
            mov EAX,DWORD PTR [ESP+4]
            movsx EAX,WORD PTR [EAX+326]
            ret 
case30:
            mov ECX,DWORD PTR [ESP+4]
            movsx EAX,WORD PTR [ECX+328]
            ret 
case31:
            mov EDX,DWORD PTR [ESP+4]
            xor EAX,EAX
            mov AL,BYTE PTR [EDX+334] ;14Eh
            ret 
case32:
            mov EAX,DWORD PTR [ESP+4]
            movsx EAX,WORD PTR [EAX+148]
            ret 
case33:
            mov ECX,DWORD PTR [ESP+4]
            movsx EAX,WORD PTR [ECX+152]
            ret 
case34:
            mov EDX,DWORD PTR [ESP+4]
            movsx EAX,WORD PTR [EDX+150]
            ret 
case35:
            mov ECX,DWORD PTR [ESP+4]
            xor EAX,EAX
            mov AX,WORD PTR [ECX+154]
            ret 
case36:
            mov EDX,DWORD PTR [ESP+4]
            xor EAX,EAX
            mov AX,WORD PTR [EDX+158]
            ret 
case37:
            mov ECX,DWORD PTR [ESP+4]
            xor EAX,EAX
            mov AX,WORD PTR [ECX+156]
            ret 
case38:
            mov EDX,DWORD PTR [ESP+4]
            movsx EAX,WORD PTR [EDX+478] ;1DEh
            ret 
case39:
            mov EAX,DWORD PTR [ESP+4]
            movsx EAX,WORD PTR [EAX+280]
            ret 
case40:
            mov ECX,DWORD PTR [ESP+4]
            movsx EAX,WORD PTR [ECX+282] ; 11Ah
            ret 
case41:
            mov EDX,DWORD PTR [ESP+4]
            xor EAX,EAX
            mov AX,WORD PTR [EDX+536]
            ret 
case42:
            mov ECX,DWORD PTR [ESP+4]
            xor EAX,EAX
            mov AX,WORD PTR [ECX+538]
            ret 
case43:
            mov EDX,DWORD PTR [ESP+4]
            xor EAX,EAX
            mov AL,BYTE PTR [EDX+467]
            
$L_4e67fd:: ; default
            ret 

            mov EDI,EDI
            
$L_4e6800   DWORD case0 ;++
            DWORD case1
            DWORD case2
            DWORD case3
            DWORD case4
            DWORD case5
            DWORD case6
            DWORD case7
            DWORD case8
            DWORD case9
            DWORD case10
            DWORD case11
            DWORD case12
            DWORD case13
            DWORD case14
            DWORD case15
            DWORD case16
            DWORD case17
            DWORD case18
            DWORD case19
            DWORD case20
            DWORD case21
            DWORD case22
            DWORD case23
            DWORD case24
            DWORD case25
            DWORD case26
            DWORD case27
            DWORD case28
            DWORD case29
            DWORD case30
            DWORD case31
            DWORD case32
            DWORD case33
            DWORD case34
            DWORD case35
            DWORD case36
            DWORD case37
            DWORD case38
            DWORD case39
            DWORD case40
            DWORD case41
            DWORD case42
            DWORD case43
$L_4e68b0::
            push esi
            push edi
            mov EDI,DWORD PTR [ESP+12]
            xor ESI,ESI
            mov EAX,DWORD PTR [EDI+28]
            mov ECX,DWORD PTR [EDI+340]
            mov SI,WORD PTR [EAX+2]
            movsx EAX,WORD PTR [EAX+4]
            push EAX
            mov EAX,ESI
            sar EAX,8
            push EAX
            push ECX
            call FUN_4e6950
            add ESP,8
            and ESI,255
            push EAX
            push ESI
            call FUN_4e4d50

            mov EAX,DWORD PTR [EDI+28]
            add ESP,12
            add EAX,6
            mov DWORD PTR [EDI+28],EAX
            pop EDI
            mov EAX,1
            pop ESI
            ret 
FUN_4e65f0 ENDP


$L_4e6900 PROC
            push ESI
            mov ESI,DWORD PTR [ESP+8]
            xor ECX,ECX
            mov EAX,DWORD PTR [ESI+28]
            mov CL,BYTE PTR [EAX+3]
            movsx EDX,WORD PTR [ECX*2+$L_98ea84]
            xor ECX,ECX
            push EDX
            mov CL,BYTE PTR [EAX+2]
            mov EDX,DWORD PTR [ESI+340]
            push ECX
            push EDX
            call FUN_4e6950

            add ESP,8
            xor ECX,ECX
            push EAX
            mov EAX,DWORD PTR [ESI+28]
            mov CL,BYTE PTR [EAX+1]
            push ECX
            call FUN_4e4d50

            mov EAX,DWORD PTR [ESI+28]
            add ESP,12
            add EAX,4
            mov DWORD PTR [ESI+28],EAX
            mov EAX,1
            pop ESI
            ret 
$L_4e6900 ENDP


ALIGN 16
FUN_4e6950 PROC
            mov EAX,DWORD PTR [ESP+8]
            cmp EAX,43
            ja $L_4e6b0a

            jmp DWORD PTR [EAX*4+$L_4e6b0c]
$L_4e6964::

            mov EAX,DWORD PTR [ESP+4]
            ret 
$L_4e6969::

            mov EAX,DWORD PTR [ESP+4]
            add EAX,2
            ret 
$L_4e6971::

            mov ECX,DWORD PTR [ESP+4]
            lea EAX,DWORD PTR [ECX+4]
            ret 
$L_4e6979::

            mov EDX,DWORD PTR [ESP+4]
            lea EAX,DWORD PTR [EDX+5]
            ret 
$L_4e6981::

            mov EAX,DWORD PTR [ESP+4]
            add EAX,6
            ret 
$L_4e6989::

            mov ECX,DWORD PTR [ESP+4]
            lea EAX,DWORD PTR [ECX+7]
            ret 
$L_4e6991::

            mov EDX,DWORD PTR [ESP+4]
            lea EAX,DWORD PTR [EDX+8]
            ret 
$L_4e6999::

            mov EAX,DWORD PTR [ESP+4]
            add EAX,270
            ret 
$L_4e69a3::

            mov ECX,DWORD PTR [ESP+4]
            lea EAX,DWORD PTR [ECX+10]
            ret 
$L_4e69ab::

            mov EDX,DWORD PTR [ESP+4]
            lea EAX,DWORD PTR [EDX+11]
            ret 
$L_4e69b3::

            mov EAX,DWORD PTR [ESP+4]
            add EAX,16
            ret 
$L_4e69bb::

            mov ECX,DWORD PTR [ESP+4]
            lea EAX,DWORD PTR [ECX+56]
            ret 
$L_4e69c3::

            mov EDX,DWORD PTR [ESP+4]
            lea EAX,DWORD PTR [EDX+60]
            ret 
$L_4e69cb::

            mov EAX,DWORD PTR [ESP+4]
            add EAX,64
            ret 
$L_4e69d3::

            mov ECX,DWORD PTR [ESP+4]
            lea EAX,DWORD PTR [ECX+116]
            ret 
$L_4e69db::

            mov EDX,DWORD PTR [ESP+4]
            lea EAX,DWORD PTR [EDX+118]
            ret 
$L_4e69e3::

            mov EAX,DWORD PTR [ESP+4]
            add EAX,120
            ret 
$L_4e69eb::

            mov ECX,DWORD PTR [ESP+4]
            lea EAX,DWORD PTR [ECX+262]
            ret 
$L_4e69f6::

            mov EDX,DWORD PTR [ESP+4]
            lea EAX,DWORD PTR [EDX+340]
            ret 
$L_4e6a01::

            mov EAX,DWORD PTR [ESP+4]
            add EAX,450
            ret 
$L_4e6a0b::

            mov ECX,DWORD PTR [ESP+4]
            lea EAX,DWORD PTR [ECX+452]
            ret 
$L_4e6a16::

            mov EDX,DWORD PTR [ESP+4]
            lea EAX,DWORD PTR [EDX+454]
            ret 
$L_4e6a21::

            mov EAX,DWORD PTR [ESP+4]
            add EAX,460
            ret 
$L_4e6a2b::

            mov ECX,DWORD PTR [ESP+4]
            lea EAX,DWORD PTR [ECX+468]
            ret 
$L_4e6a36::

            mov EDX,DWORD PTR [ESP+4]
            lea EAX,DWORD PTR [EDX+470]
            ret 
$L_4e6a41::

            mov EAX,DWORD PTR [ESP+4]
            add EAX,472
            ret 
$L_4e6a4b::

            mov ECX,DWORD PTR [ESP+4]
            lea EAX,DWORD PTR [ECX+474]
            ret 
$L_4e6a56::

            mov EDX,DWORD PTR [ESP+4]
            lea EAX,DWORD PTR [EDX+324]
            ret 
$L_4e6a61::

            mov EAX,DWORD PTR [ESP+4]
            add EAX,324
            ret 
$L_4e6a6b::

            mov ECX,DWORD PTR [ESP+4]
            lea EAX,DWORD PTR [ECX+326]
            ret 
$L_4e6a76::

            mov EDX,DWORD PTR [ESP+4]
            lea EAX,DWORD PTR [EDX+328]
            ret 
$L_4e6a81::

            mov EAX,DWORD PTR [ESP+4]
            add EAX,334
            ret 
$L_4e6a8b::

            mov ECX,DWORD PTR [ESP+4]
            lea EAX,DWORD PTR [ECX+148]
            ret 
$L_4e6a96::

            mov EDX,DWORD PTR [ESP+4]
            lea EAX,DWORD PTR [EDX+152]
            ret 
$L_4e6aa1::

            mov EAX,DWORD PTR [ESP+4]
            add EAX,150
            ret 
$L_4e6aab::

            mov ECX,DWORD PTR [ESP+4]
            lea EAX,DWORD PTR [ECX+154]
            ret 
$L_4e6ab6::

            mov EDX,DWORD PTR [ESP+4]
            lea EAX,DWORD PTR [EDX+158]
            ret 
$L_4e6ac1::

            mov EAX,DWORD PTR [ESP+4]
            add EAX,156
            ret 
$L_4e6acb::

            mov ECX,DWORD PTR [ESP+4]
            lea EAX,DWORD PTR [ECX+478]
            ret 
$L_4e6ad6::

            mov EDX,DWORD PTR [ESP+4]
            lea EAX,DWORD PTR [EDX+280]
            ret 
$L_4e6ae1::

            mov EAX,DWORD PTR [ESP+4]
            add EAX,282
            ret 
$L_4e6aeb::

            mov ECX,DWORD PTR [ESP+4]
            lea EAX,DWORD PTR [ECX+536]
            ret 
$L_4e6af6::

            mov EDX,DWORD PTR [ESP+4]
            lea EAX,DWORD PTR [EDX+538]
            ret 
$L_4e6b01::

            mov EAX,DWORD PTR [ESP+4]
            add EAX,467
$L_4e6b0a::
            ret 

$L_4e6b0c DWORD $L_4e6964
          DWORD $L_4e6969
          DWORD $L_4e6971
          DWORD $L_4e6979
          DWORD $L_4e6981
          DWORD $L_4e6989
          DWORD $L_4e6991
          DWORD $L_4e6999
          DWORD $L_4e69a3
          DWORD $L_4e69ab
          DWORD $L_4e69b3
          DWORD $L_4e69bb
          DWORD $L_4e69c3
          DWORD $L_4e69cb
          DWORD $L_4e69d3
          DWORD $L_4e69db
          DWORD $L_4e69e3
          DWORD $L_4e69eb
          DWORD $L_4e69f6
          DWORD $L_4e6a01
          DWORD $L_4e6a0b
          DWORD $L_4e6a16
          DWORD $L_4e6a21
          DWORD $L_4e6a2b
          DWORD $L_4e6a36
          DWORD $L_4e6a41
          DWORD $L_4e6a4b
          DWORD $L_4e6a56
          DWORD $L_4e6a61
          DWORD $L_4e6a6b
          DWORD $L_4e6a76
          DWORD $L_4e6a81
          DWORD $L_4e6a8b
          DWORD $L_4e6a96
          DWORD $L_4e6aa1
          DWORD $L_4e6aab
          DWORD $L_4e6ab6
          DWORD $L_4e6ac1
          DWORD $L_4e6acb
          DWORD $L_4e6ad6
          DWORD $L_4e6ae1
          DWORD $L_4e6aeb
          DWORD $L_4e6af6
          DWORD $L_4e6b01
          BYTE 090H
          BYTE 090H
          BYTE 090H
          BYTE 090H
FUN_4e6950 ENDP


$L_4e6bc0 PROC
            mov EAX,DWORD PTR [ESP+4]
            mov ECX,DWORD PTR [EAX+28]
            add ECX,8
            mov DWORD PTR [EAX+28],ECX
            mov DX,WORD PTR [ECX-2]
            push EDX
            movsx EDX,WORD PTR [ECX-4]
            movsx ECX,WORD PTR [ECX-6]
            push EDX
            mov EDX,DWORD PTR [EAX+340]
            push ECX
            push EDX
            call FUN_4b2310

            add ESP,16
            neg EAX
            sbb EAX,EAX
            inc EAX
            ret 
$L_4e6bc0 ENDP


COMMENT #
  Sound_emit(3D音效播放指令)
  DI=0 → $L_4e6c2f  原点模式     pos = (0,0,0),无参考实体
  EDI=1 → $L_4e6c37  玩家1        ECX = $L_98a0ac (Leon/Claire实体指针)
  EDI=2 → $L_4e6c3f  玩家2        ECX = $L_98a0b0 (第二角色实体指针)
  EDI=3 → $L_4e6c47  全局对象表   ECX = $L_98a0b4[ECX>>8] (按高字节索引)
  EDI=4 → $L_4e6c53  实体数组     ECX = &$L_98a5bc[(ECX>>8)*504]
  EDI>4 → $L_4e6c66  调用者实体   ECX = [ESP+36] (自身ENTITY_WORK*)
  
  这条指令让脚本能把音效锚定在任意实体的世界坐标上,加上XYZ偏移可以精确控制声源位置。
  五种目标模式覆盖了玩家、NPC、道具、机关等所有实体类型,
  绝对坐标模式则用于环境背景音(水声、风声、机械运转声等固定位置音源)。
#
$L_4e6c00 PROC

            mov EAX,DWORD PTR [ESP+4]
            sub ESP,16
            xor EDX,EDX
            push EBX
            push EBP
            push ESI
            mov ESI,DWORD PTR [EAX+28]
            push EDI
            movsx ECX,WORD PTR [ESI+4]
            mov DL,BYTE PTR [ESI+1]
            mov EDI,ECX
            movsx EAX,WORD PTR [ESI+2]
            and EDI,255
            cmp EDI,4
            ja $L_4e6c66

            jmp DWORD PTR [EDI*4+$L_4e6ccc]
$L_4e6c2f::

            xor EDI,EDI
            xor EBX,EBX
            xor ECX,ECX
            jmp $L_4e6c73
$L_4e6c37::

            mov ECX,DWORD PTR [$L_98a0ac]
            jmp $L_4e6c6a
$L_4e6c3f::

            mov ECX,DWORD PTR [$L_98a0b0]
            jmp $L_4e6c6a
$L_4e6c47::

            shr ECX,8
            mov ECX,DWORD PTR [ECX*4+$L_98a0b4]
            jmp $L_4e6c6a
$L_4e6c53::

            shr ECX,8
            mov EDI,ECX
            shl EDI,6
            sub EDI,ECX
            lea ECX,DWORD PTR [EDI*8+$L_98a5bc]
            jmp $L_4e6c6a
$L_4e6c66::

            mov ECX,DWORD PTR [ESP+36]
$L_4e6c6a::

            mov EDI,DWORD PTR [ECX+56]
            mov EBX,DWORD PTR [ECX+60]
            mov ECX,DWORD PTR [ECX+64]
$L_4e6c73::

            movsx EBP,WORD PTR [ESI+6]
            add EBP,EDI
            mov DWORD PTR [ESP+16],EBP
            movsx EDI,WORD PTR [ESI+8]
            add EDI,EBX
            mov DWORD PTR [ESP+20],EDI
            movsx EDI,WORD PTR [ESI+10]
            add EDI,ECX
            lea ECX,DWORD PTR [ESP+16]
            push ECX
            mov ECX,EAX
            and ECX,255
            mov DWORD PTR [ESP+28],EDI
            shl EDX,8
            or ECX,EDX
            shl ECX,16
            shr EAX,8
            or ECX,EAX
            push ECX
            call FUN_4ed820

            mov EDX,DWORD PTR [ESP+44]
            add ESP,8
            add ESI,12
            mov EAX,1
            mov DWORD PTR [EDX+28],ESI
            pop EDI
            pop ESI
            pop EBP
            pop EBX
            add ESP,16
            ret 
          BYTE 090H
$L_4e6ccc DWORD $L_4e6c2f
          DWORD $L_4e6c37
          DWORD $L_4e6c3f
          DWORD $L_4e6c47
          DWORD $L_4e6c53
$L_4e6c00 ENDP


$L_4e6ce0 PROC
            push ESI
            mov ESI,DWORD PTR [$L_9885bc]
            push EDI
            mov EDI,DWORD PTR [ESP+12]
            mov ESI,DWORD PTR [ESI+32]
            xor EDX,EDX
            mov ECX,DWORD PTR [EDI+28]
            xor EAX,EAX
            mov DL,BYTE PTR [ECX+1]
            mov AX,WORD PTR [ECX+2]
            shl EDX,4
            add ECX,4
            lea ESI,DWORD PTR [EDX+ESI*1+24]
            mov DL,BYTE PTR [ESI]
            xor DL,AL
            and EDX,127
            xor EDX,EAX
            mov EAX,1
            mov WORD PTR [ESI],DX
            mov DWORD PTR [EDI+28],ECX
            pop EDI
            pop ESI
            ret 
$L_4e6ce0 ENDP


$L_4e6d20 PROC
            sub ESP,8
            push EBX
            push EBP
            mov EBP,DWORD PTR [ESP+20]
            push ESI
            xor EAX,EAX
            push EDI
            mov ESI,DWORD PTR [EBP+28]
            xor EBX,EBX
            mov AX,WORD PTR [ESI+4]
            mov BX,WORD PTR [ESI+2]
            mov ECX,EAX
            sar ECX,8
            push ECX
            push EAX
            call FUN_4e7100

            mov DX,WORD PTR [ESI+8]
            xor ECX,ECX
            mov CX,WORD PTR [ESI+6]
            mov DI,WORD PTR [$L_98eab4]
            mov WORD PTR [ESP+24],DX
            mov DX,WORD PTR [ESI+10]
            mov WORD PTR [ESP+26],DX
            mov DX,WORD PTR [ESI+12]
            mov WORD PTR [ESP+28],DX
            add ESP,8
            xor EDX,EDX
            cmp DI,4
            mov DX,WORD PTR [ESI+14]
            jne $L_4e6db8

            cmp WORD PTR [$L_98eab6],0
            je $L_4e6dc8
$L_4e6d87::

            lea EDI,DWORD PTR [ESP+16]
            push EDI
            push EAX
            push EDX
            mov EDX,EBX
            xor DL,DL
            shl EBX,16
$L_4e6d95::

            or EDX,EBX
            shl EDX,8
            or EDX,ECX
            push EDX
$L_4e6d9d::

            call FUN_4b83b0

            add ESP,16
            add ESI,16
            mov DWORD PTR [EBP+28],ESI
            mov EAX,1
            pop EDI
            pop ESI
            pop EBP
            pop EBX
            add ESP,8
            ret 
$L_4e6db8::

            cmp DI,3
            jne $L_4e6d87

            cmp WORD PTR [$L_98eab6],10
            jne $L_4e6d87
$L_4e6dc8::

            lea EDI,DWORD PTR [ESP+16]
            push EDI
            push EAX
            test BL,BL
            push EDX
            je $L_4e6de4

            mov EAX,EBX
            xor AL,AL
            shl EBX,16
            or EAX,EBX
            shl EAX,8
            or EAX,ECX
            push EAX
            jmp $L_4e6d9d
$L_4e6de4::

            movsx EAX,BYTE PTR [$L_68054a]
            mov EDX,EBX
            shl EDX,8
            or EDX,EAX
            shl EDX,8
            xor BL,BL
            jmp $L_4e6d95
$L_4e6d20 ENDP


$L_4e6e00 PROC
            sub ESP,8
            push EBX
            mov EBX,DWORD PTR [ESP+16]
            push ESI
            xor EAX,EAX
            mov ESI,DWORD PTR [EBX+28]
            push EDI
            xor EDI,EDI
            mov AX,WORD PTR [ESI+4]
            mov DI,WORD PTR [ESI+2]
            mov ECX,EAX
            sar ECX,8
            push ECX
            push EAX
            call FUN_4e7100

            mov DX,WORD PTR [ESI+8]
            xor ECX,ECX
            mov CX,WORD PTR [ESI+6]
            mov WORD PTR [ESP+20],DX
            mov DX,WORD PTR [ESI+10]
            mov WORD PTR [ESP+22],DX
            mov DX,WORD PTR [ESI+12]
            mov WORD PTR [ESP+24],DX
            lea EDX,DWORD PTR [ESP+20]
            push EDX
            push EAX
            xor EAX,EAX
            xor EDX,EDX
            mov AX,WORD PTR [ESI+14]
            mov DL,BYTE PTR [ESI+1]
            shl EAX,16
            or EAX,EDX
            push EAX
            mov EAX,EDI
            xor AL,AL
            shl EDI,16
            or EAX,EDI
            shl EAX,8
            or EAX,ECX
            push EAX
            call FUN_4b8c30

            add ESP,24
            add ESI,16
            mov DWORD PTR [EBX+28],ESI
            mov EAX,1
            pop EDI
            pop ESI
            pop EBX
            add ESP,8
            ret 
$L_4e6e00 ENDP


$L_4e6e90 PROC
            sub ESP,16
            push EBX
            mov EBX,DWORD PTR [ESP+24]
            push ESI
            push EDI
            mov ESI,DWORD PTR [EBX+28]
            xor EDI,EDI
            movsx EAX,WORD PTR [ESI+4]
            mov DI,WORD PTR [ESI+2]
            mov ECX,EAX
            sar ECX,8
            push ECX
            push EAX
            call FUN_4e7100

            mov DX,WORD PTR [ESI+8]
            xor ECX,ECX
            mov CX,WORD PTR [ESI+6]
            mov WORD PTR [ESP+28],DX
            mov DX,WORD PTR [ESI+10]
            mov WORD PTR [ESP+30],DX
            mov DX,WORD PTR [ESI+12]
            mov WORD PTR [ESP+32],DX
            mov DX,WORD PTR [ESI+14]
            mov WORD PTR [ESP+20],DX
            mov DX,WORD PTR [ESI+16]
            mov WORD PTR [ESP+22],DX
            mov DX,WORD PTR [ESI+18]
            mov WORD PTR [ESP+24],DX
            lea EDX,DWORD PTR [ESP+20]
            push EDX
            lea EDX,DWORD PTR [ESP+32]
            push EDX
            mov EDX,EDI
            xor DL,DL
            push EAX
            mov AX,WORD PTR [ESI+20]
            shl EDI,16
            or EDX,EDI
            push EAX
            shl EDX,8
            or EDX,ECX
            push EDX
            call FUN_4b8660

            add ESP,28
            add ESI,22
            mov DWORD PTR [EBX+28],ESI
            mov EAX,1
            pop EDI
            pop ESI
            pop EBX
            add ESP,16
            ret 
$L_4e6e90 ENDP


$L_4e6f30 PROC
            sub ESP,16
            push EBX
            mov EBX,DWORD PTR [ESP+24]
            push ESI
            push EDI
            mov ESI,DWORD PTR [EBX+28]
            xor EDI,EDI
            movsx EAX,WORD PTR [ESI+4]
            mov DI,WORD PTR [ESI+2]
            mov ECX,EAX
            sar ECX,8
            push ECX
            push EAX
            call FUN_4e7100

            mov DX,WORD PTR [ESI+8]
            xor ECX,ECX
            mov CX,WORD PTR [ESI+6]
            mov WORD PTR [ESP+28],DX
            mov DX,WORD PTR [ESI+10]
            mov WORD PTR [ESP+30],DX
            mov DX,WORD PTR [ESI+12]
            mov WORD PTR [ESP+32],DX
            mov DX,WORD PTR [ESI+14]
            mov WORD PTR [ESP+20],DX
            mov DX,WORD PTR [ESI+16]
            mov WORD PTR [ESP+22],DX
            mov DX,WORD PTR [ESI+18]
            mov WORD PTR [ESP+24],DX
            lea EDX,DWORD PTR [ESP+20]
            push EDX
            lea EDX,DWORD PTR [ESP+32]
            push EDX
            push EAX
            xor EAX,EAX
            xor EDX,EDX
            mov AX,WORD PTR [ESI+20]
            mov DL,BYTE PTR [ESI+1]
            shl EAX,16
            or EAX,EDX
            push EAX
            mov EAX,EDI
            xor AL,AL
            shl EDI,16
            or EAX,EDI
            shl EAX,8
            or EAX,ECX
            push EAX
            call FUN_4b8940

            add ESP,28
            add ESI,22
            mov DWORD PTR [EBX+28],ESI
            mov EAX,1
            pop EDI
            pop ESI
            pop EBX
            add ESP,16
            ret 
$L_4e6f30 ENDP


$L_4e6fe0 PROC
            push ESI
            mov ESI,DWORD PTR [ESP+8]
            mov EAX,DWORD PTR [ESI+28]
            mov CL,BYTE PTR [EAX+4]
            mov DL,BYTE PTR [EAX+3]
            push ECX
            push EDX
            call FUN_4e7100

            mov ECX,DWORD PTR [ESI+28]
            push EAX
            mov AL,BYTE PTR [ECX+2]
            mov CL,BYTE PTR [ECX+1]
            push EAX
            push ECX
            call FUN_4b91a0

            mov EAX,DWORD PTR [ESI+28]
            add ESP,20
            add EAX,5
            mov DWORD PTR [ESI+28],EAX
            mov EAX,1
            pop ESI
            ret 
$L_4e6fe0 ENDP


$L_4e7020 PROC
            push ESI
            mov ESI,DWORD PTR [ESP+8]
            xor ECX,ECX
            mov EAX,DWORD PTR [ESI+28]
            mov CL,BYTE PTR [EAX+1]
            push ECX
            call FUN_4b9210

            mov EAX,DWORD PTR [ESI+28]
            add ESP,4
            add EAX,2
            mov DWORD PTR [ESI+28],EAX
            mov EAX,1
            pop ESI
            ret 
$L_4e7020 ENDP


$L_4e7050 PROC
            push ESI
            mov ESI,DWORD PTR [ESP+8]
            xor ECX,ECX
            mov EAX,DWORD PTR [ESI+28]
            mov CL,BYTE PTR [EAX+1]
            cmp ECX,6
            je $L_4e70a1

            mov AL,BYTE PTR [EAX+2]
            push EBX
            push EAX
            push ECX
            call FUN_4e7100

            add ESP,8
            mov ECX,OFFSET $L_992c40+1
            mov EDX,96
            xor EBX,EBX
$L_4e707c::

            cmp DWORD PTR [ECX+107],EAX
            jne $L_4e708a

            mov BYTE PTR [ECX],BL
            mov BYTE PTR [ECX-1],BL
            mov WORD PTR [ECX+23],BX
$L_4e708a::

            add ECX,124
            dec EDX
            jne $L_4e707c

            mov EAX,DWORD PTR [ESI+28]
            add EAX,3
            pop EBX
            mov DWORD PTR [ESI+28],EAX
            mov EAX,1
            pop ESI
            ret 
$L_4e70a1::

            call FUN_4b9290

            mov EAX,DWORD PTR [ESI+28]
            add EAX,3
            mov DWORD PTR [ESI+28],EAX
            mov EAX,1
            pop ESI
            ret 
$L_4e7050 ENDP


$L_4e70c0 PROC

            push ESI
            push EDI
            mov EDI,DWORD PTR [ESP+12]
            mov ESI,DWORD PTR [EDI+28]
            mov AL,BYTE PTR [ESI+5]
            mov CL,BYTE PTR [ESI+4]
            push EAX
            push ECX
            call FUN_4e7100

            movzx DX,BYTE PTR [ESI+3]
            mov CL,BYTE PTR [ESI+1]
            push EAX
            mov AL,BYTE PTR [ESI+2]
            push EDX
            push EAX
            push ECX
            call FUN_4b92b0

            add ESP,24
            add ESI,6
            mov DWORD PTR [EDI+28],ESI
            mov EAX,1
            pop EDI
            pop ESI
            ret 
$L_4e70c0 ENDP


ALIGN 16
FUN_4e7100 PROC

            mov AL,BYTE PTR [ESP+4]
            test AL,AL
            js $L_4e7158

            movsx EAX,AL
            cmp EAX,4
            ja $L_4e71aa

            jmp DWORD PTR [EAX*4+$L_4e71ac]
$L_4e711b::

            mov EAX,OFFSET $L_52d828
            ret 
$L_4e7121::

            mov EAX,DWORD PTR [$L_98a0ac]
            add EAX,36
            ret 
$L_4e712a::

            mov ECX,DWORD PTR [$L_98a0b0]
            lea EAX,DWORD PTR [ECX+36]
            ret 
$L_4e7134::

            movsx EDX,BYTE PTR [ESP+8]
            mov EAX,DWORD PTR [EDX*4+$L_98a0b4]
            add EAX,36
            ret 
$L_4e7144::

            movsx EAX,BYTE PTR [ESP+8]
            mov ECX,EAX
            shl ECX,6
            sub ECX,EAX
            lea EAX,DWORD PTR [ECX*8+$L_98a610]
            ret 
$L_4e7158::

            movsx ECX,AL
            mov EAX,ECX
            sar EAX,5
            and EAX,3
            sub EAX,0
            je $L_4e7184

            dec EAX
            je $L_4e717c

            dec EAX
            jne $L_4e718c

            movsx EDX,BYTE PTR [ESP+8]
            mov EDX,DWORD PTR [EDX*4+$L_98a0b4]
            jmp $L_4e7190
$L_4e717c::

            mov EDX,DWORD PTR [$L_98a0b0]
            jmp $L_4e7190
$L_4e7184::

            mov EDX,DWORD PTR [$L_98a0ac]
            jmp $L_4e7190
$L_4e718c::

            mov EDX,DWORD PTR [ESP+8]
$L_4e7190::

            and ECX,31
            mov EDX,DWORD PTR [EDX+408]
            mov EAX,ECX
            lea ECX,DWORD PTR [EAX+EAX*4]
            lea ECX,DWORD PTR [EAX+ECX*2]
            shl ECX,2
            sub ECX,EAX
            lea EAX,DWORD PTR [EDX+ECX*4+72]
$L_4e71aa::
            ret 
$L_4e71ac DWORD $L_4e711b
          DWORD $L_4e7121
          DWORD $L_4e712a
          DWORD $L_4e7134
          DWORD $L_4e7144
FUN_4e7100 ENDP


$L_4e71c0 PROC

            mov ECX,DWORD PTR [ESP+4]
            push EBX
            push ESI
            xor EBX,EBX
            mov ESI,DWORD PTR [ECX+28]
            mov EAX,DWORD PTR [ECX+340]
            push EDI
            xor EDX,EDX
            mov BL,BYTE PTR [ESI+3]
            mov DL,BYTE PTR [ESI+2]
            mov EDI,EBX
            xor EBX,EBX
            mov BH,BYTE PTR [ESI+1]
            mov BYTE PTR [EAX+332],DL
            or EBX,4
            xor EDX,EDX
            mov DWORD PTR [EAX+4],EBX
            mov BYTE PTR [EAX+333],DL
            mov WORD PTR [EAX+460],DI
            mov WORD PTR [EAX+468],DX
            mov WORD PTR [EAX+470],DX
            mov EAX,DWORD PTR [ECX+28]
            add EAX,4
            pop EDI
            mov DWORD PTR [ECX+28],EAX
            pop ESI
            mov EAX,1
            pop EBX
            ret 
$L_4e71c0 ENDP


$L_4e7220 PROC

            push EBP
            mov EBP,DWORD PTR [ESP+8]
            push ESI
            push EDI
            mov EDI,DWORD PTR [EBP+28]
            mov EAX,DWORD PTR [EBP+340]
            xor EDX,EDX
            xor ECX,ECX
            mov DL,BYTE PTR [EDI+2]
            mov CL,BYTE PTR [EAX+8]
            mov ESI,EDX
            mov DL,BYTE PTR [EAX+460]
            test DL,4
            je $L_4e7250

            xor EDX,EDX
            mov DL,BYTE PTR [EAX+5]
            cmp EDX,ESI
            je $L_4e725b
$L_4e7250::

            mov EDX,ESI
            shl EDX,8
            or EDX,4
            mov DWORD PTR [EAX+4],EDX
$L_4e725b::

            add ESI,-4
            cmp ECX,16
            jae $L_4e72c6

            cmp ESI,14
            ja $L_4e7324

            xor EDX,EDX
            mov DL,BYTE PTR [ESI+$L_4e7388]
            jmp DWORD PTR [EDX*4+$L_4e7370]
$L_4e727b::

            movzx CX,BYTE PTR [ECX*2+$L_53b281]
            jmp $L_4e731d
$L_4e7289::

            movzx DX,BYTE PTR [ECX*2+$L_53b381]
            mov WORD PTR [EAX+468],DX
            jmp $L_4e7324
$L_4e729e::

            movzx CX,BYTE PTR [ECX*2+$L_53b2c1]
            jmp $L_4e731d
$L_4e72a9::

            movzx DX,BYTE PTR [ECX*2+$L_53b341]
            mov WORD PTR [EAX+468],DX
            jmp $L_4e7324
$L_4e72bb::

            movzx CX,BYTE PTR [ECX*2+$L_53b301]
            jmp $L_4e731d
$L_4e72c6::

            cmp ESI,14
            ja $L_4e7324

            xor EDX,EDX
            mov DL,BYTE PTR [ESI+$L_4e73b0]
            jmp DWORD PTR [EDX*4+$L_4e7398]
$L_4e72da::

            movzx CX,BYTE PTR [ECX*2+$L_53b1e0+1]
            jmp $L_4e731d
$L_4e72e5::

            movzx DX,BYTE PTR [ECX*2+$L_53b2e1]
            mov WORD PTR [EAX+468],DX
            jmp $L_4e7324
$L_4e72f7::

            movzx CX,BYTE PTR [ECX*2+$L_53b220+1]
            jmp $L_4e731d
$L_4e7302::

            movzx DX,BYTE PTR [ECX*2+$L_53b2a1]
            mov WORD PTR [EAX+468],DX
            jmp $L_4e7324
$L_4e7314::

            movzx CX,BYTE PTR [ECX*2+$L_53b261]
$L_4e731d::

            mov WORD PTR [EAX+468],CX
$L_4e7324::

            mov DL,BYTE PTR [EDI+3]
            xor ECX,ECX
            mov BYTE PTR [EAX+459],DL
            mov WORD PTR [EAX+460],CX
            mov WORD PTR [EAX+470],CX
            mov CX,WORD PTR [EDI+4]
            mov WORD PTR [EAX+452],CX
            mov DX,WORD PTR [EDI+6]
            add EDI,8
            mov WORD PTR [EAX+454],DX
            mov WORD PTR [EAX+472],CX
            mov WORD PTR [EAX+474],DX
            mov DWORD PTR [EBP+28],EDI
            pop EDI
            pop ESI
            mov EAX,1
            pop EBP
            ret 
$L_4e7220 ENDP

$L_4e7370           DWORD $L_4e727b
$L_4e7374           DWORD $L_4e7289
$L_4e7378           DWORD $L_4e729e
$L_4e737c           DWORD $L_4e72a9
$L_4e7380           DWORD $L_4e72bb
$L_4e7384           DWORD $L_4e7324
$L_4e7388 DB 000h, 001h, 005h, 002h, 003h, 004h, 005h, 005h
          DB 005h, 005h, 005h, 005h, 005h, 005h, 000h, 090h  ; 0x4E7398(16)
$L_4e7398           DWORD $L_4e72da
$L_4e739c           DWORD $L_4e72e5
$L_4e73a0           DWORD $L_4e72f7
$L_4e73a4           DWORD $L_4e7302
$L_4e73a8           DWORD $L_4e7314
$L_4e73ac           DWORD $L_4e7324
$L_4e73b0 DB 000h, 001h, 005h, 002h, 003h, 004h, 005h, 005h
          DB 005h, 005h, 005h, 005h, 005h, 005h, 000h, 090h  ; 0x4E73C0(16)

$L_4e73c0 PROC
            mov EAX,DWORD PTR [ESP+4]
            push EBX
            xor EBX,EBX
            mov EDX,DWORD PTR [EAX+28]
            mov ECX,DWORD PTR [EAX+340]
            mov BH,BYTE PTR [EDX+1]
            xor EDX,EDX
            or EBX,4
            mov WORD PTR [ECX+468],DX
            mov DWORD PTR [ECX+4],EBX
            mov WORD PTR [ECX+470],DX
            mov ECX,DWORD PTR [EAX+28]
            pop EBX
            add ECX,2
            mov DWORD PTR [EAX+28],ECX
            mov EAX,1
            ret 
$L_4e73c0 ENDP


$L_4e7400 PROC
            push ECX
            mov EDX,DWORD PTR [ESP+8]
            xor ECX,ECX
            push EBX
            push EBP
            mov EAX,DWORD PTR [EDX+28]
            push ESI
            push EDI
            mov CL,BYTE PTR [EAX+1]
            mov EAX,DWORD PTR [EDX+340]
            mov EDI,ECX
            mov BYTE PTR [EAX+448],128
            mov ECX,DWORD PTR [EDX+28]
            mov ESI,DWORD PTR [EAX+408]
            movsx EBX,WORD PTR [ECX+4]
            movsx EBP,WORD PTR [ECX+2]
            mov DWORD PTR [ESP+24],EBX
            add ESI,1376
            movsx EBX,WORD PTR [ECX+6]
            movsx ECX,WORD PTR [ECX+8]
            cmp EDI,6
            mov DWORD PTR [ESP+16],EBX
            ja $L_4e7487

            jmp DWORD PTR [EDI*4+$L_4e7504]
$L_4e7453::

            mov BYTE PTR [EAX+448],146
            jmp $L_4e7487
$L_4e745c::

            mov BYTE PTR [EAX+448],136
            jmp $L_4e7487
$L_4e7465::

            mov BYTE PTR [EAX+448],170
            jmp $L_4e7487
$L_4e746e::

            mov BYTE PTR [EAX+448],216
            jmp $L_4e7487
$L_4e7477::

            mov BYTE PTR [EAX+448],132
            jmp $L_4e7487
$L_4e7480::

            mov BYTE PTR [EAX+448],0
$L_4e7487::

            mov BX,WORD PTR [ESP+24]
            cmp EDI,5
            mov WORD PTR [EAX+370],BX
            mov BX,WORD PTR [ESP+16]
            mov WORD PTR [EAX+368],BP
            mov WORD PTR [EAX+372],BX
            jne $L_4e74e1

            movsx EDI,BP
            dec EDI
            je $L_4e74cf

            dec EDI
            je $L_4e74c4

            mov EDI,DWORD PTR [ESP+24]
            add EDI,2
            mov WORD PTR [EAX+368],DI
            jmp $L_4e74d8
$L_4e74c4::

            mov WORD PTR [EAX+368],1
            jmp $L_4e74d8
$L_4e74cf::

            mov WORD PTR [EAX+368],0
$L_4e74d8::

            mov WORD PTR [EAX+370],32768
$L_4e74e1::

            mov BYTE PTR [ESI+164],CL
            pop EDI
            shr ECX,8
            mov BYTE PTR [ESI+165],CL
            mov EAX,DWORD PTR [EDX+28]
            add EAX,10
            pop ESI
            mov DWORD PTR [EDX+28],EAX
            pop EBP
            mov EAX,1
            pop EBX
            pop ECX
            ret 
$L_4e7504 DWORD $L_4e7453
          DWORD $L_4e7477
          DWORD $L_4e745c
          DWORD $L_4e7465
          DWORD $L_4e746e
          DWORD $L_4e7477
          DWORD $L_4e7480
$L_4e7400 ENDP


$L_4e7520 PROC
            mov ECX,DWORD PTR [ESP+4]
            mov EAX,DWORD PTR [ECX+340]
            mov DL,BYTE PTR [EAX+8]
            mov DWORD PTR [EAX+4],1
            cmp DL,16
            jae $L_4e7540
            and BYTE PTR [EAX+271],15
$L_4e7540::
            and BYTE PTR [EAX+271],175
            mov BYTE PTR [EAX+448],0
            mov EAX,DWORD PTR [ECX+28]
            inc EAX
            mov DWORD PTR [ECX+28],EAX
            mov EAX,1
            ret 
$L_4e7520 ENDP


$L_4e7560 PROC
            mov ECX,DWORD PTR [ESP+4]
            mov EAX,DWORD PTR [ECX+340]
            mov EDX,DWORD PTR [EAX+4]
            cmp EDX,5124
            jne $L_4e758b

            mov EDX,DWORD PTR [ECX+368]
            mov DWORD PTR [EAX+4],EDX
            mov EAX,DWORD PTR [ECX+28]
            inc EAX
            mov DWORD PTR [ECX+28],EAX
            mov EAX,1
            ret 
$L_4e758b::

            mov DWORD PTR [ECX+368],EDX
            mov DWORD PTR [EAX+4],5124
            mov EAX,DWORD PTR [ECX+28]
            inc EAX
            mov DWORD PTR [ECX+28],EAX
            mov EAX,1
            ret 
$L_4e7560 ENDP


$L_4e75b0 PROC
            mov EAX,DWORD PTR [ESP+4]
            push ESI
            xor EDX,EDX
            xor ECX,ECX
            mov ESI,DWORD PTR [EAX+28]
            mov DL,BYTE PTR [ESI+1]
            mov CX,WORD PTR [ESI+2]
            sub EDX,0
            pop ESI
            je $L_4e7607

            dec EDX
            je $L_4e75eb

            dec EDX
            jne $L_4e7614

            mov EDX,DWORD PTR [EAX+340]
            xor WORD PTR [EDX+460],CX
            mov ECX,DWORD PTR [EAX+28]
            add ECX,4
            mov DWORD PTR [EAX+28],ECX
            mov EAX,1
            ret 
$L_4e75eb::

            mov EDX,DWORD PTR [EAX+340]
            mov WORD PTR [EDX+460],CX
            mov ECX,DWORD PTR [EAX+28]
            add ECX,4
            mov DWORD PTR [EAX+28],ECX
            mov EAX,1
            ret 
$L_4e7607::

            mov EDX,DWORD PTR [EAX+340]
            or WORD PTR [EDX+460],CX
$L_4e7614::

            mov ECX,DWORD PTR [EAX+28]
            add ECX,4
            mov DWORD PTR [EAX+28],ECX
            mov EAX,1
            ret 
$L_4e75b0 ENDP


$L_4e7630 PROC
            mov EAX,DWORD PTR [ESP+4]
            xor EDX,EDX
            mov ECX,DWORD PTR [EAX+28]
            mov DL,BYTE PTR [ECX+1]
            sub EDX,0
            je $L_4e7664

            dec EDX
            jne $L_4e7675

            mov EDX,DWORD PTR [EAX+340]
            mov CX,WORD PTR [ECX+2]
            mov WORD PTR [EDX+470],CX
            mov ECX,DWORD PTR [EAX+28]
            add ECX,4
            mov DWORD PTR [EAX+28],ECX
            mov EAX,1
            ret 
$L_4e7664::

            mov EDX,DWORD PTR [EAX+340]
            mov CX,WORD PTR [ECX+2]
            mov WORD PTR [EDX+468],CX
$L_4e7675::

            mov ECX,DWORD PTR [EAX+28]
            add ECX,4
            mov DWORD PTR [EAX+28],ECX
            mov EAX,1
            ret 
$L_4e7630 ENDP


$L_4e7690 PROC
            mov EAX,DWORD PTR [ESP+4]
            mov ECX,DWORD PTR [EAX+28]
            mov EDX,DWORD PTR [EAX+340]
            mov CL,BYTE PTR [ECX+1]
            mov BYTE PTR [EDX+333],CL
            mov ECX,DWORD PTR [EAX+28]
            add ECX,2
            mov DWORD PTR [EAX+28],ECX
            mov EAX,1
            ret 
$L_4e7690 ENDP


$L_4e76c0 PROC
            mov EAX,DWORD PTR [ESP+4]
            cmp WORD PTR [$L_98eab4],3
            mov EDX,OFFSET $L_98eb34
            mov ECX,DWORD PTR [EAX+28]
            mov DWORD PTR [$L_69499c],ECX
            jge $L_4e76ed

            test DWORD PTR [$L_989e70],33554432
            jne $L_4e76ed

            mov EDX,OFFSET $L_98eb14
$L_4e76ed::

            mov AL,BYTE PTR [ECX+9]
            push EBX
            push EBP
            push ESI
            cmp AL,255
            push EDI
            je $L_4e7715

            and EAX,255
            push EAX
            push EDX
            call FUN_503040

            add ESP,8
            test EAX,EAX
            jne $L_4e7b8d

            mov ECX,DWORD PTR [$L_69499c]
$L_4e7715::

            xor EDX,EDX
            mov DL,BYTE PTR [ECX+3]
            push EDX
            call FUN_4b1f80

            mov EAX,DWORD PTR [$L_68a1b4]
            xor EBX,EBX
            add ESP,4
            cmp BYTE PTR [EAX+19],BL
            jne $L_4e7b95

            mov ECX,DWORD PTR [$L_69499c]
            movsx EDX,BYTE PTR [ECX+2]
            add EDX,2
            cmp EDX,1
            je $L_4e774b

            inc BYTE PTR [$L_989e8b]
$L_4e774b::

            mov ESI,DWORD PTR [$L_9885c4]
            lea EAX,DWORD PTR [EDX*4+$L_98a0b0]
            mov DWORD PTR [EDX*4+$L_98a0ac],ESI
            mov BYTE PTR [ESI+12],DL
            mov EDI,DWORD PTR [$L_9885c4]
            mov ECX,DWORD PTR [$L_9885cc]
            add EDI,584
            cmp ECX,EAX
            mov DWORD PTR [$L_9885c4],EDI
            jae $L_4e7783

            mov DWORD PTR [$L_9885cc],EAX
$L_4e7783::

            mov EBP,DWORD PTR [$L_9885c4]
            mov DWORD PTR [ESI],1
            mov EAX,DWORD PTR [$L_69499c]
            mov CL,BYTE PTR [EAX+7]
            mov BYTE PTR [ESI+506],CL
            mov EDI,DWORD PTR [$L_69499c]
            mov CL,BYTE PTR [$L_695e10]
            mov AL,BYTE PTR [EDI+7]
            cmp CL,AL
            je $L_4e77c0

            cmp CL,BL
            je $L_4e77bb

            mov BYTE PTR [$L_695e11],AL
            jmp $L_4e77c0
$L_4e77bb::

            mov BYTE PTR [$L_695e10],AL
$L_4e77c0::

            mov AX,WORD PTR [EDI+10]
            mov WORD PTR [ESI+68],AX
            movsx EAX,AX
            mov DWORD PTR [ESI+56],EAX
            mov ECX,DWORD PTR [$L_69499c]
            mov AX,WORD PTR [ECX+12]
            mov WORD PTR [ESI+70],AX
            movsx EAX,AX
            mov DWORD PTR [ESI+60],EAX
            mov ECX,DWORD PTR [$L_69499c]
            mov AX,WORD PTR [ECX+14]
            mov WORD PTR [ESI+72],AX
            movsx EAX,AX
            mov DWORD PTR [ESI+64],EAX
            mov ECX,DWORD PTR [$L_69499c]
            mov AX,WORD PTR [ECX+10]
            mov WORD PTR [ESI+280],AX
            mov ECX,DWORD PTR [$L_69499c]
            mov AX,WORD PTR [ECX+14]
            mov WORD PTR [ESI+116],BX
            mov WORD PTR [ESI+282],AX
            mov ECX,DWORD PTR [$L_69499c]
            mov AX,WORD PTR [ECX+16]
            mov WORD PTR [ESI+120],BX
            mov WORD PTR [ESI+118],AX
            mov ECX,DWORD PTR [$L_69499c]
            mov AL,BYTE PTR [ECX+3]
            mov BYTE PTR [ESI+8],AL
            mov ECX,DWORD PTR [$L_69499c]
            mov AX,WORD PTR [ECX+4]
            mov WORD PTR [ESI+270],AX
            mov ECX,DWORD PTR [$L_69499c]
            mov AL,BYTE PTR [ECX+9]
            mov BYTE PTR [ESI+462],AL
            mov ECX,DWORD PTR [$L_69499c]
            mov AL,BYTE PTR [ECX+8]
            mov BYTE PTR [ESI+463],AL
            mov ECX,DWORD PTR [$L_69499c]
            mov AL,BYTE PTR [ECX+6]
            mov BYTE PTR [ESI+262],AL
            mov ECX,DWORD PTR [$L_69499c]
            movzx CX,BYTE PTR [ECX+6]
            mov EAX,ECX
            mov DWORD PTR [ESI+4],EBX
            neg EAX
            shl EAX,2
            sub EAX,ECX
            mov WORD PTR [ESI+464],BX
            mov BYTE PTR [ESI+467],BL
            mov WORD PTR [ESI+340],BX
            lea EAX,DWORD PTR [EAX+EAX*4]
            mov BYTE PTR [ESI+330],BL
            mov WORD PTR [ESI+460],BX
            mov WORD PTR [ESI+478],4096
            lea EAX,DWORD PTR [EAX+EAX*8]
            mov WORD PTR [ESI+468],BX
            shl EAX,3
            mov WORD PTR [ESI+450],AX
            mov AL,BYTE PTR [ESI+8]
            cmp AL,64
            mov WORD PTR [ESI+470],BX
            mov WORD PTR [ESI+472],BX
            mov WORD PTR [ESI+474],BX
            mov DWORD PTR [ESI+516],EBX
            mov DWORD PTR [ESI+520],EBX
            mov DWORD PTR [ESI+484],EBX
            mov WORD PTR [ESI+530],BX
            mov WORD PTR [ESI+268],BX
            mov DWORD PTR [ESI+496],EBX
            mov DWORD PTR [ESI+500],EBX
            jae $L_4e791e

            mov BYTE PTR [ESI+9],4
            jmp $L_4e7922
$L_4e791e::

            mov BYTE PTR [ESI+9],128
$L_4e7922::

            mov ECX,450
            and DL,7
            mov DWORD PTR [ESI+488],EBX
            mov WORD PTR [ESI+148],BX
            mov WORD PTR [ESI+152],64006
            mov WORD PTR [ESI+150],BX
            mov WORD PTR [ESI+154],CX
            mov WORD PTR [ESI+158],1530
            mov WORD PTR [ESI+156],CX
            mov WORD PTR [ESI+144],CX
            mov WORD PTR [ESI+146],CX
            mov BYTE PTR [ESI+336],DL
            cmp AL,BYTE PTR [$L_695e0a]
            je $L_4e7a40

            mov EDI,DWORD PTR [$L_695e00]
            mov BYTE PTR [$L_695e0a],AL
            mov CL,BYTE PTR [ESI+463]
            xor EDX,EDX
            mov BYTE PTR [$L_695e0b],CL
            mov DWORD PTR [$L_695e00],ESI
            mov DL,BYTE PTR [ESI+8]
            push EDX
            call FUN_4e3980

            mov ECX,DWORD PTR [$L_695e0c]
            add ESP,4
            and ECX,255
            cmp EAX,ECX
            je $L_4e79c0

            and BYTE PTR [ESI+463],127
$L_4e79c0::

            xor EDX,EDX
            push EBP
            mov DL,BYTE PTR [$L_695e0a]
            push ESI
            push EDX
            mov BYTE PTR [$L_695e0c],AL
            call FUN_4b1530

            mov EBP,EAX
            mov EAX,DWORD PTR [$L_68a1b4]
            add ESP,12
            cmp BYTE PTR [EAX+19],BL
            jne $L_4e7b95

            mov ECX,DWORD PTR [$L_9885bc]
            mov BYTE PTR [$L_695e08],BL
            mov EDX,DWORD PTR [ECX+76]
            mov DWORD PTR [$L_695dfc],EDX
            mov AL,BYTE PTR [ESI+463]
            test AL,AL
            jns $L_4e7b0d

            mov EAX,DWORD PTR [EDI+384]
            mov DWORD PTR [ESI+384],EAX
            mov ECX,DWORD PTR [EDI+388]
            mov DWORD PTR [ESI+388],ECX
            mov EDX,DWORD PTR [EDI+392]
            mov DWORD PTR [ESI+392],EDX
            mov EAX,DWORD PTR [EDI+396]
            mov DWORD PTR [ESI+396],EAX
            jmp $L_4e7b0d
$L_4e7a40::

            mov ECX,DWORD PTR [$L_695e00]
            mov EDX,DWORD PTR [ECX+264]
            mov DWORD PTR [ESI+264],EDX
            mov EAX,DWORD PTR [$L_695e00]
            mov ECX,DWORD PTR [EAX+380]
            mov DWORD PTR [ESI+380],ECX
            mov EDX,DWORD PTR [$L_695e00]
            mov EAX,DWORD PTR [EDX+20]
            mov DWORD PTR [ESI+20],EAX
            mov ECX,DWORD PTR [$L_695e00]
            mov EDX,DWORD PTR [ECX+28]
            mov DWORD PTR [ESI+28],EDX
            mov EAX,DWORD PTR [$L_695e00]
            mov ECX,DWORD PTR [EAX+384]
            mov DWORD PTR [ESI+384],ECX
            mov EDX,DWORD PTR [$L_695e00]
            mov EAX,DWORD PTR [EDX+388]
            mov DWORD PTR [ESI+388],EAX
            mov ECX,DWORD PTR [$L_695e00]
            mov EDX,DWORD PTR [ECX+392]
            mov DWORD PTR [ESI+392],EDX
            mov EAX,DWORD PTR [$L_695e00]
            mov ECX,DWORD PTR [EAX+396]
            mov DWORD PTR [ESI+396],ECX
            mov EDX,DWORD PTR [$L_695e00]
            mov EAX,DWORD PTR [EDX+444]
            mov DWORD PTR [ESI+444],EAX
            mov ECX,DWORD PTR [$L_695e00]
            mov DL,BYTE PTR [ECX+260]
            mov BYTE PTR [ESI+260],DL
            mov EAX,DWORD PTR [$L_695e00]
            xor EDX,EDX
            mov CL,BYTE PTR [EAX+261]
            xor EAX,EAX
            mov AL,BYTE PTR [ESI+12]
            mov BYTE PTR [ESI+261],CL
            mov DL,BYTE PTR [$L_695e0a]
            push EDX
            push EAX
            call FUN_443e00

            add ESP,8
$L_4e7b0d::

            push EBP
            push ESI
            call FUN_4c11b0

            mov ECX,DWORD PTR [ESI+264]
            push EBX
            push ECX
            push EAX
            push ESI
            call FUN_4c11f0

            mov EDX,DWORD PTR [ESI+444]
            mov EDI,EAX
            push EDX
            push ESI
            call FUN_4dfbf0

            mov EAX,DWORD PTR [$L_989e70]
            add ESP,32
            test EAX,65536
            mov DWORD PTR [$L_9885c4],EDI
            je $L_4e7b56

            push EDI
            push ESI
            call FUN_4c51f0

            add ESP,8
            mov DWORD PTR [$L_9885c4],EAX
$L_4e7b56::

            mov BYTE PTR [ESI+332],BL
            mov EAX,DWORD PTR [$L_69499c]
            test BYTE PTR [ESI+271],64
            mov CX,WORD PTR [EAX+18]
            mov WORD PTR [ESI+344],CX
            mov EDX,DWORD PTR [$L_69499c]
            mov AX,WORD PTR [EDX+20]
            mov WORD PTR [ESI+346],AX
            je $L_4e7b8d

            mov BYTE PTR [ESI+448],146
$L_4e7b8d::

            mov EAX,DWORD PTR [ESP+20]
            add DWORD PTR [EAX+28],22
$L_4e7b95::

            pop EDI
            pop ESI
            pop EBP
            mov EAX,1
            pop EBX
            ret 
$L_4e76c0 ENDP


$L_4e7ba0 PROC
            mov EAX,DWORD PTR [ESP+4]
            push EBX
            push EBP
            push ESI
            mov ECX,DWORD PTR [EAX+28]
            mov AX,WORD PTR [$L_98eab4]
            cmp AX,3
            push EDI
            mov DWORD PTR [$L_69499c],ECX
            jl $L_4e7bc9

            mov EDI,OFFSET $L_98eb34
            mov EBX,OFFSET $L_98ee70
            jmp $L_4e7beb
$L_4e7bc9::

            test DWORD PTR [$L_989e70],33554432
            je $L_4e7be1

            mov EDI,OFFSET $L_98eb34
            mov EBX,OFFSET $L_98ee70
            jmp $L_4e7beb
$L_4e7be1::

            mov EDI,OFFSET $L_98eb14
            mov EBX,OFFSET $L_98ee50
$L_4e7beb::

            movsx EDX,WORD PTR [$L_98eab6]
            movsx EAX,AX
            push EDX
            push EAX
            call FUN_4e3f10

            push EAX
            push OFFSET $L_98eba4
            call FUN_503040

            add ESP,16
            test EAX,EAX
            jne $L_4e7c61

            mov EDX,DWORD PTR [$L_69499c]
            xor ECX,ECX
            mov CL,BYTE PTR [EDX+22]
            mov ESI,ECX
            call FUN_4b2960

            and EAX,255
            lea EAX,DWORD PTR [EAX+EAX*4]
            lea EAX,DWORD PTR [EAX+EAX*4]
            shl EAX,2
            cdq 
            and EDX,255
            add EAX,EDX
            sar EAX,8
            cmp EAX,ESI
            jae $L_4e7c4d

            mov ECX,DWORD PTR [$L_69499c]
            xor EAX,EAX
            mov AL,BYTE PTR [ECX+9]
            push EAX
            push EBX
            jmp $L_4e7c59
$L_4e7c4d::

            mov EAX,DWORD PTR [$L_69499c]
            xor EDX,EDX
            mov DL,BYTE PTR [EAX+9]
            push EDX
            push EDI
$L_4e7c59::

            call FUN_502ff0

            add ESP,8
$L_4e7c61::

            mov ECX,DWORD PTR [$L_69499c]
            mov AL,BYTE PTR [ECX+9]
            cmp AL,255
            je $L_4e7c85

            and EAX,255
            push EAX
            push EDI
            call FUN_503040

            add ESP,8
            test EAX,EAX
            jne $L_4e8103
$L_4e7c85::

            mov EAX,DWORD PTR [$L_69499c]
            xor EDX,EDX
            mov DL,BYTE PTR [EAX+3]
            push EDX
            call FUN_4b1f80

            mov ECX,DWORD PTR [$L_68a1b4]
            xor EBX,EBX
            add ESP,4
            cmp BYTE PTR [ECX+19],BL
            jne $L_4e810b

            mov EDX,DWORD PTR [$L_69499c]
            movsx EDX,BYTE PTR [EDX+2]
            add EDX,2
            cmp EDX,1
            je $L_4e7cc1

            inc BYTE PTR [$L_989e8b]
$L_4e7cc1::

            mov ESI,DWORD PTR [$L_9885c4]
            lea EAX,DWORD PTR [EDX*4+$L_98a0b0]
            mov DWORD PTR [EDX*4+$L_98a0ac],ESI
            mov BYTE PTR [ESI+12],DL
            mov EDI,DWORD PTR [$L_9885c4]
            mov ECX,DWORD PTR [$L_9885cc]
            add EDI,584
            cmp ECX,EAX
            mov DWORD PTR [$L_9885c4],EDI
            jae $L_4e7cf9

            mov DWORD PTR [$L_9885cc],EAX
$L_4e7cf9::

            mov EBP,DWORD PTR [$L_9885c4]
            mov DWORD PTR [ESI],1
            mov EAX,DWORD PTR [$L_69499c]
            mov CL,BYTE PTR [EAX+7]
            mov BYTE PTR [ESI+506],CL
            mov EDI,DWORD PTR [$L_69499c]
            mov CL,BYTE PTR [$L_695e10]
            mov AL,BYTE PTR [EDI+7]
            cmp CL,AL
            je $L_4e7d36

            cmp CL,BL
            je $L_4e7d31

            mov BYTE PTR [$L_695e11],AL
            jmp $L_4e7d36
$L_4e7d31::

            mov BYTE PTR [$L_695e10],AL
$L_4e7d36::

            mov AX,WORD PTR [EDI+10]
            mov WORD PTR [ESI+68],AX
            movsx EAX,AX
            mov DWORD PTR [ESI+56],EAX
            mov ECX,DWORD PTR [$L_69499c]
            mov AX,WORD PTR [ECX+12]
            mov WORD PTR [ESI+70],AX
            movsx EAX,AX
            mov DWORD PTR [ESI+60],EAX
            mov ECX,DWORD PTR [$L_69499c]
            mov AX,WORD PTR [ECX+14]
            mov WORD PTR [ESI+72],AX
            movsx EAX,AX
            mov DWORD PTR [ESI+64],EAX
            mov ECX,DWORD PTR [$L_69499c]
            mov AX,WORD PTR [ECX+10]
            mov WORD PTR [ESI+280],AX
            mov ECX,DWORD PTR [$L_69499c]
            mov AX,WORD PTR [ECX+14]
            mov WORD PTR [ESI+116],BX
            mov WORD PTR [ESI+282],AX
            mov ECX,DWORD PTR [$L_69499c]
            mov AX,WORD PTR [ECX+16]
            mov WORD PTR [ESI+120],BX
            mov WORD PTR [ESI+118],AX
            mov ECX,DWORD PTR [$L_69499c]
            mov AL,BYTE PTR [ECX+3]
            mov BYTE PTR [ESI+8],AL
            mov ECX,DWORD PTR [$L_69499c]
            mov AX,WORD PTR [ECX+4]
            mov WORD PTR [ESI+270],AX
            mov ECX,DWORD PTR [$L_69499c]
            mov AL,BYTE PTR [ECX+9]
            mov BYTE PTR [ESI+462],AL
            mov ECX,DWORD PTR [$L_69499c]
            mov AL,BYTE PTR [ECX+8]
            mov BYTE PTR [ESI+463],AL
            mov ECX,DWORD PTR [$L_69499c]
            mov AL,BYTE PTR [ECX+6]
            mov BYTE PTR [ESI+262],AL
            mov ECX,DWORD PTR [$L_69499c]
            movzx CX,BYTE PTR [ECX+6]
            mov EAX,ECX
            mov DWORD PTR [ESI+4],EBX
            neg EAX
            shl EAX,2
            sub EAX,ECX
            mov WORD PTR [ESI+464],BX
            mov BYTE PTR [ESI+467],BL
            mov WORD PTR [ESI+340],BX
            lea EAX,DWORD PTR [EAX+EAX*4]
            mov BYTE PTR [ESI+330],BL
            mov WORD PTR [ESI+460],BX
            mov WORD PTR [ESI+478],4096
            lea EAX,DWORD PTR [EAX+EAX*8]
            mov WORD PTR [ESI+468],BX
            shl EAX,3
            mov WORD PTR [ESI+450],AX
            mov AL,BYTE PTR [ESI+8]
            cmp AL,64
            mov WORD PTR [ESI+470],BX
            mov WORD PTR [ESI+472],BX
            mov WORD PTR [ESI+474],BX
            mov DWORD PTR [ESI+516],EBX
            mov DWORD PTR [ESI+520],EBX
            mov DWORD PTR [ESI+484],EBX
            mov WORD PTR [ESI+530],BX
            mov WORD PTR [ESI+268],BX
            mov DWORD PTR [ESI+496],EBX
            mov DWORD PTR [ESI+500],EBX
            jae $L_4e7e94

            mov BYTE PTR [ESI+9],4
            jmp $L_4e7e98
$L_4e7e94::

            mov BYTE PTR [ESI+9],128
$L_4e7e98::

            mov ECX,450
            and DL,7
            mov DWORD PTR [ESI+488],EBX
            mov WORD PTR [ESI+148],BX
            mov WORD PTR [ESI+152],64006
            mov WORD PTR [ESI+150],BX
            mov WORD PTR [ESI+154],CX
            mov WORD PTR [ESI+158],1530
            mov WORD PTR [ESI+156],CX
            mov WORD PTR [ESI+144],CX
            mov WORD PTR [ESI+146],CX
            mov BYTE PTR [ESI+336],DL
            cmp AL,BYTE PTR [$L_695e0a]
            je $L_4e7fb6

            mov EDI,DWORD PTR [$L_695e00]
            mov BYTE PTR [$L_695e0a],AL
            mov CL,BYTE PTR [ESI+463]
            xor EDX,EDX
            mov BYTE PTR [$L_695e0b],CL
            mov DWORD PTR [$L_695e00],ESI
            mov DL,BYTE PTR [ESI+8]
            push EDX
            call FUN_4e3980

            mov ECX,DWORD PTR [$L_695e0c]
            add ESP,4
            and ECX,255
            cmp EAX,ECX
            je $L_4e7f36

            and BYTE PTR [ESI+463],127
$L_4e7f36::

            xor EDX,EDX
            push EBP
            mov DL,BYTE PTR [$L_695e0a]
            push ESI
            push EDX
            mov BYTE PTR [$L_695e0c],AL
            call FUN_4b1530

            mov EBP,EAX
            mov EAX,DWORD PTR [$L_68a1b4]
            add ESP,12
            cmp BYTE PTR [EAX+19],BL
            jne $L_4e810b

            mov ECX,DWORD PTR [$L_9885bc]
            mov BYTE PTR [$L_695e08],BL
            mov EDX,DWORD PTR [ECX+76]
            mov DWORD PTR [$L_695dfc],EDX
            mov AL,BYTE PTR [ESI+463]
            test AL,AL
            jns $L_4e8083

            mov EAX,DWORD PTR [EDI+384]
            mov DWORD PTR [ESI+384],EAX
            mov ECX,DWORD PTR [EDI+388]
            mov DWORD PTR [ESI+388],ECX
            mov EDX,DWORD PTR [EDI+392]
            mov DWORD PTR [ESI+392],EDX
            mov EAX,DWORD PTR [EDI+396]
            mov DWORD PTR [ESI+396],EAX
            jmp $L_4e8083
$L_4e7fb6::

            mov ECX,DWORD PTR [$L_695e00]
            mov EDX,DWORD PTR [ECX+264]
            mov DWORD PTR [ESI+264],EDX
            mov EAX,DWORD PTR [$L_695e00]
            mov ECX,DWORD PTR [EAX+380]
            mov DWORD PTR [ESI+380],ECX
            mov EDX,DWORD PTR [$L_695e00]
            mov EAX,DWORD PTR [EDX+20]
            mov DWORD PTR [ESI+20],EAX
            mov ECX,DWORD PTR [$L_695e00]
            mov EDX,DWORD PTR [ECX+28]
            mov DWORD PTR [ESI+28],EDX
            mov EAX,DWORD PTR [$L_695e00]
            mov ECX,DWORD PTR [EAX+384]
            mov DWORD PTR [ESI+384],ECX
            mov EDX,DWORD PTR [$L_695e00]
            mov EAX,DWORD PTR [EDX+388]
            mov DWORD PTR [ESI+388],EAX
            mov ECX,DWORD PTR [$L_695e00]
            mov EDX,DWORD PTR [ECX+392]
            mov DWORD PTR [ESI+392],EDX
            mov EAX,DWORD PTR [$L_695e00]
            mov ECX,DWORD PTR [EAX+396]
            mov DWORD PTR [ESI+396],ECX
            mov EDX,DWORD PTR [$L_695e00]
            mov EAX,DWORD PTR [EDX+444]
            mov DWORD PTR [ESI+444],EAX
            mov ECX,DWORD PTR [$L_695e00]
            mov DL,BYTE PTR [ECX+260]
            mov BYTE PTR [ESI+260],DL
            mov EAX,DWORD PTR [$L_695e00]
            xor EDX,EDX
            mov CL,BYTE PTR [EAX+261]
            xor EAX,EAX
            mov AL,BYTE PTR [ESI+12]
            mov BYTE PTR [ESI+261],CL
            mov DL,BYTE PTR [$L_695e0a]
            push EDX
            push EAX
            call FUN_443e00

            add ESP,8
$L_4e8083::

            push EBP
            push ESI
            call FUN_4c11b0

            mov ECX,DWORD PTR [ESI+264]
            push EBX
            push ECX
            push EAX
            push ESI
            call FUN_4c11f0

            mov EDX,DWORD PTR [ESI+444]
            mov EDI,EAX
            push EDX
            push ESI
            call FUN_4dfbf0

            mov EAX,DWORD PTR [$L_989e70]
            add ESP,32
            test EAX,65536
            mov DWORD PTR [$L_9885c4],EDI
            je $L_4e80cc

            push EDI
            push ESI
            call FUN_4c51f0

            add ESP,8
            mov DWORD PTR [$L_9885c4],EAX
$L_4e80cc::

            mov BYTE PTR [ESI+332],BL
            mov EAX,DWORD PTR [$L_69499c]
            test BYTE PTR [ESI+271],64
            mov CX,WORD PTR [EAX+18]
            mov WORD PTR [ESI+344],CX
            mov EDX,DWORD PTR [$L_69499c]
            mov AX,WORD PTR [EDX+20]
            mov WORD PTR [ESI+346],AX
            je $L_4e8103

            mov BYTE PTR [ESI+448],146
$L_4e8103::

            mov EAX,DWORD PTR [ESP+20]
            add DWORD PTR [EAX+28],24
$L_4e810b::

            pop EDI
            pop ESI
            pop EBP
            mov EAX,1
            pop EBX
            ret 
$L_4e7ba0 ENDP


$L_4e8120 PROC
            push ESI
            mov ESI,DWORD PTR [ESP+8]
            xor EAX,EAX
            xor EDX,EDX
            mov ECX,DWORD PTR [ESI+28]
            mov AL,BYTE PTR [ECX+1]
            mov DX,WORD PTR [ECX+2]
            add ECX,4
            mov DWORD PTR [ESI+28],ECX
            mov ECX,DWORD PTR [$L_9885a4]
            test EDX,ECX
            pop ESI
            jne $L_4e8147

            xor EAX,1
$L_4e8147::

            ret 
$L_4e8120 ENDP


$L_4e8150 PROC
            push ESI
            mov ESI,DWORD PTR [ESP+8]
            xor EAX,EAX
            xor EDX,EDX
            mov ECX,DWORD PTR [ESI+28]
            mov AL,BYTE PTR [ECX+1]
            mov DX,WORD PTR [ECX+2]
            add ECX,4
            mov DWORD PTR [ESI+28],ECX
            mov ECX,DWORD PTR [$L_9885a8]
            test EDX,ECX
            pop ESI
            jne $L_4e8177

            xor EAX,1
$L_4e8177::

            ret 
$L_4e8150 ENDP


$L_4e8180 PROC
            push ESI
            push EDI
            mov EDI,DWORD PTR [ESP+12]
            xor EAX,EAX
            xor ECX,ECX
            xor EDX,EDX
            mov ESI,DWORD PTR [EDI+28]
            mov AL,BYTE PTR [ESI+1]
            mov CL,BYTE PTR [ESI+2]
            mov DL,BYTE PTR [ESI+3]
            shl EAX,4
            or EAX,ECX
            xor ECX,ECX
            mov CL,BYTE PTR [ESI+4]
            shl EAX,8
            or EAX,EDX
            xor EDX,EDX
            mov DL,BYTE PTR [ESI+5]
            shl EAX,8
            or EAX,ECX
            shl EAX,8
            or EAX,EDX
            push EAX
            call FUN_4ed1c0

            add ESP,4
            add ESI,6
            mov DWORD PTR [EDI+28],ESI
            mov EAX,1
            pop EDI
            pop ESI
            ret 
$L_4e8180 ENDP


$L_4e81d0 PROC
            push ESI
            mov ESI,DWORD PTR [ESP+8]
            xor ECX,ECX
            xor EDX,EDX
            mov EAX,DWORD PTR [ESI+28]
            mov CX,WORD PTR [EAX+2]
            mov DX,WORD PTR [EAX+6]
            shl ECX,16
            or ECX,EDX
            xor EDX,EDX
            mov DX,WORD PTR [EAX+4]
            or ECX,EDX
            push ECX
            call FUN_4ed7f0

            mov EAX,DWORD PTR [ESI+28]
            add ESP,4
            add EAX,8
            mov DWORD PTR [ESI+28],EAX
            mov EAX,1
            pop ESI
            ret 
$L_4e81d0 ENDP


$L_4e8210 PROC
            sub ESP,8
            mov EAX,DWORD PTR [ESP+12]
            push EBX
            push ESI
            xor ECX,ECX
            mov ESI,DWORD PTR [EAX+28]
            xor EDX,EDX
            xor EAX,EAX
            push EDI
            mov CL,BYTE PTR [ESI+1]
            mov BX,WORD PTR [ESI+4]
            mov WORD PTR [ESP+12],0
            mov WORD PTR [ESP+14],0
            mov WORD PTR [ESP+16],320
            mov WORD PTR [ESP+18],240
            mov DL,BYTE PTR [ESI+3]
            mov AH,BYTE PTR [ESI+2]
            mov EDI,ECX
            push 7
            push EDX
            or EAX,EDI
            push EBX
            push EAX
            call FUN_4c4910

            lea ECX,DWORD PTR [ESP+28]
            xor EDX,EDX
            mov DL,BYTE PTR [ESI+1]
            push ECX
            push 0
            push 0
            push EDX
            call FUN_4c49a0

            lea EAX,DWORD PTR [EDI+EDI*8]
            add ESP,32
            test BX,BX
            lea ECX,DWORD PTR [EDI+EAX*2]
            lea ECX,DWORD PTR [ECX*4+$L_98f01c]
            je $L_4e8295

            jle $L_4e8289

            xor EAX,EAX
            jmp $L_4e8292
$L_4e8289::

            add EBX,4294934528
            movsx EAX,BX
$L_4e8292::

            mov WORD PTR [ECX],AX
$L_4e8295::

            mov EDX,DWORD PTR [ESP+24]
            add ESI,6
            pop EDI
            mov EAX,1
            mov DWORD PTR [EDX+28],ESI
            pop ESI
            pop EBX
            add ESP,8
            ret 
$L_4e8210 ENDP


$L_4e82b0 PROC
            mov EAX,DWORD PTR [$L_989e70]
            push EBP
            mov EBP,DWORD PTR [ESP+8]
            push ESI
            xor ECX,ECX
            push EDI
            mov ESI,DWORD PTR [EBP+28]
            mov DI,WORD PTR [$L_98eab6]
            test EAX,524288
            je $L_4e82fa

            cmp WORD PTR [$L_98eab4],5
            jne $L_4e8317

            movsx EAX,DI
            add EAX,-9
            cmp EAX,13
            ja $L_4e8304

            xor EDX,EDX
            mov DL,BYTE PTR [EAX+$L_4e8348]
            jmp DWORD PTR [EDX*4+$L_4e8340]
$L_4e82f3::

            mov ECX,1
            jmp $L_4e8304
$L_4e82fa::

            cmp WORD PTR [$L_98eab4],5
            jne $L_4e8317
$L_4e8304::

            cmp DI,13
            jne $L_4e8313

            call FUN_442d00

            test EAX,EAX
            jmp $L_4e8315
$L_4e8313::

            test ECX,ECX
$L_4e8315::

            jne $L_4e832e
$L_4e8317::

            movsx EAX,WORD PTR [ESI+2]
            xor ECX,ECX
            push 0
            mov CL,BYTE PTR [ESI+1]
            push 0
            push EAX
            push ECX
            call FUN_4c49a0

            add ESP,16
$L_4e832e::

            add ESI,4
            pop EDI
            mov DWORD PTR [EBP+28],ESI
            pop ESI
            mov EAX,1
            pop EBP
            ret 
            LEA ECX, [ECX+0]
$L_4e8340           DWORD $L_4e82f3
$L_4e8344           DWORD $L_4e8304
$L_4e8348 DB 000h, 000h, 000h, 000h, 001h, 000h, 000h, 000h
          DB 001h, 001h, 001h, 001h, 001h, 000h  ; 0x4E8356(14)
            nop
            nop
$L_4e82b0 ENDP


$L_4e8360 PROC
            push ESI
            mov ESI,DWORD PTR [ESP+8]
            xor ECX,ECX
            xor EDX,EDX
            mov EAX,DWORD PTR [ESI+28]
            mov CX,WORD PTR [EAX+2]
            mov DL,BYTE PTR [EAX+1]
            push ECX
            push EDX
            call FUN_4eeb00

            mov ECX,DWORD PTR [$L_989e70]
            add ESP,8
            or ECX,32
            mov DWORD PTR [$L_989e70],ECX
            mov EAX,DWORD PTR [ESI+28]
            add EAX,4
            mov DWORD PTR [ESI+28],EAX
            mov EAX,1
            pop ESI
            ret 
$L_4e8360 ENDP


$L_4e83a0 PROC
            mov EAX,DWORD PTR [ESP+4]
            xor EDX,EDX
            mov ECX,DWORD PTR [EAX+28]
            mov DL,BYTE PTR [ECX+1]
            mov ECX,EDX
            cmp ECX,128
            jae $L_4e83bc

            mov DWORD PTR [$L_693e28],ECX
$L_4e83bc::

            mov ECX,DWORD PTR [EAX+28]
            add ECX,2
            mov DWORD PTR [EAX+28],ECX
            mov EAX,1
            ret 
$L_4e83a0 ENDP


$L_4e83d0 PROC
            mov AL,BYTE PTR [$L_695e12]
            push ESI
            mov ESI,DWORD PTR [ESP+8]
            cmp AL,255
            jne $L_4e8420

            mov AL,BYTE PTR [$L_693be8]
            xor EDX,EDX
            mov BYTE PTR [$L_695e12],AL
            mov ECX,DWORD PTR [ESI+28]
            mov DL,BYTE PTR [ECX+1]
            mov ECX,EDX
            xor EDX,EDX
            mov DL,AL
            mov EAX,1374389535
            imul ECX,EDX
            imul ECX
            sar EDX,5
            mov EAX,EDX
            shr EAX,31
            add EDX,EAX
            mov BYTE PTR [$L_693be8],DL
            mov EAX,DWORD PTR [ESI+28]
            add EAX,2
            mov DWORD PTR [ESI+28],EAX
            mov EAX,1
            pop ESI
            ret 
$L_4e8420::
            mov BYTE PTR [$L_693be8],AL
            mov BYTE PTR [$L_695e12],255
            mov EAX,DWORD PTR [ESI+28]
            add EAX,2
            mov DWORD PTR [ESI+28],EAX
            mov EAX,1
            pop ESI
            ret 
$L_4e83d0 ENDP


$L_4e8440 PROC
            push ESI
            mov ESI,DWORD PTR [ESP+8]
            mov EAX,DWORD PTR [ESI+28]
            movsx ECX,BYTE PTR [EAX+2]
            movsx EDX,BYTE PTR [EAX+1]
            neg ECX
            neg EDX
            push ECX
            push EDX
            call FUN_4416b0

            mov EAX,DWORD PTR [ESI+28]
            add ESP,8
            add EAX,3
            mov DWORD PTR [ESI+28],EAX
            mov EAX,1
            pop ESI
            ret 
$L_4e8440 ENDP


$L_4e8470 PROC
            push ESI
            mov ESI,DWORD PTR [ESP+8]
            xor ECX,ECX
            xor EDX,EDX
            mov EAX,DWORD PTR [ESI+28]
            mov CX,WORD PTR [EAX+2]
            mov DL,BYTE PTR [EAX+1]
            push ECX
            push EDX
            call _printx

            mov EAX,DWORD PTR [ESI+28]
            add ESP,8
            add EAX,4
            mov DWORD PTR [ESI+28],EAX
            mov EAX,1
            pop ESI
            ret 
$L_4e8470 ENDP


$L_4e84a0 PROC
            mov EAX,DWORD PTR [ESP+4]
            mov ECX,DWORD PTR [EAX+28]
            mov DL,BYTE PTR [ECX+1]
            mov BYTE PTR [$L_68053d],DL
            mov ECX,DWORD PTR [EAX+28]
            add ECX,6
            mov DWORD PTR [EAX+28],ECX
            mov EAX,1
            ret 
$L_4e84a0 ENDP


$L_4e84c0 PROC

            call _printx

            mov EAX,DWORD PTR [ESP+4]
            mov ECX,DWORD PTR [EAX+28]
            inc ECX
            mov DWORD PTR [EAX+28],ECX
            mov EAX,1
            ret 
$L_4e84c0 ENDP


$L_4e84e0 PROC
            push ESI
            mov ESI,DWORD PTR [ESP+8]
            mov EAX,DWORD PTR [ESI+28]
            mov AL,BYTE PTR [EAX+1]
            mov BYTE PTR [ESP+8],AL
            mov BYTE PTR [$L_695e0d],AL
            mov EAX,DWORD PTR [ESP+8]
            test EAX,EAX
            jne $L_4e84fe

            pop ESI
            ret 
$L_4e84fe::
            and EAX,255
            push EAX
            call FUN_43e6c0

            mov EAX,DWORD PTR [ESI+28]
            add ESP,4
            add EAX,2
            mov DWORD PTR [ESI+28],EAX
            mov EAX,1
            pop ESI
            ret 
$L_4e84e0 ENDP


$L_4e8520 PROC
            mov ECX,DWORD PTR [ESP+4]
            xor EDX,EDX
            mov EAX,DWORD PTR [ECX+28]
            mov DL,BYTE PTR [EAX+1]
            add EAX,2
            push EDX
            mov DWORD PTR [ECX+28],EAX
            call FUN_502530

            add ESP,4
            xor ECX,ECX
            test EAX,EAX
            setge CL
            mov EAX,ECX
            ret 
$L_4e8520 ENDP


$L_4e8550 PROC
            mov EDX,DWORD PTR [ESP+4]
            mov EAX,DWORD PTR [$L_691f08]
            push ESI
            mov ESI,DWORD PTR [EDX+28]
            test AL,AL
            jns $L_4e8565

            xor ECX,ECX
            jmp $L_4e8573
$L_4e8565::

            and EAX,255
            xor ECX,ECX
            mov CL,BYTE PTR [EAX*4+$L_98ecd2+3]
$L_4e8573::

            lea EAX,DWORD PTR [ESI+3]
            mov DWORD PTR [EDX+28],EAX
            xor EDX,EDX
            mov DL,BYTE PTR [ESI+1]
            xor EAX,EAX
            mov AL,BYTE PTR [ESI+2]
            cmp EDX,6
            pop ESI
            ja $L_4e85c7

            jmp DWORD PTR [EDX*4+$L_4e85d0]
$L_4e8590::

            xor EDX,EDX
            cmp ECX,EAX
            sete DL
            mov EAX,EDX
            ret 
$L_4e859a::

            cmp EAX,ECX
            sbb EAX,EAX
            neg EAX
            ret 
$L_4e85a1::

            cmp ECX,EAX
            sbb EAX,EAX
            inc EAX
            ret 
$L_4e85a7::

            cmp ECX,EAX
            sbb EAX,EAX
            neg EAX
            ret 
$L_4e85ae::

            cmp EAX,ECX
            sbb EAX,EAX
            inc EAX
            ret 
$L_4e85b4::

            xor EDX,EDX
            cmp ECX,EAX
            setne DL
            mov EAX,EDX
            ret 
$L_4e85be::

            and EAX,ECX
            neg EAX
            sbb EAX,EAX
            neg EAX
            ret 
$L_4e85c7::

            mov EAX,1
            ret 
            LEA ECX, [ECX+0]
$L_4e85d0           DWORD $L_4e8590
          DWORD $L_4e859a
          DWORD $L_4e85a1
          DWORD $L_4e85a7
          DWORD $L_4e85ae
          DWORD $L_4e85b4
          DWORD $L_4e85be
$L_4e8550 ENDP


$L_4e85f0 PROC

            push ESI
            mov ESI,DWORD PTR [ESP+8]
            xor ECX,ECX
            mov EAX,DWORD PTR [ESI+28]
            mov CL,BYTE PTR [EAX+1]
            push ECX
            call FUN_502530

            xor ECX,ECX
            add ESP,4
            cmp EAX,ECX
            jl $L_4e8621

            mov BYTE PTR [EAX*4+$L_98ecd1+3],CL
            mov BYTE PTR [EAX*4+$L_98ecd2+3],CL
            mov BYTE PTR [EAX*4+$L_98ecd4+2],CL
$L_4e8621::

            call FUN_502560

            mov EAX,DWORD PTR [ESI+28]
            add EAX,2
            mov DWORD PTR [ESI+28],EAX
            mov EAX,1
            pop ESI
            ret 
$L_4e85f0 ENDP


$L_4e8640 PROC
            mov EAX,DWORD PTR [ESP+4]
            push ESI
            xor EDX,EDX
            mov ESI,DWORD PTR [EAX+28]
            lea ECX,DWORD PTR [ESI+3]
            mov DWORD PTR [EAX+28],ECX
            mov DL,BYTE PTR [ESI+1]
            push EDX
            call FUN_502530

            xor ECX,ECX
            add ESP,4
            cmp EAX,ECX
            jl $L_4e8693

            mov DL,BYTE PTR [ESI+2]
            push EBX
            mov BL,BYTE PTR [EAX*4+$L_98ecd2+3]
            sub BL,DL
            mov BYTE PTR [EAX*4+$L_98ecd2+3],BL
            pop EBX
            jne $L_4e868e

            mov BYTE PTR [EAX*4+$L_98ecd1+3],CL
            mov BYTE PTR [EAX*4+$L_98ecd2+3],CL
            mov BYTE PTR [EAX*4+$L_98ecd4+2],CL
$L_4e868e::

            call FUN_502560
$L_4e8693::

            mov EAX,1
            pop ESI
            ret 
$L_4e8640 ENDP


$L_4e86a0 PROC
            push EBX
            push ESI
            mov ESI,DWORD PTR [ESP+12]
            xor EBX,EBX
            mov EAX,DWORD PTR [ESI+28]
            mov BL,BYTE PTR [EAX+1]
            mov AX,WORD PTR [$L_989f9e]
            and AX,61440
            or AX,BX
            test EBX,EBX
            mov WORD PTR [$L_989f9e],AX
            je $L_4e86db

            push EBX
            call FUN_502530

            add ESP,4
            mov BYTE PTR [$L_691f08],AL
            mov BYTE PTR [$L_691f0a],BL
            jmp $L_4e86e9
$L_4e86db::

            mov BYTE PTR [$L_691f08],128
            mov BYTE PTR [$L_691f0a],0
$L_4e86e9::

            push OFFSET $L_989e90
            call FUN_4d32c0

            push OFFSET $L_989e90
            call FUN_4d2c00

            mov EAX,DWORD PTR [ESI+28]
            add ESP,8
            add EAX,2
            mov DWORD PTR [ESI+28],EAX
            pop ESI
            mov EAX,1
            pop EBX
            ret 
$L_4e86a0 ENDP


$L_4e8720 PROC
            push ESI
            mov ESI,DWORD PTR [ESP+8]
            xor ECX,ECX
            push EDI
            mov EAX,DWORD PTR [ESI+28]
            push OFFSET $L_8c5820
            mov CL,BYTE PTR [EAX+1]
            mov EDI,ECX
            push EDI
            call FUN_4fdf60

            add ESP,8
            test EAX,EAX
            je $L_4e876f

            mov EDX,DWORD PTR [$L_9885c4]
            mov EAX,DWORD PTR [ESI+28]
            xor ECX,ECX
            add EDX,8608
            mov CL,BYTE PTR [EAX+2]
            push EDX
            push ECX
            push EDI
            call FUN_5026f0

            mov EAX,DWORD PTR [ESI+28]
            add ESP,12
            add EAX,3
            mov DWORD PTR [ESI+28],EAX
            mov EAX,1
$L_4e876f::

            pop EDI
            pop ESI
            ret 
$L_4e8720 ENDP


$L_4e8780 PROC
            push ECX
            push EBX
            mov EBX,DWORD PTR [ESP+12]
            push ESI
            push EDI
            mov EAX,DWORD PTR [EBX+28]
            mov DWORD PTR [ESP+12],0
            mov CL,BYTE PTR [EAX+1]
            mov BYTE PTR [ESP+20],CL
            and ECX,255
            dec ECX
            je $L_4e87da

            dec ECX
            je $L_4e87cc

            dec ECX
            jne $L_4e87e8

            movsx ECX,BYTE PTR [EAX+2]
            mov ECX,DWORD PTR [ECX*4+$L_98a0b4]
            mov DL,BYTE PTR [ECX+8]
            mov EDI,DWORD PTR [ECX+364]
            cmp DL,64
            jae $L_4e87ec

            mov DWORD PTR [ESP+12],1
            jmp $L_4e87ec
$L_4e87cc::

            mov EDX,DWORD PTR [$L_98a0b0]
            mov EDI,DWORD PTR [EDX+364]
            jmp $L_4e87ec
$L_4e87da::

            mov ECX,DWORD PTR [$L_98a0ac]
            mov EDI,DWORD PTR [ECX+364]
            jmp $L_4e87ec
$L_4e87e8::

            mov EDI,DWORD PTR [ESP+20]
$L_4e87ec::

            xor EDX,EDX
            push EBP
            mov DL,BYTE PTR [EAX+3]
            mov EBP,EDX
            xor EDX,EDX
            mov DL,BYTE PTR [EAX+4]
            mov ECX,EBP
            mov ESI,EDX
            xor EDX,EDX
            mov DL,BYTE PTR [EAX+5]
            mov EAX,EDX
            mov DL,BYTE PTR [$L_68054a]
            test DL,DL
            je $L_4e8829

            mov EDX,DWORD PTR [ESP+16]
            test EDX,EDX
            je $L_4e8829

            cmp BYTE PTR [ESP+24],3
            jne $L_4e8829

            cmp ECX,ESI
            jae $L_4e8829

            cmp ECX,EAX
            jae $L_4e8829

            mov ECX,ESI
            mov ESI,EBP
$L_4e8829::

            shl EAX,8
            mov DL,BYTE PTR [EDI+14]
            or EAX,ESI
            shl EAX,8
            pop EBP
            or EAX,ECX
            push EAX
            push EDI
            call FUN_4b3370

            mov EAX,DWORD PTR [EBX+28]
            add ESP,8
            mov CX,WORD PTR [EAX+6]
            mov WORD PTR [EDI+4],CX
            mov EDX,DWORD PTR [EBX+28]
            mov AX,WORD PTR [EDX+8]
            mov WORD PTR [EDI+6],AX
            mov ECX,DWORD PTR [EBX+28]
            mov DX,WORD PTR [ECX+10]
            mov WORD PTR [EDI],DX
            mov EAX,DWORD PTR [EBX+28]
            mov CX,WORD PTR [EAX+12]
            mov WORD PTR [EDI+2],CX
            mov EAX,DWORD PTR [EBX+28]
            add EAX,14
            pop EDI
            mov DWORD PTR [EBX+28],EAX
            pop ESI
            mov EAX,1
            pop EBX
            pop ECX
            ret 
$L_4e8780 ENDP


$L_4e8880 PROC
            push ESI
            mov ESI,DWORD PTR [ESP+8]
            xor ECX,ECX
            mov EAX,DWORD PTR [ESI+28]
            mov CL,BYTE PTR [EAX+2]
            lea EDX,DWORD PTR [ECX+ECX*2]
            movsx ECX,WORD PTR [$L_98eab8]
            lea ECX,DWORD PTR [ECX+ECX*4]
            shl ECX,3
            lea EDX,DWORD PTR [ECX+EDX*2]
            mov ECX,DWORD PTR [$L_9885bc]
            mov ECX,DWORD PTR [ECX+44]
            lea EDX,DWORD PTR [EDX+ECX*1+16]
            xor ECX,ECX
            mov CL,BYTE PTR [EAX+3]
            sub ECX,11
            je $L_4e88e7

            dec ECX
            je $L_4e88d2

            dec ECX
            jne $L_4e88ee

            mov CX,WORD PTR [EAX+4]
            add EAX,6
            mov WORD PTR [EDX+4],CX
            mov DWORD PTR [ESI+28],EAX
            mov EAX,1
            pop ESI
            ret 
$L_4e88d2::
            mov CX,WORD PTR [EAX+4]
            add EAX,6
            mov WORD PTR [EDX+2],CX
            mov DWORD PTR [ESI+28],EAX
            mov EAX,1
            pop ESI
            ret 
$L_4e88e7::
            mov CX,WORD PTR [EAX+4]
            mov WORD PTR [EDX],CX
$L_4e88ee::
            add EAX,6
            mov DWORD PTR [ESI+28],EAX
            mov EAX,1
            pop ESI
            ret 
$L_4e8880 ENDP


$L_4e8900 PROC
            mov EDX,DWORD PTR [ESP+4]
            push EBX
            movsx ECX,WORD PTR [$L_98eab8]
            mov EAX,DWORD PTR [EDX+28]
            xor EBX,EBX
            push ESI
            mov ESI,DWORD PTR [$L_9885bc]
            mov BL,BYTE PTR [EAX+1]
            lea ECX,DWORD PTR [ECX+ECX*4]
            mov ESI,DWORD PTR [ESI+44]
            push EDI
            mov DI,WORD PTR [EAX+2]
            lea ECX,DWORD PTR [EBX+ECX*4]
            add EAX,4
            mov WORD PTR [ESI+ECX*2+34],DI
            pop EDI
            mov DWORD PTR [EDX+28],EAX
            pop ESI
            mov EAX,1
            pop EBX
            ret 
$L_4e8900 ENDP


$L_4e8940 PROC
            push ESI
            mov ESI,DWORD PTR [ESP+8]
            xor ECX,ECX
            mov EAX,DWORD PTR [ESI+28]
            mov CL,BYTE PTR [EAX+1]
            add EAX,6
            lea EDX,DWORD PTR [ECX+ECX*2]
            movsx ECX,WORD PTR [$L_98eab8]
            lea ECX,DWORD PTR [ECX+ECX*4]
            lea EDX,DWORD PTR [EDX+ECX*8]
            mov ECX,DWORD PTR [$L_9885bc]
            mov ECX,DWORD PTR [ECX+44]
            lea ECX,DWORD PTR [EDX+ECX*1+4]
            mov DL,BYTE PTR [EAX-4]
            mov BYTE PTR [ECX],DL
            mov DL,BYTE PTR [EAX-3]
            mov BYTE PTR [ECX+1],DL
            mov DL,BYTE PTR [EAX-2]
            mov BYTE PTR [ECX+2],DL
            mov DWORD PTR [ESI+28],EAX
            mov EAX,1
            pop ESI
            ret 
$L_4e8940 ENDP


$L_4e8990 PROC
            push ESI
            mov ESI,DWORD PTR [ESP+8]
            xor ECX,ECX
            mov EAX,DWORD PTR [ESI+28]
            mov CL,BYTE PTR [EAX+1]
            lea EDX,DWORD PTR [ECX+ECX*4]
            xor ECX,ECX
            mov CL,BYTE PTR [EAX+2]
            lea ECX,DWORD PTR [ECX+ECX*2]
            add ECX,ECX
            lea EDX,DWORD PTR [ECX+EDX*8]
            mov ECX,DWORD PTR [$L_9885bc]
            mov ECX,DWORD PTR [ECX+44]
            lea EDX,DWORD PTR [EDX+ECX*1+16]
            xor ECX,ECX
            mov CL,BYTE PTR [EAX+3]
            sub ECX,11
            je $L_4e89f4

            dec ECX
            je $L_4e89df

            dec ECX
            jne $L_4e89fb

            mov CX,WORD PTR [EAX+4]
            add EAX,6
            mov WORD PTR [EDX+4],CX
            mov DWORD PTR [ESI+28],EAX
            mov EAX,1
            pop ESI
            ret 
$L_4e89df::
            mov CX,WORD PTR [EAX+4]
            add EAX,6
            mov WORD PTR [EDX+2],CX
            mov DWORD PTR [ESI+28],EAX
            mov EAX,1
            pop ESI
            ret 
$L_4e89f4::
            mov CX,WORD PTR [EAX+4]
            mov WORD PTR [EDX],CX
$L_4e89fb::
            add EAX,6
            mov DWORD PTR [ESI+28],EAX
            mov EAX,1
            pop ESI
            ret 
$L_4e8990 ENDP


$L_4e8a10 PROC
            mov EDX,DWORD PTR [ESP+4]
            xor ECX,ECX
            push EBX
            xor EBX,EBX
            mov EAX,DWORD PTR [EDX+28]
            push ESI
            mov ESI,DWORD PTR [$L_9885bc]
            push EDI
            mov CL,BYTE PTR [EAX+2]
            mov BL,BYTE PTR [EAX+3]
            mov ESI,DWORD PTR [ESI+44]
            mov DI,WORD PTR [EAX+4]
            lea ECX,DWORD PTR [ECX+ECX*4]
            add EAX,6
            lea ECX,DWORD PTR [EBX+ECX*4]
            mov WORD PTR [ESI+ECX*2+34],DI
            pop EDI
            mov DWORD PTR [EDX+28],EAX
            pop ESI
            mov EAX,1
            pop EBX
            ret 
$L_4e8a10 ENDP


$L_4e8a50 PROC
            push ESI
            mov ESI,DWORD PTR [ESP+8]
            xor ECX,ECX
            mov EAX,DWORD PTR [ESI+28]
            mov CL,BYTE PTR [EAX+1]
            add EAX,6
            lea EDX,DWORD PTR [ECX+ECX*4]
            xor ECX,ECX
            mov CL,BYTE PTR [EAX-4]
            lea ECX,DWORD PTR [ECX+ECX*2]
            lea EDX,DWORD PTR [ECX+EDX*8]
            mov ECX,DWORD PTR [$L_9885bc]
            mov ECX,DWORD PTR [ECX+44]
            lea ECX,DWORD PTR [EDX+ECX*1+4]
            mov DL,BYTE PTR [EAX-3]
            mov BYTE PTR [ECX],DL
            mov DL,BYTE PTR [EAX-2]
            mov BYTE PTR [ECX+1],DL
            mov DL,BYTE PTR [EAX-1]
            mov BYTE PTR [ECX+2],DL
            mov DWORD PTR [ESI+28],EAX
            mov EAX,1
            pop ESI
            ret 
$L_4e8a50 ENDP


$L_4e8aa0 PROC
            mov EAX,DWORD PTR [ESP+4]
            mov ECX,DWORD PTR [EAX+28]
            mov DX,WORD PTR [ECX+2]
            mov WORD PTR [$L_98e72c],DX
            mov ECX,DWORD PTR [EAX+28]
            add ECX,4
            mov DWORD PTR [EAX+28],ECX
            mov EAX,1
            ret 
$L_4e8aa0 ENDP


$L_4e8ad0 PROC
            mov EAX,DWORD PTR [$L_9885bc]
            mov ECX,DWORD PTR [ESP+4]
            push ESI
            push EDI
            mov EDX,DWORD PTR [EAX+52]
            mov ESI,DWORD PTR [ECX+28]
            xor EAX,EAX
            xor EDI,EDI
            mov AL,BYTE PTR [ESI+1]
            mov DI,WORD PTR [EDX]
            cmp EDI,EAX
            jbe $L_4e8b15

            lea EAX,DWORD PTR [EAX+EAX*2+3]
            lea EAX,DWORD PTR [EDX+EAX*4]
            mov DL,BYTE PTR [ESI+2]
            cmp DL,1
            jne $L_4e8b12

            and BYTE PTR [EAX],127
            mov EAX,DWORD PTR [ECX+28]
            add EAX,3
            pop EDI
            mov DWORD PTR [ECX+28],EAX
            mov EAX,1
            pop ESI
            ret 
$L_4e8b12::
            or BYTE PTR [EAX],128
$L_4e8b15::
            mov EAX,DWORD PTR [ECX+28]
            pop EDI
            add EAX,3
            pop ESI
            mov DWORD PTR [ECX+28],EAX
            mov EAX,1
            ret 
$L_4e8ad0 ENDP


$L_4e8b30 PROC
            push ESI
            mov ESI,DWORD PTR [ESP+8]
            xor ECX,ECX
            mov EAX,DWORD PTR [ESI+28]
            mov CL,BYTE PTR [EAX+1]
            push ECX
            call FUN_4cae10

            push 2
            call FUN_441830

            mov EAX,DWORD PTR [ESI+28]
            add ESP,8
            add EAX,2
            mov DWORD PTR [ESI+28],EAX
            mov EAX,1
            pop ESI
            ret 
$L_4e8b30 ENDP


$L_4e8b60 PROC
            mov EDX,DWORD PTR [ESP+4]
            mov EAX,DWORD PTR [EDX+340]
            mov CX,WORD PTR [EAX+270]
            mov DWORD PTR [EAX+4],1
            and ECX,45055
            mov DWORD PTR [EAX+440],OFFSET $L_989e90
            or CH,4
            mov BYTE PTR [EAX+448],0
            mov WORD PTR [EAX+270],CX
            mov ECX,DWORD PTR [$L_989e70]
            or ECX,268435456
            mov DWORD PTR [$L_989e70],ECX
            mov CX,WORD PTR [$L_98ee1c]
            mov WORD PTR [EAX+342],CX
            mov CL,BYTE PTR [EAX+8]
            cmp CL,69
            mov WORD PTR [EAX+354],200
            je $L_4e8bcf

            cmp CL,79
            jne $L_4e8bd6
$L_4e8bcf::

            and BYTE PTR [EAX+541],223
$L_4e8bd6::

            mov EAX,DWORD PTR [EDX+28]
            inc EAX
            mov DWORD PTR [EDX+28],EAX
            mov EAX,1
            ret 
$L_4e8b60 ENDP


$L_4e8bf0 PROC
            mov ECX,DWORD PTR [ESP+4]
            mov EAX,DWORD PTR [ECX+340]
            mov DX,WORD PTR [EAX+270]
            mov DWORD PTR [EAX+4],1540
            and EDX,64511
            mov DWORD PTR [EAX+440],EAX
            or DH,80
            mov BYTE PTR [EAX+448],146
            mov WORD PTR [EAX+270],DX
            mov EDX,DWORD PTR [$L_989e70]
            and EDX,4026531839
            mov DWORD PTR [$L_989e70],EDX
            or EDX,4294967295
            mov WORD PTR [EAX+342],DX
            mov WORD PTR [EAX+354],DX
            mov EAX,DWORD PTR [ECX+28]
            inc EAX
            mov DWORD PTR [ECX+28],EAX
            mov EAX,1
            ret 
$L_4e8bf0 ENDP


$L_4e8c60 PROC
            mov ECX,DWORD PTR [$L_98a0b0]
            mov EAX,200
            mov BYTE PTR [$L_98ee1b],0
            mov WORD PTR [$L_98ee1c],AX
            mov WORD PTR [ECX+342],AX
            mov EDX,DWORD PTR [$L_98a0b0]
            mov WORD PTR [EDX+354],AX
            mov EAX,DWORD PTR [ESP+4]
            mov ECX,DWORD PTR [EAX+28]
            inc ECX
            mov DWORD PTR [EAX+28],ECX
            mov EAX,1
            ret 
$L_4e8c60 ENDP


$L_4e8ca0 PROC
            mov EDX,DWORD PTR [$L_989e70]
            mov EAX,DWORD PTR [ESP+4]
            or EDX,65536
            mov DWORD PTR [$L_989e70],EDX
            mov ECX,DWORD PTR [EAX+28]
            mov DL,BYTE PTR [ECX+1]
            mov BYTE PTR [$L_989e15],DL
            mov ECX,DWORD PTR [EAX+28]
            mov DX,WORD PTR [ECX+2]
            mov WORD PTR [$L_989e16],DX
            mov ECX,DWORD PTR [EAX+28]
            mov DX,WORD PTR [ECX+4]
            mov WORD PTR [$L_989e1a],DX
            mov ECX,DWORD PTR [EAX+28]
            mov DX,WORD PTR [ECX+6]
            mov WORD PTR [$L_989e18],DX
            mov ECX,DWORD PTR [EAX+28]
            add ECX,8
            mov DWORD PTR [EAX+28],ECX
            mov EAX,1
            ret 
$L_4e8ca0 ENDP


$L_4e8d00 PROC
            push ESI
            push EDI
            mov EDI,DWORD PTR [ESP+12]
            xor EDX,EDX
            mov EAX,DWORD PTR [EDI+28]
            mov DL,BYTE PTR [EAX+2]
            lea ECX,DWORD PTR [EDX*8]
            sub ECX,EDX
            lea ECX,DWORD PTR [ECX+ECX*2]
            lea EDX,DWORD PTR [EDX+ECX*2]
            mov ECX,DWORD PTR [EDI+340]
            mov ECX,DWORD PTR [ECX+408]
            lea ESI,DWORD PTR [ECX+EDX*4]
            xor ECX,ECX
            mov EDX,DWORD PTR [ESI]
            or EDX,74
            mov DWORD PTR [ESI],EDX
            mov CL,BYTE PTR [EAX+3]
            xor EDX,EDX
            mov DH,BYTE PTR [EAX+5]
            mov DL,BYTE PTR [EAX+4]
            mov WORD PTR [ESI+160],0
            shl EDX,8
            or EDX,ECX
            mov DWORD PTR [ESI+112],EDX
            mov DX,WORD PTR [EAX+6]
            mov WORD PTR [ESI+152],DX
            mov CX,WORD PTR [EAX+8]
            mov WORD PTR [ESI+156],CX
            mov DX,WORD PTR [EAX+10]
            mov WORD PTR [ESI+164],DX
            mov CX,WORD PTR [EAX+12]
            mov WORD PTR [ESI+154],CX
            mov DX,WORD PTR [EAX+14]
            mov WORD PTR [ESI+158],DX
            mov EAX,DWORD PTR [EDI+28]
            add EAX,16
            mov DWORD PTR [EDI+28],EAX
            pop EDI
            mov EAX,1
            pop ESI
            ret 
$L_4e8d00 ENDP


$L_4e8da0 PROC
            push ESI
            mov ESI,DWORD PTR [ESP+8]
            xor EDX,EDX
            mov ECX,DWORD PTR [ESI+28]
            mov DL,BYTE PTR [ECX+1]
            lea EAX,DWORD PTR [EDX*8]
            sub EAX,EDX
            lea EAX,DWORD PTR [EAX+EAX*2]
            lea EDX,DWORD PTR [EDX+EAX*2]
            mov EAX,DWORD PTR [ESI+340]
            mov EAX,DWORD PTR [EAX+408]
            mov WORD PTR [EAX+EDX*4+134],0
            lea EAX,DWORD PTR [EAX+EDX*4]
            mov EDX,DWORD PTR [EAX]
            or EDX,4194
            mov DWORD PTR [EAX],EDX
            mov DX,WORD PTR [ECX+2]
            mov WORD PTR [EAX+56],DX
            mov DX,WORD PTR [ECX+4]
            mov WORD PTR [EAX+60],DX
            mov DX,WORD PTR [ECX+6]
            mov WORD PTR [EAX+58],DX
            mov DL,BYTE PTR [ECX+8]
            mov BYTE PTR [EAX+121],DL
            mov DX,WORD PTR [ECX+10]
            mov WORD PTR [EAX+62],DX
            mov DX,WORD PTR [ECX+12]
            mov WORD PTR [EAX+64],DX
            mov CX,WORD PTR [ECX+14]
            mov WORD PTR [EAX+66],CX
            mov EAX,DWORD PTR [ESI+28]
            add EAX,16
            mov DWORD PTR [ESI+28],EAX
            mov EAX,1
            pop ESI
            ret 
$L_4e8da0 ENDP


$L_4e8e30 PROC
            xor EDX,EDX
            mov DL,BYTE PTR [$L_98138a]
            push ESI
            xor ECX,ECX
            push EDI
            mov EDI,DWORD PTR [ESP+12]
            test EDX,EDX
            jbe $L_4e8e8c

            mov ESI,DWORD PTR [EDI+340]
            mov EAX,OFFSET $L_980aa0
$L_4e8e4f::

            cmp DWORD PTR [EAX+72],ESI
            je $L_4e8e6d

            inc ECX
            add EAX,76
            cmp ECX,EDX
            jb $L_4e8e4f

            mov EAX,DWORD PTR [EDI+28]
            add EAX,5
            mov DWORD PTR [EDI+28],EAX
            pop EDI
            pop ESI
            mov EAX,1
            ret 
$L_4e8e6d::

            mov ECX,DWORD PTR [EDI+28]
            mov DL,BYTE PTR [EAX]
            and DL,192
            or DL,BYTE PTR [ECX+1]
            mov BYTE PTR [EAX],DL
            mov DL,BYTE PTR [ECX+2]
            mov BYTE PTR [EAX+1],DL
            mov DL,BYTE PTR [ECX+3]
            mov BYTE PTR [EAX+2],DL
            mov CL,BYTE PTR [ECX+4]
            mov BYTE PTR [EAX+3],CL
$L_4e8e8c::

            mov EAX,DWORD PTR [EDI+28]
            add EAX,5
            mov DWORD PTR [EDI+28],EAX
            pop EDI
            pop ESI
            mov EAX,1
            ret 
$L_4e8e30 ENDP


$L_4e8ea0 PROC
            mov EAX,DWORD PTR [ESP+4]
            mov ECX,DWORD PTR [EAX+28]
            inc ECX
            mov DWORD PTR [EAX+28],ECX
            mov AX,WORD PTR [$L_989ff2]
            mov WORD PTR [$L_989fe6],AX
            xor EAX,EAX
            mov WORD PTR [$L_98a0a8],AX
            mov BYTE PTR [$L_98a0aa],AL
            mov EAX,1
            ret 
$L_4e8ea0 ENDP


$L_4e8ed0 PROC
            mov EAX,DWORD PTR [$L_989e74]
            mov EDX,DWORD PTR [$L_989e70]
            mov DWORD PTR [$L_991f64],EAX
            mov EAX,DWORD PTR [ESP+4]
            or DH,128
            mov BYTE PTR [$L_691f10],4
            mov DWORD PTR [$L_989e70],EDX
            mov BYTE PTR [$L_991f20],1
            mov ECX,DWORD PTR [EAX+28]
            mov DL,BYTE PTR [ECX+1]
            mov BYTE PTR [$L_692d02],DL
            mov ECX,DWORD PTR [EAX+28]
            add ECX,2
            mov DWORD PTR [EAX+28],ECX
            mov EAX,1
            ret 
$L_4e8ed0 ENDP


$L_4e8f20 PROC
            sub ESP,32
            mov EDX,DWORD PTR [ESP+36]
            xor ECX,ECX
            push ESI
            push EDI
            mov EAX,DWORD PTR [EDX+28]
            mov CL,BYTE PTR [EAX+1]
            mov ESI,ECX
            xor ECX,ECX
            mov CL,BYTE PTR [EAX+2]
            mov EDI,ECX
            mov ECX,DWORD PTR [ESI*4+$L_98a0ac]
            mov ESI,DWORD PTR [ECX+56]
            mov DWORD PTR [ESP+24],ESI
            mov ESI,DWORD PTR [ECX+60]
            mov DWORD PTR [ESP+28],ESI
            mov ECX,DWORD PTR [ECX+64]
            mov DWORD PTR [ESP+32],ECX
            mov ECX,DWORD PTR [EDI*4+$L_98a0ac]
            mov ESI,DWORD PTR [ECX+56]
            mov DWORD PTR [ESP+8],ESI
            mov ESI,DWORD PTR [ECX+60]
            mov DWORD PTR [ESP+12],ESI
            mov ECX,DWORD PTR [ECX+64]
            mov DWORD PTR [ESP+16],ECX
            lea ECX,DWORD PTR [EAX+6]
            mov DWORD PTR [EDX+28],ECX
            xor EDX,EDX
            mov DL,BYTE PTR [EAX+3]
            xor ECX,ECX
            mov CX,WORD PTR [EAX+4]
            push EDX
            lea EDX,DWORD PTR [ESP+12]
            push ECX
            lea EAX,DWORD PTR [ESP+32]
            push EDX
            push EAX
            call FUN_4e3310

            add ESP,16
            neg EAX
            sbb EAX,EAX
            pop EDI
            inc EAX
            pop ESI
            add ESP,32
            ret 
$L_4e8f20 ENDP


$L_4e8fb0 PROC
            mov EAX,DWORD PTR [ESP+4]
            mov ECX,DWORD PTR [EAX+28]
            inc ECX
            mov DWORD PTR [EAX+28],ECX
            xor EAX,EAX
            cmp WORD PTR [$L_98a0a8],AX
            setne AL
            ret 
$L_4e8fb0 ENDP


$L_4e8fd0 PROC
            mov EAX,DWORD PTR [ESP+4]
            mov ECX,DWORD PTR [EAX+28]
            inc ECX
            mov DWORD PTR [EAX+28],ECX
            xor EAX,EAX
            mov WORD PTR [$L_98a0a8],AX
            mov BYTE PTR [$L_98a0aa],AL
            mov DWORD PTR [$L_989e94],1
            mov EAX,1
            ret 
$L_4e8fd0 ENDP


$L_4e9000 PROC
    call_c_vm vm_vib_fade_set
            mov EAX,DWORD PTR [ESP+4]
            mov ECX,DWORD PTR [EAX+28]
            add ECX,8
            mov DWORD PTR [EAX+28],ECX
            mov EAX,1
            ret 
$L_4e9000 ENDP



; 这就是虚拟机里的 CALL 或 GOTO 指令
ALIGN 16
FUN_4e3e30 PROC

            mov EDX,DWORD PTR [$L_695dfc]
            mov EAX,DWORD PTR [ESP+8]
            xor ECX,ECX
            push ESI
            mov CX,WORD PTR [EDX+EAX*2]
            mov EAX,DWORD PTR [ESP+8]
            add ECX,EDX
            movsx ESI,BYTE PTR [EAX+2]
            add ESI,6
            mov BYTE PTR [EAX+1],1
            shl ESI,5
            add ESI,EAX
            mov BYTE PTR [EAX],0
            mov DWORD PTR [EAX+320],ESI
            mov BYTE PTR [EAX+4],255
            mov BYTE PTR [EAX+8],255
            mov DWORD PTR [EAX+28],ECX
            pop ESI
            ret 
FUN_4e3e30 ENDP


; 分配/查找一个空闲的上下文槽位,然后跳转到 FUN_4e3e30 初始化它。
; 从池中分配一个空闲上下文,初始化后开始执行指定子程序。
; 这是虚拟机里的并发/协程创建指令,类似于创建一个新的执行线程或fiber。
; FUN_4e3e70(uint8_t subroutine_id, uint8_t arg2)
ALIGN 16
FUN_4e3e70 PROC

            mov AL,BYTE PTR [$L_695e08]
            test AL,AL
            mov EAX,DWORD PTR [ESP+4]
            jne $L_4e3eae

            cmp EAX,10
            jb $L_4e3edd

            mov CL,BYTE PTR [$L_694c89]
            mov EAX,2
            test CL,CL
            je $L_4e3edd

            mov ECX,OFFSET $L_694c89
$L_4e3e96::

            cmp EAX,9
            je $L_4e3edd

            inc EAX
            add ECX,372
            cmp EAX,10
            jae $L_4e3f0c

            cmp BYTE PTR [ECX],0
            jne $L_4e3e96

            jmp $L_4e3edd
$L_4e3eae::

            cmp EAX,14
            jb $L_4e3edd

            mov CL,BYTE PTR [$L_695829]
            mov EAX,10
            test CL,CL
            je $L_4e3edd

            mov ECX,OFFSET $L_695829
$L_4e3ec7::

            cmp EAX,13
            je $L_4e3edd

            inc EAX
            add ECX,372
            cmp EAX,14
            jae $L_4e3f0c

            cmp BYTE PTR [ECX],0
            jne $L_4e3ec7
$L_4e3edd::

            mov ECX,EAX
            push EDI
            shl ECX,5
            sub ECX,EAX
            lea EAX,DWORD PTR [ECX+ECX*2]
            mov ECX,6
            lea EDX,DWORD PTR [EAX*4+$L_6949a0]
            xor EAX,EAX
            mov DWORD PTR [ESP+8],EDX
            lea EDI,DWORD PTR [EDX+344]
            mov BYTE PTR [EDX+2],0

            rep stosd DWORD PTR ES:[EDI]

            pop EDI
            jmp FUN_4e3e30
$L_4e3f0c::
            ret 
FUN_4e3e70 ENDP


; 这条指令就是虚拟机的 CALL subroutine_id
ALIGN 16
FUN_4e3e10 PROC

            push EDI
            mov ECX,32
            xor EAX,EAX
            mov EDI,OFFSET $L_9887f0

            rep stosd DWORD PTR ES:[EDI]

            mov BYTE PTR [$L_98e4c8],AL
            pop EDI
            ret 
FUN_4e3e10 ENDP