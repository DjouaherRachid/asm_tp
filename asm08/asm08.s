section .bss
    buffer: resb 20

section .text
        global _start

    _start:
        mov rdi, [rsp]
        mov rax, [rsp+16]

        cmp rdi, 1
        jle no_param

        ; convertir en int argv[1] → rax
        xor rax, rax
        xor rcx, rcx
        mov rsi, [rsp+16]
        convert:
            mov bl, [rsi+rcx]
            cmp bl, 0
            je done
            sub bl, '0'
            imul rax, rax, 10
            movzx rbx, bl
            add rax, rbx
            inc rcx
            jmp convert
        done:

    xor rcx, rcx
    xor rbx, rbx

    ;cas particuliers
    cmp rax, 1
    je return_zero
    cmp rax, 0
    je return_zero

    mov rbx, 0 ; contiendra le résultat
    mov rcx, 1 ; compteur

    sum:
        add rbx, rcx
        inc rcx
        cmp rcx, rax
        jne sum

    mov rax, rbx

        lea rdi, [buffer+19] ; on commence à la fin du buffer
        xor rcx, rcx          ; compteur de caractères

        convert_loop:
            xor rdx, rdx
            mov rbx, 10
            div rbx               ; rax / 10 -> rax = quotient, rdx = reste
            add dl, '0'           ; convertir le chiffre en ASCII
            dec rdi
            mov [rdi], dl
            inc rcx
            test rax, rax
            jnz convert_loop

        ; ajouter '\n' à la fin
        mov byte [rdi+rcx], 10
        inc rcx  

        return_ok:
        ;write(stdout, *buffer, strlen)
        mov rax, 1           ; syscall write
        mov rsi, rdi         ; adresse du buffer
        mov rdi, 1           ; stdout
        mov rdx, rcx         ; longueur
        syscall

        ;exit 0
        mov rdi, 0
        mov rax, 60
        syscall

        return_zero:
        mov byte [buffer], '0' 
        mov byte [buffer+1], 10 
        mov rsi, buffer        
        mov rcx, 2             
        jmp return_ok

        no_param:
        ;exit 1
        mov rdi, 1
        mov rax, 60
        syscall