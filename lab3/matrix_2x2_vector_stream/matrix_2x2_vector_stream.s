.data
.org 0x88

; === DEFAULTS ===
input_addr: .word 0x80
output_addr: .word 0x84

; s10 - адрес ввода
; s1 - единица
; s11 - адрес вывода

; t0 - кол-во пар { матрица, вектор } (далее N)
; t1 - a * x
; t2 - b * y
; t3 - c * x
; t4 - d * y

; a0 - u
; a1 - v
; a2 - a
; a3 - b
; a4 - c
; a5 - d
; a6 - x
; a7 - y


.text
_start:

    addi s10, s10, %lo(input_addr) / addi s11, s11, %lo(output_addr) / /   ; Загрузка ячеек, хранящих IO-адреса
    addi s1, s1, %lo(0x01) / / lw s10, s10 / ; Загрузка единицы в s1. Загрузка адреса ввода
     / / lw t0, s10 / ; Загрузка N
     / / lw s11, s11 / beqz t0, _halt ; Загрузка адреса вывода. if mator == 0 goto _halt

_main_loop:

     / / / beqz t0, _halt

     / / lw a2, s10 / ; a2 <= a
     / / lw a3, s10 / ; a3 <= b
     / / lw a4, s10 / ; a4 <= c
     / / lw a5, s10 / ; a5 <= d
     / / lw a6, s10 / ; a6 <= x

    mul t1, a2, a6 / mul t3, a4, a6 / lw a7, s10 / ; t1 <= a * x. t3 <= c * x. a7 <= y
    mul t2, a3, a7 / mul t4, a5, a7 / / ; t2 <= b * y. t4 <= d * y.
    add a0, t1, t2 / add a1, t3, t4 / / ; a0 <= a * x + b * y. a1 <= c * x + d * y.

    sub t0, t0, s1 / / sw a0, s11 /
     / / sw a1, s11 / j _main_loop



_halt:
     / / / halt ; Холс без вывода