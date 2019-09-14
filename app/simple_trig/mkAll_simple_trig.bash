#!/bin/bash

for y in `find . -name "GNUmakefile" | grep trig | sort -r`;
do
  b=`dirname $y`
  a="make -j -C "
  x="$PWD/$b"
  z=$a$x
  echo $z
  $z
done;
echo Done!

