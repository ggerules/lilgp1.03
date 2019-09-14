#!/bin/bash
frmwrk=5
maxdepth=7
pop=1000
maxgen=50
numindruns=100
useConst=$1

#file prefix format
#$frmwrk-$prblm-{1}-$wadf-$adf-$acgpwhat-$maxdepth

rm rfile
for x in `seq 1 $numindruns`;
do
  #maxdepth
  #for y in {4..15};
  for y in {7..7};
  do
    echo $x " " $y " " $pop " " $maxgen " " $frmwrk " " $useConst >> rfile
  done;
done;
