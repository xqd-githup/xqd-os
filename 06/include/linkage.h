#ifndef _LINUX_LINKAGE_H
#define _LINUX_LINKAGE_H


#define SYMBOL_NAME(X) X
#ifdef __STDC__
#define SYMBOL_NAME_LABEL(X) X##:
#else
#define SYMBOL_NAME_LABEL(X) X/**/:
#endif

#define __ALIGN .align 16,0x90
#define __ALIGN_STR ".align 16,0x90"

#define ALIGN __ALIGN
#define ALIGN_STR __ALIGN_STR

#define ENTRY(name) \
  .globl SYMBOL_NAME(name); \
  ALIGN; \
  SYMBOL_NAME_LABEL(name)


#endif
