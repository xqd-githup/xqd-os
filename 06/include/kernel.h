#include <stdarg.h>
#ifndef __KERNEL_H
#define __KERNEL_H

extern int sprintf(char * buf, const char * fmt, ...)
	__attribute__ ((format (printf, 2, 3)));
extern int vsprintf(char *buf, const char *, va_list)
	__attribute__ ((format (printf, 2, 0)));

#endif
	