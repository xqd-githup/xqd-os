#include "vga.h"

struct vga   VGA = {
	.width = 1440,
	.height = 900,
	.addr = (int*)0xffffffff82800000
};

static int current_xpos=0, current_ypos = 0, font_x= 8, font_y = 16;

// color:RGB颜色   x,y显示的坐标  ascii：ascii字符
void putchar(unsigned int color, int x,int y,unsigned char ascii)
{
	for(int i = 0; i< 16;i++)
	{
		// 该字符在显存中起始地址
		int * addr = VGA.addr + VGA.width * ( y + i ) + x;
		// 用于对比每一位
		int testval = 0x100;
		// 第i行的点阵
		unsigned char font_i = fontdata[ascii*16+i];
		for(int j = 0;j < 8;j ++)		
		{
			testval = testval >> 1;
			if( font_i & testval)
				*addr = color;
			addr ++ ;
		}
	}
}
void printStr( unsigned int color, const char * str ){

	char c;
	// int  i, k, j;

	while ((c = *str++) != '\0' ) {
		// if (current_ypos >= VGA.height) {
		// 	/* scroll 1 line up */
		// 	// for( j = 1 ; j < VGA.height; j ++ )
		// 	// 	for(i = 0; i < VGA.width; i++) {
		// 	// 		*(VGA.addr + (j-1) * VGA.width + i ) = *(VGA.addr + (j) * VGA.width + i );
		// 	// 	}
			

		// 	// for(i = 0; i < MAX_XPOS; i++) {
		// 	// 	int r = i / VGA.width * 63 / VGA.width + 192;
		// 	// 	int g = i % VGA.width * 63 / VGA.width + 192;

		// 	// 	*(VGA.addr + (VGA.height-1) * VGA.width + i ) = (r<<16) + (g << 8) + 224;
		// 	// }
		// 	current_ypos = VGA.height-1;
		// }
		if (c == '\n') {
			current_xpos = 0;
			current_ypos+= font_y;
		} else if( c == '\t'){
			current_xpos += font_x * 4 ;
		} else if (c != '\r')  {
			putchar( color, current_xpos, current_ypos, c ); 
			current_xpos += font_x;
		}
		if (current_xpos >= VGA.width ) {
			current_xpos = 0;
			current_ypos+=font_y;
		}
	}

}