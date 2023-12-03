FLAGS = -felf64 -g 
FILES =HelloWorld.asm

compile:
	@nasm ${FLAGS} ${FILES}

link:
	@ld *.o

run:
	@./a.out

debug:
	@gdb -tui a.out
