.data
.org 0x88

; === DEFAULTS ===
input_addr:     .word 0x80
output_addr:    .word 0x84

; s1 - адрес ввода
; s2 - адрес вывода
; s3 - единица
; s4 - тройка

; a0 - число
; a2 - результат маскирования
; a3 - кол-во шагов
; a7 - сохранение адреса след. команды при call

; sp - стек

.text
_start:
    addi        s3, s3, %lo(0x01)       ; Загрузка единицы
    addi        s4, s4, %lo(0x03)       ; Загрузка тройки
    lui         sp, %hi(1000)           ; Инициализация стека
    addi        sp, sp, %lo(1000)       ; Инициализация стека
    addi        s1, s1, %lo(input_addr) ; Загрузка ячейки с адресом ввода
    lw          s1, s1                  ; Загрузка адреса ввода
    addi        s2, s2, %lo(output_addr); Загрузка ячейки с адресом вывода
    lw          s2, s2                  ; Загрузка адреса вывода

    lw          a0, s1                  ; Чтение числа

    ble         a0, zero, 88            ; if input <= 0 goto _input_ble_zero (22 * 4)
    bleu        a0, s3, 76              ; if else input == 1 goto _input_eq_one (19 * 4)

    jal         a7, 8                   ; else call _save_to_stack (2 * 4)
    j           84                      ; Вывод кол-ва шагов -> _result (21 * 4)

_save_to_stack:
    sw          a7, sp                  ; Сохранение адреса в Mem[sp]
    sub         sp, sp, s3              ; Декримент стека

_main_loop:
    beq         a0, s3, 44              ; if input == 1 goto _success (11 * 4)
    add         a3, a3, s3              ; Кол-во шагов++
    and         a2, a0, s3              ; input and 0x01
    beqz        a2, 12                  ; if input[31] == 0 goto _even (3 * 4)
    jal         a7, 16                  ; else call _odd (4 * 4)
    j           -20                     ; jump _main_loop (-5 * 4)

_even:
    sra         a0, a0, s3              ; Деление на 2 путем ролла
    j           -28                     ; jump _main_loop (-7 * 4)

_odd:
    mul         a0, a0, s4              ; input * 3
    add         a0, a0, s3              ; input + 1
    jr          a7                      ; return to "j -20"

_success:
    add         sp, sp, s3              ; Инкримент стека
    lw          a7, sp                  ; Восстановление адреса в a7
    jr          a7                      ; return to "j 84"

_input_eq_one:
    mv          a3, zero                ; a3 <- 0
    j           12                      ; jump _result (3 * 4)

_input_ble_zero:
    lui         a3, %hi(-1)             ; a3 <- 0xfffff000
    addi        a3, a3, %lo(-1)         ; a3 += 0xfff

_result:
    sw          a3, s2                  ; Загружаем результат в ячейку вывода
    halt                                ; Холт