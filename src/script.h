#include <stdint.h>
#pragma pack(push, 1)


typedef struct {
  uint32_t  id;         // offset 0-3: 这里就是 state_table[i] 的元素位置(偏移+4计算出)
  union {
    struct {
      int16_t   count;      // offset 4-5: 循环/跳转计数器 (2 bytes)
      uint8_t   flags;      // offset 6: 状态标志 (1 byte)
      uint8_t   reserved0;  // offset 7: 对齐填充 (1 byte)
      uint16_t  locals[12]; // offset 8-31: 局部变量区 (12 * 2 = 24 bytes)
    };
    uint8_t data[28];
  };
} VMJumpSnapshot;


// Resident Evil 2 VM Context Structure
struct VMContext {
  uint8_t  event_status;          // offset 0: 事件状态
  uint8_t  is_active;             // offset 1: 由 $L_4e42d7 修改，推测为激活状态/错误标志
  int8_t   jump_index;            // offset 2: 槽位索引
  uint8_t  jump_offsets[5];       // offset 3-7: 对齐填充
  int8_t   data_buffer[20];       // offset 8-27: 数据缓冲区

  uint8_t* pc;                    // offset 28: 程序计数器

  VMJumpSnapshot snap[9];         // offset 32-319
  uint32_t* call_stack;           // offset 320: 栈指针/下一指令指针
  uint8_t*  jump_table[14];       // offset 324: 跳转表
};


typedef struct VMStatusSlot {
    uint8_t active;       // offset 0: 标志位
    uint8_t data[92];     // offset 1-92: 其他数据成员
} VMStatusSlot;


typedef struct {
  uint8_t  opcode;
  union {
    struct {
      uint8_t flag_idx;
    } flag;
    
    struct {
      uint8_t  _pad;     // 占位
      int16_t  offset;   // 用于 OP_REL_JUMP
    } jump;
  };
} VMInstruction;

#define VMI(ctx, field) (((VMInstruction*)ctx->pc)->field)
#pragma pack(pop)