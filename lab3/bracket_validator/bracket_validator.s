.data
.org 0x88

input_addr:        .word 0x80
output_addr:       .word 0x84

closers:           .word 0x00
cl0:               .word 0x29
cl1:               .word 0x5d
cl2:               .word 0x7d

.text

_start:
    movea.l input_addr, A0
    movea.l (A0), A0
    movea.l 0x1000, A7
    clr.l D5
    clr.l D1
    move.l D1, -(A7)
    jsr parse
    halt

parse:
    link A6, -4
    move.l 8(A6), D2
    jsr closer_of
    move.b D3, -4(A6)

_parse_loop:
    jsr read_char

    cmp.b 0x28, D0
    beq _open_paren
    cmp.b 0x5b, D0
    beq _open_bracket
    cmp.b 0x7b, D0
    beq _open_brace
    cmp.b 0x29, D0
    beq _close
    cmp.b 0x5d, D0
    beq _close
    cmp.b 0x7d, D0
    beq _close
    cmp.b 0x0a, D0
    bne _parse_loop

_newline:
    move.b -4(A6), D2
    beq _success
    jmp _fail_nl

_open_paren:
    move.l 1, D1
    jmp _enter

_open_bracket:
    move.l 2, D1
    jmp _enter

_open_brace:
    move.l 3, D1

_enter:
    move.l D1, -(A7)
    jsr parse
    move.l (A7)+, D1
    jmp _parse_loop

_close:
    cmp.b -4(A6), D0
    bne _fail
    unlk A6
    rts

closer_of:
    move.l D2, -(A7)
    asl.l 2, D2
    movea.l closers, A2
    move.l 0(A2,D2), D3
    move.l (A7)+, D2
    rts

read_char:
    move.b (A0), D0
    add.l 1, D5
    cmp.b 0x0a, D0
    beq _rc_ret
    cmp.l 0x40, D5
    beq _overflow
_rc_ret:
    rts

write_result:
    movea.l output_addr, A1
    movea.l (A1), A1
    move.l D1, (A1)
    rts

_success:
    move.l 1, D1
    jsr write_result
    halt

_fail:
    jsr read_char
    cmp.b 0x0a, D0
    bne _fail

_fail_nl:
    move.l -1, D1
    jsr write_result
    halt

_overflow:
    move.l -858993460, D1
    jsr write_result
    halt