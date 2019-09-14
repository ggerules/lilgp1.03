#!/bin/bash
for x in `find . -name "*.r"`;
do
 sed -i 's/Lawnmower 8x12 /Lawnmower 50x50 /g' $x
 sed -i 's/prob014_lawnmower_8x12/prob015_lawnmower_50x50/g' $x
done;

