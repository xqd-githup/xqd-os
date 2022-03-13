#include <vga.h>
#include <kernel.h>
void start_kernel()
{
	for( int i = 0 ; i < VGA.width*VGA.height ; i ++)
	{
		int r = i / VGA.width * 63 / VGA.width + 192;
		int g = i % VGA.width * 63 / VGA.width + 192;
		* ( VGA.addr + i ) = (r<<16) + (g << 8) + 224;
	}
	printStr( 0xff,   "\n\n\t\tHello  Xqd-os\n");
	printStr( 0xff,"\t\tÄãºÃ°¡");

	while( 1 ) ;
}