.data
.org 0x88

; === DEFAULTS ===
input_addr: .word 0x80
output_addr: .word 0x84

; s1 - единица
; s2 - 0xCCCCCCCC
; s3 - 0xFFFFFFFF
; s4 - адрес возврата
; s10 - адрес ввода
; s11 - адрес вывода

; t0 - кол-во пар { матрица, вектор } (далее N)
; t1 - a * x OR c * x
; t2 - b * y OR d * y
; t3 - overflow

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
    addi s1, s1, %lo(0x01) / lui s2, %hi(0xCCCCCCCC) / lw s10, s10 / ; Загрузка единицы в s1. Загрузка 0xCCCCC000. Загрузка адреса ввода
    addi s2, s2, %lo(0xCCCCCCCC) / lui s3, %hi(0xFFFFFFFF) / lw t0, s10 / ; Загрузка 0xCCCCCCCC. Загрузка 0xFFFFF000. Загрузка N
    addi s3, s3, %lo(0xFFFFFFFF) / / lw s11, s11 / beqz t0, _halt ; Загрузка Загрузка адреса вывода. if mator == 0 goto _halt

_main_loop:

     / / / beqz t0, _halt

     / / lw a2, s10 / ; a2 <= a
     / / lw a3, s10 / ; a3 <= b
     / / lw a4, s10 / ; a4 <= c
     / / lw a5, s10 / ; a5 <= d
     / / lw a6, s10 / ; a6 <= x

    mul t1, a2, a6 / mulh t3, a2, a6 / lw a7, s10 / bnez t3, _overflow ; t1 <= a * x. overflow <= a * x. a7 <= y. if overflow goto _overflow
    mul t2, a3, a7 / mulh t3, a3, a7 / / bnez t3, _overflow ; t2 <= b * y. overflow <= b * y. if overflow goto _overflow
    add a0, t1, t2 / mulh t3, a4, a6 / / bnez t3, _overflow ; a0 <= a * x + b * y. overflow <= c * x. if overflow goto _overflow
    mul t1, a4, a6 / mulh t3, a5, a7 / / bnez t3, _overflow ; t1 <= c * x. overflow <= d * y. if overflow goto _overflow
    mul t2, a5, a7 / / sw a0, s11 / ; t2 <= d * y. OUT <= u
    add a1, t1, t2 / sub t0, t0, s1 / / ; a1 <=  c * x + d * y
     / / sw a1, s11 / j _main_loop ; OUT <= v


_overflow:
     / / sw s2, s11 / halt

_halt:
     / / / halt ; Холс без вывода