
all: img



boot.o: boot.S boot.h

boot: boot.o
	ld -Ttext 0 -s --oformat binary -o $@ $< 
	
setup: setup.o
	ld -Ttext 0 -s --oformat binary -o $@ $< 

kernel: head.o main.o
	ld  -b elf64-x86-64 -Ttext 0xffffffff80100000 -s -o $@ $^  


img:boot setup kernel
	dd if=boot of=c.img count=1 conv=notrunc seek=0
	dd if=setup of=c.img count=1 conv=notrunc seek=1
	objcopy -I elf64-x86-64 -S -R ".eh_frame" -R ".comment" -O binary kernel system
	dd if=system of=c.img count=128 conv=notrunc seek=9


run: boot bochsrc.os
	bochs -f bochsrc.os

clean:
	rm boot setup  system kernel *.o 

%.s: %.S
	gcc -E $< -o $@
%.o: %.c
	gcc  -mcmodel=large -fno-builtin -m64 -c $<