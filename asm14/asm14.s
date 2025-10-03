section .rodata
    msg:    db 'Hello Universe!', 64
    msglen: equ $-msg-1

section .text
    global _start

    _start:
    ; nom du fichier entré en argument
    mov rdi, [rsp]
    cmp rdi, 1
    jle no_filename 

    ; open file(char *filename, int flags, umode_t mode)
    mov rax, 2
    mov rdi, [rsp + 16]
    mov rsi, 578
    mov rdx, 0777
    syscall
    mov r12, rax

    ; write (fd, msg, msglen)
    mov rax, 1
    mov rdi, r12
    mov rsi, msg
    mov rdx, msglen
    syscall

    mov rax,3
    mov rdi,r12
    syscall

    mov rdi, 0
    mov rax, 60
    syscall

    no_filename:
    mov rdi, 1
    mov rax, 60
    syscall