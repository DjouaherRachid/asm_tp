section .bss
outbuf resb 20   ; buffer pour stocker le résultat

section .text
    global _start

_start:
    mov rsi, [rsp]        ; argc
    cmp rsi, 3
    jl no_param            ; si moins de 2 arguments, exit(1)

    mov rsi, [rsp+16]      ; argv[1]
    call str_to_int
    mov rax, rdi           ; rax = premier nombre

    mov rsi, [rsp+24]      ; argv[2]
    call str_to_int
    add rax, rdi           ; rax = somme

    mov rdi, rax
    lea rsi, [outbuf+19]   ; début de la conversion
    call int_to_str         ; convertir et écrire

    ; exit(0)
    mov rdi, 0
    mov rax, 60
    syscall

no_param:
    mov rdi, 1
    mov rax, 60
    syscall

;---------------------------------------
; Convertir une chaîne ASCII en entier
; Entrée : rsi = adresse chaîne
; Sortie : rdi = entier
;---------------------------------------
str_to_int:
    xor rdi, rdi       ; résultat
    xor rbx, rbx       ; temporaire pour chaque chiffre
    xor rcx, rcx       ; index
    xor rdx, rdx       ; flag négatif

str_loop:
    mov bl, [rsi+rcx]
    cmp bl, 0
    je str_done
    cmp bl, '-'
    jne str_digit
    inc rcx
    mov dl, 1          ; nombre négatif
    jmp str_loop

str_digit:
    sub bl, '0'
    imul rdi, rdi, 10
    add rdi, rbx
    inc rcx
    jmp str_loop

str_done:
    cmp dl, 1
    jne str_return
    neg rdi
str_return:
    ret

;---------------------------------------
; Convertir un entier en chaîne ASCII et write
; Entrée : rdi = entier
;         rsi = pointe vers fin du buffer
;---------------------------------------
int_to_str:
    xor rcx, rcx        ; compteur
    mov rax, rdi
    test rax, rax
    jns int_positive
    neg rax
    mov byte [outbuf], '-' ; signe négatif
    mov rbx, 1
    jmp int_convert

int_positive:
    mov rbx, 0

int_convert:
    xor rdx, rdx
    mov r10, 10
div_loop:
    xor rdx, rdx
    div r10
    add dl, '0'
    dec rsi
    mov [rsi], dl
    inc rcx
    test rax, rax
    jnz div_loop

    ; ajouter le signe si nécessaire
    cmp rbx, 1
    jne skip_sign
    dec rsi
    mov byte [rsi], '-'
    inc rcx
skip_sign:

    ; ajouter '\n'
    mov byte [rsi+rcx], 10
    inc rcx

    ; write(stdout, buffer, length)
    mov rax, 1
    mov rdi, 1
    mov rdx, rcx
    syscall
    ret
