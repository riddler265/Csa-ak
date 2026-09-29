.data
.org 33

; === DEFAULTS ===
input_addr:        .word 0x80
output_addr:       .word 0x84
mem_ptr:           .word 0x00

; === CONSTANTS ===
c_1:               .word 0x01
c_32:              .word 0x20
c_terminator:      .word 0x0a
c_space:           .word 0x20
c_last_mem:        .word 0x19

; === VARIABLES ===
v_buffer:          .word 0x00
v_write:           .word 0x01
v_current_symbol:  .word 0x00
v_is_first_letter: .word 0x01




.text
.org 0x150
_start:

    load_imm 0x20               ; Итерация буффера, проверка режима записи, захват символа, проверка на первый символ.
    sub v_buffer
    beqz _halt

    load_addr v_write
    beqz _fill

    load_addr input_addr
    load_acc
    store_addr v_current_symbol

    load_imm 0x0a                 ; Проверка на терминатора.
    sub v_current_symbol
    beqz _stop_write

    load_imm 0x20                 ; Проверка на пробел.
    sub v_current_symbol
    beqz _set_first_letter

    load_addr v_is_first_letter
    beqz _select_symbol

    ; Работа с символами, обязаными передти в верхний регистр.

    load_imm 0x00                 ; Сброс флага первой буквы.
    store_addr v_is_first_letter

    ; Проверка на не принадлежность к буквам в нижнем регистре

    load_imm 0x7a                 ; Проверка верхней границы 0x7a >= v_current_symbol
    sub v_current_symbol
    bltz _out

    load_imm 0x60
    sub v_current_symbol
    bgtz _out

    load_addr v_current_symbol
    sub c_32
    store_addr v_current_symbol
    jmp _out



_select_symbol:                   ; Проверка на не принадлежность к буквам в нижнем регистре, иначе вывод

    load_imm 0x5a                 ; Проверка верхней границы 0x7a >= v_current_symbol
    sub v_current_symbol
    bltz _out

    load_imm 0x40
    sub v_current_symbol
    bgtz _out

    load_addr v_current_symbol
    add c_32
    store_addr v_current_symbol
    jmp _out



_stop_write:
    
    load_imm 0x00
    store_addr v_write
    load_imm 0x00
    store_ind mem_ptr

    load_addr mem_ptr
    add c_1
    store_addr mem_ptr

    load_addr v_buffer
    sub c_1
    store_addr v_buffer

    jmp _start



_set_first_letter:

    load_imm 0x01
    store_addr v_is_first_letter

    jmp _out



_out:

    load_addr v_current_symbol
    store_ind output_addr
    
    jmp _out_to_mem



_out_to_mem:

    load_addr v_current_symbol
    store_ind mem_ptr

    jmp _inc_mem_ptr



_fill:

    load_imm 0x5f
    store_ind mem_ptr

    jmp _inc_mem_ptr



_inc_mem_ptr:

    load_addr mem_ptr
    add c_1
    store_addr mem_ptr

    load_addr v_buffer
    add c_1
    store_addr v_buffer

    jmp _start



_halt:
    halt

_remark:

    load_imm 0x00
    store_ind c_last_mem
    halt