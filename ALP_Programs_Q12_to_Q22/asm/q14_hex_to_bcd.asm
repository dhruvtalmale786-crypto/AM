; Q14. Write an ALP to convert 64-bit Hex number into its equivalent BCD number.

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
    msg1 db "Enter 64-bit Hex number: ", 0
    len1 equ $- msg1

    msg2 db "Equivalent BCD number is: ", 0
    len2 equ $- msg2

    nl db 10
    len_nl equ $- nl

section .bss
    char_buff resb 17
    act1      resq 1
    num       resq 1
    cnt       resb 1
    x         resb 1

section .text
    global _start

_start:
    WRITE msg1, len1
    call accept
    mov [num], rbx

    mov byte [cnt], 00H
    mov rax, [num]
    mov rbx, 0AH

l2:
    mov rdx, 00H
    div rbx
    push rdx
    inc byte [cnt]
    cmp rax, 00H
    jne l2

    WRITE msg2, len2

l3:
    pop rdx
    add dl, 30H
    mov byte [x], dl
    WRITE x, 1
    dec byte [cnt]
    jnz l3

    WRITE nl, len_nl
    EXIT

accept:
    READ char_buff, 17
    dec rax
    jz accept_zero
    mov [act1], rax
    mov rsi, char_buff
    mov rbx, 00H

up:
    shl rbx, 04H
    mov rdx, 00H
    mov dl, byte [rsi]
    cmp dl, 39H
    jbe sub30
    cmp dl, 46H
    jbe sub07
    sub dl, 20H
sub07:
    sub dl, 07H
sub30:
    sub dl, 30H
    add rbx, rdx
    inc rsi
    dec qword [act1]
    jnz up
    ret

accept_zero:
    mov rbx, 0
    ret
