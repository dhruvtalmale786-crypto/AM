; Q21 (ALP). Write X86 ALP to implement following DOS commands using
; command line arguments:
; A) Copy    B) Delete
; Usage:
;   ./q21_dos_cmd copy <source_file> <dest_file>
;   ./q21_dos_cmd delete <target_file>

%macro WRITE 2
    mov rax, 1
    mov rdi, 1
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
    cmd_copy   db "copy", 0
    cmd_delete db "delete", 0

    msg_usage db "Usage:", 10
              db "  ./q21_dos_cmd copy <src> <dst>", 10
              db "  ./q21_dos_cmd delete <file>", 10, 0
    len_usage equ $- msg_usage

    msg_copydone db "File copied successfully.", 10, 0
    len_copydone equ $- msg_copydone

    msg_deldone db "File deleted successfully.", 10, 0
    len_deldone equ $- msg_deldone

    msg_err db "Error: Operation failed (check file path/permissions).", 10, 0
    len_err equ $- msg_err

    msg_inv db "Error: Invalid command. Use 'copy' or 'delete'.", 10, 0
    len_inv equ $- msg_inv

section .bss
    argc    resq 1
    arg1    resq 1
    arg2    resq 1
    arg3    resq 1
    fd_in   resq 1
    fd_out  resq 1
    buf     resb 4096

section .text
    global _start

_start:
    pop rax                 ; argc
    mov [argc], rax
    cmp rax, 3
    jb show_usage

    pop rbx                 ; argv[0] (program name)
    pop rbx                 ; argv[1] (command)
    mov [arg1], rbx
    pop rbx                 ; argv[2] (src or target)
    mov [arg2], rbx

    ; Check if argv[1] == "copy"
    mov rsi, [arg1]
    mov rdi, cmd_copy
    call strcmp
    cmp rax, 0
    je do_copy

    ; Check if argv[1] == "delete"
    mov rsi, [arg1]
    mov rdi, cmd_delete
    call strcmp
    cmp rax, 0
    je do_delete

    WRITE msg_inv, len_inv
    jmp show_usage

do_copy:
    cmp qword [argc], 4
    jb show_usage
    pop rbx                 ; argv[3] (dest)
    mov [arg3], rbx

    ; sys_open(src, O_RDONLY=0, 0)
    mov rax, 2
    mov rdi, [arg2]
    mov rsi, 0
    mov rdx, 0
    syscall
    cmp rax, 0
    jl op_error
    mov [fd_in], rax

    ; sys_open(dst, O_WRONLY|O_CREAT|O_TRUNC = 577, 0644o = 420)
    mov rax, 2
    mov rdi, [arg3]
    mov rsi, 577
    mov rdx, 420
    syscall
    cmp rax, 0
    jl close_in_err
    mov [fd_out], rax

copy_loop:
    ; sys_read(fd_in, buf, 4096)
    mov rax, 0
    mov rdi, [fd_in]
    mov rsi, buf
    mov rdx, 4096
    syscall
    cmp rax, 0
    jle copy_done

    ; sys_write(fd_out, buf, rax)
    mov rdx, rax
    mov rax, 1
    mov rdi, [fd_out]
    mov rsi, buf
    syscall
    jmp copy_loop

copy_done:
    mov rax, 3              ; sys_close(fd_in)
    mov rdi, [fd_in]
    syscall

    mov rax, 3              ; sys_close(fd_out)
    mov rdi, [fd_out]
    syscall

    WRITE msg_copydone, len_copydone
    EXIT

close_in_err:
    mov rax, 3
    mov rdi, [fd_in]
    syscall
    jmp op_error

do_delete:
    ; sys_unlink(target)
    mov rax, 87
    mov rdi, [arg2]
    syscall
    cmp rax, 0
    jl op_error

    WRITE msg_deldone, len_deldone
    EXIT

op_error:
    WRITE msg_err, len_err
    EXIT

show_usage:
    WRITE msg_usage, len_usage
    EXIT

; Compare null-terminated strings at rsi and rdi; returns rax = 0 if equal
strcmp:
    mov al, byte [rsi]
    mov bl, byte [rdi]
    cmp al, bl
    jne strcmp_neq
    cmp al, 0
    je strcmp_eq
    inc rsi
    inc rdi
    jmp strcmp
strcmp_eq:
    mov rax, 0
    ret
strcmp_neq:
    mov rax, 1
    ret
