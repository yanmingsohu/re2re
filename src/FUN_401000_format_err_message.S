; Disassembled by yanming.J
; SPDX-License-Identifier: MIT
; https://github.com/yanmingsohu/

COMMENT !
  这是一个 x86 汇编编写的分发函数（Dispatcher），
  通常对应高级语言中的 switch-case 结构或状态机。

  主要功能：

  路由逻辑：接收一个栈参数作为输入 ID，通过一系列比较指令判断其值。
  分支跳转：根据匹配到的常量范围，利用跳转表（Jump Table）或直接加载地址，决定执行路径。
  子程序调用：绝大多数情况下，最终会调用同一个公共函数 FUN_448300，
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
            jmp FUN_448300
$L_401079:

            mov DWORD PTR [ESP+4],OFFSET $L_51cb44
            jmp FUN_448300
$L_401086:

            mov DWORD PTR [ESP+4],OFFSET $L_51cab0
            jmp FUN_448300
$L_401093:

            cmp EAX,2147942414
            jne $L_401907
$L_40109e:

            mov DWORD PTR [ESP+4],OFFSET $L_51ca60
            jmp FUN_448300
$L_4010ab:

            mov DWORD PTR [ESP+4],OFFSET $L_51ca00
            jmp FUN_448300
$L_4010b8:

            add EAX,2005532667
            cmp EAX,35
            ja $L_401907

            xor ECX,ECX
            mov CL,BYTE PTR [EAX+$L_401928]
            jmp DWORD PTR [ECX*4+$L_401914]
$L_4010d5:

            mov DWORD PTR [ESP+4],OFFSET $L_51c9cc
            jmp FUN_448300
$L_4010e2:

            mov DWORD PTR [ESP+4],OFFSET $L_51c980
            jmp FUN_448300
$L_4010ef:

            mov DWORD PTR [ESP+4],OFFSET $L_51c930
            jmp FUN_448300
$L_4010fc:

            mov DWORD PTR [ESP+4],OFFSET $L_51c8f8
            jmp FUN_448300
$L_401109:

            mov DWORD PTR [ESP+4],OFFSET $L_51c8a0
            jmp FUN_448300
$L_401116:

            add EAX,2005532582
            cmp EAX,70
            ja $L_401907

            xor EDX,EDX
            mov DL,BYTE PTR [EAX+$L_401974]
            jmp DWORD PTR [EDX*4+$L_40194c]
$L_401133:

            mov DWORD PTR [ESP+4],OFFSET $L_51c850
            jmp FUN_448300
$L_401140:

            mov DWORD PTR [ESP+4],OFFSET $L_51c7f0
            jmp FUN_448300
$L_40114d:

            mov DWORD PTR [ESP+4],OFFSET $L_51c798
            jmp FUN_448300
$L_40115a:

            mov DWORD PTR [ESP+4],OFFSET $L_51c754
            jmp FUN_448300
$L_401167:

            mov DWORD PTR [ESP+4],OFFSET $L_51c714
            jmp FUN_448300
$L_401174:

            mov DWORD PTR [ESP+4],OFFSET $L_51c6c0
            jmp FUN_448300
$L_401181:

            mov DWORD PTR [ESP+4],OFFSET $L_51c684
            jmp FUN_448300
$L_40118e:

            mov DWORD PTR [ESP+4],OFFSET $L_51c654
            jmp FUN_448300
$L_40119b:

            mov DWORD PTR [ESP+4],OFFSET $L_51c5f8
            jmp FUN_448300
$L_4011a8:

            mov DWORD PTR [ESP+4],OFFSET $L_51c5d0
            jmp FUN_448300
$L_4011b5:

            add EAX,2005532492
            cmp EAX,140
            ja $L_401907

            xor ECX,ECX
            mov CL,BYTE PTR [EAX+$L_401a0c]
            jmp DWORD PTR [ECX*4+$L_4019bc]
$L_4011d4:

            mov DWORD PTR [ESP+4],OFFSET $L_51c558
            jmp FUN_448300
$L_4011e1:

            mov DWORD PTR [ESP+4],OFFSET $L_51c530
            jmp FUN_448300
$L_4011ee:

            mov DWORD PTR [ESP+4],OFFSET $L_51c4b8
            jmp FUN_448300
$L_4011fb:

            mov DWORD PTR [ESP+4],OFFSET $L_51c448
            jmp FUN_448300
$L_401208:

            mov DWORD PTR [ESP+4],OFFSET $L_51c408
            jmp FUN_448300
$L_401215:

            mov DWORD PTR [ESP+4],OFFSET $L_51c398
            jmp FUN_448300
$L_401222:

            mov DWORD PTR [ESP+4],OFFSET $L_51c348
            jmp FUN_448300
$L_40122f:

            mov DWORD PTR [ESP+4],OFFSET $L_51c2c8
            jmp FUN_448300
$L_40123c:

            mov DWORD PTR [ESP+4],OFFSET $L_51c288
            jmp FUN_448300
$L_401249:

            mov DWORD PTR [ESP+4],OFFSET $L_51c260
            jmp FUN_448300
$L_401256:

            mov DWORD PTR [ESP+4],OFFSET $L_51c1f8
            jmp FUN_448300
$L_401263:

            mov DWORD PTR [ESP+4],OFFSET $L_51c1c8
            jmp FUN_448300
$L_401270:

            mov DWORD PTR [ESP+4],OFFSET $L_51c158
            jmp FUN_448300
$L_40127d:

            mov DWORD PTR [ESP+4],OFFSET $L_51c0d8
            jmp FUN_448300
$L_40128a:

            mov DWORD PTR [ESP+4],OFFSET $L_51c068
            jmp FUN_448300
$L_401297:

            mov DWORD PTR [ESP+4],OFFSET $L_51c000
            jmp FUN_448300
$L_4012a4:

            mov DWORD PTR [ESP+4],OFFSET $L_51bf80
            jmp FUN_448300
$L_4012b1:

            mov DWORD PTR [ESP+4],OFFSET $L_51bef8
            jmp FUN_448300
$L_4012be:

            mov DWORD PTR [ESP+4],OFFSET $L_51be88
            jmp FUN_448300
$L_4012cb:

            mov DWORD PTR [ESP+4],OFFSET $L_51be10
            jmp FUN_448300
$L_4012d8:

            add EAX,2005532337
            cmp EAX,242
            ja $L_401907

            xor EDX,EDX
            mov DL,BYTE PTR [EAX+$L_401b3c]
            jmp DWORD PTR [EDX*4+$L_401a9c]
$L_4012f7:

            mov DWORD PTR [ESP+4],OFFSET $L_51bd88
            jmp FUN_448300
$L_401304:

            mov DWORD PTR [ESP+4],OFFSET $L_51bd18
            jmp FUN_448300
$L_401311:

            mov DWORD PTR [ESP+4],OFFSET $L_51bc88
            jmp FUN_448300
$L_40131e:

            mov DWORD PTR [ESP+4],OFFSET $L_51bc28
            jmp FUN_448300
$L_40132b:

            mov DWORD PTR [ESP+4],OFFSET $L_51bbe8
            jmp FUN_448300
$L_401338:

            mov DWORD PTR [ESP+4],OFFSET $L_51bb78
            jmp FUN_448300
$L_401345:

            mov DWORD PTR [ESP+4],OFFSET $L_51bb38
            jmp FUN_448300
$L_401352:

            mov DWORD PTR [ESP+4],OFFSET $L_51bae0
            jmp FUN_448300
$L_40135f:

            mov DWORD PTR [ESP+4],OFFSET $L_51ba78
            jmp FUN_448300
$L_40136c:

            mov DWORD PTR [ESP+4],OFFSET $L_51ba08
            jmp FUN_448300
$L_401379:

            mov DWORD PTR [ESP+4],OFFSET $L_51b8e0
            jmp FUN_448300
$L_401386:

            mov DWORD PTR [ESP+4],OFFSET $L_51b898
            jmp FUN_448300
$L_401393:

            mov DWORD PTR [ESP+4],OFFSET $L_51b7e8
            jmp FUN_448300
$L_4013a0:

            mov DWORD PTR [ESP+4],OFFSET $L_51b7ac
            jmp FUN_448300
$L_4013ad:

            mov DWORD PTR [ESP+4],OFFSET $L_51b770
            jmp FUN_448300
$L_4013ba:

            mov DWORD PTR [ESP+4],OFFSET $L_51b708
            jmp FUN_448300
$L_4013c7:

            mov DWORD PTR [ESP+4],OFFSET $L_51b6cc
            jmp FUN_448300
$L_4013d4:

            mov DWORD PTR [ESP+4],OFFSET $L_51b688
            jmp FUN_448300
$L_4013e1:

            mov DWORD PTR [ESP+4],OFFSET $L_51b630
            jmp FUN_448300
$L_4013ee:

            mov DWORD PTR [ESP+4],OFFSET $L_51b600
            jmp FUN_448300
$L_4013fb:

            mov DWORD PTR [ESP+4],OFFSET $L_51b580
            jmp FUN_448300
$L_401408:

            mov DWORD PTR [ESP+4],OFFSET $L_51b528
            jmp FUN_448300
$L_401415:

            mov DWORD PTR [ESP+4],OFFSET $L_51b4c8
            jmp FUN_448300
$L_401422:

            mov DWORD PTR [ESP+4],OFFSET $L_51b460
            jmp FUN_448300
$L_40142f:

            mov DWORD PTR [ESP+4],OFFSET $L_51b3e8
            jmp FUN_448300
$L_40143c:

            mov DWORD PTR [ESP+4],OFFSET $L_51b3b4
            jmp FUN_448300
$L_401449:

            mov DWORD PTR [ESP+4],OFFSET $L_51b370
            jmp FUN_448300
$L_401456:

            mov DWORD PTR [ESP+4],OFFSET $L_51b300
            jmp FUN_448300
$L_401463:

            mov DWORD PTR [ESP+4],OFFSET $L_51b2c0
            jmp FUN_448300
$L_401470:

            mov DWORD PTR [ESP+4],OFFSET $L_51b248
            jmp FUN_448300
$L_40147d:

            mov DWORD PTR [ESP+4],OFFSET $L_51b1c8
            jmp FUN_448300
$L_40148a:

            mov DWORD PTR [ESP+4],OFFSET $L_51b140
            jmp FUN_448300
$L_401497:

            mov DWORD PTR [ESP+4],OFFSET $L_51b104
            jmp FUN_448300
$L_4014a4:

            mov DWORD PTR [ESP+4],OFFSET $L_51b0c0
            jmp FUN_448300
$L_4014b1:

            mov DWORD PTR [ESP+4],OFFSET $L_51b058
            jmp FUN_448300
$L_4014be:

            mov DWORD PTR [ESP+4],OFFSET $L_51b03c
            jmp FUN_448300
$L_4014cb:

            mov DWORD PTR [ESP+4],OFFSET $L_51b010
            jmp FUN_448300
$L_4014d8:

            mov DWORD PTR [ESP+4],OFFSET $L_51afc0
            jmp FUN_448300
$L_4014e5:

            mov DWORD PTR [ESP+4],OFFSET $L_51af30
            jmp FUN_448300
$L_4014f2:

            add EAX,2005532093
            cmp EAX,196
            ja $L_401907

            xor ECX,ECX
            mov CL,BYTE PTR [EAX+$L_401d6c]
            jmp DWORD PTR [ECX*4+$L_401c30]
$L_401511:

            mov DWORD PTR [ESP+4],OFFSET $L_51aeb8
            jmp FUN_448300
$L_40151e:

            mov DWORD PTR [ESP+4],OFFSET $L_51ae60
            jmp FUN_448300
$L_40152b:

            mov DWORD PTR [ESP+4],OFFSET $L_51adf8
            jmp FUN_448300
$L_401538:

            mov DWORD PTR [ESP+4],OFFSET $L_51ada0
            jmp FUN_448300
$L_401545:

            mov DWORD PTR [ESP+4],OFFSET $L_51ad40
            jmp FUN_448300
$L_401552:

            mov DWORD PTR [ESP+4],OFFSET $L_51acb0
            jmp FUN_448300
$L_40155f:

            mov DWORD PTR [ESP+4],OFFSET $L_51ac7c
            jmp FUN_448300
$L_40156c:

            mov DWORD PTR [ESP+4],OFFSET $L_51ac44
            jmp FUN_448300
$L_401579:

            mov DWORD PTR [ESP+4],OFFSET $L_51abe8
            jmp FUN_448300
$L_401586:

            mov DWORD PTR [ESP+4],OFFSET $L_51ab88
            jmp FUN_448300
$L_401593:

            mov DWORD PTR [ESP+4],OFFSET $L_51ab40
            jmp FUN_448300
$L_4015a0:

            mov DWORD PTR [ESP+4],OFFSET $L_51ab00
            jmp FUN_448300
$L_4015ad:

            mov DWORD PTR [ESP+4],OFFSET $L_51aa80
            jmp FUN_448300
$L_4015ba:

            mov DWORD PTR [ESP+4],OFFSET $L_51aa18
            jmp FUN_448300
$L_4015c7:

            mov DWORD PTR [ESP+4],OFFSET $L_51a9b0
            jmp FUN_448300
$L_4015d4:

            mov DWORD PTR [ESP+4],OFFSET $L_51a950
            jmp FUN_448300
$L_4015e1:

            mov DWORD PTR [ESP+4],OFFSET $L_51a8e0
            jmp FUN_448300
$L_4015ee:

            mov DWORD PTR [ESP+4],OFFSET $L_51a858
            jmp FUN_448300
$L_4015fb:

            mov DWORD PTR [ESP+4],OFFSET $L_51a818
            jmp FUN_448300
$L_401608:

            mov DWORD PTR [ESP+4],OFFSET $L_51a7dc
            jmp FUN_448300
$L_401615:

            mov DWORD PTR [ESP+4],OFFSET $L_51a780
            jmp FUN_448300
$L_401622:

            mov DWORD PTR [ESP+4],OFFSET $L_51a728
            jmp FUN_448300
$L_40162f:

            mov DWORD PTR [ESP+4],OFFSET $L_51a6fc
            jmp FUN_448300
$L_40163c:

            mov DWORD PTR [ESP+4],OFFSET $L_51a688
            jmp FUN_448300
$L_401649:

            mov DWORD PTR [ESP+4],OFFSET $L_51a670
            jmp FUN_448300
$L_401656:

            mov DWORD PTR [ESP+4],OFFSET $L_51a658
            jmp FUN_448300
$L_401663:

            mov DWORD PTR [ESP+4],OFFSET $L_51a640
            jmp FUN_448300
$L_401670:

            mov DWORD PTR [ESP+4],OFFSET $L_51a62c
            jmp FUN_448300
$L_40167d:

            mov DWORD PTR [ESP+4],OFFSET $L_51a614
            jmp FUN_448300
$L_40168a:

            mov DWORD PTR [ESP+4],OFFSET $L_51a5f4
            jmp FUN_448300
$L_401697:

            mov DWORD PTR [ESP+4],OFFSET $L_51a5d4
            jmp FUN_448300
$L_4016a4:

            mov DWORD PTR [ESP+4],OFFSET $L_51a5b8
            jmp FUN_448300
$L_4016b1:

            mov DWORD PTR [ESP+4],OFFSET $L_51a598
            jmp FUN_448300
$L_4016be:

            mov DWORD PTR [ESP+4],OFFSET $L_51a580
            jmp FUN_448300
$L_4016cb:

            mov DWORD PTR [ESP+4],OFFSET $L_51a564
            jmp FUN_448300
$L_4016d8:

            mov DWORD PTR [ESP+4],OFFSET $L_51a54c
            jmp FUN_448300
$L_4016e5:

            mov DWORD PTR [ESP+4],OFFSET $L_51a52c
            jmp FUN_448300
$L_4016f2:

            mov DWORD PTR [ESP+4],OFFSET $L_51a510
            jmp FUN_448300
$L_4016ff:

            mov DWORD PTR [ESP+4],OFFSET $L_51a4f0
            jmp FUN_448300
$L_40170c:

            mov DWORD PTR [ESP+4],OFFSET $L_51a4d0
            jmp FUN_448300
$L_401719:

            mov DWORD PTR [ESP+4],OFFSET $L_51a4b4
            jmp FUN_448300
$L_401726:

            mov DWORD PTR [ESP+4],OFFSET $L_51a494
            jmp FUN_448300
$L_401733:

            mov DWORD PTR [ESP+4],OFFSET $L_51a478
            jmp FUN_448300
$L_401740:

            mov DWORD PTR [ESP+4],OFFSET $L_51a45c
            jmp FUN_448300
$L_40174d:

            mov DWORD PTR [ESP+4],OFFSET $L_51a444
            jmp FUN_448300
$L_40175a:

            mov DWORD PTR [ESP+4],OFFSET $L_51a428
            jmp FUN_448300
$L_401767:

            mov DWORD PTR [ESP+4],OFFSET $L_51a408
            jmp FUN_448300
$L_401774:

            mov DWORD PTR [ESP+4],OFFSET $L_51a3ec
            jmp FUN_448300
$L_401781:

            mov DWORD PTR [ESP+4],OFFSET $L_51a3cc
            jmp FUN_448300
$L_40178e:

            mov DWORD PTR [ESP+4],OFFSET $L_51a3ac
            jmp FUN_448300
$L_40179b:

            mov DWORD PTR [ESP+4],OFFSET $L_51a38c
            jmp FUN_448300
$L_4017a8:

            mov DWORD PTR [ESP+4],OFFSET $L_51a36c
            jmp FUN_448300
$L_4017b5:

            mov DWORD PTR [ESP+4],OFFSET $L_51a34c
            jmp FUN_448300
$L_4017c2:

            mov DWORD PTR [ESP+4],OFFSET $L_51a330
            jmp FUN_448300
$L_4017cf:

            mov DWORD PTR [ESP+4],OFFSET $L_51a314
            jmp FUN_448300
$L_4017dc:

            mov DWORD PTR [ESP+4],OFFSET $L_51a2fc
            jmp FUN_448300
$L_4017e9:

            mov DWORD PTR [ESP+4],OFFSET $L_51a2e0
            jmp FUN_448300
$L_4017f6:

            mov DWORD PTR [ESP+4],OFFSET $L_51a2c0
            jmp FUN_448300
$L_401803:

            mov DWORD PTR [ESP+4],OFFSET $L_51a2a0
            jmp FUN_448300
$L_401810:

            mov DWORD PTR [ESP+4],OFFSET $L_51a280
            jmp FUN_448300
$L_40181d:

            mov DWORD PTR [ESP+4],OFFSET $L_51a260
            jmp FUN_448300
$L_40182a:

            mov DWORD PTR [ESP+4],OFFSET $L_51a248
            jmp FUN_448300
$L_401837:

            mov DWORD PTR [ESP+4],OFFSET $L_51a228
            jmp FUN_448300
$L_401844:

            mov DWORD PTR [ESP+4],OFFSET $L_51a208
            jmp FUN_448300
$L_401851:

            mov DWORD PTR [ESP+4],OFFSET $L_51a1ec
            jmp FUN_448300
$L_40185e:

            mov DWORD PTR [ESP+4],OFFSET $L_51a1d4
            jmp FUN_448300
$L_40186b:

            mov DWORD PTR [ESP+4],OFFSET $L_51a1bc
            jmp FUN_448300
$L_401878:

            mov DWORD PTR [ESP+4],OFFSET $L_51a19c
            jmp FUN_448300
$L_401885:

            mov DWORD PTR [ESP+4],OFFSET $L_51a184
            jmp FUN_448300
$L_401892:

            mov DWORD PTR [ESP+4],OFFSET $L_51a168
            jmp FUN_448300
$L_40189f:

            mov DWORD PTR [ESP+4],OFFSET $L_51a14c
            jmp FUN_448300
$L_4018ac:

            mov DWORD PTR [ESP+4],OFFSET $L_51a134
            jmp FUN_448300
$L_4018b9:

            mov DWORD PTR [ESP+4],OFFSET $L_51a124
            jmp FUN_448300
$L_4018c6:

            mov DWORD PTR [ESP+4],OFFSET $L_51a110
            jmp FUN_448300
$L_4018d3:

            mov DWORD PTR [ESP+4],OFFSET $L_51a0fc
            jmp FUN_448300
$L_4018e0:

            mov DWORD PTR [ESP+4],OFFSET $L_51a0e0
            jmp FUN_448300
$L_4018ed:

            mov DWORD PTR [ESP+4],OFFSET $L_51a0c4
            jmp FUN_448300
$L_4018fa:

            mov DWORD PTR [ESP+4],OFFSET $L_51a0a8
            jmp FUN_448300
$L_401907:

            mov DWORD PTR [ESP+4],OFFSET $L_51a070
            jmp FUN_448300
$L_401914           DWORD $L_4010d5
$L_401918           DWORD $L_4010e2
$L_40191c           DWORD $L_4010ef
$L_401920           DWORD $L_4010fc
$L_401924           DWORD $L_401907
$L_401928           BYTE ($L_401914-$L_401914)/4
          BYTE ($L_401924-$L_401914)/4
          BYTE ($L_401924-$L_401914)/4
          BYTE ($L_401924-$L_401914)/4
          BYTE ($L_401924-$L_401914)/4
          BYTE ($L_401918-$L_401914)/4
          BYTE ($L_401924-$L_401914)/4
          BYTE ($L_401924-$L_401914)/4
          BYTE ($L_401924-$L_401914)/4
          BYTE ($L_401924-$L_401914)/4
          BYTE ($L_401924-$L_401914)/4
          BYTE ($L_401924-$L_401914)/4
          BYTE ($L_401924-$L_401914)/4
          BYTE ($L_401924-$L_401914)/4
          BYTE ($L_401924-$L_401914)/4
          BYTE ($L_40191c-$L_401914)/4
          BYTE ($L_401924-$L_401914)/4
          BYTE ($L_401924-$L_401914)/4
          BYTE ($L_401924-$L_401914)/4
          BYTE ($L_401924-$L_401914)/4
          BYTE ($L_401924-$L_401914)/4
          BYTE ($L_401924-$L_401914)/4
          BYTE ($L_401924-$L_401914)/4
          BYTE ($L_401924-$L_401914)/4
          BYTE ($L_401924-$L_401914)/4
          BYTE ($L_401924-$L_401914)/4
          BYTE ($L_401924-$L_401914)/4
          BYTE ($L_401924-$L_401914)/4
          BYTE ($L_401924-$L_401914)/4
          BYTE ($L_401924-$L_401914)/4
          BYTE ($L_401924-$L_401914)/4
          BYTE ($L_401924-$L_401914)/4
          BYTE ($L_401924-$L_401914)/4
          BYTE ($L_401924-$L_401914)/4
          BYTE ($L_401924-$L_401914)/4
          BYTE ($L_401920-$L_401914)/4
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
$L_401974           BYTE ($L_40194c-$L_40194c)/4
          BYTE ($L_401970-$L_40194c)/4
          BYTE ($L_401970-$L_40194c)/4
          BYTE ($L_401970-$L_40194c)/4
          BYTE ($L_401970-$L_40194c)/4
          BYTE ($L_401950-$L_40194c)/4
          BYTE ($L_401970-$L_40194c)/4
          BYTE ($L_401970-$L_40194c)/4
          BYTE ($L_401970-$L_40194c)/4
          BYTE ($L_401970-$L_40194c)/4
          BYTE ($L_401954-$L_40194c)/4
          BYTE ($L_401970-$L_40194c)/4
          BYTE ($L_401970-$L_40194c)/4
          BYTE ($L_401970-$L_40194c)/4
          BYTE ($L_401970-$L_40194c)/4
          BYTE ($L_401970-$L_40194c)/4
          BYTE ($L_401970-$L_40194c)/4
          BYTE ($L_401970-$L_40194c)/4
          BYTE ($L_401970-$L_40194c)/4
          BYTE ($L_401970-$L_40194c)/4
          BYTE ($L_401958-$L_40194c)/4
          BYTE ($L_401970-$L_40194c)/4
          BYTE ($L_401970-$L_40194c)/4
          BYTE ($L_401970-$L_40194c)/4
          BYTE ($L_401970-$L_40194c)/4
          BYTE ($L_401970-$L_40194c)/4
          BYTE ($L_401970-$L_40194c)/4
          BYTE ($L_401970-$L_40194c)/4
          BYTE ($L_401970-$L_40194c)/4
          BYTE ($L_401970-$L_40194c)/4
          BYTE ($L_40195c-$L_40194c)/4
          BYTE ($L_401970-$L_40194c)/4
          BYTE ($L_401970-$L_40194c)/4
          BYTE ($L_401970-$L_40194c)/4
          BYTE ($L_401970-$L_40194c)/4
          BYTE ($L_401970-$L_40194c)/4
          BYTE ($L_401970-$L_40194c)/4
          BYTE ($L_401970-$L_40194c)/4
          BYTE ($L_401970-$L_40194c)/4
          BYTE ($L_401970-$L_40194c)/4
          BYTE ($L_401960-$L_40194c)/4
          BYTE ($L_401970-$L_40194c)/4
          BYTE ($L_401970-$L_40194c)/4
          BYTE ($L_401970-$L_40194c)/4
          BYTE ($L_401970-$L_40194c)/4
          BYTE ($L_401970-$L_40194c)/4
          BYTE ($L_401970-$L_40194c)/4
          BYTE ($L_401970-$L_40194c)/4
          BYTE ($L_401970-$L_40194c)/4
          BYTE ($L_401970-$L_40194c)/4
          BYTE ($L_401970-$L_40194c)/4
          BYTE ($L_401970-$L_40194c)/4
          BYTE ($L_401970-$L_40194c)/4
          BYTE ($L_401970-$L_40194c)/4
          BYTE ($L_401970-$L_40194c)/4
          BYTE ($L_401964-$L_40194c)/4
          BYTE ($L_401970-$L_40194c)/4
          BYTE ($L_401970-$L_40194c)/4
          BYTE ($L_401970-$L_40194c)/4
          BYTE ($L_401970-$L_40194c)/4
          BYTE ($L_401968-$L_40194c)/4
          BYTE ($L_401970-$L_40194c)/4
          BYTE ($L_401970-$L_40194c)/4
          BYTE ($L_401970-$L_40194c)/4
          BYTE ($L_401970-$L_40194c)/4
          BYTE ($L_401970-$L_40194c)/4
          BYTE ($L_401970-$L_40194c)/4
          BYTE ($L_401970-$L_40194c)/4
          BYTE ($L_401970-$L_40194c)/4
          BYTE ($L_401970-$L_40194c)/4
          BYTE ($L_40196c-$L_40194c)/4
          BYTE 090H
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
$L_401a0c           BYTE ($L_4019bc-$L_4019bc)/4
          BYTE ($L_401a08-$L_4019bc)/4
          BYTE ($L_401a08-$L_4019bc)/4
          BYTE ($L_401a08-$L_4019bc)/4
          BYTE ($L_401a08-$L_4019bc)/4
          BYTE ($L_401a08-$L_4019bc)/4
          BYTE ($L_401a08-$L_4019bc)/4
          BYTE ($L_401a08-$L_4019bc)/4
          BYTE ($L_401a08-$L_4019bc)/4
          BYTE ($L_401a08-$L_4019bc)/4
          BYTE ($L_401a08-$L_4019bc)/4
          BYTE ($L_401a08-$L_4019bc)/4
          BYTE ($L_401a08-$L_4019bc)/4
          BYTE ($L_401a08-$L_4019bc)/4
          BYTE ($L_401a08-$L_4019bc)/4
          BYTE ($L_401a08-$L_4019bc)/4
          BYTE ($L_401a08-$L_4019bc)/4
          BYTE ($L_401a08-$L_4019bc)/4
          BYTE ($L_401a08-$L_4019bc)/4
          BYTE ($L_401a08-$L_4019bc)/4
          BYTE ($L_401a08-$L_4019bc)/4
          BYTE ($L_401a08-$L_4019bc)/4
          BYTE ($L_401a08-$L_4019bc)/4
          BYTE ($L_401a08-$L_4019bc)/4
          BYTE ($L_401a08-$L_4019bc)/4
          BYTE ($L_4019c0-$L_4019bc)/4
          BYTE ($L_401a08-$L_4019bc)/4
          BYTE ($L_401a08-$L_4019bc)/4
          BYTE ($L_401a08-$L_4019bc)/4
          BYTE ($L_401a08-$L_4019bc)/4
          BYTE ($L_4019c4-$L_4019bc)/4
          BYTE ($L_401a08-$L_4019bc)/4
          BYTE ($L_4019c8-$L_4019bc)/4
          BYTE ($L_401a08-$L_4019bc)/4
          BYTE ($L_401a08-$L_4019bc)/4
          BYTE ($L_4019cc-$L_4019bc)/4
          BYTE ($L_401a08-$L_4019bc)/4
          BYTE ($L_401a08-$L_4019bc)/4
          BYTE ($L_401a08-$L_4019bc)/4
          BYTE ($L_401a08-$L_4019bc)/4
          BYTE ($L_4019d0-$L_4019bc)/4
          BYTE ($L_401a08-$L_4019bc)/4
          BYTE ($L_4019d4-$L_4019bc)/4
          BYTE ($L_401a08-$L_4019bc)/4
          BYTE ($L_401a08-$L_4019bc)/4
          BYTE ($L_4019d8-$L_4019bc)/4
          BYTE ($L_401a08-$L_4019bc)/4
          BYTE ($L_401a08-$L_4019bc)/4
          BYTE ($L_401a08-$L_4019bc)/4
          BYTE ($L_401a08-$L_4019bc)/4
          BYTE ($L_4019dc-$L_4019bc)/4
          BYTE ($L_401a08-$L_4019bc)/4
          BYTE ($L_401a08-$L_4019bc)/4
          BYTE ($L_401a08-$L_4019bc)/4
          BYTE ($L_401a08-$L_4019bc)/4
          BYTE ($L_401a08-$L_4019bc)/4
          BYTE ($L_401a08-$L_4019bc)/4
          BYTE ($L_401a08-$L_4019bc)/4
          BYTE ($L_401a08-$L_4019bc)/4
          BYTE ($L_401a08-$L_4019bc)/4
          BYTE ($L_4019e0-$L_4019bc)/4
          BYTE ($L_401a08-$L_4019bc)/4
          BYTE ($L_401a08-$L_4019bc)/4
          BYTE ($L_401a08-$L_4019bc)/4
          BYTE ($L_401a08-$L_4019bc)/4
          BYTE ($L_401a08-$L_4019bc)/4
          BYTE ($L_401a08-$L_4019bc)/4
          BYTE ($L_401a08-$L_4019bc)/4
          BYTE ($L_401a08-$L_4019bc)/4
          BYTE ($L_401a08-$L_4019bc)/4
          BYTE ($L_4019e4-$L_4019bc)/4
          BYTE ($L_401a08-$L_4019bc)/4
          BYTE ($L_401a08-$L_4019bc)/4
          BYTE ($L_401a08-$L_4019bc)/4
          BYTE ($L_401a08-$L_4019bc)/4
          BYTE ($L_4019e8-$L_4019bc)/4
          BYTE ($L_401a08-$L_4019bc)/4
          BYTE ($L_401a08-$L_4019bc)/4
          BYTE ($L_401a08-$L_4019bc)/4
          BYTE ($L_401a08-$L_4019bc)/4
          BYTE ($L_4019ec-$L_4019bc)/4
          BYTE ($L_401a08-$L_4019bc)/4
          BYTE ($L_401a08-$L_4019bc)/4
          BYTE ($L_401a08-$L_4019bc)/4
          BYTE ($L_401a08-$L_4019bc)/4
          BYTE ($L_401a08-$L_4019bc)/4
          BYTE ($L_401a08-$L_4019bc)/4
          BYTE ($L_401a08-$L_4019bc)/4
          BYTE ($L_401a08-$L_4019bc)/4
          BYTE ($L_401a08-$L_4019bc)/4
          BYTE ($L_401a08-$L_4019bc)/4
          BYTE ($L_401a08-$L_4019bc)/4
          BYTE ($L_401a08-$L_4019bc)/4
          BYTE ($L_401a08-$L_4019bc)/4
          BYTE ($L_401a08-$L_4019bc)/4
          BYTE ($L_401a08-$L_4019bc)/4
          BYTE ($L_401a08-$L_4019bc)/4
          BYTE ($L_401a08-$L_4019bc)/4
          BYTE ($L_401a08-$L_4019bc)/4
          BYTE ($L_401a08-$L_4019bc)/4
          BYTE ($L_4019f0-$L_4019bc)/4
          BYTE ($L_401a08-$L_4019bc)/4
          BYTE ($L_401a08-$L_4019bc)/4
          BYTE ($L_401a08-$L_4019bc)/4
          BYTE ($L_401a08-$L_4019bc)/4
          BYTE ($L_401a08-$L_4019bc)/4
          BYTE ($L_401a08-$L_4019bc)/4
          BYTE ($L_401a08-$L_4019bc)/4
          BYTE ($L_401a08-$L_4019bc)/4
          BYTE ($L_401a08-$L_4019bc)/4
          BYTE ($L_4019f4-$L_4019bc)/4
          BYTE ($L_401a08-$L_4019bc)/4
          BYTE ($L_401a08-$L_4019bc)/4
          BYTE ($L_401a08-$L_4019bc)/4
          BYTE ($L_401a08-$L_4019bc)/4
          BYTE ($L_401a08-$L_4019bc)/4
          BYTE ($L_401a08-$L_4019bc)/4
          BYTE ($L_401a08-$L_4019bc)/4
          BYTE ($L_401a08-$L_4019bc)/4
          BYTE ($L_401a08-$L_4019bc)/4
          BYTE ($L_401a08-$L_4019bc)/4
          BYTE ($L_401a08-$L_4019bc)/4
          BYTE ($L_401a08-$L_4019bc)/4
          BYTE ($L_401a08-$L_4019bc)/4
          BYTE ($L_401a08-$L_4019bc)/4
          BYTE ($L_401a08-$L_4019bc)/4
          BYTE ($L_401a08-$L_4019bc)/4
          BYTE ($L_401a08-$L_4019bc)/4
          BYTE ($L_401a08-$L_4019bc)/4
          BYTE ($L_401a08-$L_4019bc)/4
          BYTE ($L_4019f8-$L_4019bc)/4
          BYTE ($L_401a08-$L_4019bc)/4
          BYTE ($L_401a08-$L_4019bc)/4
          BYTE ($L_401a08-$L_4019bc)/4
          BYTE ($L_401a08-$L_4019bc)/4
          BYTE ($L_401a08-$L_4019bc)/4
          BYTE ($L_4019fc-$L_4019bc)/4
          BYTE ($L_401a00-$L_4019bc)/4
          BYTE ($L_401a08-$L_4019bc)/4
          BYTE ($L_401a08-$L_4019bc)/4
          BYTE ($L_401a04-$L_4019bc)/4
          BYTE 08dH
          BYTE 049H
          BYTE 000H
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
$L_401b3c           BYTE ($L_401a9c-$L_401a9c)/4
          BYTE ($L_401b38-$L_401a9c)/4
          BYTE ($L_401b38-$L_401a9c)/4
          BYTE ($L_401b38-$L_401a9c)/4
          BYTE ($L_401b38-$L_401a9c)/4
          BYTE ($L_401aa0-$L_401a9c)/4
          BYTE ($L_401b38-$L_401a9c)/4
          BYTE ($L_401b38-$L_401a9c)/4
          BYTE ($L_401b38-$L_401a9c)/4
          BYTE ($L_401b38-$L_401a9c)/4
          BYTE ($L_401b38-$L_401a9c)/4
          BYTE ($L_401b38-$L_401a9c)/4
          BYTE ($L_401b38-$L_401a9c)/4
          BYTE ($L_401b38-$L_401a9c)/4
          BYTE ($L_401b38-$L_401a9c)/4
          BYTE ($L_401aa4-$L_401a9c)/4
          BYTE ($L_401b38-$L_401a9c)/4
          BYTE ($L_401b38-$L_401a9c)/4
          BYTE ($L_401b38-$L_401a9c)/4
          BYTE ($L_401b38-$L_401a9c)/4
          BYTE ($L_401b38-$L_401a9c)/4
          BYTE ($L_401b38-$L_401a9c)/4
          BYTE ($L_401b38-$L_401a9c)/4
          BYTE ($L_401b38-$L_401a9c)/4
          BYTE ($L_401b38-$L_401a9c)/4
          BYTE ($L_401aa8-$L_401a9c)/4
          BYTE ($L_401b38-$L_401a9c)/4
          BYTE ($L_401b38-$L_401a9c)/4
          BYTE ($L_401b38-$L_401a9c)/4
          BYTE ($L_401b38-$L_401a9c)/4
          BYTE ($L_401b38-$L_401a9c)/4
          BYTE ($L_401b38-$L_401a9c)/4
          BYTE ($L_401b38-$L_401a9c)/4
          BYTE ($L_401b38-$L_401a9c)/4
          BYTE ($L_401b38-$L_401a9c)/4
          BYTE ($L_401b38-$L_401a9c)/4
          BYTE ($L_401b38-$L_401a9c)/4
          BYTE ($L_401b38-$L_401a9c)/4
          BYTE ($L_401b38-$L_401a9c)/4
          BYTE ($L_401b38-$L_401a9c)/4
          BYTE ($L_401b38-$L_401a9c)/4
          BYTE ($L_401b38-$L_401a9c)/4
          BYTE ($L_401b38-$L_401a9c)/4
          BYTE ($L_401b38-$L_401a9c)/4
          BYTE ($L_401b38-$L_401a9c)/4
          BYTE ($L_401aac-$L_401a9c)/4
          BYTE ($L_401b38-$L_401a9c)/4
          BYTE ($L_401ab0-$L_401a9c)/4
          BYTE ($L_401b38-$L_401a9c)/4
          BYTE ($L_401b38-$L_401a9c)/4
          BYTE ($L_401b38-$L_401a9c)/4
          BYTE ($L_401b38-$L_401a9c)/4
          BYTE ($L_401ab4-$L_401a9c)/4
          BYTE ($L_401b38-$L_401a9c)/4
          BYTE ($L_401b38-$L_401a9c)/4
          BYTE ($L_401b38-$L_401a9c)/4
          BYTE ($L_401b38-$L_401a9c)/4
          BYTE ($L_401b38-$L_401a9c)/4
          BYTE ($L_401b38-$L_401a9c)/4
          BYTE ($L_401b38-$L_401a9c)/4
          BYTE ($L_401b38-$L_401a9c)/4
          BYTE ($L_401b38-$L_401a9c)/4
          BYTE ($L_401b38-$L_401a9c)/4
          BYTE ($L_401b38-$L_401a9c)/4
          BYTE ($L_401b38-$L_401a9c)/4
          BYTE ($L_401ab8-$L_401a9c)/4
          BYTE ($L_401b38-$L_401a9c)/4
          BYTE ($L_401b38-$L_401a9c)/4
          BYTE ($L_401b38-$L_401a9c)/4
          BYTE ($L_401b38-$L_401a9c)/4
          BYTE ($L_401b38-$L_401a9c)/4
          BYTE ($L_401b38-$L_401a9c)/4
          BYTE ($L_401b38-$L_401a9c)/4
          BYTE ($L_401b38-$L_401a9c)/4
          BYTE ($L_401b38-$L_401a9c)/4
          BYTE ($L_401abc-$L_401a9c)/4
          BYTE ($L_401b38-$L_401a9c)/4
          BYTE ($L_401b38-$L_401a9c)/4
          BYTE ($L_401b38-$L_401a9c)/4
          BYTE ($L_401b38-$L_401a9c)/4
          BYTE ($L_401b38-$L_401a9c)/4
          BYTE ($L_401b38-$L_401a9c)/4
          BYTE ($L_401b38-$L_401a9c)/4
          BYTE ($L_401b38-$L_401a9c)/4
          BYTE ($L_401b38-$L_401a9c)/4
          BYTE ($L_401ac0-$L_401a9c)/4
          BYTE ($L_401b38-$L_401a9c)/4
          BYTE ($L_401b38-$L_401a9c)/4
          BYTE ($L_401b38-$L_401a9c)/4
          BYTE ($L_401b38-$L_401a9c)/4
          BYTE ($L_401b38-$L_401a9c)/4
          BYTE ($L_401b38-$L_401a9c)/4
          BYTE ($L_401b38-$L_401a9c)/4
          BYTE ($L_401b38-$L_401a9c)/4
          BYTE ($L_401b38-$L_401a9c)/4
          BYTE ($L_401ac4-$L_401a9c)/4
          BYTE ($L_401b38-$L_401a9c)/4
          BYTE ($L_401b38-$L_401a9c)/4
          BYTE ($L_401b38-$L_401a9c)/4
          BYTE ($L_401b38-$L_401a9c)/4
          BYTE ($L_401ac8-$L_401a9c)/4
          BYTE ($L_401b38-$L_401a9c)/4
          BYTE ($L_401b38-$L_401a9c)/4
          BYTE ($L_401b38-$L_401a9c)/4
          BYTE ($L_401b38-$L_401a9c)/4
          BYTE ($L_401acc-$L_401a9c)/4
          BYTE ($L_401b38-$L_401a9c)/4
          BYTE ($L_401b38-$L_401a9c)/4
          BYTE ($L_401b38-$L_401a9c)/4
          BYTE ($L_401b38-$L_401a9c)/4
          BYTE ($L_401b38-$L_401a9c)/4
          BYTE ($L_401b38-$L_401a9c)/4
          BYTE ($L_401b38-$L_401a9c)/4
          BYTE ($L_401b38-$L_401a9c)/4
          BYTE ($L_401b38-$L_401a9c)/4
          BYTE ($L_401ad0-$L_401a9c)/4
          BYTE ($L_401b38-$L_401a9c)/4
          BYTE ($L_401b38-$L_401a9c)/4
          BYTE ($L_401b38-$L_401a9c)/4
          BYTE ($L_401b38-$L_401a9c)/4
          BYTE ($L_401b38-$L_401a9c)/4
          BYTE ($L_401b38-$L_401a9c)/4
          BYTE ($L_401b38-$L_401a9c)/4
          BYTE ($L_401b38-$L_401a9c)/4
          BYTE ($L_401b38-$L_401a9c)/4
          BYTE ($L_401ad4-$L_401a9c)/4
          BYTE ($L_401b38-$L_401a9c)/4
          BYTE ($L_401b38-$L_401a9c)/4
          BYTE ($L_401b38-$L_401a9c)/4
          BYTE ($L_401b38-$L_401a9c)/4
          BYTE ($L_401b38-$L_401a9c)/4
          BYTE ($L_401b38-$L_401a9c)/4
          BYTE ($L_401b38-$L_401a9c)/4
          BYTE ($L_401b38-$L_401a9c)/4
          BYTE ($L_401b38-$L_401a9c)/4
          BYTE ($L_401ad8-$L_401a9c)/4
          BYTE ($L_401b38-$L_401a9c)/4
          BYTE ($L_401b38-$L_401a9c)/4
          BYTE ($L_401b38-$L_401a9c)/4
          BYTE ($L_401b38-$L_401a9c)/4
          BYTE ($L_401b38-$L_401a9c)/4
          BYTE ($L_401b38-$L_401a9c)/4
          BYTE ($L_401b38-$L_401a9c)/4
          BYTE ($L_401b38-$L_401a9c)/4
          BYTE ($L_401b38-$L_401a9c)/4
          BYTE ($L_401adc-$L_401a9c)/4
          BYTE ($L_401b38-$L_401a9c)/4
          BYTE ($L_401b38-$L_401a9c)/4
          BYTE ($L_401b38-$L_401a9c)/4
          BYTE ($L_401b38-$L_401a9c)/4
          BYTE ($L_401b38-$L_401a9c)/4
          BYTE ($L_401b38-$L_401a9c)/4
          BYTE ($L_401b38-$L_401a9c)/4
          BYTE ($L_401b38-$L_401a9c)/4
          BYTE ($L_401b38-$L_401a9c)/4
          BYTE ($L_401ae0-$L_401a9c)/4
          BYTE ($L_401b38-$L_401a9c)/4
          BYTE ($L_401b38-$L_401a9c)/4
          BYTE ($L_401b38-$L_401a9c)/4
          BYTE ($L_401b38-$L_401a9c)/4
          BYTE ($L_401b38-$L_401a9c)/4
          BYTE ($L_401b38-$L_401a9c)/4
          BYTE ($L_401b38-$L_401a9c)/4
          BYTE ($L_401b38-$L_401a9c)/4
          BYTE ($L_401b38-$L_401a9c)/4
          BYTE ($L_401b38-$L_401a9c)/4
          BYTE ($L_401b38-$L_401a9c)/4
          BYTE ($L_401b38-$L_401a9c)/4
          BYTE ($L_401b38-$L_401a9c)/4
          BYTE ($L_401b38-$L_401a9c)/4
          BYTE ($L_401b38-$L_401a9c)/4
          BYTE ($L_401b38-$L_401a9c)/4
          BYTE ($L_401b38-$L_401a9c)/4
          BYTE ($L_401b38-$L_401a9c)/4
          BYTE ($L_401b38-$L_401a9c)/4
          BYTE ($L_401ae4-$L_401a9c)/4
          BYTE ($L_401b38-$L_401a9c)/4
          BYTE ($L_401b38-$L_401a9c)/4
          BYTE ($L_401b38-$L_401a9c)/4
          BYTE ($L_401b38-$L_401a9c)/4
          BYTE ($L_401b38-$L_401a9c)/4
          BYTE ($L_401b38-$L_401a9c)/4
          BYTE ($L_401b38-$L_401a9c)/4
          BYTE ($L_401b38-$L_401a9c)/4
          BYTE ($L_401b38-$L_401a9c)/4
          BYTE ($L_401ae8-$L_401a9c)/4
          BYTE ($L_401b38-$L_401a9c)/4
          BYTE ($L_401b38-$L_401a9c)/4
          BYTE ($L_401b38-$L_401a9c)/4
          BYTE ($L_401b38-$L_401a9c)/4
          BYTE ($L_401b38-$L_401a9c)/4
          BYTE ($L_401b38-$L_401a9c)/4
          BYTE ($L_401b38-$L_401a9c)/4
          BYTE ($L_401b38-$L_401a9c)/4
          BYTE ($L_401b38-$L_401a9c)/4
          BYTE ($L_401b38-$L_401a9c)/4
          BYTE ($L_401b38-$L_401a9c)/4
          BYTE ($L_401b38-$L_401a9c)/4
          BYTE ($L_401b38-$L_401a9c)/4
          BYTE ($L_401b38-$L_401a9c)/4
          BYTE ($L_401b38-$L_401a9c)/4
          BYTE ($L_401b38-$L_401a9c)/4
          BYTE ($L_401aec-$L_401a9c)/4
          BYTE ($L_401b38-$L_401a9c)/4
          BYTE ($L_401b38-$L_401a9c)/4
          BYTE ($L_401af0-$L_401a9c)/4
          BYTE ($L_401b38-$L_401a9c)/4
          BYTE ($L_401b38-$L_401a9c)/4
          BYTE ($L_401b38-$L_401a9c)/4
          BYTE ($L_401b38-$L_401a9c)/4
          BYTE ($L_401b38-$L_401a9c)/4
          BYTE ($L_401b38-$L_401a9c)/4
          BYTE ($L_401b38-$L_401a9c)/4
          BYTE ($L_401b38-$L_401a9c)/4
          BYTE ($L_401b38-$L_401a9c)/4
          BYTE ($L_401b38-$L_401a9c)/4
          BYTE ($L_401b38-$L_401a9c)/4
          BYTE ($L_401b38-$L_401a9c)/4
          BYTE ($L_401b38-$L_401a9c)/4
          BYTE ($L_401b38-$L_401a9c)/4
          BYTE ($L_401b38-$L_401a9c)/4
          BYTE ($L_401b38-$L_401a9c)/4
          BYTE ($L_401b38-$L_401a9c)/4
          BYTE ($L_401b38-$L_401a9c)/4
          BYTE ($L_401b38-$L_401a9c)/4
          BYTE ($L_401af4-$L_401a9c)/4
          BYTE ($L_401af8-$L_401a9c)/4
          BYTE ($L_401afc-$L_401a9c)/4
          BYTE ($L_401b00-$L_401a9c)/4
          BYTE ($L_401b38-$L_401a9c)/4
          BYTE ($L_401b04-$L_401a9c)/4
          BYTE ($L_401b08-$L_401a9c)/4
          BYTE ($L_401b0c-$L_401a9c)/4
          BYTE ($L_401b10-$L_401a9c)/4
          BYTE ($L_401b14-$L_401a9c)/4
          BYTE ($L_401b18-$L_401a9c)/4
          BYTE ($L_401b1c-$L_401a9c)/4
          BYTE ($L_401b20-$L_401a9c)/4
          BYTE ($L_401b24-$L_401a9c)/4
          BYTE ($L_401b28-$L_401a9c)/4
          BYTE ($L_401b2c-$L_401a9c)/4
          BYTE ($L_401b30-$L_401a9c)/4
          BYTE ($L_401b34-$L_401a9c)/4
          BYTE 090H
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
$L_401d6c           BYTE ($L_401c30-$L_401c30)/4
          BYTE ($L_401c34-$L_401c30)/4
          BYTE ($L_401c38-$L_401c30)/4
          BYTE ($L_401c3c-$L_401c30)/4
          BYTE ($L_401c40-$L_401c30)/4
          BYTE ($L_401c44-$L_401c30)/4
          BYTE ($L_401c48-$L_401c30)/4
          BYTE ($L_401c4c-$L_401c30)/4
          BYTE ($L_401c50-$L_401c30)/4
          BYTE ($L_401c54-$L_401c30)/4
          BYTE ($L_401c58-$L_401c30)/4
          BYTE ($L_401c5c-$L_401c30)/4
          BYTE ($L_401c60-$L_401c30)/4
          BYTE ($L_401c64-$L_401c30)/4
          BYTE ($L_401d68-$L_401c30)/4
          BYTE ($L_401d68-$L_401c30)/4
          BYTE ($L_401d68-$L_401c30)/4
          BYTE ($L_401d68-$L_401c30)/4
          BYTE ($L_401d68-$L_401c30)/4
          BYTE ($L_401d68-$L_401c30)/4
          BYTE ($L_401d68-$L_401c30)/4
          BYTE ($L_401c68-$L_401c30)/4
          BYTE ($L_401c6c-$L_401c30)/4
          BYTE ($L_401d68-$L_401c30)/4
          BYTE ($L_401d68-$L_401c30)/4
          BYTE ($L_401d68-$L_401c30)/4
          BYTE ($L_401d68-$L_401c30)/4
          BYTE ($L_401d68-$L_401c30)/4
          BYTE ($L_401d68-$L_401c30)/4
          BYTE ($L_401d68-$L_401c30)/4
          BYTE ($L_401d68-$L_401c30)/4
          BYTE ($L_401d68-$L_401c30)/4
          BYTE ($L_401d68-$L_401c30)/4
          BYTE ($L_401d68-$L_401c30)/4
          BYTE ($L_401d68-$L_401c30)/4
          BYTE ($L_401d68-$L_401c30)/4
          BYTE ($L_401d68-$L_401c30)/4
          BYTE ($L_401d68-$L_401c30)/4
          BYTE ($L_401d68-$L_401c30)/4
          BYTE ($L_401d68-$L_401c30)/4
          BYTE ($L_401d68-$L_401c30)/4
          BYTE ($L_401c70-$L_401c30)/4
          BYTE ($L_401d68-$L_401c30)/4
          BYTE ($L_401d68-$L_401c30)/4
          BYTE ($L_401d68-$L_401c30)/4
          BYTE ($L_401d68-$L_401c30)/4
          BYTE ($L_401d68-$L_401c30)/4
          BYTE ($L_401d68-$L_401c30)/4
          BYTE ($L_401d68-$L_401c30)/4
          BYTE ($L_401d68-$L_401c30)/4
          BYTE ($L_401d68-$L_401c30)/4
          BYTE ($L_401c74-$L_401c30)/4
          BYTE ($L_401d68-$L_401c30)/4
          BYTE ($L_401d68-$L_401c30)/4
          BYTE ($L_401d68-$L_401c30)/4
          BYTE ($L_401d68-$L_401c30)/4
          BYTE ($L_401d68-$L_401c30)/4
          BYTE ($L_401d68-$L_401c30)/4
          BYTE ($L_401d68-$L_401c30)/4
          BYTE ($L_401d68-$L_401c30)/4
          BYTE ($L_401d68-$L_401c30)/4
          BYTE ($L_401c78-$L_401c30)/4
          BYTE ($L_401d68-$L_401c30)/4
          BYTE ($L_401d68-$L_401c30)/4
          BYTE ($L_401d68-$L_401c30)/4
          BYTE ($L_401d68-$L_401c30)/4
          BYTE ($L_401d68-$L_401c30)/4
          BYTE ($L_401d68-$L_401c30)/4
$L_401db0           BYTE ($L_401d68-$L_401c30)/4
          BYTE ($L_401d68-$L_401c30)/4
          BYTE ($L_401d68-$L_401c30)/4
          BYTE ($L_401d68-$L_401c30)/4
          BYTE ($L_401d68-$L_401c30)/4
          BYTE ($L_401d68-$L_401c30)/4
          BYTE ($L_401d68-$L_401c30)/4
          BYTE ($L_401d68-$L_401c30)/4
          BYTE ($L_401d68-$L_401c30)/4
          BYTE ($L_401d68-$L_401c30)/4
          BYTE ($L_401d68-$L_401c30)/4
          BYTE ($L_401d68-$L_401c30)/4
          BYTE ($L_401d68-$L_401c30)/4
          BYTE ($L_401c7c-$L_401c30)/4
          BYTE ($L_401d68-$L_401c30)/4
          BYTE ($L_401d68-$L_401c30)/4
          BYTE ($L_401d68-$L_401c30)/4
          BYTE ($L_401d68-$L_401c30)/4
          BYTE ($L_401d68-$L_401c30)/4
          BYTE ($L_401d68-$L_401c30)/4
          BYTE ($L_401d68-$L_401c30)/4
          BYTE ($L_401d68-$L_401c30)/4
          BYTE ($L_401d68-$L_401c30)/4
          BYTE ($L_401d68-$L_401c30)/4
          BYTE ($L_401d68-$L_401c30)/4
          BYTE ($L_401d68-$L_401c30)/4
          BYTE ($L_401d68-$L_401c30)/4
          BYTE ($L_401d68-$L_401c30)/4
          BYTE ($L_401d68-$L_401c30)/4
          BYTE ($L_401d68-$L_401c30)/4
          BYTE ($L_401d68-$L_401c30)/4
          BYTE ($L_401d68-$L_401c30)/4
          BYTE ($L_401d68-$L_401c30)/4
          BYTE ($L_401c80-$L_401c30)/4
          BYTE ($L_401d68-$L_401c30)/4
          BYTE ($L_401d68-$L_401c30)/4
          BYTE ($L_401d68-$L_401c30)/4
          BYTE ($L_401d68-$L_401c30)/4
          BYTE ($L_401d68-$L_401c30)/4
          BYTE ($L_401d68-$L_401c30)/4
          BYTE ($L_401d68-$L_401c30)/4
          BYTE ($L_401d68-$L_401c30)/4
          BYTE ($L_401d68-$L_401c30)/4
          BYTE ($L_401c84-$L_401c30)/4
          BYTE ($L_401d68-$L_401c30)/4
          BYTE ($L_401d68-$L_401c30)/4
          BYTE ($L_401d68-$L_401c30)/4
          BYTE ($L_401d68-$L_401c30)/4
          BYTE ($L_401c88-$L_401c30)/4
          BYTE ($L_401d68-$L_401c30)/4
          BYTE ($L_401d68-$L_401c30)/4
          BYTE ($L_401d68-$L_401c30)/4
          BYTE ($L_401c8c-$L_401c30)/4
          BYTE ($L_401c90-$L_401c30)/4
          BYTE ($L_401c94-$L_401c30)/4
          BYTE ($L_401d68-$L_401c30)/4
          BYTE ($L_401d68-$L_401c30)/4
          BYTE ($L_401d68-$L_401c30)/4
          BYTE ($L_401c98-$L_401c30)/4
          BYTE ($L_401c9c-$L_401c30)/4
          BYTE ($L_401ca0-$L_401c30)/4
          BYTE ($L_401d68-$L_401c30)/4
          BYTE ($L_401d68-$L_401c30)/4
          BYTE ($L_401ca4-$L_401c30)/4
          BYTE ($L_401ca8-$L_401c30)/4
          BYTE ($L_401cac-$L_401c30)/4
          BYTE ($L_401cb0-$L_401c30)/4
          BYTE ($L_401cb4-$L_401c30)/4
          BYTE ($L_401cb8-$L_401c30)/4
          BYTE ($L_401cbc-$L_401c30)/4
          BYTE ($L_401cc0-$L_401c30)/4
          BYTE ($L_401d68-$L_401c30)/4
          BYTE ($L_401d68-$L_401c30)/4
          BYTE ($L_401cc4-$L_401c30)/4
          BYTE ($L_401cc8-$L_401c30)/4
          BYTE ($L_401ccc-$L_401c30)/4
          BYTE ($L_401cd0-$L_401c30)/4
          BYTE ($L_401cd4-$L_401c30)/4
          BYTE ($L_401cd8-$L_401c30)/4
          BYTE ($L_401cdc-$L_401c30)/4
          BYTE ($L_401ce0-$L_401c30)/4
          BYTE ($L_401ce4-$L_401c30)/4
          BYTE ($L_401ce8-$L_401c30)/4
          BYTE ($L_401cec-$L_401c30)/4
          BYTE ($L_401cf0-$L_401c30)/4
          BYTE ($L_401cf4-$L_401c30)/4
          BYTE ($L_401cf8-$L_401c30)/4
          BYTE ($L_401cfc-$L_401c30)/4
          BYTE ($L_401d00-$L_401c30)/4
          BYTE ($L_401d04-$L_401c30)/4
          BYTE ($L_401d08-$L_401c30)/4
          BYTE ($L_401d0c-$L_401c30)/4
          BYTE ($L_401d10-$L_401c30)/4
          BYTE ($L_401d14-$L_401c30)/4
          BYTE ($L_401d18-$L_401c30)/4
          BYTE ($L_401d1c-$L_401c30)/4
          BYTE ($L_401d20-$L_401c30)/4
          BYTE ($L_401d24-$L_401c30)/4
          BYTE ($L_401d28-$L_401c30)/4
          BYTE ($L_401d2c-$L_401c30)/4
          BYTE ($L_401d30-$L_401c30)/4
          BYTE ($L_401d68-$L_401c30)/4
          BYTE ($L_401d68-$L_401c30)/4
          BYTE ($L_401d34-$L_401c30)/4
          BYTE ($L_401d38-$L_401c30)/4
          BYTE ($L_401d3c-$L_401c30)/4
          BYTE ($L_401d68-$L_401c30)/4
          BYTE ($L_401d68-$L_401c30)/4
          BYTE ($L_401d68-$L_401c30)/4
          BYTE ($L_401d68-$L_401c30)/4
          BYTE ($L_401d68-$L_401c30)/4
          BYTE ($L_401d68-$L_401c30)/4
          BYTE ($L_401d68-$L_401c30)/4
          BYTE ($L_401d40-$L_401c30)/4
          BYTE ($L_401d44-$L_401c30)/4
          BYTE ($L_401d48-$L_401c30)/4
          BYTE ($L_401d4c-$L_401c30)/4
          BYTE ($L_401d68-$L_401c30)/4
          BYTE ($L_401d68-$L_401c30)/4
          BYTE ($L_401d68-$L_401c30)/4
          BYTE ($L_401d68-$L_401c30)/4
          BYTE ($L_401d68-$L_401c30)/4
          BYTE ($L_401d68-$L_401c30)/4
          BYTE ($L_401d50-$L_401c30)/4
          BYTE ($L_401d54-$L_401c30)/4
          BYTE ($L_401d58-$L_401c30)/4
          BYTE ($L_401d5c-$L_401c30)/4
          BYTE ($L_401d60-$L_401c30)/4
          BYTE ($L_401d64-$L_401c30)/4

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
            nop
            nop
            nop
FUN_401000 ENDP