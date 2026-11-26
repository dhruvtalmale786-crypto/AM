; Q15. Write an ALP to convert 64-bit BCD into its equivalent Hex number.

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
    msg1 db "Enter BCD number (up to 19 digits): ", 0
    len1 equ $- msg1

    msg2 db "Equivalent 64-bit Hex number is: ", 0
    len2 equ $- msg2

    nl db 10
    len_nl equ $- nl

section .bss
    char_buff resb 21
    act1      resq 1

section .text
    global _start

_start:
    WRITE msg1, len1
    READ char_buff, 21
    dec rax
    jz zero_input
    mov [act1], rax

    mov rsi, char_buff
    mov rax, 0
    mov rbx, 0AH

bcd_loop:
    mul rbx
    mov rdx, 0
    mov dl, byte [rsi]
    sub dl, 30H
    add rax, rdx
    inc rsi
    dec qword [act1]
    jnz bcd_loop
    jmp show_res

zero_input:
    mov rax, 0

show_res:
    push rax
    WRITE msg2, len2
    pop rbx
    call display
    WRITE nl, len_nl
    EXIT

display:
    mov rsi, char_buff
    mov rcx, 16

above:
    rol rbx, 04H
    mov dl, bl
    and dl, 0FH
    cmp dl, 09H
    jbe add30
    add dl, 07H
add30:
    add dl, 30H
    mov byte [rsi], dl
    inc rsi
    dec rcx
    jnz above
    WRITE char_buff, 16
    ret
