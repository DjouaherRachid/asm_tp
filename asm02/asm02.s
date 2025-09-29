section .bss
    buffer: resb 64

section .text
        global _start

    _start:
        ; read(0, buffer, 64)
        mov rsi, buffer
        mov rdi, 0
        mov rdx, 64
        mov rax, 0
        syscall

        mov ax, word[buffer]
        cmp ax, '42'
        jne is_not_equal

        is_equal:
            ; exit(0)
            mov rdi, 0
            mov rax, 60
            syscall
        jmp end

        is_not_equal:
            ; exit(1)
            mov rdi, 1
            mov rax, 60
            syscall

    end: 