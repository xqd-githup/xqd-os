BOOTSEG		= 0x07C0		/* 引导程序加载的位置*/

.code16
.text
	jmpl	$BOOTSEG, $_start

.global _start
_start:
// 初始化寄存器
	movw	%cs, %ax
	movw	%ax, %ds
	movw	%ax, %es
	movw	%ax, %ss
	movw	$0x7c00, %sp

showMsg:
// 调用0x10中断显示字符串
	movw	$27, %cx
	movb	$0x07, %bl	
	movw	$0, %dx	 
	movw	$msg1, %bp
	movw	$0x1301, %ax	 
	int		$0x10			 

// 死循环
end:
	jmp end

msg1:
	.ascii	"Hello, Boot is starting\r\n"

.org 510
boot_flag:	.word 0xAA55
