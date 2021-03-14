
task3: task3.o
	ld -m elf_i386 -o task3 task3.o
	rm -f *.o
 
task3.o: task3.s
	nasm -g -f elf -w+all -o task3.o task3.s

.PHONY: clean

clean: 
	rm -f *.o task3
