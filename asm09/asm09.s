section .bss
buffer resb 64        ; buffer pour l’affichage (suffisamment grand)

section .text
        global _start

_start:
        ; récupérer argc et argv
        mov rdi, [rsp]          ; argc
        cmp rdi, 1
        jle no_param            ; si pas d’argument → exit 1

        mov rsi, [rsp+16]       ; argv[1] (pointeur sur chaîne)
        
        ; convertir argv[1] (ASCII décimal) → entier dans rdi
        xor rdi, rdi            ; résultat = 0
        xor rcx, rcx            ; index = 0
convert_ascii_to_dec:
        mov bl, [rsi+rcx]       ; lire caractère
        cmp bl, 0
        je convert_done         ; fin de chaîne

        cmp bl, '0'
        jb not_digit
        cmp bl, '9'
        ja not_digit

        sub bl, '0'
        imul rdi, rdi, 10
        movzx rbx, bl
        add rdi, rbx
        inc rcx
        jmp convert_ascii_to_dec

convert_done:
        ; rdi contient le nombre entier
        mov rax, rdi

        ; préparer la conversion en hexadécimal
        mov rcx, 16             ; 16 nibbles (64 bits)
        lea rsi, [buffer+32]    ; pointeur fin du buffer
        mov byte [rsi], 0       ; fin de chaîne C
        dec rsi

hex_loop:
        mov rbx, rax
        and rbx, 0xF            ; extraire 4 bits
        cmp rbx, 9
        jbe hex_digit
        add rbx, 'A' - 10
        jmp hex_store
hex_digit:
        add rbx, '0'
hex_store:
        mov byte [rsi], bl
        dec rsi
        shr rax, 4
        loop hex_loop

        inc rsi                 ; corriger pour pointer sur 1er caractère

        ; écrire sur stdout
        mov rax, 1              ; syscall write
        mov rdi, 1              ; fd=stdout
        mov rdx, 32             ; longueur max affichée
        syscall

        ; exit 0
        mov rax, 60
        xor rdi, rdi
        syscall

no_param:
        ; exit 1
        mov rax, 60
        mov rdi, 1
        syscall

not_digit:
        ; exit 2
        mov rax, 60
        mov rdi, 2
        syscall
