section .bss
    buffer resb 64

section .text
        global _start

    _start:
        ; read(0, buffer, 64)
        mov rsi, buffer
        mov rdi, 0
        mov rdx, 64
        mov rax, 0
        syscall

        xor rcx, rcx ;rcx is the str length
        xor rdi, rdi ;rdi is the number of vowels

        strlen_loop:
        mov al, byte[buffer+rcx]
        cmp al, 0
        je strlen_done

        ;normalisation
        or al, 0x20

        cmp al, 'a'
        je increase_vowel_number
        cmp al, 'e'
        je increase_vowel_number
        cmp al, 'i'
        je increase_vowel_number
        cmp al, 'o'
        je increase_vowel_number
        cmp al, 'u'
        je increase_vowel_number
        cmp al, 'y'
        je increase_vowel_number

        inc rcx
        jmp strlen_loop

        strlen_done:

    xor rcx, rcx
    xor rdx, rdx
    mov r12, rdi
    xor r13, r13

    ; on réinitialise le buffer
    lea rdi, [buffer]   
    mov rcx, 64         
    xor rax, rax        
    rep stosb           ; écrit 0 dans rcx octets à partir de rdi

    int_to_str:                ; rax = dividende, rcx = diviseur, rdx = reste, r12 = nombre de voyelles, r13 = offset pour '\n'
        mov rax, r12           ; mettre le nombre dans RAX
        mov rcx, 10            ; diviseur = 10
        lea rsi, [buffer+64]   ; pointer à la fin du buffer pour écrire à l’envers
        xor rdx, rdx           ; nettoyer le reste

        ; on ajoute '\n' à la fin
        mov byte [rsi], 10
        dec rsi

    convert_loop:
        xor rdx, rdx
        div rcx                 ; RAX / 10 -> quotient dans RAX, reste dans RDX
        add dl, '0'             ; convertir le reste en ASCII
        dec rsi
        mov [rsi], dl           ; stocker le chiffre
        test rax, rax
        jnz convert_loop        ; répéter tant que quotient != 0'

    ; write(stdout, buffer, length)
    mov rax, 1
    mov rdi, 1
    mov rsi, buffer
    mov rdx, 65
    syscall

    ;exit 0
    mov rdi, 0
    mov rax, 60
    syscall
    ret

    increase_vowel_number:
        inc rdi
        inc rcx
        jmp strlen_loop
