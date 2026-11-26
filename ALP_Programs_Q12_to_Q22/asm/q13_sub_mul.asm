; Q13. Write a menu driven ALP for the following 64-bit Arithmetic operations
; and display the result. Accept the numbers from the user.
; A) Subtraction    B) Multiplication    C) Exit

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
    msg1 db "Enter first 64-bit number (Hex): ", 0
    len1 equ $- msg1

    msg2 db "Enter second 64-bit number (Hex): ", 0
    len2 equ $- msg2

    menu db 10, "--- MENU ---", 10
         db "1. Subtraction", 10
         db "2. Multiplication", 10
         db "3. Exit", 10
         db "Enter your choice: ", 0
    menulen equ $- menu

    msg_sub db 10, "Subtraction Result (Hex): ", 0
    len_sub equ $- msg_sub

    minus_sign db "-", 0

    msg_mul db 10, "Multiplication Result (128-bit Hex): ", 0
    len_mul equ $- msg_mul

    msg_inv db 10, "Invalid Choice! Try again.", 10, 0
    len_inv equ $- msg_inv

    nl db 10
    len_nl equ $- nl

section .bss
    char_buff resb 17
    act1      resq 1
    num1      resq 1
    num2      resq 1
    res_high  resq 1
    res_low   resq 1
    choice    resb 2

section .text
    global _start

_start:
    WRITE msg1, len1
    call accept
    mov [num1], rbx

    WRITE msg2, len2
    call accept
    mov [num2], rbx

printmenu:
    WRITE menu, menulen
    READ choice, 2

    cmp byte [choice], 31H
    je do_sub

    cmp byte [choice], 32H
    je do_mul

    cmp byte [choice], 33H
    je exit_prog

    WRITE msg_inv, len_inv
    jmp printmenu

do_sub:
    WRITE msg_sub, len_sub
    mov rax, [num1]
    sub rax, [num2]
    jnc pos_sub
    push rax
    WRITE minus_sign, 1
    pop rax
    neg rax
pos_sub:
    mov rbx, rax
    call display
    WRITE nl, len_nl
    jmp printmenu

do_mul:
    WRITE msg_mul, len_mul
    mov rax, [num1]
    mul qword [num2]
    mov [res_high], rdx
    mov [res_low], rax

    mov rbx, [res_high]
    call display
    mov rbx, [res_low]
    call display
    WRITE nl, len_nl
    jmp printmenu

exit_prog:
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
