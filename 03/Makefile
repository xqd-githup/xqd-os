
all: img



boot.o: boot.S boot.h

boot: boot.o
	ld -Ttext 0 -s --oformat binary -o $@ $< 
	
setup: setup.o
	ld -Ttext 0 -s --oformat binary -o $@ $< 

system: system.o
	ld -Ttext 0 -s --oformat binary -o $@ $< 


img:boot setup system
	dd if=boot of=c.img count=1 conv=notrunc seek=0
	dd if=setup of=c.img count=1 conv=notrunc seek=1
	dd if=system of=c.img count=1 conv=notrunc seek=9


run: boot bochsrc.os
	bochs -f bochsrc.os

clean:
	rm boot setup  system *.o 

%.s: %.S
	gcc -E $< -o $@