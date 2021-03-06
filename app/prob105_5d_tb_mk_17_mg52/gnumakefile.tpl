[+ AutoGen5 template +]
[+ FOR objlst +][+IF (exist? "kname")+]
#
# GNU makefile, application portion.
#
# "make" or "make all" to build executable.
# "make clean" to delete object code.
#
#dirname=[+dirname+]

KERNELDIR = ../../../[+kname+]
CC = gcc
#note -lubsan is added as link library in kernel, for bounds checking
CFLAGS = -O2 -fsanitize=bounds -fsanitize=undefined 
#CFLAGS = -g -fsanitize=bounds -fsanitize=undefined 
TARGET = gp

uobjects = function.o app.o
uheaders = appdef.h app.h function.h

include $(KERNELDIR)/GNUmakefile.kernel
-|[+ENDIF+][+ ENDFOR +]
