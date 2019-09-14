#!/bin/bash

my_func() {
frmwrk=5
prblm=0
wadf=0
adf=0
useConst=$6
acgpwhat=0
#$frmwrk-$prblm-{1}-$wadf-$adf-$acgpwhat-$maxdepth
./gp -p pop_size=$3 -p max_generations=$4  -p random_seed=$1 -p acgp.what=0 -p max_depth=$2 -p output.basename=tmp_w0/$frmwrk-$prblm-$1-$wadf-$adf-$useConst-$acgpwhat-$2 -f input.file < acgp1p1p2_simple_trig_no_adf_qt.txt
}
export -f my_func

#parallel my_func ::: 1 2 3 4 5 6
time parallel --eta -j 8  --colsep ' ' my_func $1 $2 $3 $4 $5 $6 :::: rfile
cd ./tmp_w0/
fh | sort | uniq > ./hits.txt
sed -i 's/hits://g' ./hits.txt
sed -i 's/\.bst//g' ./hits.txt
sed -i 's/:/,/g'    ./hits.txt
sed -i 's/-/,/g'    ./hits.txt


