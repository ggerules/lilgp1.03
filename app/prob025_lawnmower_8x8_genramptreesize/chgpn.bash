#!/bin/bash
for x in `find . -name "*.r"`;
do
 sed -i 's/Koza1 Full 2adfs /Lawnmower 8x8 /g' $x
 sed -i 's/prob008_koza1_full_2adfs/prob011_lawnmower_8x8/g' $x
done;

