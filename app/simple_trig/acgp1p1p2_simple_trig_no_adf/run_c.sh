#!/bin/bash
./cln.sh

echo "Constrained"
rm -fR ./tmp_w0
rm -fR ./tmp_w1
rm -fR ./tmp_w2
rm -fR ./tmp_w3
./mkd_tmp
rm -fR ../constraints
rm -fR ./acgp1p1p2_simple_trig_no_adf_qt.txt
cp -vf ./b1acgp1p1p2_simple_trig_no_adf_qt.txt ./acgp1p1p2_simple_trig_no_adf_qt.txt
./pr_run_all
mkdir -p ../constraints
mkdir -p ../constraints/tmp_w0
mkdir -p ../constraints/tmp_w1
mkdir -p ../constraints/tmp_w2
mkdir -p ../constraints/tmp_w3
rsync --progress -avth ./tmp_w0/ ../constraints/tmp_w0/
rsync --progress -avth ./tmp_w1/ ../constraints/tmp_w1/
rsync --progress -avth ./tmp_w2/ ../constraints/tmp_w2/
rsync --progress -avth ./tmp_w3/ ../constraints/tmp_w3/
