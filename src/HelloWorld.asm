global _start


%include "src/Utils/SysCall.mac"
%include "src/Utils/System.mac"


SECTION .text
_start:
	CALL _main
	EXIT 0


_main:
	push rbp
	mov rbp,rsp
	WRITE STD_OUT,message,message_len

	SOCKET							;;get File descriptor
	push rax
	mov rax,[rbp-8]					;;file descriptor
	;mov QWORD [sockfd],rax
	CHECK_ERRORS

	WRITE STD_OUT,bind_msg,bind_msg_len

	BIND [rbp-8],client_data,client_data_len
	CHECK_ERRORS

	WRITE STD_OUT,listen_msg,listen_msg_len
	LISTEN [rbp-8],5
	CHECK_ERRORS

	_process_request:
		WRITE STD_OUT,accept_msg,accept_msg_len
		ACCEPT [rbp-8],addr,addr_len
		push rax
		mov QWORD [rbp-16],rax			;;connection file descriptor
		CHECK_ERRORS
	
		WRITE [rbp-16],response,response_len
		WRITE [rbp-16],resp_html,resp_html_len
		CHECK_ERRORS
	
		WRITE STD_OUT,ok_msg,ok_msg_len
	
		READ [rbp-16],buffer,buffer_len
		mov rdi,buffer
		mov rsi,path
		call getPath
	
		WRITE STD_OUT,buffer,buffer_len
		WRITE STD_OUT,path,1024
		CHECK_ERRORS
		CLOSE [rbp-16]
	jmp _process_request

	CLOSE [rbp-8]
	leave
	RET


_error:
	WRITE STD_OUT,error,error_len
	CLOSE [rbp-8]
	EXIT 1

getPath:
	add rdi,4
	__getPath_loop:
	mov al, byte [rdi]
	cmp al,32
	je __getPath_exit
	mov [rsi],rax
	inc rdi
	inc rsi
	mov al,0
	mov byte [rsi],0
	jmp __getPath_loop
	__getPath_exit:
	mov rax,0
	mov byte [rsi],al
	mov byte [rsi+1],al
	ret


SECTION .data

	;sockfd: dq -1
	;connfd: dq -1
	buffer: times(2048) db 0
	buffer_len equ $-buffer


	response:	db "HTTP/1.0 200 OK\r\n"
				db "Content-Type: text-html;charset=utf-8",13,10
				db "Connection:close",13,10
				db 13,10
				;db "<h1>Hello World</h1>",10
	response_len equ $-response

	str resp_html,"<h1>Hello World!</h1>"

	;message : db "[INFO]: Server started",10,0
	;message_len equ $ - message
	str message,"[INFO]: Server started"

	str bind_msg,"[INFO]: Socket Bound"

	str listen_msg,"[INFO]: Listening to 127.0.0.1"

	str accept_msg,"[INFO]: Accepted Connection to 127.0.0.1"

	str ok_msg,"[INFO]: OK"

	str error,"[ERROR]: ERROR FOUND RETURNING WITH 1"

	path: times(1024) db 0

	client_data:	dw AF_INET
					dw 47115
					dd 0
					dq 0
	client_data_len equ 16


	addr:		dq 0
                dq 0

	addr_len: dd 16 ;need a pointer for ACCEPT

