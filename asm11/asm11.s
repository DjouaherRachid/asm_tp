section .bss
    buffer resb 8

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

        inc rcx
        jmp strlen_loop

        strlen_done:

    xor rcx, rcx
    xor rdx, rdx
    mov qword[buffer], ''

    int_to_str: ;rax dividende, rcx est le diviseur, rdx reste, rdi nombre de voyelles en int
        mov rax, rdi 
        mov rcx, 10
        div rcx

        add dl, '0'
        mov [buffer], dx
        mov byte[buffer+1], 10

    ; write(stdout, buffer, length)
    mov rax, 1
    mov rdi, 1
    mov rsi, buffer
    mov rdx, 8
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
