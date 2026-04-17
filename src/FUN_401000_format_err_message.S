; Disassembled by yanming.J
; SPDX-License-Identifier: MIT
; https://github.com/yanmingsohu/

COMMENT !
  这是一个 x86 汇编编写的分发函数（Dispatcher），
  通常对应高级语言中的 switch-case 结构或状态机。

  主要功能：

  路由逻辑：接收一个栈参数作为输入 ID，通过一系列比较指令判断其值。
  分支跳转：根据匹配到的常量范围，利用跳转表（Jump Table）或直接加载地址，决定执行路径。
  子程序调用：绝大多数情况下，最终会调用同一个公共函数 _printx，
  但传递不同的后续处理入口地址作为参数。
  用途：
  常用于协议解析、命令分发或编译器生成的状态机调度代码，根据输入类型动态路由到具体的处理逻辑。
!
ALIGN 16
FUN_401000 PROC

            mov EAX,DWORD PTR [ESP+4]
$L_401004::

            cmp EAX,2289435202
            jg $L_4014f2

            je $L_4014e5

            cmp EAX,2289434954
            jg $L_4012d8

            je $L_4012cb

            cmp EAX,2289434794
            jg $L_4011b5

            je $L_4011a8

            cmp EAX,2289434679
            jg $L_401116

            je $L_401109

            cmp EAX,2147942487
            jg $L_4010b8

            je $L_4010ab

            cmp EAX,2147746288
            jg $L_401093

            je $L_401086

            cmp EAX,2147500033
            je $L_401079

            cmp EAX,2147500037
            jne $L_401907

            mov DWORD PTR [ESP+4],OFFSET $L_51cb6c
            jmp _printx
$L_401079:

            mov DWORD PTR [ESP+4],OFFSET $L_51cb44
            jmp _printx
$L_401086:

            mov DWORD PTR [ESP+4],OFFSET $L_51cab0
            jmp _printx
$L_401093:

            cmp EAX,2147942414
            jne $L_401907
$L_40109e:

            mov DWORD PTR [ESP+4],OFFSET $L_51ca60
            jmp _printx
$L_4010ab:

            mov DWORD PTR [ESP+4],OFFSET $L_51ca00
            jmp _printx
$L_4010b8:

            add EAX,2005532667
            cmp EAX,35
            ja $L_401907

            xor ECX,ECX
            mov CL,BYTE PTR [EAX+$L_401928]
            jmp DWORD PTR [ECX*4+$L_401914]
$L_4010d5:

            mov DWORD PTR [ESP+4],OFFSET $L_51c9cc
            jmp _printx
$L_4010e2:

            mov DWORD PTR [ESP+4],OFFSET $L_51c980
            jmp _printx
$L_4010ef:

            mov DWORD PTR [ESP+4],OFFSET $L_51c930
            jmp _printx
$L_4010fc:

            mov DWORD PTR [ESP+4],OFFSET $L_51c8f8
            jmp _printx
$L_401109:

            mov DWORD PTR [ESP+4],OFFSET $L_51c8a0
            jmp _printx
$L_401116:

            add EAX,2005532582
            cmp EAX,70
            ja $L_401907

            xor EDX,EDX
            mov DL,BYTE PTR [EAX+$L_401974]
            jmp DWORD PTR [EDX*4+$L_40194c]
$L_401133:

            mov DWORD PTR [ESP+4],OFFSET $L_51c850
            jmp _printx
$L_401140:

            mov DWORD PTR [ESP+4],OFFSET $L_51c7f0
            jmp _printx
$L_40114d:

            mov DWORD PTR [ESP+4],OFFSET $L_51c798
            jmp _printx
$L_40115a:

            mov DWORD PTR [ESP+4],OFFSET $L_51c754
            jmp _printx
$L_401167:

            mov DWORD PTR [ESP+4],OFFSET $L_51c714
            jmp _printx
$L_401174:

            mov DWORD PTR [ESP+4],OFFSET $L_51c6c0
            jmp _printx
$L_401181:

            mov DWORD PTR [ESP+4],OFFSET $L_51c684
            jmp _printx
$L_40118e:

            mov DWORD PTR [ESP+4],OFFSET $L_51c654
            jmp _printx
$L_40119b:

            mov DWORD PTR [ESP+4],OFFSET $L_51c5f8
            jmp _printx
$L_4011a8:

            mov DWORD PTR [ESP+4],OFFSET $L_51c5d0
            jmp _printx
$L_4011b5:

            add EAX,2005532492
            cmp EAX,140
            ja $L_401907

            xor ECX,ECX
            mov CL,BYTE PTR [EAX+$L_401a0c]
            jmp DWORD PTR [ECX*4+$L_4019bc]
$L_4011d4:

            mov DWORD PTR [ESP+4],OFFSET $L_51c558
            jmp _printx
$L_4011e1:

            mov DWORD PTR [ESP+4],OFFSET $L_51c530
            jmp _printx
$L_4011ee:

            mov DWORD PTR [ESP+4],OFFSET $L_51c4b8
            jmp _printx
$L_4011fb:

            mov DWORD PTR [ESP+4],OFFSET $L_51c448
            jmp _printx
$L_401208:

            mov DWORD PTR [ESP+4],OFFSET $L_51c408
            jmp _printx
$L_401215:

            mov DWORD PTR [ESP+4],OFFSET $L_51c398
            jmp _printx
$L_401222:

            mov DWORD PTR [ESP+4],OFFSET $L_51c348
            jmp _printx
$L_40122f:

            mov DWORD PTR [ESP+4],OFFSET $L_51c2c8
            jmp _printx
$L_40123c:

            mov DWORD PTR [ESP+4],OFFSET $L_51c288
            jmp _printx
$L_401249:

            mov DWORD PTR [ESP+4],OFFSET $L_51c260
            jmp _printx
$L_401256:

            mov DWORD PTR [ESP+4],OFFSET $L_51c1f8
            jmp _printx
$L_401263:

            mov DWORD PTR [ESP+4],OFFSET $L_51c1c8
            jmp _printx
$L_401270:

            mov DWORD PTR [ESP+4],OFFSET $L_51c158
            jmp _printx
$L_40127d:

            mov DWORD PTR [ESP+4],OFFSET $L_51c0d8
            jmp _printx
$L_40128a:

            mov DWORD PTR [ESP+4],OFFSET $L_51c068
            jmp _printx
$L_401297:

            mov DWORD PTR [ESP+4],OFFSET $L_51c000
            jmp _printx
$L_4012a4:

            mov DWORD PTR [ESP+4],OFFSET $L_51bf80
            jmp _printx
$L_4012b1:

            mov DWORD PTR [ESP+4],OFFSET $L_51bef8
            jmp _printx
$L_4012be:

            mov DWORD PTR [ESP+4],OFFSET $L_51be88
            jmp _printx
$L_4012cb:

            mov DWORD PTR [ESP+4],OFFSET $L_51be10
            jmp _printx
$L_4012d8:

            add EAX,2005532337
            cmp EAX,242
            ja $L_401907

            xor EDX,EDX
            mov DL,BYTE PTR [EAX+$L_401b3c]
            jmp DWORD PTR [EDX*4+$L_401a9c]
$L_4012f7:

            mov DWORD PTR [ESP+4],OFFSET $L_51bd88
            jmp _printx
$L_401304:

            mov DWORD PTR [ESP+4],OFFSET $L_51bd18
            jmp _printx
$L_401311:

            mov DWORD PTR [ESP+4],OFFSET $L_51bc88
            jmp _printx
$L_40131e:

            mov DWORD PTR [ESP+4],OFFSET $L_51bc28
            jmp _printx
$L_40132b:

            mov DWORD PTR [ESP+4],OFFSET $L_51bbe8
            jmp _printx
$L_401338:

            mov DWORD PTR [ESP+4],OFFSET $L_51bb78
            jmp _printx
$L_401345:

            mov DWORD PTR [ESP+4],OFFSET $L_51bb38
            jmp _printx
$L_401352:

            mov DWORD PTR [ESP+4],OFFSET $L_51bae0
            jmp _printx
$L_40135f:

            mov DWORD PTR [ESP+4],OFFSET $L_51ba78
            jmp _printx
$L_40136c:

            mov DWORD PTR [ESP+4],OFFSET $L_51ba08
            jmp _printx
$L_401379:

            mov DWORD PTR [ESP+4],OFFSET $L_51b8e0
            jmp _printx
$L_401386:

            mov DWORD PTR [ESP+4],OFFSET $L_51b898
            jmp _printx
$L_401393:

            mov DWORD PTR [ESP+4],OFFSET $L_51b7e8
            jmp _printx
$L_4013a0:

            mov DWORD PTR [ESP+4],OFFSET $L_51b7ac
            jmp _printx
$L_4013ad:

            mov DWORD PTR [ESP+4],OFFSET $L_51b770
            jmp _printx
$L_4013ba:

            mov DWORD PTR [ESP+4],OFFSET $L_51b708
            jmp _printx
$L_4013c7:

            mov DWORD PTR [ESP+4],OFFSET $L_51b6cc
            jmp _printx
$L_4013d4:

            mov DWORD PTR [ESP+4],OFFSET $L_51b688
            jmp _printx
$L_4013e1:

            mov DWORD PTR [ESP+4],OFFSET $L_51b630
            jmp _printx
$L_4013ee:

            mov DWORD PTR [ESP+4],OFFSET $L_51b600
            jmp _printx
$L_4013fb:

            mov DWORD PTR [ESP+4],OFFSET $L_51b580
            jmp _printx
$L_401408:

            mov DWORD PTR [ESP+4],OFFSET $L_51b528
            jmp _printx
$L_401415:

            mov DWORD PTR [ESP+4],OFFSET $L_51b4c8
            jmp _printx
$L_401422:

            mov DWORD PTR [ESP+4],OFFSET $L_51b460
            jmp _printx
$L_40142f:

            mov DWORD PTR [ESP+4],OFFSET $L_51b3e8
            jmp _printx
$L_40143c:

            mov DWORD PTR [ESP+4],OFFSET $L_51b3b4
            jmp _printx
$L_401449:

            mov DWORD PTR [ESP+4],OFFSET $L_51b370
            jmp _printx
$L_401456:

            mov DWORD PTR [ESP+4],OFFSET $L_51b300
            jmp _printx
$L_401463:

            mov DWORD PTR [ESP+4],OFFSET $L_51b2c0
            jmp _printx
$L_401470:

            mov DWORD PTR [ESP+4],OFFSET $L_51b248
            jmp _printx
$L_40147d:

            mov DWORD PTR [ESP+4],OFFSET $L_51b1c8
            jmp _printx
$L_40148a:

            mov DWORD PTR [ESP+4],OFFSET $L_51b140
            jmp _printx
$L_401497:

            mov DWORD PTR [ESP+4],OFFSET $L_51b104
            jmp _printx
$L_4014a4:

            mov DWORD PTR [ESP+4],OFFSET $L_51b0c0
            jmp _printx
$L_4014b1:

            mov DWORD PTR [ESP+4],OFFSET $L_51b058
            jmp _printx
$L_4014be:

            mov DWORD PTR [ESP+4],OFFSET $L_51b03c
            jmp _printx
$L_4014cb:

            mov DWORD PTR [ESP+4],OFFSET $L_51b010
            jmp _printx
$L_4014d8:

            mov DWORD PTR [ESP+4],OFFSET $L_51afc0
            jmp _printx
$L_4014e5:

            mov DWORD PTR [ESP+4],OFFSET $L_51af30
            jmp _printx
$L_4014f2:

            add EAX,2005532093
            cmp EAX,196
            ja $L_401907

            xor ECX,ECX
            mov CL,BYTE PTR [EAX+$L_401d6c]
            jmp DWORD PTR [ECX*4+$L_401c30]
$L_401511:

            mov DWORD PTR [ESP+4],OFFSET $L_51aeb8
            jmp _printx
$L_40151e:

            mov DWORD PTR [ESP+4],OFFSET $L_51ae60
            jmp _printx
$L_40152b:

            mov DWORD PTR [ESP+4],OFFSET $L_51adf8
            jmp _printx
$L_401538:

            mov DWORD PTR [ESP+4],OFFSET $L_51ada0
            jmp _printx
$L_401545:

            mov DWORD PTR [ESP+4],OFFSET $L_51ad40
            jmp _printx
$L_401552:

            mov DWORD PTR [ESP+4],OFFSET $L_51acb0
            jmp _printx
$L_40155f:

            mov DWORD PTR [ESP+4],OFFSET $L_51ac7c
            jmp _printx
$L_40156c:

            mov DWORD PTR [ESP+4],OFFSET $L_51ac44
            jmp _printx
$L_401579:

            mov DWORD PTR [ESP+4],OFFSET $L_51abe8
            jmp _printx
$L_401586:

            mov DWORD PTR [ESP+4],OFFSET $L_51ab88
            jmp _printx
$L_401593:

            mov DWORD PTR [ESP+4],OFFSET $L_51ab40
            jmp _printx
$L_4015a0:

            mov DWORD PTR [ESP+4],OFFSET $L_51ab00
            jmp _printx
$L_4015ad:

            mov DWORD PTR [ESP+4],OFFSET $L_51aa80
            jmp _printx
$L_4015ba:

            mov DWORD PTR [ESP+4],OFFSET $L_51aa18
            jmp _printx
$L_4015c7:

            mov DWORD PTR [ESP+4],OFFSET $L_51a9b0
            jmp _printx
$L_4015d4:

            mov DWORD PTR [ESP+4],OFFSET $L_51a950
            jmp _printx
$L_4015e1:

            mov DWORD PTR [ESP+4],OFFSET $L_51a8e0
            jmp _printx
$L_4015ee:

            mov DWORD PTR [ESP+4],OFFSET $L_51a858
            jmp _printx
$L_4015fb:

            mov DWORD PTR [ESP+4],OFFSET $L_51a818
            jmp _printx
$L_401608:

            mov DWORD PTR [ESP+4],OFFSET $L_51a7dc
            jmp _printx
$L_401615:

            mov DWORD PTR [ESP+4],OFFSET $L_51a780
            jmp _printx
$L_401622:

            mov DWORD PTR [ESP+4],OFFSET $L_51a728
            jmp _printx
$L_40162f:

            mov DWORD PTR [ESP+4],OFFSET $L_51a6fc
            jmp _printx
$L_40163c:

            mov DWORD PTR [ESP+4],OFFSET $L_51a688
            jmp _printx
$L_401649:

            mov DWORD PTR [ESP+4],OFFSET $L_51a670
            jmp _printx
$L_401656:

            mov DWORD PTR [ESP+4],OFFSET $L_51a658
            jmp _printx
$L_401663:

            mov DWORD PTR [ESP+4],OFFSET $L_51a640
            jmp _printx
$L_401670:

            mov DWORD PTR [ESP+4],OFFSET $L_51a62c
            jmp _printx
$L_40167d:

            mov DWORD PTR [ESP+4],OFFSET $L_51a614
            jmp _printx
$L_40168a:

            mov DWORD PTR [ESP+4],OFFSET $L_51a5f4
            jmp _printx
$L_401697:

            mov DWORD PTR [ESP+4],OFFSET $L_51a5d4
            jmp _printx
$L_4016a4:

            mov DWORD PTR [ESP+4],OFFSET $L_51a5b8
            jmp _printx
$L_4016b1:

            mov DWORD PTR [ESP+4],OFFSET $L_51a598
            jmp _printx
$L_4016be:

            mov DWORD PTR [ESP+4],OFFSET $L_51a580
            jmp _printx
$L_4016cb:

            mov DWORD PTR [ESP+4],OFFSET $L_51a564
            jmp _printx
$L_4016d8:

            mov DWORD PTR [ESP+4],OFFSET $L_51a54c
            jmp _printx
$L_4016e5:

            mov DWORD PTR [ESP+4],OFFSET $L_51a52c
            jmp _printx
$L_4016f2:

            mov DWORD PTR [ESP+4],OFFSET $L_51a510
            jmp _printx
$L_4016ff:

            mov DWORD PTR [ESP+4],OFFSET $L_51a4f0
            jmp _printx
$L_40170c:

            mov DWORD PTR [ESP+4],OFFSET $L_51a4d0
            jmp _printx
$L_401719:

            mov DWORD PTR [ESP+4],OFFSET $L_51a4b4
            jmp _printx
$L_401726:

            mov DWORD PTR [ESP+4],OFFSET $L_51a494
            jmp _printx
$L_401733:

            mov DWORD PTR [ESP+4],OFFSET $L_51a478
            jmp _printx
$L_401740:

            mov DWORD PTR [ESP+4],OFFSET $L_51a45c
            jmp _printx
$L_40174d:

            mov DWORD PTR [ESP+4],OFFSET $L_51a444
            jmp _printx
$L_40175a:

            mov DWORD PTR [ESP+4],OFFSET $L_51a428
            jmp _printx
$L_401767:

            mov DWORD PTR [ESP+4],OFFSET $L_51a408
            jmp _printx
$L_401774:

            mov DWORD PTR [ESP+4],OFFSET $L_51a3ec
            jmp _printx
$L_401781:

            mov DWORD PTR [ESP+4],OFFSET $L_51a3cc
            jmp _printx
$L_40178e:

            mov DWORD PTR [ESP+4],OFFSET $L_51a3ac
            jmp _printx
$L_40179b:

            mov DWORD PTR [ESP+4],OFFSET $L_51a38c
            jmp _printx
$L_4017a8:

            mov DWORD PTR [ESP+4],OFFSET $L_51a36c
            jmp _printx
$L_4017b5:

            mov DWORD PTR [ESP+4],OFFSET $L_51a34c
            jmp _printx
$L_4017c2:

            mov DWORD PTR [ESP+4],OFFSET $L_51a330
            jmp _printx
$L_4017cf:

            mov DWORD PTR [ESP+4],OFFSET $L_51a314
            jmp _printx
$L_4017dc:

            mov DWORD PTR [ESP+4],OFFSET $L_51a2fc
            jmp _printx
$L_4017e9:

            mov DWORD PTR [ESP+4],OFFSET $L_51a2e0
            jmp _printx
$L_4017f6:

            mov DWORD PTR [ESP+4],OFFSET $L_51a2c0
            jmp _printx
$L_401803:

            mov DWORD PTR [ESP+4],OFFSET $L_51a2a0
            jmp _printx
$L_401810:

            mov DWORD PTR [ESP+4],OFFSET $L_51a280
            jmp _printx
$L_40181d:

            mov DWORD PTR [ESP+4],OFFSET $L_51a260
            jmp _printx
$L_40182a:

            mov DWORD PTR [ESP+4],OFFSET $L_51a248
            jmp _printx
$L_401837:

            mov DWORD PTR [ESP+4],OFFSET $L_51a228
            jmp _printx
$L_401844:

            mov DWORD PTR [ESP+4],OFFSET $L_51a208
            jmp _printx
$L_401851:

            mov DWORD PTR [ESP+4],OFFSET $L_51a1ec
            jmp _printx
$L_40185e:

            mov DWORD PTR [ESP+4],OFFSET $L_51a1d4
            jmp _printx
$L_40186b:

            mov DWORD PTR [ESP+4],OFFSET $L_51a1bc
            jmp _printx
$L_401878:

            mov DWORD PTR [ESP+4],OFFSET $L_51a19c
            jmp _printx
$L_401885:

            mov DWORD PTR [ESP+4],OFFSET $L_51a184
            jmp _printx
$L_401892:

            mov DWORD PTR [ESP+4],OFFSET $L_51a168
            jmp _printx
$L_40189f:

            mov DWORD PTR [ESP+4],OFFSET $L_51a14c
            jmp _printx
$L_4018ac:

            mov DWORD PTR [ESP+4],OFFSET $L_51a134
            jmp _printx
$L_4018b9:

            mov DWORD PTR [ESP+4],OFFSET $L_51a124
            jmp _printx
$L_4018c6:

            mov DWORD PTR [ESP+4],OFFSET $L_51a110
            jmp _printx
$L_4018d3:

            mov DWORD PTR [ESP+4],OFFSET $L_51a0fc
            jmp _printx
$L_4018e0:

            mov DWORD PTR [ESP+4],OFFSET $L_51a0e0
            jmp _printx
$L_4018ed:

            mov DWORD PTR [ESP+4],OFFSET $L_51a0c4
            jmp _printx
$L_4018fa:

            mov DWORD PTR [ESP+4],OFFSET $L_51a0a8
            jmp _printx
$L_401907:

            mov DWORD PTR [ESP+4],OFFSET $L_51a070
            jmp _printx
$L_401914           DWORD $L_4010d5
$L_401918           DWORD $L_4010e2
$L_40191c           DWORD $L_4010ef
$L_401920           DWORD $L_4010fc
$L_401924           DWORD $L_401907
$L_401928 DB 000h,004h,004h,004h,004h,001h,004h,004h ; 0x401928 (8 bytes)
          DB 004h,004h,004h,004h,004h,004h,004h,002h ; 0x401930 (16 bytes)
          DB 004h,004h,004h,004h,004h,004h,004h,004h ; 0x401938 (24 bytes)
          DB 004h,004h,004h,004h,004h,004h,004h,004h ; 0x401940 (32 bytes)
          DB 004h,004h,004h,003h ; 0x401948 (36 bytes)
$L_40194c           DWORD $L_401133
$L_401950           DWORD $L_401140
$L_401954           DWORD $L_40114d
$L_401958           DWORD $L_40115a
$L_40195c           DWORD $L_401167
$L_401960           DWORD $L_401174
$L_401964           DWORD $L_401181
$L_401968           DWORD $L_40118e
$L_40196c           DWORD $L_40119b
$L_401970           DWORD $L_401907
$L_401974 DB 000h,009h,009h,009h,009h,001h,009h,009h ; 0x401974 (8 bytes)
          DB 009h,009h,002h,009h,009h,009h,009h,009h ; 0x40197c (16 bytes)
          DB 009h,009h,009h,009h,003h,009h,009h,009h ; 0x401984 (24 bytes)
          DB 009h,009h,009h,009h,009h,009h,004h,009h ; 0x40198c (32 bytes)
          DB 009h,009h,009h,009h,009h,009h,009h,009h ; 0x401994 (40 bytes)
          DB 005h,009h,009h,009h,009h,009h,009h,009h ; 0x40199c (48 bytes)
          DB 009h,009h,009h,009h,009h,009h,009h,006h ; 0x4019a4 (56 bytes)
          DB 009h,009h,009h,009h,007h,009h,009h,009h ; 0x4019ac (64 bytes)
          DB 009h,009h,009h,009h,009h,009h,008h,090h ; 0x4019b4 (72 bytes)
$L_4019bc           DWORD $L_4011d4
$L_4019c0           DWORD $L_4011e1
$L_4019c4           DWORD $L_4011ee
$L_4019c8           DWORD $L_4011fb
$L_4019cc           DWORD $L_401208
$L_4019d0           DWORD $L_401215
$L_4019d4           DWORD $L_401222
$L_4019d8           DWORD $L_40122f
$L_4019dc           DWORD $L_40123c
$L_4019e0           DWORD $L_401249
$L_4019e4           DWORD $L_401256
$L_4019e8           DWORD $L_401263
$L_4019ec           DWORD $L_401270
$L_4019f0           DWORD $L_40127d
$L_4019f4           DWORD $L_40128a
$L_4019f8           DWORD $L_401297
$L_4019fc           DWORD $L_4012a4
$L_401a00           DWORD $L_4012b1
$L_401a04           DWORD $L_4012be
$L_401a08           DWORD $L_401907
$L_401a0c DB 000h,013h,013h,013h,013h,013h,013h,013h ; 0x401a0c (8 bytes)
          DB 013h,013h,013h,013h,013h,013h,013h,013h ; 0x401a14 (16 bytes)
          DB 013h,013h,013h,013h,013h,013h,013h,013h ; 0x401a1c (24 bytes)
          DB 013h,001h,013h,013h,013h,013h,002h,013h ; 0x401a24 (32 bytes)
          DB 003h,013h,013h,004h,013h,013h,013h,013h ; 0x401a2c (40 bytes)
          DB 005h,013h,006h,013h,013h,007h,013h,013h ; 0x401a34 (48 bytes)
          DB 013h,013h,008h,013h,013h,013h,013h,013h ; 0x401a3c (56 bytes)
          DB 013h,013h,013h,013h,009h,013h,013h,013h ; 0x401a44 (64 bytes)
          DB 013h,013h,013h,013h,013h,013h,00Ah,013h ; 0x401a4c (72 bytes)
          DB 013h,013h,013h,00Bh,013h,013h,013h,013h ; 0x401a54 (80 bytes)
          DB 00Ch,013h,013h,013h,013h,013h,013h,013h ; 0x401a5c (88 bytes)
          DB 013h,013h,013h,013h,013h,013h,013h,013h ; 0x401a64 (96 bytes)
          DB 013h,013h,013h,013h,00Dh,013h,013h,013h ; 0x401a6c (104 bytes)
          DB 013h,013h,013h,013h,013h,013h,00Eh,013h ; 0x401a74 (112 bytes)
          DB 013h,013h,013h,013h,013h,013h,013h,013h ; 0x401a7c (120 bytes)
          DB 013h,013h,013h,013h,013h,013h,013h,013h ; 0x401a84 (128 bytes)
          DB 013h,013h,00Fh,013h,013h,013h,013h,013h ; 0x401a8c (136 bytes)
          DB 010h,011h,013h,013h,012h,08Dh,049h,000h ; 0x401a94 (144 bytes)
$L_401a9c           DWORD $L_4012f7
$L_401aa0           DWORD $L_401304
$L_401aa4           DWORD $L_401311
$L_401aa8           DWORD $L_40131e
$L_401aac           DWORD $L_40109e
$L_401ab0           DWORD $L_40132b
$L_401ab4           DWORD $L_401338
$L_401ab8           DWORD $L_401345
$L_401abc           DWORD $L_401352
$L_401ac0           DWORD $L_40135f
$L_401ac4           DWORD $L_40136c
$L_401ac8           DWORD $L_401379
$L_401acc           DWORD $L_401386
$L_401ad0           DWORD $L_401393
$L_401ad4           DWORD $L_4013a0
$L_401ad8           DWORD $L_4013ad
$L_401adc           DWORD $L_4013ba
$L_401ae0           DWORD $L_4013c7
$L_401ae4           DWORD $L_4013d4
$L_401ae8           DWORD $L_4013e1
$L_401aec           DWORD $L_4013ee
$L_401af0           DWORD $L_4013fb
$L_401af4           DWORD $L_401408
$L_401af8           DWORD $L_401415
$L_401afc           DWORD $L_401422
$L_401b00           DWORD $L_40142f
$L_401b04           DWORD $L_40143c
$L_401b08           DWORD $L_401449
$L_401b0c           DWORD $L_401456
$L_401b10           DWORD $L_401463
$L_401b14           DWORD $L_401470
$L_401b18           DWORD $L_40147d
$L_401b1c           DWORD $L_40148a
$L_401b20           DWORD $L_401497
$L_401b24           DWORD $L_4014a4
$L_401b28           DWORD $L_4014b1
$L_401b2c           DWORD $L_4014be
$L_401b30           DWORD $L_4014cb
$L_401b34           DWORD $L_4014d8
$L_401b38           DWORD $L_401907
$L_401b3c DB 000h,027h,027h,027h,027h,001h,027h,027h ; 0x401b3c (8 bytes)
          DB 027h,027h,027h,027h,027h,027h,027h,002h ; 0x401b44 (16 bytes)
          DB 027h,027h,027h,027h,027h,027h,027h,027h ; 0x401b4c (24 bytes)
          DB 027h,003h,027h,027h,027h,027h,027h,027h ; 0x401b54 (32 bytes)
          DB 027h,027h,027h,027h,027h,027h,027h,027h ; 0x401b5c (40 bytes)
          DB 027h,027h,027h,027h,027h,004h,027h,005h ; 0x401b64 (48 bytes)
          DB 027h,027h,027h,027h,006h,027h,027h,027h ; 0x401b6c (56 bytes)
          DB 027h,027h,027h,027h,027h,027h,027h,027h ; 0x401b74 (64 bytes)
          DB 027h,007h,027h,027h,027h,027h,027h,027h ; 0x401b7c (72 bytes)
          DB 027h,027h,027h,008h,027h,027h,027h,027h ; 0x401b84 (80 bytes)
          DB 027h,027h,027h,027h,027h,009h,027h,027h ; 0x401b8c (88 bytes)
          DB 027h,027h,027h,027h,027h,027h,027h,00Ah ; 0x401b94 (96 bytes)
          DB 027h,027h,027h,027h,00Bh,027h,027h,027h ; 0x401b9c (104 bytes)
          DB 027h,00Ch,027h,027h,027h,027h,027h,027h ; 0x401ba4 (112 bytes)
          DB 027h,027h,027h,00Dh,027h,027h,027h,027h ; 0x401bac (120 bytes)
          DB 027h,027h,027h,027h,027h,00Eh,027h,027h ; 0x401bb4 (128 bytes)
          DB 027h,027h,027h,027h,027h,027h,027h,00Fh ; 0x401bbc (136 bytes)
          DB 027h,027h,027h,027h,027h,027h,027h,027h ; 0x401bc4 (144 bytes)
          DB 027h,010h,027h,027h,027h,027h,027h,027h ; 0x401bcc (152 bytes)
          DB 027h,027h,027h,011h,027h,027h,027h,027h ; 0x401bd4 (160 bytes)
          DB 027h,027h,027h,027h,027h,027h,027h,027h ; 0x401bdc (168 bytes)
          DB 027h,027h,027h,027h,027h,027h,027h,012h ; 0x401be4 (176 bytes)
          DB 027h,027h,027h,027h,027h,027h,027h,027h ; 0x401bec (184 bytes)
          DB 027h,013h,027h,027h,027h,027h,027h,027h ; 0x401bf4 (192 bytes)
          DB 027h,027h,027h,027h,027h,027h,027h,027h ; 0x401bfc (200 bytes)
          DB 027h,027h,014h,027h,027h,015h,027h,027h ; 0x401c04 (208 bytes)
          DB 027h,027h,027h,027h,027h,027h,027h,027h ; 0x401c0c (216 bytes)
          DB 027h,027h,027h,027h,027h,027h,027h,027h ; 0x401c14 (224 bytes)
          DB 027h,016h,017h,018h,019h,027h,01Ah,01Bh ; 0x401c1c (232 bytes)
          DB 01Ch,01Dh,01Eh,01Fh,020h,021h,022h,023h ; 0x401c24 (240 bytes)
          DB 024h,025h,026h,090h ; 0x401c2c (244 bytes)
$L_401c30           DWORD $L_401511
$L_401c34           DWORD $L_40151e
$L_401c38           DWORD $L_40152b
$L_401c3c           DWORD $L_401538
$L_401c40           DWORD $L_401545
$L_401c44           DWORD $L_401552
$L_401c48           DWORD $L_40155f
$L_401c4c           DWORD $L_40156c
$L_401c50           DWORD $L_401579
$L_401c54           DWORD $L_401586
$L_401c58           DWORD $L_401593
$L_401c5c           DWORD $L_4015a0
$L_401c60           DWORD $L_4015ad
$L_401c64           DWORD $L_4015ba
$L_401c68           DWORD $L_4015c7
$L_401c6c           DWORD $L_4015d4
$L_401c70           DWORD $L_4015e1
$L_401c74           DWORD $L_4015ee
$L_401c78           DWORD $L_4015fb
$L_401c7c           DWORD $L_401608
$L_401c80           DWORD $L_401615
$L_401c84           DWORD $L_401622
$L_401c88           DWORD $L_40162f
$L_401c8c           DWORD $L_40163c
$L_401c90           DWORD $L_401649
$L_401c94           DWORD $L_401656
$L_401c98           DWORD $L_401663
$L_401c9c           DWORD $L_401670
$L_401ca0           DWORD $L_40167d
$L_401ca4           DWORD $L_40168a
$L_401ca8           DWORD $L_401697
$L_401cac           DWORD $L_4016a4
$L_401cb0           DWORD $L_4016b1
$L_401cb4           DWORD $L_4016be
$L_401cb8           DWORD $L_4016cb
$L_401cbc           DWORD $L_4016d8
$L_401cc0           DWORD $L_4016e5
$L_401cc4           DWORD $L_4016f2
$L_401cc8           DWORD $L_4016ff
$L_401ccc           DWORD $L_40170c
$L_401cd0           DWORD $L_401719
$L_401cd4           DWORD $L_401726
$L_401cd8           DWORD $L_401733
$L_401cdc           DWORD $L_401740
$L_401ce0           DWORD $L_40174d
$L_401ce4           DWORD $L_40175a
$L_401ce8           DWORD $L_401767
$L_401cec           DWORD $L_401774
$L_401cf0           DWORD $L_401781
$L_401cf4           DWORD $L_40178e
$L_401cf8           DWORD $L_40179b
$L_401cfc           DWORD $L_4017a8
$L_401d00           DWORD $L_4017b5
$L_401d04           DWORD $L_4017c2
$L_401d08           DWORD $L_4017cf
$L_401d0c           DWORD $L_4017dc
$L_401d10           DWORD $L_4017e9
$L_401d14           DWORD $L_4017f6
$L_401d18           DWORD $L_401803
$L_401d1c           DWORD $L_401810
$L_401d20           DWORD $L_40181d
$L_401d24           DWORD $L_40182a
$L_401d28           DWORD $L_401837
$L_401d2c           DWORD $L_401844
$L_401d30           DWORD $L_401851
$L_401d34           DWORD $L_40185e
$L_401d38           DWORD $L_40186b
$L_401d3c           DWORD $L_401878
$L_401d40           DWORD $L_401885
$L_401d44           DWORD $L_401892
$L_401d48           DWORD $L_40189f
$L_401d4c           DWORD $L_4018ac
$L_401d50           DWORD $L_4018b9
$L_401d54           DWORD $L_4018c6
$L_401d58           DWORD $L_4018d3
$L_401d5c           DWORD $L_4018e0
$L_401d60           DWORD $L_4018ed
$L_401d64           DWORD $L_4018fa
$L_401d68           DWORD $L_401907
$L_401d6c DB 000h,001h,002h,003h,004h,005h,006h,007h ; 0x401d6c (8 bytes)
          DB 008h,009h,00Ah,00Bh,00Ch,00Dh,04Eh,04Eh ; 0x401d74 (16 bytes)
          DB 04Eh,04Eh,04Eh,04Eh,04Eh,00Eh,00Fh,04Eh ; 0x401d7c (24 bytes)
          DB 04Eh,04Eh,04Eh,04Eh,04Eh,04Eh,04Eh,04Eh ; 0x401d84 (32 bytes)
          DB 04Eh,04Eh,04Eh,04Eh,04Eh,04Eh,04Eh,04Eh ; 0x401d8c (40 bytes)
          DB 04Eh,010h,04Eh,04Eh,04Eh,04Eh,04Eh,04Eh ; 0x401d94 (48 bytes)
          DB 04Eh,04Eh,04Eh,011h,04Eh,04Eh,04Eh,04Eh ; 0x401d9c (56 bytes)
          DB 04Eh,04Eh,04Eh,04Eh,04Eh,012h,04Eh,04Eh ; 0x401da4 (64 bytes)
          DB 04Eh,04Eh,04Eh,04Eh,04Eh,04Eh,04Eh,04Eh ; 0x401dac (72 bytes)
          DB 04Eh,04Eh,04Eh,04Eh,04Eh,04Eh,04Eh,04Eh ; 0x401db4 (80 bytes)
          DB 04Eh,013h,04Eh,04Eh,04Eh,04Eh,04Eh,04Eh ; 0x401dbc (88 bytes)
          DB 04Eh,04Eh,04Eh,04Eh,04Eh,04Eh,04Eh,04Eh ; 0x401dc4 (96 bytes)
          DB 04Eh,04Eh,04Eh,04Eh,04Eh,014h,04Eh,04Eh ; 0x401dcc (104 bytes)
          DB 04Eh,04Eh,04Eh,04Eh,04Eh,04Eh,04Eh,015h ; 0x401dd4 (112 bytes)
          DB 04Eh,04Eh,04Eh,04Eh,016h,04Eh,04Eh,04Eh ; 0x401ddc (120 bytes)
          DB 017h,018h,019h,04Eh,04Eh,04Eh,01Ah,01Bh ; 0x401de4 (128 bytes)
          DB 01Ch,04Eh,04Eh,01Dh,01Eh,01Fh,020h,021h ; 0x401dec (136 bytes)
          DB 022h,023h,024h,04Eh,04Eh,025h,026h,027h ; 0x401df4 (144 bytes)
          DB 028h,029h,02Ah,02Bh,02Ch,02Dh,02Eh,02Fh ; 0x401dfc (152 bytes)
          DB 030h,031h,032h,033h,034h,035h,036h,037h ; 0x401e04 (160 bytes)
          DB 038h,039h,03Ah,03Bh,03Ch,03Dh,03Eh,03Fh ; 0x401e0c (168 bytes)
          DB 040h,04Eh,04Eh,041h,042h,043h,04Eh,04Eh ; 0x401e14 (176 bytes)
          DB 04Eh,04Eh,04Eh,04Eh,04Eh,044h,045h,046h ; 0x401e1c (184 bytes)
          DB 047h,04Eh,04Eh,04Eh,04Eh,04Eh,04Eh,048h ; 0x401e24 (192 bytes)
          DB 049h,04Ah,04Bh,04Ch,04Dh,090h,090h,090h ; 0x401e2c (200 bytes)
          DB 090h,090h,090h,090h,090h,090h,090h,090h ; 0x401e34 (208 bytes)
          DB 090h,090h,090h,090h ; 0x401e3c (212 bytes)
FUN_401000 ENDP


ALIGN 16
FUN_406a10 PROC

            mov EAX,DWORD PTR [ESP+4]
            add EAX,2005531972
            cmp EAX,63
            ja $L_406cb6

            xor ECX,ECX
            mov CL,BYTE PTR [EAX+$L_406d44]
            jmp DWORD PTR [ECX*4+$L_406cb8]
$L_406a31::

            push OFFSET $L_51dd40
            push OFFSET $L_51a670
            call DWORD PTR [__imp__printf]

            add ESP,8
            ret 
$L_406a44::

            push OFFSET $L_51dd40
            push OFFSET $L_51a658
            call DWORD PTR [__imp__printf]

            add ESP,8
            ret 
$L_406a57::

            push OFFSET $L_51dd40
            push OFFSET $L_51a5f4
            call DWORD PTR [__imp__printf]

            add ESP,8
            ret 
$L_406a6a::

            push OFFSET $L_51dd40
            push OFFSET $L_51a5d4
            call DWORD PTR [__imp__printf]

            add ESP,8
            ret 
$L_406a7d::

            push OFFSET $L_51dd40
            push OFFSET $L_51a5b8
            call DWORD PTR [__imp__printf]

            add ESP,8
            ret 
$L_406a90::

            push OFFSET $L_51dd40
            push OFFSET $L_51a598
            call DWORD PTR [__imp__printf]

            add ESP,8
            ret 
$L_406aa3::

            push OFFSET $L_51dd40
            push OFFSET $L_51a580
            call DWORD PTR [__imp__printf]

            add ESP,8
            ret 
$L_406ab6::

            push OFFSET $L_51dd40
            push OFFSET $L_51a564
            call DWORD PTR [__imp__printf]

            add ESP,8
            ret 
$L_406ac9::

            push OFFSET $L_51dd40
            push OFFSET $L_51a54c
            call DWORD PTR [__imp__printf]

            add ESP,8
            ret 
$L_406adc::

            push OFFSET $L_51dd40
            push OFFSET $L_51a52c
            call DWORD PTR [__imp__printf]

            add ESP,8
            ret 
$L_406aef::

            push OFFSET $L_51dd40
            push OFFSET $L_51a510
            call DWORD PTR [__imp__printf]

            add ESP,8
            ret 
$L_406b02::

            push OFFSET $L_51dd40
            push OFFSET $L_51a4f0
            call DWORD PTR [__imp__printf]

            add ESP,8
            ret 
$L_406b15::

            push OFFSET $L_51dd40
            push OFFSET $L_51a4d0
            call DWORD PTR [__imp__printf]

            add ESP,8
            ret 
$L_406b28::

            push OFFSET $L_51dd40
            push OFFSET $L_51a4b4
            call DWORD PTR [__imp__printf]

            add ESP,8
            ret 
$L_406b3b::

            push OFFSET $L_51dd40
            push OFFSET $L_51a494
            call DWORD PTR [__imp__printf]

            add ESP,8
            ret 
$L_406b4e::

            push OFFSET $L_51dd40
            push OFFSET $L_51a478
            call DWORD PTR [__imp__printf]

            add ESP,8
            ret 
$L_406b61::

            push OFFSET $L_51dd40
            push OFFSET $L_51a45c
            call DWORD PTR [__imp__printf]

            add ESP,8
            ret 
$L_406b74::

            push OFFSET $L_51dd40
            push OFFSET $L_51a444
            call DWORD PTR [__imp__printf]

            add ESP,8
            ret 
$L_406b87::

            push OFFSET $L_51dd40
            push OFFSET $L_51a428
            call DWORD PTR [__imp__printf]

            add ESP,8
            ret 
$L_406b9a::

            push OFFSET $L_51dd40
            push OFFSET $L_51a408
            call DWORD PTR [__imp__printf]

            add ESP,8
            ret 
$L_406bad::

            push OFFSET $L_51dd40
            push OFFSET $L_51a3ec
            call DWORD PTR [__imp__printf]

            add ESP,8
            ret 
$L_406bc0::

            push OFFSET $L_51dd40
            push OFFSET $L_51a3cc
            call DWORD PTR [__imp__printf]

            add ESP,8
            ret 
$L_406bd3::

            push OFFSET $L_51dd40
            push OFFSET $L_51a3ac
            call DWORD PTR [__imp__printf]

            add ESP,8
            ret 
$L_406be6::

            push OFFSET $L_51dd40
            push OFFSET $L_51a38c
            call DWORD PTR [__imp__printf]

            add ESP,8
            ret 
$L_406bf9::

            push OFFSET $L_51dd40
            push OFFSET $L_51a36c
            call DWORD PTR [__imp__printf]

            add ESP,8
            ret 
$L_406c0c::

            push OFFSET $L_51dd40
            push OFFSET $L_51a2c0
            call DWORD PTR [__imp__printf]

            add ESP,8
            ret 
$L_406c1f::

            push OFFSET $L_51dd40
            push OFFSET $L_51a2a0
            call DWORD PTR [__imp__printf]

            add ESP,8
            ret 
$L_406c32::

            push OFFSET $L_51dd40
            push OFFSET $L_51a280
            call DWORD PTR [__imp__printf]

            add ESP,8
            ret 
$L_406c45::

            push OFFSET $L_51dd40
            push OFFSET $L_51a260
            call DWORD PTR [__imp__printf]

            add ESP,8
            ret 
$L_406c58::

            push OFFSET $L_51dd40
            push OFFSET $L_51a1d4
            call DWORD PTR [__imp__printf]

            add ESP,8
            ret 
$L_406c6b::

            push OFFSET $L_51dd40
            push OFFSET $L_51a184
            call DWORD PTR [__imp__printf]

            add ESP,8
            ret 
$L_406c7e::

            push OFFSET $L_51dd40
            push OFFSET $L_51a168
            call DWORD PTR [__imp__printf]

            add ESP,8
            ret 
$L_406c91::

            push OFFSET $L_51dd40
            push OFFSET $L_51a14c
            call DWORD PTR [__imp__printf]

            add ESP,8
            ret 
$L_406ca4::

            push OFFSET $L_51dd40
            push OFFSET $L_51a134
            call DWORD PTR [__imp__printf]

            add ESP,8
$L_406cb6::

            ret 
          BYTE 090H
$L_406cb8           DWORD $L_406a31 ;++
$L_406cbc           DWORD $L_406a44
$L_406cc0           DWORD $L_406a57
$L_406cc4           DWORD $L_406a6a
$L_406cc8           DWORD $L_406a7d
$L_406ccc           DWORD $L_406a90
$L_406cd0           DWORD $L_406aa3
$L_406cd4           DWORD $L_406ab6
$L_406cd8           DWORD $L_406ac9
$L_406cdc           DWORD $L_406adc
$L_406ce0           DWORD $L_406aef
$L_406ce4           DWORD $L_406b02
$L_406ce8           DWORD $L_406b15
$L_406cec           DWORD $L_406b28
$L_406cf0           DWORD $L_406b3b
$L_406cf4           DWORD $L_406b4e
$L_406cf8           DWORD $L_406b61
$L_406cfc           DWORD $L_406b74
$L_406d00           DWORD $L_406b87
$L_406d04           DWORD $L_406b9a
$L_406d08           DWORD $L_406bad
$L_406d0c           DWORD $L_406bc0
$L_406d10           DWORD $L_406bd3
$L_406d14           DWORD $L_406be6
$L_406d18           DWORD $L_406bf9
$L_406d1c           DWORD $L_406c0c
$L_406d20           DWORD $L_406c1f
$L_406d24           DWORD $L_406c32
$L_406d28           DWORD $L_406c45
$L_406d2c           DWORD $L_406c58
$L_406d30           DWORD $L_406c6b
$L_406d34           DWORD $L_406c7e
$L_406d38           DWORD $L_406c91
$L_406d3c           DWORD $L_406ca4
$L_406d40           DWORD $L_406cb6
$L_406d44 DB 00h,01h,22h,22h,22h,22h,22h,22h,22h,22h,02h,03h,04h,05h,06h,07h ; 0x406D44 (16 bytes)
          DB 08h,09h,22h,22h,0Ah,0Bh,0Ch,0Dh,0Eh,0Fh,10h,11h,12h,13h,14h,15h ; 0x406D54 (32 bytes)
          DB 16h,17h,18h,22h,22h,22h,22h,22h,19h,1Ah,1Bh,1Ch,22h,22h,22h,22h ; 0x406D64 (48 bytes)
          DB 22h,22h,1Dh,22h,22h,22h,22h,22h,22h,22h,22h,22h,1Eh,1Fh,20h,21h ; 0x406D74 (64 bytes)
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
            nop
FUN_406a10 ENDP