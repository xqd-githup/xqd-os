#ifndef VGA_H
#define VGA_H

// 界面显示信息
struct vga{
	int width;
	int height;
	int *addr;
}    ;
extern struct vga VGA;
// 字体， 8 * 16 的ascii的字体
extern unsigned char fontdata[];
// 显示单个字符
extern void putchar(unsigned int color, int x,int y,unsigned char ascii);
// 显示字符串
extern void printStr( unsigned int color, const char * str );
#endif