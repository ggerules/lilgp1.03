#!/bin/bash
echo "running ./cln.sh"
./cln.sh
echo "finished ./cln.sh"
exe=gp
pop=1000
maxgen=50
numindruns=100
echo "pop=$pop"
echo "maxgen=$maxgen"
echo "maxindruns=$numindruns"

./g0.sh $exe $pop $maxgen $numindruns $1
./g1.sh $exe $pop $maxgen $numindruns $1
./g2.sh $exe $pop $maxgen $numindruns $1
./g3.sh $exe $pop $maxgen $numindruns $1
