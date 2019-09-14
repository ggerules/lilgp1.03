#!/bin/bash
for x in `find . -name "*.r"`;
do
 sed -i 's/prob009_koza1_full/prob010_koza3_full/g' $x
 sed -i 's/Koza2 /Koza3 /g' $x
done;
