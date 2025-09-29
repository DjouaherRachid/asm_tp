section .text
        global _start

    _start:
        ; exit(0)
        mov rdi, 0  ;on retourne le code d'erreur 0
        mov rax, 60 ;le numéro du syscall est 60 (pour un exit)
        syscall