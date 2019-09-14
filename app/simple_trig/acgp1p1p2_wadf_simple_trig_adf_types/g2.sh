#!/bin/bash

frmwrk=7
prblm=0
wadf=1
adf=1
useConst=$5
acgpwhat=2
maxdepth=7
seq 1 $4 | parallel -j 8 -eta ./$1 -p pop_size=$2  -p max_generations=$3  -p random_seed={1} -p app.use_ercs=0 -p app.save_pop=0 -p acgp.what=2 -p max_depth=$maxdepth -p output.basename=tmp_w2/$frmwrk-$prblm-{1}-$wadf-$adf-$useConst-$acgpwhat-$maxdepth -f input_w2.file
cd ./tmp_w2
fh | sort | uniq > ./hits.txt
sed -i 's/hits://g' ./hits.txt
sed -i 's/\.bst//g' ./hits.txt
sed -i 's/:/,/g'    ./hits.txt
sed -i 's/-/,/g'    ./hits.txt

