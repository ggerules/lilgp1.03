#!/bin/bash
for x in `find . -name "*.r"`;
do
 sed -i 's/Lawnmower 8x8 /Lawnmower 8x10 /g' $x
 sed -i 's/prob011_lawnmower_8x8/prob013_lawnmower_8x10/g' $x
done;

