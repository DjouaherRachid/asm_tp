section .bss
outbuf resb 20   ; buffer pour stocker le résultat

section .text
        global _start

    _start:
        mov rax, [rsp+16]
        mov rdx, [rsp+24]

        ; convertir argv[1] → rax
        xor rax, rax
        xor rcx, rcx
        mov rsi, [rsp+16]
        convert1:
            mov bl, [rsi+rcx]
            cmp bl, 0
            je done1
            sub bl, '0'
            imul rax, rax, 10
            add rax, rbx
            inc rcx
            jmp convert1
        done1:

        ; convertir argv[2] → rdx
        xor rdx, rdx
        xor rcx, rcx
        mov rsi, [rsp+24]
        convert2:
            mov bl, [rsi+rcx]
            cmp bl, 0
            je done2
            sub bl, '0'
            imul rdx, rdx, 10
            add rdx, rbx
            inc rcx
            jmp convert2
        done2:

        ; addition
        add rax, rdx
        mov rdi, rax

        xor rcx,rcx

        lea rdi, [outbuf+19] ; on commence à la fin du buffer
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