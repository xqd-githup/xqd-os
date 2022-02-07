
all: boot

boot: boot.o
	ld -Ttext 0 -s --oformat binary -o boot boot.o
run: boot bochsrc.os
	bochs -f bochsrc.os

clean:
	rm boot *.o