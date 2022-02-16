#include "boot.h"
#include "linkage.h"

.code16
.text

.global _start
_start:
	jmp setup

# 输出ds:si中的字符串
prtstr:
	lodsb
	andb	%al, %al
	jz	fin

	call	prtchr
	jmp	prtstr

fin:	ret
prtchr:	
	pushw	%ax
	pushw	%cx
	movw	$0007,%bx
	movw	$0x01, %cx
	movb	$0x0e, %ah
	int	$0x10
	popw	%cx
	popw	%ax
	ret	

setup:
# 寄存器初始化
	movw	%cs, %ax		
	movw	%ax, %ds
	movw	%ax, %es
	movw	%ax, %fs
	movw	$0,	%ax
	movw	%ax,%ss 
	movw	$0x7c00, %sp


	lea	showSetup,%si
	call	prtstr
#关闭中断
	cli 

# 开启A20
	inb	$0x92, %al			
	orb	$02, %al			 
	outb	%al, $0x92			 


	xorl	%eax, %eax			# 计算GDT的基地址
	movw	%ds, %ax			 
	shll	$4, %eax
	addl	$gdt, %eax
	movl	%eax, (gdt_48+2)
	lgdt	gdt_48				# 加载gdt



	movw	$1, %ax				# protected mode (PE) bit
	lmsw	%ax				# 进入保护模式

	ljmp $8, $DEF_SETUPSEG<<4 + mov_sys



.code32

# 拷贝system到0x100000(1MB)
	cld
mov_sys:
	movw	$0x10, %ax
	movw 	%ax, %es
	movw	%ax, %ds
	movw 	%ax, %ss 
	movl 	$0x7c00, %esp
	movl 	$0x10000, %esi 
	movl 	$0x100000, %edi
	movl 	$DEF_SYSSIZE << 2, %ecx 
	rep
	movsd
	

	jmpl $8, $0x100000


showSetup:
	.string "this is setup....\r\n"


gdt:
	.word	0, 0, 0, 0			# dummy

	.word	0xFFFF				# 4Gb - (0x100000*0x1000 = 4Gb)
	.word	0				# base address = 0
	.word	0x9A00				# code read/exec
	.word	0x00CF				# granularity = 4096, 386
						#  (+5th nibble of limit)

	.word	0xFFFF				# 4Gb - (0x100000*0x1000 = 4Gb)
	.word	0				# base address = 0
	.word	0x9200				# data read/write
	.word	0x00CF				# granularity = 4096, 386
						#  (+5th nibble of limit)


gdt_48:
	.word	gdt_48-gdt-1				# 
	.word	0				# gdt base  稍后通过计算设置这个值