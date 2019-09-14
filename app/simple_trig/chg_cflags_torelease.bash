#!/bin/bash

#CFLAGS = -g
#CFLAGS = -g
#CFLAGS = -O2
#CFLAGS = -O2
#CFLAGS = -O2 -DDEBUG
#CFLAGS = -O2 -DDEBUG_EVAL
#CFLAGS = -O2 -DTOLERANCE_ZERO
#CFLAGS = -O3 -DTOLERANCE_ZERO

find . -name "GNUmakefile" -exec sed -i 's/CFLAGS = -g/CFLAGS = -O2/g' "{}" \;
find . -name "GNUmakefile" -exec grep -nH "CFLAGS =" "{}" \; | sort -r
