#!/bin/bash
for x in `find . -name "*.r"`;
do
 sed -i 's/Lawnmower 8x8 /Lawnmower 8x12 /g' $x
 sed -i 's/prob011_lawnmower_8x8/prob014_lawnmower_8x12/g' $x
done;

