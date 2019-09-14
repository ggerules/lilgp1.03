#!/bin/bash
echo "running ./cln.sh"
./cln.sh
echo "finished ./cln.sh"
echo "create rfile"
./create_rfile.sh $1
echo "./g0_sh" 
./g0.sh 
echo "./g1_sh"
./g1.sh 
echo "./g2_sh"
./g2.sh 
echo "./g3_sh" 
./g3.sh 
