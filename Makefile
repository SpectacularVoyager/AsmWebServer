FLAGS = -felf64 -g 
FILES =src/HelloWorld.asm

compile:
	@nasm ${FLAGS} ${FILES}

link:
	@ld src/*.o

run:
	@./a.out

debug:
	@gdb -tui a.out
