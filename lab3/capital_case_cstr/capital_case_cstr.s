.data
.org 0x88

; === DEFAULTS ===
input_addr:        .word 0x80
output_addr:       .word 0x84
mem_ptr:           .word 0x00

; === CONSTANTS ===
c_1:               .word 0x01
c_32:              .word 0x20
c_ff:              .word 0xff
c_overflow:        .word -858993460

; === VARIABLES ===
v_buffer:          .word 0x00
v_write:           .word 0x01
v_current_symbol:  .word 0x00
v_is_first_letter: .word 0x01



.text
_start:

    load_imm 0x20
    sub v_buffer
    beqz _finish

    load_addr v_write
    beqz _fill

    load_addr input_addr
    load_acc
    store_addr v_current_symbol

    load_imm 0x0a
    sub v_current_symbol
    beqz _stop_write

    load_imm 0x20
    sub v_current_symbol
    beqz _set_first_letter

    load_addr v_is_first_letter
    beqz _select_symbol

    load_imm 0x00
    store_addr v_is_first_letter

    load_imm 0x7a
    sub v_current_symbol
    bltz _out

    load_imm 0x60
    sub v_current_symbol
    bgez _out

    load_addr v_current_symbol
    sub c_32
    store_addr v_current_symbol
    jmp _out



_select_symbol:

    load_imm 0x5a
    sub v_current_symbol
    bltz _out

    load_imm 0x40
    sub v_current_symbol
    bgez _out

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
    add c_1
    store_addr v_buffer

    jmp _start



_set_first_letter:

    load_imm 0x01
    store_addr v_is_first_letter

    jmp _out



_out:

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



_finish:

    load_addr v_write
    bnez _overflow

    load_imm 0x00
    store_addr mem_ptr



_print_loop:

    load_addr mem_ptr
    load_acc
    and c_ff
    beqz _halt
    store_ind output_addr

    load_addr mem_ptr
    add c_1
    store_addr mem_ptr

    jmp _print_loop



_overflow:

    load_addr c_overflow
    store_ind output_addr



_halt:

    halt