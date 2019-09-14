#!/bin/bash
./cln.sh

echo "Not Constrained"
rm -fR ./tmp_w0
rm -fR ./tmp_w1
rm -fR ./tmp_w2
rm -fR ./tmp_w3
./mkd_tmp
rm -fR ../no_constraints
rm -fR ./acgp1p1p2_simple_trig_no_adf_qt.txt
cp -vf ./b3acgp1p1p2_simple_trig_no_adf_qt.txt ./acgp1p1p2_simple_trig_no_adf_qt.txt
./pr_run_all
mkdir -p ../no_constraints
mkdir -p ../no_constraints/tmp_w0
mkdir -p ../no_constraints/tmp_w1
mkdir -p ../no_constraints/tmp_w2
mkdir -p ../no_constraints/tmp_w3
rsync --progress -avth ./tmp_w0/ ../no_constraints/tmp_w0/
rsync --progress -avth ./tmp_w1/ ../no_constraints/tmp_w1/
rsync --progress -avth ./tmp_w2/ ../no_constraints/tmp_w2/
rsync --progress -avth ./tmp_w3/ ../no_constraints/tmp_w3/
