#!/bin/bash
for x in `ls -b group*.r`;
do
 echo $x
# sed -i 's/prob004_koza1/prob005_koza1_full/g' $x
 sed -i 's/Koza1 /Koza1 Full /g' $x
done;
