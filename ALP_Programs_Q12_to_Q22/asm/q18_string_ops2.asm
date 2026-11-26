; Q18. Write a menu driven ALP program to implement following string operations.
; A) String Copy    B) String Reverse    C) Check for substring    D) Exit

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
         db "1. String Copy", 10
         db "2. String Reverse", 10
         db "3. Check for Substring", 10
         db "4. Exit", 10
         db "Enter your choice: ", 0
    menulen equ $- menu

    msg_s1 db 10, "Enter String: ", 0
    len_s1 equ $- msg_s1

    msg_sub db "Enter Substring: ", 0
    len_sub equ $- msg_sub

    msg_copy db 10, "Copied String: ", 0
    len_mcopy equ $- msg_copy

    msg_rev db 10, "Reversed String: ", 0
    len_mrev equ $- msg_rev

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
    sub1   resb 100
    slen1  resq 1
    sublen resq 1
    choice resb 2

section .text
    global _start

_start:
printmenu:
    WRITE menu, menulen
    READ choice, 2

    cmp byte [choice], 31H
    je op_copy

    cmp byte [choice], 32H
    je op_reverse

    cmp byte [choice], 33H
    je op_substring

    cmp byte [choice], 34H
    je exit_prog

    WRITE msg_inv, len_inv
    jmp printmenu

op_copy:
    WRITE msg_s1, len_s1
    READ str1, 100
    dec rax
    mov [slen1], rax

    cmp rax, 0
    je print_copy

    cld
    mov rsi, str1
    mov rdi, str2
    mov rcx, [slen1]
    rep movsb

print_copy:
    WRITE msg_copy, len_mcopy
    WRITE str2, [slen1]
    WRITE nl, len_nl
    jmp printmenu

op_reverse:
    WRITE msg_s1, len_s1
    READ str1, 100
    dec rax
    mov [slen1], rax

    cmp rax, 0
    je print_rev

    mov rsi, str1
    add rsi, rax
    dec rsi
    mov rdi, str2
    mov rcx, [slen1]

rev_loop:
    mov al, byte [rsi]
    mov byte [rdi], al
    dec rsi
    inc rdi
    dec rcx
    jnz rev_loop

print_rev:
    WRITE msg_rev, len_mrev
    WRITE str2, [slen1]
    WRITE nl, len_nl
    jmp printmenu

op_substring:
    WRITE msg_s1, len_s1
    READ str1, 100
    dec rax
    mov [slen1], rax

    WRITE msg_sub, len_sub
    READ sub1, 100
    dec rax
    mov [sublen], rax

    cmp rax, 0
    je sub_found

    mov rbx, [slen1]
    cmp rax, rbx
    ja sub_not_found

    sub rbx, rax
    inc rbx                 ; Outer loop count = slen1 - sublen + 1
    mov rsi, str1

sub_outer:
    push rsi
    mov rdi, sub1
    mov rcx, [sublen]
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
