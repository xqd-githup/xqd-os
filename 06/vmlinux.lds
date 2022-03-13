/* ld script to make x86-64 Linux kernel
 * Written by Martin Mares <mj@atrey.karlin.mff.cuni.cz>;
 */
OUTPUT_FORMAT("elf64-x86-64", "elf64-x86-64", "elf64-x86-64")
OUTPUT_ARCH(i386:x86-64)
ENTRY(_start)
SEARCH_DIR("=."); 
SECTIONS
{
  . = 0xffffffff80100000;
  _text = .;			/* Text and read-only data */
  .text : {
	*(.text)
	*(.fixup)
	*(.gnu.warning)
	} 
  .text.lock : { *(.text.lock) }	/* out-of-line lock text */

  _etext = .;			/* End of text section */

  .rodata : { *(.rodata) *(.rodata.*) }
  .kstrtab : { *(.kstrtab) }


  .data : {			/* Data */
	*(.data)
	}
  _edata = .;			/* End of data section */
. = ALIGN(32768);
  __bss_start = .;		/* BSS */
  .bss : {
	*(.bss)
	}
  __bss_end = .;

  .comment 0 : { *(.comment) }
}
