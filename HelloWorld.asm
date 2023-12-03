global _start


%include "Utils/SysCall.mac"
%include "Utils/System.mac"




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
		CHECK_ERRORS
	
		WRITE STD_OUT,ok_msg,ok_msg_len
	
		READ [rbp-16],buffer,buffer_len
	
		WRITE STD_OUT,buffer,buffer_len
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


SECTION .data

	;sockfd: dq -1
	;connfd: dq -1
	buffer: times(2048) db 0
	buffer_len equ $-buffer


	response:	db "HTTP/1.0 200 OK",13,10
				db "Content-Type: text-html;charset=utf-8",13,10
				db "Connection:close",13,10
				db 13,10
				db "<h1>Hello World</h1>",10
	response_len equ $-response

	message : db "[INFO]: Server started",10,0
	message_len equ $ - message


	bind_msg : db "[INFO]: Socket Bound",10,0
	bind_msg_len equ $ - bind_msg

	listen_msg : db "[INFO]: Listening to 127.0.0.1",10,0
	listen_msg_len equ $ - listen_msg

	accept_msg : db "[INFO]: Accepted Connection to 127.0.0.1",10,0
	accept_msg_len equ $ - accept_msg


	ok_msg : db "[INFO]: OK",10,0
	ok_msg_len equ $ - ok_msg

	error : db "[ERROR]: ERROR FOUND RETURNING WITH 1",10,0
	error_len equ $ - error


	client_data:	dw AF_INET
					dw 47115
					dd 0
					dq 0
	client_data_len equ 16


	addr:		dq 0
                dq 0

	addr_len: dd 16 ;need a pointer for ACCEPT

