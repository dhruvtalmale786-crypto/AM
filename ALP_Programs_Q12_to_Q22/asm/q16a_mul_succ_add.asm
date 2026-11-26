; Q16a. Write a menu driven ALP to perform multiplication of two 64-bit
; hexadecimal numbers using successive addition.

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

    msg_n db "Enter second 64-bit number (Hex): ", 0
    len_n equ $- msg_n

    menu db 10, "--- MENU ---", 10
         db "1. Successive Addition", 10
         db "2. Exit", 10
         db "Enter your choice: ", 0
    menulen equ $- menu

    msg2 db 10, "The Multiplication Result is: ", 0
    len2 equ $- msg2

    msg3 db 10, "Invalid Choice! Try again.", 10, 0
    len3 equ $- msg3

    nl db 10
    len_nl equ $- nl

section .bss
    char_buff resb 17
    act1      resq 1
    m         resq 1
    n         resq 1
    ans       resq 1
    choice    resb 2

section .text
    global _start

_start:
    WRITE msg1, len1
    call accept
    mov [m], rbx

    WRITE msg_n, len_n
    call accept
    mov [n], rbx

printmenu:
    WRITE menu, menulen
    READ choice, 2

    cmp byte [choice], 31H
    je succadd

    cmp byte [choice], 32H
    je exit_prog

    WRITE msg3, len3
    jmp printmenu

succadd:
    mov rbx, 00
    mov rcx, [n]
    cmp rcx, 0
    je done

l1:
    add rbx, [m]
    dec rcx
    jnz l1

done:
    mov [ans], rbx
    WRITE msg2, len2
    mov rbx, [ans]
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
