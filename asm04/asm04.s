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

        ; --- convertir buffer en entier ---
        xor rax, rax      ; rax = résultat (valeur finale)
        xor rcx, rcx      ; rcx = index dans buffer

        convert_loop:
            mov bl, [rsi+rcx] ; charger 1 caractère (octet)
            cmp bl, 10        ; '\n' ?
            je end_convert
            cmp bl, 0         ; fin de chaîne ?
            je end_convert

            cmp bl, '0'            ; < '0' ?
            jb not_digit
            cmp bl, '9'            ; > '9' ?
            ja not_digit

            sub bl, '0'       ; convertir '0'–'9' en 0–9
            cmp bl, 9
            ja end_convert    ; si ce n’est pas un chiffre, on arrête

            imul rax, rax, 10 ; rax = rax * 10
            add rax, rbx      ; rax += chiffre

            inc rcx
            jmp convert_loop

    end_convert:

        ; buffer mod 2
        mov rax, [buffer]
        xor rdx, rdx
        xor rbx, rbx
        mov rbx, 2
        div rbx
        cmp rdx, 0
        jne is_not_even

        is_even:
            ; exit(0)
            mov rdi, 0
            mov rax, 60
            syscall
        jmp end

        is_not_even:
            ; exit(1)
            mov rdi, 1
            mov rax, 60
            syscall

    not_digit:
            ; exit(1)
            mov rdi, 2
            mov rax, 60
            syscall

    end: 