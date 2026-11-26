; Q17. Write a menu driven ALP program to implement following string operations.
; A) String length    B) String Compare    C) String palindrome    D) Exit

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
    menu db 10, "--- STRING OPERATIONS MENU ---", 10
         db "1. String Length", 10
         db "2. String Compare", 10
         db "3. String Palindrome", 10
         db "4. Exit", 10
         db "Enter your choice: ", 0
    menulen equ $- menu

    msg_s1 db 10, "Enter String: ", 0
    len_s1 equ $- msg_s1

    msg_s2 db "Enter Second String: ", 0
    len_s2 equ $- msg_s2

    msg_len db 10, "Length of String (Hex): ", 0
    len_mlen equ $- msg_len

    msg_eq db 10, "Strings are Equal.", 10, 0
    len_eq equ $- msg_eq

    msg_neq db 10, "Strings are NOT Equal.", 10, 0
    len_neq equ $- msg_neq

    msg_pal db 10, "String is a Palindrome.", 10, 0
    len_pal equ $- msg_pal

    msg_npal db 10, "String is NOT a Palindrome.", 10, 0
    len_npal equ $- msg_npal

    msg_inv db 10, "Invalid Choice! Try again.", 10, 0
    len_inv equ $- msg_inv

    nl db 10
    len_nl equ $- nl

section .bss
    str1      resb 100
    str2      resb 100
    slen1     resq 1
    slen2     resq 1
    char_buff resb 16
    choice    resb 2

section .text
    global _start

_start:
printmenu:
    WRITE menu, menulen
    READ choice, 2

    cmp byte [choice], 31H
    je op_length

    cmp byte [choice], 32H
    je op_compare

    cmp byte [choice], 33H
    je op_palindrome

    cmp byte [choice], 34H
    je exit_prog

    WRITE msg_inv, len_inv
    jmp printmenu

op_length:
    WRITE msg_s1, len_s1
    READ str1, 100
    dec rax
    mov [slen1], rax

    WRITE msg_len, len_mlen
    mov rbx, [slen1]
    call display
    WRITE nl, len_nl
    jmp printmenu

op_compare:
    WRITE msg_s1, len_s1
    READ str1, 100
    dec rax
    mov [slen1], rax

    WRITE msg_s2, len_s2
    READ str2, 100
    dec rax
    mov [slen2], rax

    mov rax, [slen1]
    cmp rax, [slen2]
    jne not_equal

    cmp rax, 0
    je equal

    cld
    mov rsi, str1
    mov rdi, str2
    mov rcx, [slen1]
    repe cmpsb
    jne not_equal

equal:
    WRITE msg_eq, len_eq
    jmp printmenu

not_equal:
    WRITE msg_neq, len_neq
    jmp printmenu

op_palindrome:
    WRITE msg_s1, len_s1
    READ str1, 100
    dec rax
    mov [slen1], rax

    cmp rax, 1
    jbe is_pal

    mov rsi, str1
    mov rdi, str1
    add rdi, rax
    dec rdi

pal_loop:
    cmp rsi, rdi
    jae is_pal
    mov al, byte [rsi]
    cmp al, byte [rdi]
    jne not_pal
    inc rsi
    dec rdi
    jmp pal_loop

is_pal:
    WRITE msg_pal, len_pal
    jmp printmenu

not_pal:
    WRITE msg_npal, len_npal
    jmp printmenu

exit_prog:
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
