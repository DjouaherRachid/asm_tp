; assemble: nasm -felf64 patcher.asm && ld patcher.o -o patcher
section .bss
    buffer resb 16384

section .rodata
    target     db "1337"
    target_len equ $ - target
    patch      db "H4CK"
    patch_len  equ $ - patch

section .text
    global _start

_start:
    ; argc à [rsp], argv[0] à [rsp+8], argv[1] à [rsp+16]
    mov rax, [rsp]        ; argc
    cmp rax, 2
    jl  no_filename       ; besoin d'au moins 2 args (prog + filename)

    mov rdi, [rsp + 16]   ; argv[1] -> pointeur filename

    ; open(filename, O_RDWR)
    mov rax, 2            ; syscall: open
    ; flags: O_RDWR = 2  (ici on n'utilise pas O_CREAT)
    mov rsi, 2
    mov rdx, 0            ; mode (ignored si pas O_CREAT)
    syscall
    cmp rax, 0
    js  open_failed
    cmp rax, 0
    jl open_failed
    mov r12, rax          ; sauvegarde fd

    ; read(fd, buffer, sizeof buffer)
    mov rax, 0            ; syscall: read
    mov rdi, r12
    lea rsi, [buffer]
    mov rdx, 16384
    syscall
    cmp rax, 0
    js  read_failed
    mov r13, rax          ; bytes_read

    ; si bytes_read < target_len => rien à faire
    mov rax, r13
    cmp rax, target_len
    jl  nothing_to_do

    ; recherche naive : for i in [0 .. bytes_read - target_len]
    lea rsi, [buffer]     ; base buffer
    lea rbx, [target]     ; base target
    mov rcx, r13
    sub rcx, target_len
    ; rcx = max_index (inclusive)
    xor rdi, rdi          ; index i = 0
    xor rax, rax          ; rax=0 -> adresse de trouvaille (0 = not found)

search_loop:
    ; comparator: compare target_len bytes at buffer + rdi with target
    mov r8, rdi
    lea r9, [rsi + r8]    ; ptr to current position in buffer
    mov r10, target_len
    xor r11, r11           ; j = 0
cmp_inner:
    mov al, [r9 + r11]
    cmp al, [rbx + r11]
    jne next_pos
    inc r11
    cmp r11, r10
    jb  cmp_inner
    ; toutes les bytes correspondent -> found
    lea rax, [rsi + r8]    ; rax = address found
    jmp found

next_pos:
    inc rdi
    dec rcx
    jns search_loop        ; rcx >= 0 -> continuer
    ; non trouvé
    xor rax, rax
    jmp after_search

found:
    ; rax contient l'adresse dans le buffer où patcher
    ; applique le patch (patch_len == target_len attendu)
    cld                    ; direction flag = 0 (avance)
    mov rdi, rax           ; dest = buffer + offset
    lea rsi, [patch]       ; source = patch
    mov rcx, patch_len
    rep movsb

after_search:
    cmp rax, 0
    je  not_found      ; pas trouvé -> erreur

    ; repositionner au début du fichier (lseek(fd, 0, SEEK_SET))
    mov rax, 8             ; syscall: lseek (x86_64 classic mapping)
    mov rdi, r12
    xor rsi, rsi           ; offset = 0
    xor rdx, rdx           ; whence = 0 (SEEK_SET)
    syscall

    ; write(fd, buffer, bytes_read)
    mov rax, 1             ; syscall: write
    mov rdi, r12
    lea rsi, [buffer]
    mov rdx, r13
    syscall

    ; close(fd)
    mov rax, 3
    mov rdi, r12
    syscall

    ; exit(0)
    mov rax, 60
    xor rdi, rdi
    syscall

no_filename:
open_failed:
read_failed:
not_found:
    ; exit(1)
    mov rax, 60
    mov rdi, 1
    syscall

nothing_to_do:
    ; exit(0)
    mov rax, 60
    xor rdi, rdi
    syscall
