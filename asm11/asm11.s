section .bss
    buffer resb 10

section .text
        global _start

    _start:
        mov rsi, [rsp]
        mov rbx, [rsp+16]

        cmp rsi,1
        jle no_param

        xor rcx, rcx ;rcx is the str length
        xor rdi, rdi ;rdi is the number of vowels

        strlen_loop:
        mov al, byte[rbx+rcx]
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

    no_param:
        ;exit 1
        mov rdi, 1
        mov rax, 60
        syscall

    increase_vowel_number:
        inc rdi
        inc rcx
        jmp strlen_loop
