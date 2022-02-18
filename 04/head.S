


#include "linkage.h"


	.text
	.code32

.global _start
_start:
	movl %ebx,%ebp	/* Save trampoline flag */
	
	movl $0x18,%eax
	movl %eax,%ds

	
	/* 检查CPU是否支持长模式 */
	movl	$0x80000000, %eax
	cpuid
	cmpl	$0x80000000, %eax
	jbe	no_long_mode
	mov	$0x80000001, %eax
	cpuid
	btl	$29, %edx
	jnc	no_long_mode

	movl	%edx,%edi
	

	// /* 开启 PAE 和 PGE */
	xorl	%eax, %eax
	btsl	$5, %eax
	btsl	$7, %eax
	movl	%eax, %cr4
	


	/* 设置4级页表 */
	movl	$0x101000, %eax
	movl	%eax, %cr3

	/* Setup EFER (Extended Feature Enable Register) */
	movl	$0xc0000080, %ecx
	rdmsr
	/* Fool rdmsr and reset %eax to avoid dependences */
	xorl	%eax, %eax
	/* Enable Long Mode */
	btsl	$8, %eax
	btsl	$11, %eax

	/* Make changes effective */
	wrmsr

	xorl	%eax, %eax
	/* Enable paging and in turn activate Long Mode */
	btsl	$31, %eax
	/* Enable protected mode */
	btsl	$0, %eax
	/* Make changes effective */
	movl	%eax, %cr0
	
	/*
	 * At this point we're in long mode but in 32bit compatibility mode
	 * with EFER.LME = 1, CS.L = 0, CS.D = 1 (and in turn
	 * EFER.LMA = 1). Now we want to jump in 64bit mode, to do that we load
	 * the new gdt/idt that has __KERNEL_CS with CS.L = 1.
	 */

	/* Load new GDT with the 64bit segment using 32bit descriptor */
	movl	$0x100F00, %eax
	lgdt	(%eax)

	/* Finally jump in 64bit mode */
	ljmp	$0x10,$0x100100

	.code64
	.org 0x100	
reach_long64:
	// movq init_rsp(%rip),%rsp
	
	/* zero EFLAGS after setting rsp */
	pushq $0
	popfq
	/*
	 * We must switch to a new descriptor in kernel space for the GDT
	 * because soon the kernel won't have access anymore to the userspace
	 * addresses where we're currently running on. We have to do that here
	 * because in 32bit we couldn't load a 64bit linear address.
	 */
	lgdt	pGDT64

	/* 
	 * Setup up a dummy PDA. this is just for some early bootup code
	 * that does in_interrupt() 
	 */ 
	 // movl $0xc0000101,%ecx
	 // movq $cpu_pda,%rax
	 // movq %rax,%rdx
	 // shrq $32,%rdx
	 // wrmsr	

	/* set up data segments. actually 0 would do too */	
	movl $0x18,%eax
	movl %eax,%ds
	movl %eax,%ss
	movl %eax,%es

	/* esi is pointer to real mode structure with interesting info.
	   pass it to C */
	movl	%esi, %edi


	/* Finally jump to run C code and to be on real kernel address
	 * Since we are running on identity-mapped space we have to jump
	 * to the full 64bit address , this is only possible as indirect
	 * jump
	 */


	// movq	initial_code(%rip),	%rax		/* movq address */
	// pushq	$0x10
	// pushq	%rax
	// lretq


	movq	initial_code(%rip),%rax
	jmp	*%rax

	/* SMP bootup changes these two */	
	.globl	initial_code
initial_code:
	.quad	start_kernel
// 	.globl init_rsp
// init_rsp:
// 	.quad  init_task_union+(2*(1UL << 12))-8

	
.code32
ENTRY(no_long_mode)
	/* This isn't an x86-64 CPU so hang */
1:
	jmp	1b	
	
	.globl pGDT32	
.org 0xf00
pGDT32:
	.word	gdt32_end-gdt_table32-1
	.long	gdt_table32-_start+0x100000

.org 0xf10	
ljumpvector:
	.long	reach_long64-_start+0x100000
	.word	8

ENTRY(stext)
ENTRY(_stext)

	/*
	 * This default setting generates an ident mapping at address 0x100000
	 * and a mapping for the kernel that precisely maps virtual address
	 * 0xffffffff80000000 to physical address 0x000000. (always using
	 * 2Mbyte large pages provided by PAE mode)
	 */
.org 0x1000
ENTRY(init_level4_pgt)
	.quad	0x0000000000102007		/* -> level3_ident_pgt */
	.fill	255,8,0
	.quad	0x000000000010a007
	.fill	254,8,0
	/* (2^48-(2*1024*1024*1024))/(2^39) = 511 */
	.quad	0x0000000000103007		/* -> level3_kernel_pgt */

.org 0x2000
/* Kernel does not "know" about 4-th level of page tables. */
ENTRY(level3_ident_pgt)
	.quad	0x0000000000104007
	.fill	511,8,0
	
.org 0x3000
ENTRY(level3_kernel_pgt)
	.fill	510,8,0
	/* (2^48-(2*1024*1024*1024)-((2^39)*511))/(2^30) = 510 */
	.quad	0x0000000000105007		/* -> level2_kernel_pgt */
	.fill	1,8,0

.org 0x4000
ENTRY(level2_ident_pgt)
	/* 40MB for bootup. 	*/
	.quad	0x0000000000000283
	.quad	0x0000000000200183
	.quad	0x0000000000400183
	.quad	0x0000000000600183
	.quad	0x0000000000800183
	.quad	0x0000000000A00183
	.quad	0x0000000000C00183
	.quad	0x0000000000E00183
	.quad	0x0000000001000183
	.quad	0x0000000001200183
	.quad	0x0000000001400183
	.quad	0x0000000001600183
	.quad	0x0000000001800183
	.quad	0x0000000001A00183
	.quad	0x0000000001C00183
	.quad	0x0000000001E00183
	.quad	0x0000000002000183
	.quad	0x0000000002200183
	.quad	0x0000000002400183
	.quad	0x0000000002600183
	/* Temporary mappings for the super early allocator in arch/x86_64/mm/init.c */
	.globl temp_boot_pmds
temp_boot_pmds:
	.fill	492,8,0
		
.org 0x5000
ENTRY(level2_kernel_pgt)
	/* 40MB kernel mapping. The kernel code cannot be bigger than that.
	   When you change this change KERNEL_TEXT_SIZE in pgtable.h too. */
	/* (2^48-(2*1024*1024*1024)-((2^39)*511)-((2^30)*510)) = 0 */
	.quad	0x0000000000000183
	.quad	0x0000000000200183
	.quad	0x0000000000400183
	.quad	0x0000000000600183
	.quad	0x0000000000800183
	.quad	0x0000000000A00183
	.quad	0x0000000000C00183
	.quad	0x0000000000E00183
	.quad	0x0000000001000183
	.quad	0x0000000001200183
	.quad	0x0000000001400183
	.quad	0x0000000001600183
	.quad	0x0000000001800183
	.quad	0x0000000001A00183
	.quad	0x0000000001C00183
	.quad	0x0000000001E00183
	.quad	0x0000000002000183
	.quad	0x0000000002200183
	.quad	0x0000000002400183
	.quad	0x0000000002600183
	/* Module mapping starts here */
	.fill	492,8,0

.org 0x6000
ENTRY(empty_zero_page)

.org 0x7000
ENTRY(empty_bad_page)

.org 0x8000
ENTRY(empty_bad_pte_table)

.org 0x9000
ENTRY(empty_bad_pmd_table)

.org 0xa000
ENTRY(level3_physmem_pgt)
	.quad	0x0000000000105007		/* -> level2_kernel_pgt (so that __va works even before pagetable_init) */

	.org 0xb000
#ifdef CONFIG_ACPI_SLEEP
ENTRY(wakeup_level4_pgt)
        .quad   0x0000000000102007              /* -> level3_ident_pgt */
        .fill   255,8,0
        .quad   0x000000000010a007
        .fill   254,8,0
        /* (2^48-(2*1024*1024*1024))/(2^39) = 511 */
        .quad   0x0000000000103007              /* -> level3_kernel_pgt */
#endif



.globl SYMBOL_NAME(gdt)

	.globl pGDT64
	.word 0
	.align 16
	.word 0
pGDT64:
	.word	gdt_end-gdt_table-1
SYMBOL_NAME_LABEL(gdt)
	.quad	gdt_table-_start+0x100000
	

.align 64 /* cacheline aligned */
ENTRY(gdt_table32)
	.quad	0x0000000000000000	/* This one is magic */
	.quad	0x0000000000000000	/* unused */
	.quad	0x00af9a000000ffff	/* __KERNEL_CS */
gdt32_end:	
	
/* We need valid kernel segments for data and code in long mode too
 * IRET will check the segment types  kkeil 2000/10/28
 * Also sysret mandates a special GDT layout 
 */
		 		
.align 64 /* cacheline aligned, keep this synchronized with asm/desc.h */
ENTRY(gdt_table)
	.quad	0x0000000000000000	/* This one is magic */
	.quad	0x008f9a000000ffff	/* __KERNEL_COMPAT32_CS */	
	.quad	0x00af9a000000ffff	/* __KERNEL_CS */
	.quad	0x00cf92000000ffff	/* __KERNEL_DS */
	.quad	0x00cffe000000ffff	/* __USER32_CS */
	.quad	0x00cff2000000ffff	/* __USER_DS, __USER32_DS  */		
	.quad	0x00affa000000ffff	/* __USER_CS */
	.word	0xFFFF				# 4Gb - (0x100000*0x1000 = 4Gb)
	.word	0				# base address = 0
	.word	0x9A00				# code read/exec
	.word	0x00CF				# granularity = 4096, 386
						#  (+5th nibble of limit)
					/* __KERNEL32_CS */
	/* when you add something here fix constant in desc.h */				
// 	.globl gdt_cpu_table
// gdt_cpu_table:	
// 	.fill 4*PER_CPU_GDT_SIZE,1,0
gdt_end:	
	.globl gdt_end

	.align  64
ENTRY(idt_table)	
	.rept   256
	.quad   0
	.quad 	0
	.endr		
