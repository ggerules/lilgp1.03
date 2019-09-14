
#
# GNU makefile, application portion.
#
# "make" or "make all" to build executable.
# "make clean" to delete object code.
#
#dirname=orig_ywadf_yadf_ntypes_ncons_nwhatn

#KERNELDIR = ../../kernel_orig
KERNELDIR = ../../kernel.acgpf2.1

CC = gcc
CFLAGS = -Ofast -fstack-check -fsanitize=bounds -fsanitize=undefined 
#CFLAGS = -O3 -fsanitize=bounds -fsanitize=undefined 
#CFLAGS = -O2 -march=native -fsanitize=bounds -fsanitize=undefined 
#CFLAGS = -g -fsanitize=bounds -fsanitize=undefined 

TARGET = gp

uobjects = function.o app.o
uheaders = appdef.h app.h function.h

include $(KERNELDIR)/GNUmakefile.kernel
 
