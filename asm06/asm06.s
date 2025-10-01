section .bss
outbuf resb 20   ; buffer pour stocker le résultat
neg_flag resb 1 ; savoir si le nombre est négatif ou pas

section .text
        global _start

    _start:

        mov rsi, [rsp]
        mov rax, [rsp+16]
        mov rdx, [rsp+24]

        cmp rsi, 2
        jle no_param

        ; convertir argv[1] → rax
        xor rax, rax
        xor rcx, rcx
        mov rsi, [rsp+16]
        convert1:
            mov bl, [rsi+rcx]
            cmp bl, 0
            je done1
            cmp bl, '-'
            je is_negative1
            sub bl, '0'
            imul rax, rax, 10
            add rax, rbx
            inc rcx
            jmp convert1
        done1:

        ;on regarde si argv[1] est négatif
        cmp byte[neg_flag], 1
        je arg1_negative
        jmp continue1

        arg1_negative:
            neg rax

        continue1:
        mov byte[neg_flag],0
        ; convertir argv[2] → rdx
        xor rdx, rdx
        xor rcx, rcx
        mov rsi, [rsp+24]
        convert2:
            mov bl, [rsi+rcx]
            cmp bl, 0
            je done2
            cmp bl, '-'
            je is_negative2
            sub bl, '0'
            imul rdx, rdx, 10
            add rdx, rbx
            inc rcx
            jmp convert2
        done2:

        ;on regarde si argv[2] est négatif
        cmp byte[neg_flag], 1
        je arg2_negative
        jmp continue2

        arg2_negative:
            neg rdx

        continue2:
        ; addition
        add rax, rdx
        mov rdi, rax

        lea rdi, [outbuf+19] ; on commence à la fin du buffer
        xor rcx, rcx          ; compteur de caractères

        ; vérifier si le nombre est négatif
        mov rbx, rax
        test rax, rax
        jns positive_number
        neg rax
        mov byte [outbuf], '-'  ; mettre le signe au début
        mov rsi, outbuf         ; début du buffer
        jmp convert_number

        positive_number:
        mov rsi, outbuf         ; début du buffer

        convert_number:
        convert_loop:
            xor rdx, rdx
            mov rbx, 10
            idiv rbx               ; rax / 10 -> rax = quotient, rdx = reste
            add dl, '0'           ; convertir le chiffre en ASCII
            dec rdi
            mov [rdi], dl
            inc rcx
            test rax, rax
            jnz convert_loop
        
        ; si le nombre est négatif, ajouter le signe devant
            cmp byte [outbuf], '-'
            jne skip_sign
            dec rdi
            mov byte [rdi], '-' 
            inc rcx
        
        skip_sign:
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

    no_param:
        ;exit 1
        mov rdi, 1
        mov rax, 60
        syscall

    is_negative1:
        inc rcx
        mov byte[neg_flag], 1
        jmp convert1

    is_negative2:
        inc rcx
        mov byte[neg_flag], 1
        jmp convert2