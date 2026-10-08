.data
.org 0x88

; === DEFAULTS ===
input_addr: .word 0x80
output_addr: .word 0x84


; s1 - адрес ввода
; s2 - адрес вывода
; s3 - единица

; a0 - число
; a2 - результат максирования
; a3 - кол-во шагов
; a7 - сохранение адреса след. команды при call

; sp - стек


.text
_start:
    addi s3, s3, %lo(0x01) ; Загрузка единицы
    lui sp, %hi(0x999) ; Инициализация стека
    addi sp, sp, %lo(0x999) ; Инициализация стека
    addi s1, s1, %lo(input_addr) ; Загрузка ячейки с адресом ввода
    lw s1, s1 ; Загрузка адреса ввода
    addi s2, s2, %lo(output_addr) ; Загрузка ячейки с адресом вывода
    lw s2, s2 ; Загрузкаа адреса вывода


    lw a0, s1 ; Чтение числа

    ble a0, zero, 28 ; if input <= 0 goto _input_ble_zero
    bleu a0, s3, 16 ; if else input == 1 goto _input_eq_one

    jal a7, 4 ; else call main loop (но сначала сохран в стек)
    j 80 ; Вывод кол-ва шагов

_save_to_stack:
    sw a7, sp ; Сохранение "j 80" в Mem[sp]

_main_loop:
    bleu a0, s3, ??? ; if input == 1 goto _success
    add a3, a3, s3 ; Кол-во шагов++
    and a2, a0, s3 ; input and 0x01
    beqz a2, 12 ; if input[31] == 0 goto _even
    jal a7, 16 ; else call _odd
    j -20 ; jump _main_loop

_even:
    sra a0, a0, s3 ; Деление на 2 путем рола
    j -16 ; jump _main_loop

_odd:
    add a0, a0, a0 ; input * 2...
    add a0, a0, a0 ; input * 3
    add a0, a0, s3 ; input + 1

    jr a7 return to "j -20"

_success:
    lw a7, sp ; Восстановление адреса "j 80" в a7
    jr a7 : return to "j 80"

_input_eq_one:
    mv a3, zero ; a3 <- 0
    j 12 ; jump _result

_input_ble_zero:
    lui a3, %hi(-1) a3 <- x0fffff000
    addi a3, a3, %lo(-1) a3 += 0xfff

_result:
    sw a3, s2 ; Загружаем результат в ячейку вывода
    halt ; Холс