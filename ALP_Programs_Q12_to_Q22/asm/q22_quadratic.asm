; Q22. Write an ALP to find the roots of the quadratic equation (ax^2 + bx + c = 0).

%macro WRITE 2
    mov rax, 1
    mov rdi, 1
    mov rsi, %1
    mov rdx, %2
    syscall
%endmacro

%macro READ 2
    mov rax, 0
    mov rdi, 0
    mov rsi, %1
    mov rdx, %2
    syscall
%endmacro

%macro EXIT 0
    mov rax, 60
    mov rdi, 0
    syscall
%endmacro

section .data
    msg_a db "Enter coefficient a (integer): ", 0
    len_a equ $- msg_a

    msg_b db "Enter coefficient b (integer): ", 0
    len_b equ $- msg_b

    msg_c db "Enter coefficient c (integer): ", 0
    len_c equ $- msg_c

    msg_notquad db 10, "Not a quadratic equation (a cannot be 0).", 10, 0
    len_notquad equ $- msg_notquad

    msg_real db 10, "Roots are Real and Distinct:", 10, 0
    len_real equ $- msg_real

    msg_equal db 10, "Roots are Real and Equal:", 10, 0
    len_equal equ $- msg_equal

    msg_imag db 10, "Roots are Complex / Imaginary:", 10, 0
    len_imag equ $- msg_imag

    msg_r1 db "Root 1 = ", 0
    len_r1 equ $- msg_r1

    msg_r2 db "Root 2 = ", 0
    len_r2 equ $- msg_r2

    str_plus_i  db " + ", 0
    str_minus_i db " - ", 0
    str_i       db "i", 10, 0
    minus_ch    db "-", 0
    dot_ch      db ".", 0
    nl          db 10

    four  dq 4
    two   dq 2
    ten_k dd 10000

section .bss
    char_buff resb 22
    act1      resq 1
    a         resq 1
    b         resq 1
    c         resq 1
    disc      resq 1
    two_a     resq 1
    real_p    resq 1
    imag_p    resq 1
    int_part  resq 1
    frac_part resq 1
    cw_old    resw 1
    cw_trunc  resw 1
    digit     resb 1
    frac_buf  resb 4

section .text
    global _start

_start:
    WRITE msg_a, len_a
    call accept_signed_dec
    mov [a], rax

    cmp qword [a], 0
    je not_quadratic

    WRITE msg_b, len_b
    call accept_signed_dec
    mov [b], rax

    WRITE msg_c, len_c
    call accept_signed_dec
    mov [c], rax

    finit

    ; Compute 2*a
    fild qword [two]
    fild qword [a]
    fmulp st1, st0
    fstp qword [two_a]

    ; Compute Discriminant D = b^2 - 4*a*c
    fild qword [b]
    fmul st0, st0
    fild qword [four]
    fild qword [a]
    fmulp st1, st0
    fild qword [c]
    fmulp st1, st0
    fsubp st1, st0          ; ST(0) = b^2 - 4ac

    ftst
    fstsw ax
    sahf
    ja real_distinct
    je real_equal
    jmp complex_roots

not_quadratic:
    WRITE msg_notquad, len_notquad
    EXIT

real_distinct:
    WRITE msg_real, len_real
    fsqrt                   ; ST(0) = sqrt(D)
    fst qword [disc]

    ; Root 1 = (-b + sqrt(D)) / (2a)
    fild qword [b]
    fchs
    fadd qword [disc]
    fdiv qword [two_a]
    WRITE msg_r1, len_r1
    call print_float
    WRITE nl, 1

    ; Root 2 = (-b - sqrt(D)) / (2a)
    fild qword [b]
    fchs
    fsub qword [disc]
    fdiv qword [two_a]
    WRITE msg_r2, len_r2
    call print_float
    WRITE nl, 1
    EXIT

real_equal:
    fstp st0                ; pop D
    WRITE msg_equal, len_equal

    fild qword [b]
    fchs
    fdiv qword [two_a]
    fst qword [real_p]

    WRITE msg_r1, len_r1
    call print_float
    WRITE nl, 1

    WRITE msg_r2, len_r2
    fld qword [real_p]
    call print_float
    WRITE nl, 1
    EXIT

complex_roots:
    fchs                    ; ST(0) = -D > 0
    fsqrt                   ; ST(0) = sqrt(-D)
    fdiv qword [two_a]
    fabs                    ; positive imaginary magnitude
    fstp qword [imag_p]

    fild qword [b]
    fchs
    fdiv qword [two_a]
    fstp qword [real_p]

    WRITE msg_imag, len_imag

    ; Root 1: real + imag i
    WRITE msg_r1, len_r1
    fld qword [real_p]
    call print_float
    WRITE str_plus_i, 3
    fld qword [imag_p]
    call print_float
    WRITE str_i, 2

    ; Root 2: real - imag i
    WRITE msg_r2, len_r2
    fld qword [real_p]
    call print_float
    WRITE str_minus_i, 3
    fld qword [imag_p]
    call print_float
    WRITE str_i, 2
    EXIT

;--------------------------------------------------------
; Accept signed decimal integer -> rax
;--------------------------------------------------------
accept_signed_dec:
    READ char_buff, 22
    dec rax
    jz dec_zero
    mov [act1], rax
    mov rsi, char_buff
    mov rbx, 0              ; sign flag (0=pos, 1=neg)

    cmp byte [rsi], '-'
    jne parse_digits
    mov rbx, 1
    inc rsi
    dec qword [act1]
    jz dec_zero

parse_digits:
    mov rax, 0
    mov rcx, 10
dec_loop:
    mul rcx
    mov rdx, 0
    mov dl, byte [rsi]
    sub dl, 30H
    add rax, rdx
    inc rsi
    dec qword [act1]
    jnz dec_loop

    cmp rbx, 1
    jne dec_done
    neg rax
dec_done:
    ret
dec_zero:
    mov rax, 0
    ret

;--------------------------------------------------------
; Print ST(0) as signed float with 4 decimal places (pops ST(0))
;--------------------------------------------------------
print_float:
    ftst
    fstsw ax
    sahf
    jae pf_pos
    WRITE minus_ch, 1
    fchs
pf_pos:
    fnstcw [cw_old]
    mov ax, [cw_old]
    or ax, 0C00H
    mov [cw_trunc], ax
    fldcw [cw_trunc]

    fld st0
    fistp qword [int_part]
    fldcw [cw_old]

    fild qword [int_part]
    fsubp st1, st0
    fimul dword [ten_k]
    fistp qword [frac_part]

    mov rax, [frac_part]
    cmp rax, 10000
    jb pf_print
    sub rax, 10000
    mov [frac_part], rax
    inc qword [int_part]

pf_print:
    mov rax, [int_part]
    call print_uint
    WRITE dot_ch, 1

    ; Print 4-digit fractional part
    mov rax, [frac_part]
    mov rcx, 4
    mov rdi, frac_buf + 3
    mov rbx, 10
frac_loop:
    mov rdx, 0
    div rbx
    add dl, 30H
    mov byte [rdi], dl
    dec rdi
    dec rcx
    jnz frac_loop
    WRITE frac_buf, 4
    ret

print_uint:
    mov rcx, 0
    mov rbx, 10
pu_div:
    mov rdx, 0
    div rbx
    push rdx
    inc rcx
    cmp rax, 0
    jne pu_div
pu_out:
    pop rdx
    add dl, 30H
    mov byte [digit], dl
    push rcx
    WRITE digit, 1
    pop rcx
    dec rcx
    jnz pu_out
    ret
