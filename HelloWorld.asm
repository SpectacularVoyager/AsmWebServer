global _start

%define SYS_READ 0
%define SYS_WRITE 1
%define SYS_CLOSE 3
%define SYS_EXIT 60
%define STD_OUT 0

%define SYS_SOCKET 41
%define SYS_ACCEPT 43
%define SYS_BIND 49
%define SYS_LISTEN 50

%define AF_INET 2
%define SOCK_STREAM 1



%include "Utils/SysCall.mac"

;;MACROS
%macro EXIT 1
	syscall_m SYS_EXIT,%1
%endmacro

%macro WRITE 3
	syscall_m SYS_WRITE,%1,%2,%3
%endmacro

%macro READ 3
	syscall_m SYS_READ,%1,%2,%3
%endmacro

%macro CHECK_ERRORS 0
	cmp rax,0
	jl _error
%endmacro


%macro SOCKET 0
	syscall_m SYS_SOCKET,AF_INET,SOCK_STREAM,0	
%endmacro

%macro BIND  3
	syscall_m SYS_BIND,%1,%2,%3
%endmacro

%macro LISTEN  2
	syscall_m SYS_LISTEN,%1,%2
%endmacro

%macro ACCEPT  3
	syscall_m SYS_ACCEPT,%1,%2,%3
%endmacro


%macro SEND  3
	syscall_m SYS_ACCEPT,%1,%2,%3
%endmacro

%macro CLOSE 1
	syscall_m SYS_CLOSE,%1
%endmacro

SECTION .text
_start:

	CALL _main
	EXIT 0
_main:
	;PUSH rbp
	;MOV rbp,rsp
	WRITE STD_OUT,message,message_len

	SOCKET							;;get File descriptor
	mov QWORD [sockfd],rax
	CHECK_ERRORS

	WRITE STD_OUT,bind_msg,bind_msg_len

	BIND [sockfd],client_data,client_data_len
	CHECK_ERRORS

	WRITE STD_OUT,listen_msg,listen_msg_len
	LISTEN [sockfd],5
	CHECK_ERRORS

_process_request:
	WRITE STD_OUT,accept_msg,accept_msg_len
	ACCEPT [sockfd],addr,addr_len
	mov QWORD [connfd],rax
	CHECK_ERRORS

	WRITE [connfd],response,response_len
	CHECK_ERRORS

	WRITE STD_OUT,ok_msg,ok_msg_len

	;_read:
		READ [connfd],buffer,buffer_len
;		cmp rax,-1
;		jg _read

	WRITE STD_OUT,buffer,buffer_len
	CHECK_ERRORS
	CLOSE [connfd]
	jmp _process_request

	CLOSE [sockfd]
	RET


_error:
	WRITE STD_OUT,error,error_len
	CLOSE [sockfd]
	EXIT 1



SECTION .data

	sockfd: dq -1
	connfd: dq -1
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

