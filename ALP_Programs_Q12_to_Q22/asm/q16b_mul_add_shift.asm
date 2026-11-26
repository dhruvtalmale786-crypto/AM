; Q16b. Write a menu driven ALP to perform multiplication of two 64-bit
; hexadecimal numbers using add and shift method.

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
         db "1. Add and Shift Multiplication", 10
         db "2. Exit", 10
         db "Enter your choice: ", 0
    menulen equ $- menu

    msg2 db 10, "The Multiplication Result (128-bit Hex) is: ", 0
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
    ans_high  resq 1
    ans_low   resq 1
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
    je add_shift

    cmp byte [choice], 32H
    je exit_prog

    WRITE msg3, len3
    jmp printmenu

add_shift:
    mov r8, 0               ; Product low 64 bits
    mov r9, 0               ; Product high 64 bits
    mov r10, [m]            ; Multiplicand low 64 bits
    mov r11, 0              ; Multiplicand high 64 bits
    mov rbx, [n]            ; Multiplier
    mov rcx, 64             ; Bit counter

shift_loop:
    shr rbx, 1
    jnc skip_add
    add r8, r10
    adc r9, r11

skip_add:
    shl r10, 1
    rcl r11, 1
    dec rcx
    jnz shift_loop

    mov [ans_high], r9
    mov [ans_low], r8

    WRITE msg2, len2
    mov rbx, [ans_high]
    call display
    mov rbx, [ans_low]
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
