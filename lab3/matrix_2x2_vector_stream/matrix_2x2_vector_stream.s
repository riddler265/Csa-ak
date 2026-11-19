.data
.org 0x88

; === DEFAULTS ===
input_addr:  .word 0x80
output_addr: .word 0x84

; s1  - единица
; s2  - 0xCCCCCCCC
; s3  - 0xFFFFFFFF
; s4  - адрес возврата
; s5  - 0x80000000
; s10 - адрес ввода
; s11 - адрес вывода

; t0  - кол-во пар { матрица, вектор } (далее N)
; t1  - a * x OR c * x
; t2  - b * y OR d * y
; t3  - multiply result sign (имеющийся)
; t4  - multiply result sign (ожидаемое)
; t5  - произведение

; a0  - u
; a1  - v
; a2  - a
; a3  - b
; a4  - c
; a5  - d
; a6  - x
; a7  - y


.text
_start:

    addi s10, s10, %lo(input_addr) / addi s11, s11, %lo(output_addr) /             /                     ; Загрузка ячеек, хранящих IO-адреса.
    addi s1, s1, %lo(0x01)         / lui s2, %hi(0xCCCCCCCC)         / lw s10, s10 /                     ; Загрузка единицы в s1. Загрузка 0xCCCCC000. Загрузка адреса ввода
    addi s2, s2, %lo(0xCCCCCCCC)   / lui s3, %hi(0xFFFFFFFF)         / lw t0, s10  /                     ; Загрузка 0xCCCCCCCC. Загрузка 0xFFFFF000. Загрузка N
    addi s3, s3, %lo(0xFFFFFFFF)   / lui s5, %hi(0x80000000)         / lw s11, s11 / beqz t0, _halt      ; Загрузка Загрузка адреса вывода. if mator == 0 goto _halt

_main_loop:

     / / / beqz t0, _halt                                                                     ; if N == 0 goto _halt

     / / lw a2, s10 /                                                                         ; a2 <= a
     / / lw a3, s10 /                                                                         ; a3 <= b
     / / lw a4, s10 /                                                                         ; a4 <= c
     / / lw a5, s10 /                                                                         ; a5 <= d
     / / lw a6, s10 /                                                                         ; a6 <= x
     / / lw a7, s10 /                                                                         ; a7 <= y

    mul t1, a2, a6 / xor t3, a2, a6 /  /                                                      ; t1 <= a * x          /   t3 <= a ^ x   / /
    mv t5, t1      /                /  / jal s4, _check_overflow                              ; t5 <= a * x          /                 / /   call _check_overflow (a * x)
    mul t2, a3, a7 / xor t3, a3, a7 /  /                                                      ; t2 <= b * y          /   t3 <= b ^ y   / /
    mv t5, t2      /                /  / jal s4, _check_overflow                              ; t5 <= b * y          /                 / /   call _check_overflow (b * y)
    add a0, t1, t2 /                /  /                                                      ; a0 <= a * x + b * y  /                 / /
    mul t1, a4, a6 / xor t3, a4, a6 /  /                                                      ; t1 <= c * x          /   t3 <= c ^ x   / /
    mv t5, t1      /                /  / jal s4, _check_overflow                              ; t5 <= c * x          /                 / /   call _check_overflow (c * x)
    mul t2, a5, a7 / xor t3, a5, a7 /  /                                                      ; t2 <= d * y          /   t3 <= d ^ y   / /
    mv t5, t2      /                /  / jal s4, _check_overflow                              ; t5 <= d * y          /                 / /   call _check_overflow (d * y)
    add a1, t1, t2 /                /  /                                                      ; a1 <= c * x + d * y  /                 / /
    
    sub t0, t0, s1 /                / sw a0, s11 /                                            ; dec t0   / /   OUT <= u   /
                   /                / sw a1, s11 / j _main_loop                               ;          / /   OUT <= v   /   jump _main_loop


_check_overflow:
    and t3, t3, s5 / and t4, t5, s5 /            / beq t3, t4, _return                        ; знаки совпали - молодцом
                   /                / sw s2, s11 / j    _halt                                 ; else OUT <= 0xCCCCCCCC

_return:
     / / / jr   s4                                                                            ; return

_halt:
     / / / halt                                                                               ; холс без вывода (додеп)