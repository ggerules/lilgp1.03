#!/bin/bash

./cln.sh
echo "Not Constrained"
rm -fR ../no_constraints
rm -fR ./acgp1p1p2_simple_trig_no_adf_qt.txt
cp -vf ./b3acgp1p1p2_simple_trig_no_adf_qt.txt ./acgp1p1p2_simple_trig_no_adf_qt.txt
./pr_run_all
mkdir -vp ../data/$c/no_constraints/tmp_w0
mkdir -vp ../data/$c/no_constraints/tmp_w1
mkdir -vp ../data/$c/no_constraints/tmp_w2
mkdir -vp ../data/$c/no_constraints/tmp_w3
rsync --progress -avth ./tmp_w0/ ../data/$c/no_constraints/tmp_w0/
rsync --progress -avth ./tmp_w1/ ../data/$c/no_constraints/tmp_w1/
rsync --progress -avth ./tmp_w2/ ../data/$c/no_constraints/tmp_w2/
rsync --progress -avth ./tmp_w3/ ../data/$c/no_constraints/tmp_w3/

