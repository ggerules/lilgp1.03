#!/bin/bash
for x in `find . -name "*.r"`;
do
 sed -i 's/prob005_koza1_full/prob008_koza1_full_2adfs/g' $x
done;
