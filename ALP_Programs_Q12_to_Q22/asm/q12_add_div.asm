; Q12. Write a menu driven ALP for the following 64-bit Arithmetic operations
; and display the result. Accept the numbers from the user.
; A) Addition    B) Division    C) Exit

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
         db "1. Addition", 10
         db "2. Division", 10
         db "3. Exit", 10
         db "Enter your choice: ", 0
    menulen equ $- menu

    msg_add db 10, "Addition Result (Hex): ", 0
    len_add equ $- msg_add

    msg_carry db "1", 0
    len_carry equ $- msg_carry

    msg_quo db 10, "Quotient (Hex): ", 0
    len_quo equ $- msg_quo

    msg_rem db 10, "Remainder (Hex): ", 0
    len_rem equ $- msg_rem

    msg_divzero db 10, "Error: Division by zero!", 10, 0
    len_divzero equ $- msg_divzero

    msg_inv db 10, "Invalid Choice! Try again.", 10, 0
    len_inv equ $- msg_inv

    nl db 10
    len_nl equ $- nl

section .bss
    char_buff resb 17
    act1      resq 1
    num1      resq 1
    num2      resq 1
    quo       resq 1
    rem       resq 1
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
    je do_add

    cmp byte [choice], 32H
    je do_div

    cmp byte [choice], 33H
    je exit_prog

    WRITE msg_inv, len_inv
    jmp printmenu

do_add:
    WRITE msg_add, len_add
    mov rax, [num1]
    add rax, [num2]
    jnc no_carry
    push rax
    WRITE msg_carry, 1
    pop rax
no_carry:
    mov rbx, rax
    call display
    WRITE nl, len_nl
    jmp printmenu

do_div:
    cmp qword [num2], 0
    je div_zero

    mov rdx, 0
    mov rax, [num1]
    div qword [num2]
    mov [quo], rax
    mov [rem], rdx

    WRITE msg_quo, len_quo
    mov rbx, [quo]
    call display

    WRITE msg_rem, len_rem
    mov rbx, [rem]
    call display
    WRITE nl, len_nl
    jmp printmenu

div_zero:
    WRITE msg_divzero, len_divzero
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
