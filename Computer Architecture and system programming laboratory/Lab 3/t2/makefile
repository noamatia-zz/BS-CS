all: virusDetector

# Tool invocations
# Executable "task2b" depends on the file task2b
virusDetector: task2b.o 
	gcc -m32 -g -Wall -o virusDetector task2b.o 

# Depends on the source files
task2b.o: task2b.c
	gcc -g -Wall -m32  -c -o task2b.o task2b.c

#tell make that "clean" is not a file name!
.PHONY: clean

#Clean the build directory
clean:
	rm -f *.o virusDetector