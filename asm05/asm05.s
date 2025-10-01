section .bss
    buffer: resb 64

section .text
        global _start

    _start:
        mov rsi, [rsp]
        mov rbx, [rsp+16]

        cmp rsi,1
        jle no_param

        xor rcx, rcx ;rcx is the str length

        strlen_loop:
        cmp byte[rbx+rcx], 0
        je strlen_done
        inc rcx
        jmp strlen_loop

        strlen_done:

        ; Ajouter '\n' à la fin du buffer
        mov byte [rbx+rcx], 10   ; ASCII 10 = '\n'
        inc rcx                   ; longueur totale à écrire

        ;write(stdout, *buffer, strlen)
        mov rax, 1
        mov rdi, 1
        mov rsi, rbx
        mov rdx, rcx
        syscall

        ;exit 0
        mov rdi, 0
        mov rax, 60
        syscall

    no_param:
        ;exit 1
        mov rdi, 1
        mov rax, 60
        syscall