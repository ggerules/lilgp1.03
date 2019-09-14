#!/bin/bash

echo "making initial directory scripts and directories"
autogen -T mkDirs.tpl --writable -b mkDirs info.def
chmod 700 mkDirs.bash
echo "making dirs"
./mkDirs.bash
autogen -T rmvDirs.tpl --writable -b rmvDirs info.def
chmod 700 rmvDirs.bash
#./rmvDirs.bash

echo "making GNUmakefiles"
autogen -T gnumakefile.tpl --writable info.def > GNUmakefile
awk '{print $0 " -|"> "GNUmakefile" NR}' RS='-\\|' GNUmakefile
rm GNUmakefile
for x in `ls -b GNUmakefile*`;
do
  sed -i 's/-|//g' $x
done;
autogen -T cpymakefile.tpl --writable -b cpymakefile info.def  
chmod 700 ./cpymakefile.bash
./cpymakefile.bash
rm -fR cpymakefile.bash
rm -fR GNUmakefile*

echo "making appdef.h files"
autogen -T appdef.tpl -o h --writable -b appdef info.def  
autogen -T cpyappdef.tpl -o bashh --writable -b cpyappdef info.def  
chmod 700 ./cpyappdef.bashh
./cpyappdef.bashh
rm -fR cpyappdef.bashh
rm -fR appdef.h

autogen -T appdef.tpl -o adf --writable -b appdef info.def  
autogen -T cpyappdef.tpl -o bashadf --writable -b cpyappdef info.def  
chmod 700 ./cpyappdef.bashadf
./cpyappdef.bashadf
rm -fR cpyappdef.bashadf
rm -fR appdef.adf
#cp appdef.adf appdef.adf.h

echo "making function.h function.c files"
autogen -T function.tpl -o h --writable -b function info.def  
autogen -T function.tpl -o c --writable -b function info.def  
autogen -T cpyfunction.tpl --writable -b cpyfunction info.def  
chmod 700 ./cpyfunction.bash
./cpyfunction.bash
rm -fR cpyfunction.bash
rm -fR function.h function.c

echo "making app.h files"
autogen -T app.tpl -o h --writable -b app info.def  
autogen -T cpyapp.tpl -o bashh --writable -b cpyapp info.def  
chmod 700 ./cpyapp.bashh
./cpyapp.bashh
rm -fR cpyapp.bashh
rm -fR app.h

echo "making app.c files"
autogen -T app.tpl -o c --writable -b app info.def  
autogen -T cpyapp.tpl -o bashc --writable -b cpyapp info.def  
chmod 700 ./cpyapp.bashc
./cpyapp.bashc
rm -fR cpyapp.bashc
rm -fR app.c

autogen -T app.tpl -o adf --writable -b app info.def  
autogen -T cpyapp.tpl -o bashadf --writable -b cpyapp info.def  
chmod 700 ./cpyapp.bashadf
./cpyapp.bashadf
rm -fR cpyapp.bashadf
rm -fR app.adf

echo "making makeall.bash"
autogen -T makeall.tpl --writable -b makeall info.def  
chmod 700 ./makeall.bash
#./makeall.bash

echo "making makeclean.bash"
autogen -T makeclean.tpl --writable -b makeclean info.def  
chmod 700 ./makeclean.bash

echo "making input.files"
autogen -T inputfile.tpl --writable info.def > Inputfile 
awk '{print $0 " -|"> "Inputfile" NR}' RS='-\\|' Inputfile 
rm Inputfile
for x in `ls -b Inputfile*`;
do
  sed -i 's/-|//g' $x
done;
autogen -T cpyinputfile.tpl --writable -b cpyinputfile info.def  
chmod 700 ./cpyinputfile.bash
./cpyinputfile.bash
rm -fR cpyinputfile.bash
rm -fR Inputfile*

echo "making cln.sh scripts"
autogen -T cln.tpl -o sh --writable -b cln info.def  
chmod 700 ./cln.sh
autogen -T cpycln.tpl -o sh --writable -b cpycln info.def  
chmod 700 ./cpycln.sh
./cpycln.sh
rm -fR cpycln.sh
#rm -fR cln.sh

echo "making run.sh scripts"
autogen -T run.tpl --writable info.def > Run 
awk '{print $0 " -|"> "Run" NR}' RS='-\\|' Run
rm Run 
for x in `ls -b Run*`;
do
  sed -i 's/-|//g' $x
done;
autogen -T cpyrun.tpl --writable -b cpyrun info.def  
chmod 700 ./cpyrun.bash
./cpyrun.bash
rm -fR cpyrun.bash
rm -fR Run*

echo "making runprob script" 
autogen -T runprob.tpl --writable -b runprob info.def
chmod 700 runprob.bash

echo "making interface.files"
autogen -T interfacefile.tpl --writable info.def > Interfacefile
awk '{print $0 " -|"> "Interfacefile" NR}' RS='-\\|' Interfacefile
rm Interfacefile
for x in `ls -b Interfacefile*`;
do
  sed -i 's/-|//g' $x
done;
autogen -T cpyinterfacefile.tpl --writable -b cpyinterfacefile info.def  
chmod 700 ./cpyinterfacefile.bash
./cpyinterfacefile.bash
rm -fR cpyinterfacefile.bash
rm -fR Interfacefile*

echo "making acgp1p1p2_cli_input files"
autogen -T acgp1p1p2_cli_input.tpl -o txtnc --writable -b acgp1p1p2_cli_input info.def  
autogen -T cpyacgp1p1p2_cli_input.tpl -o bashnc --writable -b cpyacgp1p1p2_cli_input info.def  
chmod 700 ./cpyacgp1p1p2_cli_input.bashnc
./cpyacgp1p1p2_cli_input.bashnc
rm -fR cpyacgp1p1p2_cli_input.bashnc
rm -fR acgp1p1p2_cli_input.txtnc

autogen -T acgp1p1p2_cli_input.tpl -o txtyc --writable -b acgp1p1p2_cli_input info.def  
autogen -T cpyacgp1p1p2_cli_input.tpl -o bashyc --writable -b cpyacgp1p1p2_cli_input info.def  
chmod 700 ./cpyacgp1p1p2_cli_input.bashyc
./cpyacgp1p1p2_cli_input.bashyc
rm -fR cpyacgp1p1p2_cli_input.bashyc
rm -fR acgp1p1p2_cli_input.txtyc

echo "making checkhits files"
autogen -T checkhits.tpl -o lsh --writable -b checkhits info.def  
autogen -T cpycheckhits.tpl -o sh --writable -b cpycheckhits info.def  
chmod 700 ./cpycheckhits.sh
./cpycheckhits.sh
rm -fR ./cpycheckhits.sh
rm -fR ./checkhits.sh

echo "making adfused files"
autogen -T adfused.tpl -o lsh --writable -b adfused info.def  
autogen -T cpyadfused.tpl -o sh --writable -b cpyadfused info.def  
chmod 700 ./cpyadfused.sh
./cpyadfused.sh
rm -fR ./cpyadfused.sh
rm -fR ./adfused.sh

echo "making runcheckhits script" 
autogen -T runcheckhits.tpl --writable -b runcheckhits info.def
chmod 700 runcheckhits.bash

./makeclean.bash
./makeall.bash
./runprob.bash

