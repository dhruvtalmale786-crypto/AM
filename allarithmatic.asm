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

    menu db 10, "----- MENU -----", 10
         db "1. Addition", 10
         db "2. Subtraction", 10
         db "3. Multiplication", 10
         db "4. Division", 10
         db "5. Exit", 10
         db "Enter your choice: "
    menulen equ $-menu

    msg1 db "Enter first hexadecimal number: "
    len1 equ $-msg1

    msg2 db "Enter second hexadecimal number: "
    len2 equ $-msg2

    addmsg db "Addition = "
    addlen equ $-addmsg

    submsg db "Subtraction = "
    sublen equ $-submsg

    mulmsg db "Multiplication = "
    mullen equ $-mulmsg

    divmsg db "Division = "
    divlen equ $-divmsg

    errormsg db "Error: Division by zero!", 10
    errorlen equ $-errormsg

    newline db 10


section .bss

    a resq 1
    b resq 1
    c resq 1

    char_buff resb 17
    act1 resq 1


section .text

global _start

_start:


; ---------------- MENU ----------------

menu_loop:

    WRITE menu, menulen

    READ char_buff, 2

    mov al, byte [char_buff]

    cmp al, '1'
    je addition

    cmp al, '2'
    je subtraction

    cmp al, '3'
    je multiplication

    cmp al, '4'
    je division

    cmp al, '5'
    je exit_program

    jmp menu_loop


; ---------------- ADDITION ----------------

addition:

    WRITE msg1, len1
    call accept
    mov [a], rbx

    WRITE msg2, len2
    call accept
    mov [b], rbx

    mov rax, [a]
    mov rbx, [b]

    add rax, rbx

    mov [c], rax

    WRITE addmsg, addlen

    mov rbx, [c]
    call display

    WRITE newline, 1

    jmp menu_loop


; ---------------- SUBTRACTION ----------------

subtraction:

    WRITE msg1, len1
    call accept
    mov [a], rbx

    WRITE msg2, len2
    call accept
    mov [b], rbx

    mov rax, [a]
    mov rbx, [b]

    sub rax, rbx

    mov [c], rax

    WRITE submsg, sublen

    mov rbx, [c]
    call display

    WRITE newline, 1

    jmp menu_loop


; ---------------- MULTIPLICATION ----------------

multiplication:

    WRITE msg1, len1
    call accept
    mov [a], rbx

    WRITE msg2, len2
    call accept
    mov [b], rbx

    mov rax, [a]
    mov rbx, [b]

    mul rbx

    mov [c], rax

    WRITE mulmsg, mullen

    mov rbx, [c]
    call display

    WRITE newline, 1

    jmp menu_loop


; ---------------- DIVISION ----------------

division:

    WRITE msg1, len1
    call accept
    mov [a], rbx

    WRITE msg2, len2
    call accept
    mov [b], rbx

    cmp qword [b], 0
    je divide_error

    mov rax, [a]
    mov rbx, [b]

    mov rdx, 0

    div rbx

    mov [c], rax

    WRITE divmsg, divlen

    mov rbx, [c]
    call display

    WRITE newline, 1

    jmp menu_loop


; ---------------- DIVISION ERROR ----------------

divide_error:

    WRITE errormsg, errorlen

    jmp menu_loop


; ---------------- ACCEPT PROCEDURE ----------------

accept:

    READ char_buff, 17

    dec rax

    mov [act1], rax

    mov rsi, char_buff

    mov rbx, 0

up:

    shl rbx, 4

    mov rdx, 0

    mov dl, byte [rsi]

    cmp dl, '9'

    jbe sub30

    sub dl, 07H

sub30:

    sub dl, 30H

    add rbx, rdx

    inc rsi

    dec qword [act1]

    jnz up

    ret


; ---------------- DISPLAY PROCEDURE ----------------

display:

    mov rsi, char_buff

    mov rcx, 16

above:

    rol rbx, 4

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


; ---------------- EXIT ----------------

exit_program:

    EXIT
