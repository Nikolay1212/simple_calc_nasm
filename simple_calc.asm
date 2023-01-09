section .data
        enterA db 'Enter first number: ', 10
        a_length equ $ - enterA

        enterB db 'Enter second number: ', 10
        b_length equ $ - enterB

        enterOp db 'Enter operation: 1 - sum, 2 - sub, 3 - mul, 4 - div', 10
        op_length equ $ - enterOp

	output db 'Result = '
	output_length equ $ - output

	wrongOp db 'Wrong operation type', 10
	wrongOp_length equ $ - wrongOp

	negative db '-'
	negative_length equ $ - negative

section .bss
        number1 resb 8
        number2 resb 8
        input resb 255
        op resb 8
        digitSpace resb 10
        position resb 8

section .text
        global _start

_start:
        call _printInput1
        call _stringToInt
        push rbx
        call _printInput2
        call _stringToInt
        push rbx
        call _printInputOp
        call _getInputOp

	movzx rax, byte[op]

	cmp rax, '1'
	je _add
	cmp rax, '2'
	je _sub
	cmp rax, '3'
	je _mul
	cmp rax, '4'
	je _div

        call _printWrongOp

_exit:
        mov rax, 60
        mov rdi, 0
        syscall

_add:
	pop rbx
	mov rdx, rbx
	pop rbx
	mov rax, rbx
	add rax, rdx
	call _printResult
	call _print
	call _exit

_sub:
	pop rbx
	mov rdx, rbx
	pop rbx
	mov rax, rbx
	cmp rax, rdx
	jle _subBack
	sub rax, rdx
	call _printResult
	call _print
	call _exit

_subBack:
	sub rdx, rax
	mov rax, rdx
	call _printResult
	call _printNegativeSign
	call _print
	call _exit

_mul:
	pop rbx
	mov rdx, rbx
	pop rbx
	mov rax, rbx
	mul rdx
	call _printResult
	call _print
	call _exit

_div:
	pop rbx
	mov rcx, rbx
	pop rbx
	mov rax, rbx
	mov rbx, rcx
	xor rdx, rdx
	div rbx
	call _printResult
	call _print
	call _exit

_printResult:
	push rax
	mov rax, 1
	mov rdi, 1
	mov rsi, output
	mov rdx, output_length
	syscall
	pop rax
	ret

_printNegativeSign:
	push rax
	mov rax, 1
	mov rdi, 1
	mov rsi, negative
	mov rdx, negative_length
	syscall
	pop rax
	ret

_printWrongOp:
	mov rax, 1
	mov rdi, 1
	mov rsi, wrongOp
	mov rdx, wrongOp_length
	syscall
	ret

_printInput1:
        mov rax, 1
        mov rdi, 1
        mov rsi, enterA
        mov rdx, a_length
        syscall
        ret

_printInput2:
        mov rax, 1
        mov rdi, 1
        mov rsi, enterB
        mov rdx, b_length
        syscall
        ret

_printInputOp:
        mov rax, 1
        mov rdi, 1
        mov rsi, enterOp
        mov rdx, op_length
        syscall
        ret

_inputValue:
        mov rax, 0              ; number of syscall
        mov rdi, 0              ; source stdin
        mov rsi, input          ; where is the value
        mov rdx, 8              ; how many bytes, so the last byte will be '\n'
        syscall
        ret

_getInputOp:
        mov rax, 0
        mov rdi, 0
        mov rsi, op
        mov rdx, 8
        syscall
        ret

_stringToInt:
    call _inputValue
    mov     rcx, 0		; position counter
    mov     rbx, 0		; start value = 0

    nextNumber:
        mov     rax, 10		; decimal system
        mul     rbx		; now rax contains rbx * 10
        mov     rbx, rax
        mov     al, [input+rcx]	; put in low register char-symbol by the current position-address
        sub     al, '0'		; al contains really digit  at the position
        movzx   rax, al		; rax = rax + al
        add     rbx, rax	; rbx + rax = stored new value in rbx
        inc     rcx		; position + 1
        movzx   rax, byte[input+ecx]	; put into rax next value by position
        cmp     rax, 10		; if nasm met new line, then jump to nextNumber else return
        jne     nextNumber
        ret

_print:
        mov rcx, digitSpace	; now rcx contains address of digitSpace
        mov rbx, 10		; rbx contains 10
        mov [rcx], rbx		;
        inc rcx
        mov [position], rcx

_directCycle:
        mov rdx, 0
        mov rbx, 10
        div rbx
        push rax
        add rdx, 48
        mov rcx, [position]
        mov [rcx], dl
        inc rcx
        mov [position], rcx
        pop rax
        cmp rax, 0
        jne _directCycle

_backwordCycle:
        mov rcx, [position]
        mov rax, 1
        mov rdi, 1
        mov rsi, rcx
        mov rdx, 1
        syscall
        mov rcx, [position]
        dec rcx
        mov [position], rcx
        cmp rcx, digitSpace
        jge _backwordCycle
        ret
