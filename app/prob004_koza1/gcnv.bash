#!/bin/bash
for x in `ls -b group*.r`;
do
 echo $x
 sed -i 's/prob003_tb/prob004_koza1/g' $x
 sed -i 's/Two Box /Koza1 /g' $x
done;
