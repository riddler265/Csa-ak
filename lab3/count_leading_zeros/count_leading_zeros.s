.data
.org 0x88

    \ === DEFAULTS ===
    input_addr:     .word 0x80
    output_addr:    .word 0x84

    \ === CONSTS ===
    c_mask:         .word 0x80000000

    \ === VARIABLES ===
    v_zeros_count:  .word 0x00
    v_number:       .word 0x00


.text
_start:

    @p input_addr
    a!
    @
    dup
    if _break

    !p v_number
    _main_loop
    _output ;


_main_loop:

    @p v_number
    @p c_mask
    and
    if _count

    @p v_zeros_count
    ;


_count:

    lit 1
    @p v_zeros_count
    + 
    !p v_zeros_count

    @p v_number
    2*
    !p v_number

    _main_loop ;


_break:

    lit 32


_output:

    @p output_addr
    b!
    !b
    halt