#!/bin/bash
for x in `ls -b *.bind`;
do 
  b=".bind"
  d=".dat"
  l="lush2"
  s=" "
  f=`basename -s.bind $x`
  #echo $l$s$f$b$s$f$d
  `$l$s$f$b$s$f$d`
done;
