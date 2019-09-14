#!/bin/bash
./cln.sh

b=`basename $PWD`
echo $b
rm -fR ../data/$b

echo "Constrained"
constrained=2
rm -fR ../constraints
rm -fR ./acgp1p1p2_simple_trig_no_adf_qt.txt
cp -vf ./b1acgp1p1p2_simple_trig_no_adf_qt.txt ./acgp1p1p2_simple_trig_no_adf_qt.txt
./pr_run_all.sh $constrained
mkdir -vp ../data/$b/constraints/tmp_w0
mkdir -vp ../data/$b/constraints/tmp_w1
mkdir -vp ../data/$b/constraints/tmp_w2
mkdir -vp ../data/$b/constraints/tmp_w3
rsync --progress -avth ./tmp_w0/ ../data/$b/constraints/tmp_w0/
rsync --progress -avth ./tmp_w1/ ../data/$b/constraints/tmp_w1/
rsync --progress -avth ./tmp_w2/ ../data/$b/constraints/tmp_w2/
rsync --progress -avth ./tmp_w3/ ../data/$b/constraints/tmp_w3/

./cln.sh
echo "Not Constrained"
rm -fR ../no_constraints
rm -fR ./acgp1p1p2_simple_trig_no_adf_qt.txt
cp -vf ./b3acgp1p1p2_simple_trig_no_adf_qt.txt ./acgp1p1p2_simple_trig_no_adf_qt.txt
constrained=1
./pr_run_all.sh $constrained
mkdir -vp ../data/$b/no_constraints/tmp_w0
mkdir -vp ../data/$b/no_constraints/tmp_w1
mkdir -vp ../data/$b/no_constraints/tmp_w2
mkdir -vp ../data/$b/no_constraints/tmp_w3
rsync --progress -avth ./tmp_w0/ ../data/$b/no_constraints/tmp_w0/
rsync --progress -avth ./tmp_w1/ ../data/$b/no_constraints/tmp_w1/
rsync --progress -avth ./tmp_w2/ ../data/$b/no_constraints/tmp_w2/
rsync --progress -avth ./tmp_w3/ ../data/$b/no_constraints/tmp_w3/

