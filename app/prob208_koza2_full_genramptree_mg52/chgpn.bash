#!/bin/bash
for x in `find . -name "*.r"`;
do
 sed -i 's/prob005_koza1_full/prob009_koza2_full/g' $x
 sed -i 's/Koza1 /Koza2 /g' $x
done;
