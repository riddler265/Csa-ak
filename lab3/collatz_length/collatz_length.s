.data
.org 0x88

; === DEFAULTS ===
input_addr: .word 0x80
output_addr: .word 0x84

; === CONSTANS ===
c_0: .word 0x00
c_1: .word 0x01

.text
_start:

    lui  a0, %hi(input_addr)
    addi a0, a0, %lo(input_addr)

    lw a0, a0
    lw s1, a0

    lui a1, %hi(c_0)

    ble s1, a1, 8
    j 8
    halt

_main_loop:
    ;lui  a1, 0x01
    addi a1, a3, %lo(0x01)
    and a2, s1, a1
    halt
    