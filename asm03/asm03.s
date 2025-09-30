section .data
    msg:    db '1337', 10
    msglen: equ $-msg

section .text
        global _start

    _start:
        mov rbx, [rsp+16]

        cmp word[rbx], '42'
        jne is_not_equal

        is_equal:
            ; write(1, msg, msglen)
            mov rsi, msg
            mov rdi, 1
            mov rdx, msglen
            mov rax, 1
            syscall
                
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