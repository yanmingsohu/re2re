// Disassembled by yanming.J
// SPDX-License-Identifier: MIT
// https://github.com/yanmingsohu/

#include <stdint.h>
#include "imports.h"
#include "script.h"


// FUN_450100 主虚拟机循环
int vm_main_loop(struct VMContext* ctx) { return 0; }

// FUN_4e41e0 实体有限状态机
int vm_entity_fsm(struct VMContext* ctx) { return 0; }


// FUN_4e4280 空操作
int vm_nop(struct VMContext* ctx) {
  // msgc("nop ");
  ctx->pc++;
  return 1;
}


// FUN_4e42a0 条件跳转
int vm_jump(struct VMContext* ctx) {
  // msgc("vm_jump");
  if (ctx->jump_index == 0) {
    ctx->is_active = 0;
    return 2;
  }

  uint8_t idx = ctx->jump_index - 1;
  int8_t offset = ctx->jump_offsets[idx];
  ctx->pc = ctx->jump_table[idx];
  ctx->jump_index = idx;
  
  // 计算目标地址: base(196) + (offset + idx*8)*4
  ctx->call_stack = (uint32_t*)&ctx->snap[5 + idx].slots[offset];
  return 1;
}


// FUN_4e42f0 结束
int vm_end(struct VMContext* ctx) { 
  // msgc("vm_end");
  ctx->pc++;
  return 2;
}


// FUN_4e4310 数据加载
int vm_load(struct VMContext* ctx) { return 0; }

// FUN_4e4330 数据存储
int vm_store(struct VMContext* ctx) { return 0; }


// FUN_4e4360 终止协程
int vm_kill(struct VMContext* ctx) { 
  // msgc("vm_kill");
  int index = VMI(ctx, flag).flag_idx;
  pt_vm_slot_flag[index][0].active = 0;
  ctx->pc += 2;
  return 1;
}


// FUN_4e3e30 ???
void _vm_jump(struct VMContext* ctx, uint32_t index) {
  // 计算目标 PC: 基址 + 表中对应的偏移量
  uintptr_t base = (uintptr_t)*pt_vm_base;
  uint16_t offset = (*pt_vm_base)[index]; // 对应 [EDX + EAX*2]
  ctx->pc = (uint8_t*)(base + offset);
  ctx->is_active = 1;
  ctx->event_status = 0;
  ctx->jump_offsets[1] = 255; // [EAX+4]
  ctx->data_buffer[0] = 255; // [EAX+8]
  ctx->call_stack = (uint32_t *) &ctx->snap[ctx->jump_index + 6];
}


// FUN_4e4390 函数调用
int vm_call(struct VMContext* ctx) {
  VMInstruction* inst = (VMInstruction*) ctx->pc;
  // printf("vm_call %x ", inst->jump.offset);
  ctx->pc += 4;
  ctx->jump_offsets[ctx->jump_index + 1]++;
  *ctx->call_stack = (uint32_t)(uintptr_t)(ctx->pc + inst->jump.offset);
  ctx->call_stack++;
  return 1;
}


// FUN_4e43e0 函数返回
int vm_return(struct VMContext* ctx) {
  // msgc("vm_return");
  ctx->call_stack--;
  ctx->pc += VMI(ctx, jump).offset;
  ctx->jump_offsets[ctx->jump_index + 1]--;
  return 1;
}


// FUN_4e4420 让出执行权
int vm_yield(struct VMContext* ctx) {
  msgc("vm_yield");
  ctx->call_stack--;
  ctx->pc += 2;
  ctx->jump_offsets[ctx->jump_index + 1]--;
  return 1;
}


// FUN_4e4450 压栈
int vm_push(struct VMContext* ctx) { return 0; }

// FUN_4e4490 循环控制
int vm_loop(struct VMContext* ctx) { return 0; }

// FUN_4e44e0 栈上分配
int vm_alloc(struct VMContext* ctx) { return 0; }

// FUN_4e4510 条件等待后弹栈
int vm_wait_pop(struct VMContext* ctx) { return 0; }

// FUN_4e4540 对象方法调用
int vm_call_object(struct VMContext* ctx) { return 0; }

// FUN_4e45b0 对象存在性检查跳转
int vm_if_entity(struct VMContext* ctx) { return 0; }

// FUN_4e4640 for循环控制
int vm_for_loop(struct VMContext* ctx) { return 0; }

// FUN_4e4690 创建协程
int vm_spawn(struct VMContext* ctx) { return 0; }

// FUN_4e4700 结束协程
int vm_coroutine_end(struct VMContext* ctx) { return 0; }

// FUN_4e4730 函数调用
int vm_call_func(struct VMContext* ctx) { return 0; }

// FUN_4e4780 等待事件
int vm_await(struct VMContext* ctx) { return 0; }

// FUN_4e47d0 流式求值器
int vm_eval_stream(struct VMContext* ctx) { return 0; }

// FUN_4e4840 对象状态条件检查
int vm_if_state(struct VMContext* ctx) { return 0; }

// FUN_4e48d0 跳转+6
int vm_jump_6(struct VMContext* ctx) { return 0; }

// FUN_4e48f0 跳转+2
int vm_jump_2(struct VMContext* ctx) { return 0; }

// FUN_4e4910 跳过2字节
int vm_skip_2(struct VMContext* ctx) { return 0; }

// FUN_4e4940 设置暂存区
int vm_set_stash(struct VMContext* ctx) { return 0; }

// FUN_4e4990 指令派发
int vm_dispatch(struct VMContext* ctx) { return 0; }

// FUN_4e49f0 退出slot
int vm_slot_exit(struct VMContext* ctx) { return 0; }

// FUN_4e4a30 切换slot
int vm_slot_next(struct VMContext* ctx) { return 0; }

// FUN_4e4a70 从表设变量
int vm_set_var(struct VMContext* ctx) { return 0; }

// FUN_4e4ac0 暂停所有协程
int vm_pause_all(struct VMContext* ctx) { return 0; }

// FUN_4e4ae0 位测试
int vm_bit_test(struct VMContext* ctx) { return 0; }

// FUN_4e4b30 位操作
int vm_bit_write(struct VMContext* ctx) { return 0; }

// FUN_4e4bb0 比较运算
int vm_cmp_var(struct VMContext* ctx) { return 0; }

// FUN_4e4c50 写入变量表
int vm_set_table(struct VMContext* ctx) { return 0; }

// FUN_4e4c80 变量间传送
int vm_mov_var(struct VMContext* ctx) { return 0; }

// FUN_4e4cc0 算术运算
int vm_calc(struct VMContext* ctx) { return 0; }

// FUN_4e4d00 算术运算2
int vm_calc_2(struct VMContext* ctx) { return 0; }

// FUN_4e4d50 算术运算表
int vm_arith_table(struct VMContext* ctx) { return 0; }

// FUN_4e4e70 键盘输入
int vm_key_input(struct VMContext* ctx) { return 0; }

// FUN_4e4ed0 按键检查
int vm_key_check(struct VMContext* ctx) { return 0; }

// FUN_4e4f10 按键回调
int vm_key_callback(struct VMContext* ctx) { return 0; }

// FUN_4e4f40 按键状态设置
int vm_key_state(struct VMContext* ctx) { return 0; }

// FUN_4e4f80 检查更新
int vm_check_update(struct VMContext* ctx) { return 0; }

// FUN_4e5010 获取更新
int vm_get_update(struct VMContext* ctx) { return 0; }

// FUN_4e5060 障碍物检查
int vm_obstacle_check(struct VMContext* ctx) { return 0; }

// FUN_4e50b0 障碍物信息
int vm_obstacle_info(struct VMContext* ctx) { return 0; }

// FUN_4e50f0 障碍物触发
int vm_obstacle_trigger(struct VMContext* ctx) { return 0; }

// FUN_4e5140 障碍物检查2
int vm_obstacle_check_2(struct VMContext* ctx) { return 0; }

// FUN_4e5180 障碍物触发2
int vm_obstacle_trigger_2(struct VMContext* ctx) { return 0; }

// FUN_4e51d0 障碍物处理
int vm_obstacle_handler(struct VMContext* ctx) { return 0; }

// FUN_4e52a0 障碍物处理2
int vm_obstacle_handler_2(struct VMContext* ctx) { return 0; }

// FUN_4e5410 障碍物处理3
int vm_obstacle_handler_3(struct VMContext* ctx) { return 0; }

// FUN_4e54f0 对象设置
int vm_object_set(struct VMContext* ctx) { return 0; }

// FUN_4e5550 对象操作
int vm_object_op(struct VMContext* ctx) { return 0; }

// FUN_4e55a0 关卡实体加载
int vm_load_entity(struct VMContext* ctx) { return 0; }

// FUN_4e58d0 实体加载2
int vm_load_entity_2(struct VMContext* ctx) { return 0; }

// FUN_4e5ab0 实体加载3
int vm_load_entity_3(struct VMContext* ctx) { return 0; }

// FUN_4e5d20 位置设置
int vm_position_set(struct VMContext* ctx) { return 0; }

// FUN_4e5d80 设置当前工作对象
int vm_set_work(struct VMContext* ctx) { return 0; }

// FUN_4e5e50 设置对象成员
int vm_set_member(struct VMContext* ctx) { return 0; }

// FUN_4e5f30 设置速度
int vm_speed_set(struct VMContext* ctx) { return 0; }

// FUN_4e5f60 速度→位置积分
int vm_move_apply(struct VMContext* ctx) { return 0; }

// FUN_4e5fd0 加速度→速度积分
int vm_accel_apply(struct VMContext* ctx) { return 0; }

// FUN_4e6040 设置位置
int vm_pos_set(struct VMContext* ctx) { return 0; }

// FUN_4e60d0 设置旋转
int vm_rot_set(struct VMContext* ctx) { return 0; }

// FUN_4e6110 设置变量
int vm_set_variable(struct VMContext* ctx) { return 0; }

// FUN_4e6150 从表设变量
int vm_set_from_table(struct VMContext* ctx) { return 0; }

// FUN_4e6190 成员设置 (44种)
int vm_set_member_2(struct VMContext* ctx) { return 0; }

// FUN_4e6500 立即数设变量
int vm_set_imm(struct VMContext* ctx) { return 0; }

// FUN_4e6540 立即数比较
int vm_cmp_imm(struct VMContext* ctx) { return 0; }

// FUN_4e65f0 成员获取 (44种)
int vm_get_member(struct VMContext* ctx) { return 0; }

// FUN_4e6950 成员地址计算
int vm_get_member_addr(struct VMContext* ctx) { return 0; }

// FUN_4e6900 成员运算
int vm_member_op(struct VMContext* ctx) { return 0; }

// FUN_4e6bc0 碰撞检测
int vm_collision_test(struct VMContext* ctx) { return 0; }

// FUN_4e6c00 3D音效播放
int vm_sound_emit(struct VMContext* ctx) { return 0; }

// FUN_4e6ce0 输入读取
int vm_input_read(struct VMContext* ctx) { return 0; }

// FUN_4e6d20 粒子效果
int vm_particle(struct VMContext* ctx) { return 0; }

// FUN_4e6e00 粒子效果2
int vm_particle_2(struct VMContext* ctx) { return 0; }

// FUN_4e6e90 粒子效果3
int vm_particle_3(struct VMContext* ctx) { return 0; }

// FUN_4e6f30 粒子效果4
int vm_particle_4(struct VMContext* ctx) { return 0; }

// FUN_4e6fe0 游戏事件
int vm_game_event(struct VMContext* ctx) { return 0; }

// FUN_4e7020 事件查询
int vm_event_query(struct VMContext* ctx) { return 0; }

// FUN_4e7050 事件设置
int vm_event_set(struct VMContext* ctx) { return 0; }

// FUN_4e70c0 事件回调
int vm_event_callback(struct VMContext* ctx) { return 0; }

// FUN_4e7100 目标获取
int vm_get_target(struct VMContext* ctx) { return 0; }

// FUN_4e71c0 激活实体
int vm_activate(struct VMContext* ctx) { return 0; }

// FUN_4e7220 动作加载
int vm_action_load(struct VMContext* ctx) { return 0; }

// FUN_4e73c0 停用实体
int vm_deactivate(struct VMContext* ctx) { return 0; }

// FUN_4e7400 动画播放
int vm_anim_play(struct VMContext* ctx) { return 0; }

// FUN_4e7520 动画停止
int vm_anim_stop(struct VMContext* ctx) { return 0; }

// FUN_4e7560 动画暂停
int vm_anim_pause(struct VMContext* ctx) { return 0; }

// FUN_4e75b0 碰撞标志位操作
int vm_flag_set(struct VMContext* ctx) { return 0; }

// FUN_4e7630 包围盒设置
int vm_hitbox_set(struct VMContext* ctx) { return 0; }

// FUN_4e7690 状态设置
int vm_state_set(struct VMContext* ctx) { return 0; }

// FUN_4e76c0 房间加载
int vm_room_load(struct VMContext* ctx) { return 0; }

// FUN_4e7ba0 实体生成
int vm_entity_spawn(struct VMContext* ctx) { return 0; }

// FUN_4e8120 按键测试
int vm_key_test(struct VMContext* ctx) { return 0; }

// FUN_4e8150 按键测试2
int vm_key_test_2(struct VMContext* ctx) { return 0; }

// FUN_4e8180 消息发送
int vm_message_send(struct VMContext* ctx) { return 0; }

// FUN_4e81d0 消息发送扩展
int vm_message_send_ext(struct VMContext* ctx) { return 0; }

// FUN_4e8210 屏幕效果
int vm_screen_effect(struct VMContext* ctx) { return 0; }

// FUN_4e82b0 门/区域操作
int vm_door_region(struct VMContext* ctx) { return 0; }

// FUN_4e8360 计时器启动
int vm_timer_start(struct VMContext* ctx) { return 0; }

// FUN_4e83a0 计时器操作
int vm_timer(struct VMContext* ctx) { return 0; }

// FUN_4e83d0 随机数生成
int vm_random(struct VMContext* ctx) { return 0; }

// FUN_4e8440 旋转
int vm_rotate(struct VMContext* ctx) { return 0; }

// FUN_4e8470 打印
int vm_print(struct VMContext* ctx) { return 0; }

// FUN_4e84a0 打印字节
int vm_print_byte(struct VMContext* ctx) { return 0; }

// FUN_4e84c0 打印字符
int vm_print_char(struct VMContext* ctx) { return 0; }

// FUN_4e84e0 给予物品
int vm_give_item(struct VMContext* ctx) { return 0; }

// FUN_4e8520 检查物品
int vm_check_item(struct VMContext* ctx) { return 0; }

// FUN_4e8550 物品比较
int vm_cmp_item(struct VMContext* ctx) { return 0; }

// FUN_4e85f0 设置物品标志
int vm_set_item_flag(struct VMContext* ctx) { return 0; }

// FUN_4e8640 递减物品标志
int vm_dec_item_flag(struct VMContext* ctx) { return 0; }

// FUN_4e86a0 钥匙物品
int vm_key_item(struct VMContext* ctx) { return 0; }

// FUN_4e8720 徽章
int vm_emblem(struct VMContext* ctx) { return 0; }

// FUN_4e8780 运动
int vm_motion(struct VMContext* ctx) { return 0; }

// FUN_4e8880 翻转效果
int vm_flip(struct VMContext* ctx) { return 0; }

// FUN_4e8900 翻转效果2
int vm_flip_2(struct VMContext* ctx) { return 0; }

// FUN_4e8940 翻转效果3
int vm_flip_3(struct VMContext* ctx) { return 0; }

// FUN_4e8990 翻转效果4
int vm_flip_4(struct VMContext* ctx) { return 0; }

// FUN_4e8a10 翻转表
int vm_flip_table(struct VMContext* ctx) { return 0; }

// FUN_4e8a50 翻转表2
int vm_flip_table_2(struct VMContext* ctx) { return 0; }

// FUN_4e8aa0 全局变量设置
int vm_global_set(struct VMContext* ctx) { return 0; }

// FUN_4e8ad0 开关操作
int vm_switch(struct VMContext* ctx) { return 0; }

// FUN_4e8b30 门打开
int vm_door_open(struct VMContext* ctx) { return 0; }

// FUN_4e8b60 地图标记
int vm_map_marker(struct VMContext* ctx) { return 0; }

// FUN_4e8bf0 获取徽章
int vm_emblem_get(struct VMContext* ctx) { return 0; }

// FUN_4e8c60 玩家重置
int vm_player_reset(struct VMContext* ctx) { return 0; }

// FUN_4e8ca0 过场动画
int vm_cutscene(struct VMContext* ctx) { return 0; }

// FUN_4e8d00 翻转表3
int vm_flip_table_3(struct VMContext* ctx) { return 0; }

// FUN_4e8da0 翻转表4
int vm_flip_table_4(struct VMContext* ctx) { return 0; }

// FUN_4e8e30 更新表
int vm_update_table(struct VMContext* ctx) { return 0; }

// FUN_4e8ea0 游戏重置
int vm_game_reset(struct VMContext* ctx) { return 0; }

// FUN_4e8ed0 章节控制
int vm_chapter(struct VMContext* ctx) { return 0; }

// FUN_4e8f20 距离检查
int vm_distance_check(struct VMContext* ctx) { return 0; }

// FUN_4e8fb0 检查标志
int vm_check_flag(struct VMContext* ctx) { return 0; }

// FUN_4e8fd0 清除标志
int vm_clear_flag(struct VMContext* ctx) { return 0; }

// FUN_4e9000 震动控制
int vm_vibration(struct VMContext* ctx) { return 0; }

// L_4503a0: 门模型设置
int vm_door_model_set(struct VMContext* ctx) { return 0; }


// L_4e48d0: 震动设置0
int vm_vib_set0(struct VMContext* ctx) {
  // msgc("vm_vib_set0");
  ctx->pc += 6;
  return 1;
}


// L_4e48d0: 震动设置1
int vm_vib_set1(struct VMContext* ctx) {
  // msgc("vm_vib_set1");
  ctx->pc += 6;
  return 1;
}


// 0x8C: 震动渐变
int vm_vib_fade_set(struct VMContext* ctx) { 
  // msgc("vm_vib_fade_set");
  ctx->pc += 8;
  return 1;
}