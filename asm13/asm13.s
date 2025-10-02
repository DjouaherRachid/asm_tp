section .bss
    buffer resb 64
    buffer_inv resb 64

section .text
    global _start
    
    _start:
    ; read(0, buffer, 64)
    mov rsi, buffer
    mov rdi, 0
    mov rdx, 64
    mov rax, 0
    syscall

    cmp byte[buffer],10
    je exit_0

    mov r8, rax   ; longueur lue

    lea rsi,[buffer]
    mov rdi, [buffer_inv]

    xor r12, r12 ;start
    inc r12

    invert_loop:
    mov rax, r8
    dec rax
    sub rax, r12
    mov bl, [buffer + rax]
    mov [buffer_inv + r12], bl
    inc r12
    cmp r12, r8
    jne invert_loop

    mov rsi, buffer
    mov rdi, buffer_inv
    mov rcx, r8

    xor r10,r10

    compare_buffers:
    cmp r10, r8
    je exit_0
    mov al, [buffer+r10-1]
    mov bl, [buffer_inv+r10]
    cmp al, bl
    jne exit_1
    inc r10
    jmp compare_buffers

    ; write(stdout, buffer, length)
    mov rax, 1
    mov rsi, buffer_inv
    mov rdi, 1
    mov rdx, r8
    syscall

    ; write(stdout, buffer, length)
    mov rax, 1
    mov rsi, buffer
    mov rdi, 1
    mov rdx, r8
    syscall

exit_0:
    ;exit 0
    mov rdi, 0
    mov rax, 60
    syscall

exit_1:
    ;exit 1
    mov rdi, 1
    mov rax, 60
    syscall
