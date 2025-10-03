section .bss
    buffer: resb 64
    buffer_caesar: resb 64

section .text
    global _start

_start:
    mov r13, [rsp + 16]        ; argv[1] (pointeur vers clé)
    mov rsi, [rsp]
    cmp rsi, 1
    jle exit_1

    ; read(0, buffer, 64)
    mov rsi, buffer
    mov rdi, 0
    mov rdx, 64
    mov rax, 0
    syscall
    cmp rax, 0
    jle exit_1                 ; rien lu
    cmp byte[rsi], 10
    je exit_1

    mov r9, rax                ; sauvegarder longueur du buffer lue
    lea rsi, [buffer]          ; source
    lea r8, [buffer_caesar]    ; destination

    ; convertir argv[1] en entier
    mov rdi, r13               ; passer argv[1] à str_to_int
    call str_to_int
    mov r10, rdi               ; clé entière


    ; réduire clé modulo 26
    mov rax, r10
    xor rdx, rdx
    mov rcx, 26
    div rcx
    mov r11b, dl               ; décalage final

    ; boucler
    xor rcx, rcx

caesar_loop:
    cmp rcx, r9                
    jge caesar_done

    mov al, [rsi + rcx]

    ; majuscule ?
    cmp al, 'A'
    jb check_lower
    cmp al, 'Z'
    ja check_lower
    add al, dl
    cmp al, 'Z'
    jle store_char
    sub al, 26
    jmp store_char

check_lower:
    cmp al, 'a'
    jb store_char
    cmp al, 'z'
    ja store_char
    add al, dl
    cmp al, 'z'
    jle store_char
    sub al, 26

store_char:
    mov [r8 + rcx], al
    inc rcx
    jmp caesar_loop

caesar_done:
    inc rcx

    ; write(1, buffer_caesar, rcx)
    mov rax, 1
    mov rdi, 1
    mov rsi, buffer_caesar
    mov rdx, rcx
    syscall

    ; exit 0
exit_0:
    mov rax, 60
    xor rdi, rdi
    syscall

exit_1:
    mov rax, 60
    mov rdi, 1
    syscall

; -------------------
; atoi(argv[1])
; entrée : r13 = pointeur vers chaîne
; sortie : rdi = entier
str_to_int:
    xor rdi, rdi
    xor rcx, rcx
    xor rdx, rdx

str_loop:
    mov bl, [r13 + rcx]
    cmp bl, 0
    je str_done
    cmp bl, '-'
    jne str_digit
    inc rcx
    mov dl, 1
    jmp str_loop

str_digit:
    sub bl, '0'
    imul rdi, rdi, 10
    add rdi, rbx
    inc rcx
    jmp str_loop

str_done:
    test dl, dl
    jz str_return
    neg rdi
str_return:
    ret