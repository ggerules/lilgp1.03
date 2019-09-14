#!/bin/bash
find . -name "GNUmakefile" -exec grep -nH "CFLAGS =" "{}" \; | sort -r

