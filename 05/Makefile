
all: img



boot.o: boot.S 

boot.bin: boot.o
	ld -Ttext 0 -s --oformat binary -o $@ $< 
	
setup.bin: setup.o
	ld -Ttext 0 -s --oformat binary -o $@ $< 

kernel.bin: head.o main.o  vga.o font.o
	ld  -b elf64-x86-64  -o $@ $^  -T  vmlinux.lds


img:boot.bin setup.bin kernel.bin
	dd if=boot.bin of=c.img count=1 conv=notrunc seek=0
	dd if=setup.bin of=c.img count=1 conv=notrunc seek=1
	objcopy -I elf64-x86-64 -S -R ".eh_frame" -R ".comment" -O binary kernel.bin system.bin
	dd if=system.bin of=c.img count=200 conv=notrunc seek=9


run: boot.bin bochsrc.os
	bochs -f bochsrc.os

clean:
	rm *.bin *.o 

%.o: %.S
	gcc -I include -c $< -o $@
%.o: %.c
	gcc  -I include  -mcmodel=large -fno-builtin -m64 -c $<