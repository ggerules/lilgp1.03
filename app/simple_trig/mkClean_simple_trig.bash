#!/bin/bash

for y in `find . -name "GNUmakefile" | grep trig | sort -r`;
do
  b=`dirname $y`
  e=" clean"
  a="make -j -C "
  x="$PWD/$b"
  z=$a$x$e
  echo $z
  $z
done;
find . -name "gp" -delete
echo Done!

