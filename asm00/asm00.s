section .text
        global _start

    _start:
        ; exit(0)
        mov rdi, 0
        mov rax, 60
        syscall