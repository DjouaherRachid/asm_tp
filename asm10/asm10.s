section .bss
outbuf resb 20   ; buffer pour stocker le résultat

section .text
    global _start

_start:
    mov rsi, [rsp]        ; argc
    cmp rsi, 4
    jl no_param            ; si moins de 3 arguments, exit(1)

    ; convertir argv[1] → rax
    mov rsi, [rsp+16]
    call str_to_int
    mov rax, rdi           ; rax = premier nombre

    ; convertir argv[2] → rbx
    mov rsi, [rsp+24]
    call str_to_int
    mov rbx, rdi           ; rbx = deuxième nombre

    ; convertir argv[3] → rcx
    mov rsi, [rsp+32]
    call str_to_int
    mov rcx, rdi           ; rcx = troisième nombre

    ; calculer le maximum
    mov rdx, rax           ; rdx = max temporaire
    cmp rbx, rdx
    jle skip1
    mov rdx, rbx
skip1:
    cmp rcx, rdx
    jle skip2
    mov rdx, rcx
skip2:

    ; convertir et afficher le maximum
    mov rdi, rdx
    lea rsi, [outbuf+19]
    call int_to_str

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
    xor r10, r10       ; temporaire pour chaque chiffre
    xor rcx, rcx       ; index
    xor rdx, rdx       ; flag négatif

str_loop:
    mov r10b, [rsi+rcx]
    cmp r10b, 0
    je str_done
    cmp r10b, '-'
    jne str_digit
    inc rcx
    mov dl, 1          ; nombre négatif
    jmp str_loop

str_digit:
    sub r10b, '0'
    imul rdi, rdi, 10
    add rdi, r10
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
