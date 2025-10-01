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

        cmp byte[buffer], '0'
        jb not_digit
        cmp byte[buffer], '9'
        ja not_digit

        ; --- convertir buffer en entier ---
        xor rax, rax      ; rax = résultat (valeur finale)
        xor rcx, rcx      ; rcx = index dans buffer

        convert_loop:
            mov bl, [rsi+rcx] ; charger 1 caractère (octet)
            cmp bl, 10        ; '\n' ?
            je end_convert
            cmp bl, 0         ; fin de chaîne ?
            je end_convert

            sub bl, '0'       ; convertir '0'–'9' en 0–9
            cmp bl, 9
            ja end_convert    ; si ce n’est pas un chiffre, on arrête

            imul rax, rax, 10 ; rax = rax * 10
            add rax, rbx      ; rax += chiffre

            inc rcx
            jmp convert_loop

    end_convert:

    mov rdi,rax

    xor rcx,rcx ;rcx est le compteur ici
    mov rcx, 2

    ;cas particuliers
    cmp rdi, 1
    je not_prime
    cmp rdi, 2
    je is_prime

    prime_loop:
        mov rax, rdi
        xor rdx, rdx
        div rcx             ; rax = rdi / rcx, rdx = rdi % rcx
        cmp rdx, 0
        je not_prime        ; divisible → pas premier

        inc rcx
        mov rax, rcx
        imul rax, rcx       ; rax = rcx * rcx
        cmp rax, rdi
        jle prime_loop      ; tant que rcx*rcx <= n

    is_prime:
        ; exit(0)
        mov rdi, 0
        mov rax, 60
        syscall

    not_prime:
        ; exit(1)
        mov rdi, 1
        mov rax, 60
        syscall
        end: 

    not_digit:
        ; exit(2)
        mov rdi, 2
        mov rax, 60
        syscall