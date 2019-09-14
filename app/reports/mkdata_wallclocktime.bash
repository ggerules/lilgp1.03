#!/bin/bash

rm -f ./wallclocktimes.csv
rm -f ./wallclocktimes_b.csv 
rm -f ./wallclocktimes.txt

./sqldroptableswc.bash

./run_mkwallcocktime.r

#echo building wallcocktimes.csv
mv -fv wallclocktimes.csv wallclocktimes.txt
nl -s, wallclocktimes.txt > wallclocktimes_b.csv
cat ./header_wallclocktimes.txt > wallclocktimes.csv
cat ./wallclocktimes_b.csv >> wallclocktimes.csv
rm -f ./wallclocktimes_b.csv 
rm -f ./wallclocktimes.txt
sed -i 's/:/,/g' wallclocktimes.csv
sed -i 's/\./,/g' wallclocktimes.csv

#echo making sql data.db
./sqlcreatewallclocktimes.bash
./run_reports_wallclocktime.r
#echo Done

