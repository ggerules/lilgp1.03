#!/bin/bash
./cln.sh

b=`basename $PWD`
echo $b
rm -fR ../data/$b

echo "Constrained"
constrained=2
rm -fR ./interface.file
cp -vf ./b1interface.file ./interface.file
./pr_run_all.sh $constrained
mkdir -vp ../data/$b/constraints/tmp
rsync --progress -avth ./tmp/ ../data/$b/constraints/tmp/

./cln.sh
echo "Not Constrained"
constrained=1
rm -fR ./interface.file
cp -vf ./b3interface.file ./interface.file
./pr_run_all.sh $constrained
mkdir -vp ../data/$b/no_constraints/tmp
rsync --progress -avth ./tmp/ ../data/$b/no_constraints/tmp/

