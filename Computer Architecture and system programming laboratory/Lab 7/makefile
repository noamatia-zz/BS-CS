all: task1 task4

task1: task1.o 
	gcc -m32 -g -Wall -o task1 task1.o 
	rm task1.o 

task4: task4.o 
	gcc -m32 -g -fno-pie -Wall -o task4 task4.o 
	rm task4.o

task1.o: task1.c
	gcc -g -Wall -m32  -c -o task1.o task1.c

task4.o: task4.c
	gcc -g -fno-pie -Wall -m32  -c -o task4.o task4.c

.PHONY: clean

clean:
	rm -f *.o task1 task4
