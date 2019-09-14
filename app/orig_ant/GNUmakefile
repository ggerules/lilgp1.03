#
# GNU makefile, application portion.
#
# "make" or "make all" to build executable.
# "make clean" to delete object code.
#
# some users have reported a "high performance arithmetic trap" on DEC Alphas
# and on LINUX.  if you get this, try adding "-DTOLERANCE_ZERO" to CFLAGS --
# it apparently works on Alphas; don't know about Linux.
#

KERNELDIR = ../../kernel_orig
CC = gcc
#CFLAGS = -O2 -DTOLERANCE_ZERO
#CFLAGS = -O3 -DTOLERANCE_ZERO
#CFLAGS = -O2 -DDEBUG_EVAL
#CFLAGS = -O2 -DDEBUG
CFLAGS = -O3
#CFLAGS = -g
TARGET = gp

uobjects = function.o app.o
uheaders = appdef.h app.h function.h

include $(KERNELDIR)/GNUmakefile.kernel
