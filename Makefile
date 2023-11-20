FLAGS = -felf64 -g 
FILES =HelloWorld.asm

compile:
	@nasm ${FLAGS} ${FILES}

link:
	@ld ${OUTPUT}/*.o

run:
	@./a.out
