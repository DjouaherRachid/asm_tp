section .bss
    buffer resb 5

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
    mov rsi, 0
    syscall
    mov r12, rax

    ; read (fd, buffer, buffer_len)
    mov rax, 0
    mov rdi, r12
    mov rsi, buffer
    mov rdx, 5
    syscall

    cmp rax, 4
    jb  incorrect_length               ; moins de 4 octets lus -> pas un ELF valide

    ;compare buffer to '0x7F E L F'
    mov al, byte[buffer]
    cmp al, 0x7F
    jne not_elf
    mov al, byte[buffer+1]
    cmp al, 0x45
    jne not_elf
    mov al, byte[buffer+2]
    cmp al, 0x4c
    jne not_elf
    mov al, byte[buffer+3]
    cmp al, 0x46
    jne not_elf

    ;close
    mov rax,3
    mov rdi,r12
    syscall

    mov rdi, 0
    mov rax, 60
    syscall

    no_filename:
    not_elf:
    incorrect_length:
    mov rdi, 1
    mov rax, 60
    syscall