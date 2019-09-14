#!/bin/bash
for x in `ls -b group*.r`;
do
 echo $x
 sed -i 's/prob004_koza1/prob008_koza1_full_2adfs/g' $x
 sed -i 's/Koza1 /Koza1 Full 2adfs /g' $x
done;
