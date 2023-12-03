global start

start:
	push rbp
	mov rbp,rsp


	push 60
	call sum


	leave
	mov rax,60
	syscall
sum:
	push rbp
	mov rbp,rsp


	leave
	ret
