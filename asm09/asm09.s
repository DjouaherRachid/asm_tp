section .bss
        result_buffer resb 65
 
 section .data
        newline db 10
        hex_chars db "0123456789ABCDEF"
        bin_flag db "-b", 0
 
 section .text
        global _start
 
 _start:
        mov r12, 16
        mov r13, [rsp+16]
        
        cmp qword [rsp], 3
        jne .check_arg_count
        mov rdi, [rsp+16]
        mov rsi, bin_flag
        call string_compare
        cmp rax, 0
        jne .check_arg_count
        
        mov r12, 2
        mov r13, [rsp+24]
        
.check_arg_count:
        cmp qword [rsp], 2
        jl exit_failure
        
        mov rsi, r13
        call ascii_to_int
        
        mov rdi, result_buffer
        mov rsi, r12
        call int_to_base_ascii
        
        mov rdx, rax
        mov rax, 1
        mov rdi, 1
        mov rsi, result_buffer
        syscall
        
        mov rax, 1
        mov rdi, 1
        mov rsi, newline
        mov rdx, 1
        syscall
        
exit_success:
        mov rax, 60
        xor rdi, rdi
        syscall
        
exit_failure:
        mov rax, 60
        mov rdi, 1
        syscall
        
string_compare:
        push rsi
        push rdi
        .loop:
        mov al, [rdi]
        mov ah, [rsi]
        cmp al, ah
        jne .notequal
        cmp al, 0
        je .equal
        inc rsi
        inc rdi
        jmp .loop
        .equal:
        pop rdi
        pop rsi
        xor rax, rax
        ret
.notequal:
        pop rdi
        pop rsi
        mov rax, 1
        ret
        
ascii_to_int:
        xor rax, rax
        xor rbx, rbx
        .loop:
        mov bl, [rsi]
        cmp bl, 0
        je .done
        sub bl, '0'
        imul rax, 10
        add rax, rbx
        inc rsi
        jmp .loop
        .done:
        ret
        
int_to_base_ascii:
        mov r8, rdi
        mov r9, rsi
        add rdi, 64
        mov byte [rdi], 0
        dec rdi
        .loop:
        xor rdx, rdx
        div r9
        lea r10, [hex_chars]
        mov r10b, [r10+rdx]
        mov [rdi], r10b
        dec rdi
        test rax, rax
        jnz .loop
        
        inc rdi
        mov rdx, r8
        add rdx, 65
        sub rdx, rdi
        mov rax, rdx
        
        mov rcx, rax
        mov rsi, rdi
        mov rdi, r8
        rep movsb
        ret