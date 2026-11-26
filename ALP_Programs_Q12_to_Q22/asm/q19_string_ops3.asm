; Q19. Write a menu driven ALP program to implement following string operations.
; A) String Concatenate    B) String Compare    C) Check for substring    D) Exit

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
         db "1. String Concatenate", 10
         db "2. String Compare", 10
         db "3. Check for Substring", 10
         db "4. Exit", 10
         db "Enter your choice: ", 0
    menulen equ $- menu

    msg_s1 db 10, "Enter First String: ", 0
    len_s1 equ $- msg_s1

    msg_s2 db "Enter Second String: ", 0
    len_s2 equ $- msg_s2

    msg_sub db "Enter Substring: ", 0
    len_sub equ $- msg_sub

    msg_cat db 10, "Concatenated String: ", 0
    len_mcat equ $- msg_cat

    msg_eq db 10, "Strings are Equal.", 10, 0
    len_eq equ $- msg_eq

    msg_neq db 10, "Strings are NOT Equal.", 10, 0
    len_neq equ $- msg_neq

    msg_found db 10, "Substring Found!", 10, 0
    len_found equ $- msg_found

    msg_nfound db 10, "Substring NOT Found!", 10, 0
    len_nfound equ $- msg_nfound

    msg_inv db 10, "Invalid Choice! Try again.", 10, 0
    len_inv equ $- msg_inv

    nl db 10
    len_nl equ $- nl

section .bss
    str1   resb 100
    str2   resb 100
    res    resb 200
    slen1  resq 1
    slen2  resq 1
    totlen resq 1
    choice resb 2

section .text
    global _start

_start:
printmenu:
    WRITE menu, menulen
    READ choice, 2

    cmp byte [choice], 31H
    je op_concat

    cmp byte [choice], 32H
    je op_compare

    cmp byte [choice], 33H
    je op_substring

    cmp byte [choice], 34H
    je exit_prog

    WRITE msg_inv, len_inv
    jmp printmenu

op_concat:
    WRITE msg_s1, len_s1
    READ str1, 100
    dec rax
    mov [slen1], rax

    WRITE msg_s2, len_s2
    READ str2, 100
    dec rax
    mov [slen2], rax

    cld
    mov rdi, res
    mov rcx, [slen1]
    cmp rcx, 0
    je copy_second
    mov rsi, str1
    rep movsb

copy_second:
    mov rcx, [slen2]
    cmp rcx, 0
    je print_cat
    mov rsi, str2
    rep movsb

print_cat:
    mov rax, [slen1]
    add rax, [slen2]
    mov [totlen], rax

    WRITE msg_cat, len_mcat
    WRITE res, [totlen]
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

op_substring:
    WRITE msg_s1, len_s1
    READ str1, 100
    dec rax
    mov [slen1], rax

    WRITE msg_sub, len_sub
    READ str2, 100
    dec rax
    mov [slen2], rax

    cmp rax, 0
    je sub_found

    mov rbx, [slen1]
    cmp rax, rbx
    ja sub_not_found

    sub rbx, rax
    inc rbx
    mov rsi, str1

sub_outer:
    push rsi
    mov rdi, str2
    mov rcx, [slen2]
    cld
    repe cmpsb
    pop rsi
    je sub_found
    inc rsi
    dec rbx
    jnz sub_outer

sub_not_found:
    WRITE msg_nfound, len_nfound
    jmp printmenu

sub_found:
    WRITE msg_found, len_found
    jmp printmenu

exit_prog:
    EXIT
