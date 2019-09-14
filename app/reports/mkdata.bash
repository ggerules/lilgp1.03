#!/bin/bash
#reports version of mksttlong
pd=$PWD

rm -vr ./data.db

echo making evaltimelong.csv
rm -vf ./evaltimelong.txt
rm -vf ./evaltimelong.csv

cd ../mg50/
 rm -vf ./evaltimelong.csv
 lush ./mkevaltimelong.lsh
cd ../mg52/
 rm -vf ./evaltimelong.csv
 lush ./mkevaltimelong.lsh
cd ../mg104/
 rm -vf ./evaltimelong.csv
 lush ./mkevaltimelong.lsh
cd ../mg156/
 rm -vf ./evaltimelong.csv
 lush ./mkevaltimelong.lsh
cd ../mg208/
 rm -vf ./evaltimelong.csv
 lush ./mkevaltimelong.lsh
cd ../reports/

cat ../mg50/evaltimelong.csv > evaltimelong.txt
cat ../mg52/evaltimelong.csv >> evaltimelong.txt
cat ../mg104/evaltimelong.csv >> evaltimelong.txt
cat ../mg156/evaltimelong.csv >> evaltimelong.txt
cat ../mg208/evaltimelong.csv >> evaltimelong.txt
#cat ../mg500/evaltimelong.csv >> evaltimelong.txt

echo "Numbering Lines"
#number lines
nl -s, evaltimelong.txt > evaltimelong_b.csv

#put header at top of csv
cat header_evaltime_long.txt > evaltimelong.csv

echo "Building records part 1"
#put in records
cat evaltimelong_b.csv >> evaltimelong.csv
echo "Building records part 2"
sed -i 's/-/,/g' evaltimelong.csv
sed -i 's/,,/,/g' evaltimelong.csv

#cleanup
rm -f evaltimelong_b.csv
#rm -f evaltimelong.txt


echo making sttlong.csv
rm -vf ./sttlong.csv
rm -vf ./sttlong.txt
rm -vf ./sttlong_b.csv
rm -vf ./sttlong_tmp.txt
rm -vr ./beststatslong.csv
rm -vr ./beststatslong.txt

cd ../mg50/
 rm -vf ./sttlong_d2.txt
 ./mksttlong.bash
cd ../mg52/
 rm -vf ./sttlong_d2.txt
 ./mksttlong.bash
cd ../mg104/
 rm -vf ./sttlong_d2.txt
 ./mksttlong.bash
cd ../mg156/
 rm -vf ./sttlong_d2.txt
 ./mksttlong.bash
cd ../mg208/
 rm -vf ./sttlong_d2.txt
 ./mksttlong.bash
cd ../reports/

cat ../mg50/sttlong_d2.txt > sttlong_tmp.txt
cat ../mg52/sttlong_d2.txt >> sttlong_tmp.txt
cat ../mg104/sttlong_d2.txt >> sttlong_tmp.txt
cat ../mg156/sttlong_d2.txt >> sttlong_tmp.txt
cat ../mg208/sttlong_d2.txt >> sttlong_tmp.txt
#cat ../mg500/sttlong_d2.txt >> sttlong_tmp.txt

echo "Numbering Lines"
#number lines
nl -s, sttlong_tmp.txt > sttlong_b.csv

#put header at top of csv
cat header_stt_long.txt > sttlong.csv

echo "Building records part 1"
#put in records
cat sttlong_b.csv >> sttlong.csv
echo "Building records part 2"
sed -i 's/-/,/g' sttlong.csv
sed -i 's/,,/,/g' sttlong.csv

#cleanup
rm -f sttlong_b.csv
rm -f sttlong_tmp.txt

echo making beststatslong.csv
cd  ../mg50/
lush ./mkbeststatslong.lsh
cd  ../mg52/
lush ./mkbeststatslong.lsh
cd  ../mg104/
lush ./mkbeststatslong.lsh
cd  ../mg156/
lush ./mkbeststatslong.lsh
cd  ../mg208/
lush ./mkbeststatslong.lsh
cd ../reports

#beststatslong.csv
cat ./header_beststats_long.txt > beststatslong.csv
cat ../mg50/beststatslong.csv > beststatslong.txt
cat ../mg52/beststatslong.csv >> beststatslong.txt
cat ../mg104/beststatslong.csv >> beststatslong.txt
cat ../mg156/beststatslong.csv >> beststatslong.txt
cat ../mg208/beststatslong.csv >> beststatslong.txt
nl -s, beststatslong.txt >> beststatslong.csv

echo makeing runparams

rm -f ./runparams0.csv
rm -f ./runparams1.csv

./run_mktableau.r

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
./sqlcreatedata.bash

echo making reports
./run_reports_bofrs.r
./run_reports_runparams0.r
./run_reports_bofrs_shapiro_testofnorm.r
./run_reports_wilcox_stats.r
./run_reports_evaltime.r
./run_reports_hyp.r
./run_reports_gr_hyp.r
./run_reports_stt.r

echo making wall clock time data and reports
./mkdata_wallclocktime.bash


echo Done!
