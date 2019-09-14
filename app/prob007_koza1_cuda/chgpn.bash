#!/bin/bash
for x in `find . -name "*.r"`;
do
 sed -i 's/prob004_koza1/prob007_koza1_cuda/g' $x
done;
