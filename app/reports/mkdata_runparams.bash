#!/bin/bash

rm -f ./runparams0.csv
rm -f ./runparams1.csv

./sqldroptablesrp.bash

./run_mktableau.bash

echo building runparams0.csv
mv -fv runparams0.csv runparams0.txt
nl -s, runparams0.txt > runparams0_b.csv
cat ./header_runparam0.txt > runparams0.csv
cat ./runparams0_b.csv >> runparams0.csv
rm -f ./runparams0_b.csv 
rm -f ./runparams0.txt


echo building runparams1.csv
mv -fv runparams1.csv runparams1.txt
nl -s, runparams1.txt > runparams1_b.csv
cat ./header_runparam1.txt > runparams1.csv
cat ./runparams1_b.csv >> runparams1.csv
rm -f ./runparams1_b.csv 
rm -f ./runparams1.txt
sed -i 's/NA//g' runparams1.csv


echo making sql data.db
./sqlcreaterunparams.bash
./run_reports_runparams0.bash
echo Done

