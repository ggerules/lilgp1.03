#!/bin/bash

constrained=0
b=`basename $PWD`
echo $b
rm -fR ../data/$b
./pr_run_all.sh $constrained
mkdir -p ../data/$b/tmp
rsync --progress -avth ./tmp/ ../data/$b/tmp/


