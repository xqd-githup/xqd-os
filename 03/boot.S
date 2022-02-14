#include "boot.h"

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

// 清屏	
	movw	$0x0700, %bx	
	movw	$0x0600, %ax	
	movw	$0x184f, %dx
	int		$0x10			

showMsg:
// 调用0x10中断显示字符串
	movw	$27, %cx
	movw	$0x7, %bx	
	movw	$0, %dx	 
	movw	$msg1, %bp
	movw	$0x1301, %ax	 
	int		$0x10			 


read_setup:
	movb $0x42, %ah
	movb $0x80, %dl
	movw $setup_packet, %si  
	int $0x13

read_system:
	movb $0x42, %ah
	movb $0x80, %dl
	movw $system_packet, %si  
	int $0x13
// 跳转到setup

	jmpl $DEF_SETUPSEG, $0

msg1:
	.ascii	"Hello, Boot is starting\r\n"

setup_packet:
	.word 0x10  /* struct's size */
	.word 8 /* 读多少个 sectors */
	.word 0, DEF_SETUPSEG>>4 /* buffer address */
	.quad 1 /* 从哪个 sector 开始读 */

system_packet:
	.word 0x10  /* struct's size */
	.word DEF_SYSSIZE/512 /* 读多少个 sectors */
	.word 0,DEF_SYSSEG>>4 /* buffer address */
	.quad 9 /* 从哪个 sector 开始读 */

.org 510
boot_flag:	.word 0xAA55
