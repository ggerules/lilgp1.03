#!/bin/bash
./cln.sh

d=`basename $PWD`
e="_tmp"
c="$d$e"
echo $c
rm -fR ../data/$c

echo "Constrained"
rm -fR ../constraints
rm -fR ./interface.file
cp -vf ./b1interface.file ./interface.file
./pr_run_all
mkdir -vp ../data/$c/constraints/tmp_w0
mkdir -vp ../data/$c/constraints/tmp_w1
mkdir -vp ../data/$c/constraints/tmp_w2
mkdir -vp ../data/$c/constraints/tmp_w3
rsync --progress -avth ./tmp_w0/ ../data/$c/constraints/tmp_w0/
rsync --progress -avth ./tmp_w1/ ../data/$c/constraints/tmp_w1/
rsync --progress -avth ./tmp_w2/ ../data/$c/constraints/tmp_w2/
rsync --progress -avth ./tmp_w3/ ../data/$c/constraints/tmp_w3/

