#!/bin/bash
rm *.pdf
rm -f stats_hits_long.r
rm -f stats_stt_long.r

echo "making stats R scripts"
#autogen -T header_hits_long.tpl --writable -b header_hits_long info.def 
#cp -vf header_hits_long.txt 
#lush mkbeststatslong.lsh
#autogen -T stats_hits_long.tpl --writable -b stats_hits_long info.def 

#Rscript stats_hits_long.r

#autogen -T header_stt_long.tpl --writable -b header_stt_long info.def 
#cp -vf header_stt_long.txt  
#./mksttlong.bash

#lush ./checkmksttlong.lsh

# Feb 2018 version of long stats reports

autogen -T stats_stt_long2.tpl --writable -b stats_stt_long2 info.def 

Rscript stats_stt_long2.r

# Dec 2017 version of stats reports
# not effective at end of december meeting
#autogen -T stats_stt_long.tpl --writable -b stats_stt_long info.def 
#
#Rscript stats_stt_long.r

cd ./plots

f=`ls -tr -b a*.pdf`
pdfunite $f ../meanstdfitbestofgeninds.pdf

#f=`ls -tr -b b*.pdf`
#pdfunite $f ../meanstdfitofrun.pdf
#
#f=`ls -tr -b c*.pdf`
#pdfunite $f ../stdfitbestindofgen.pdf
#
#f=`ls -tr -b d*.pdf`
#pdfunite $f ../stdfitbestindofrun.pdf
#
#f=`ls -tr -b e*.pdf`
#pdfunite $f ../treesizebestofgenind.pdf
#
#f=`ls -tr -b f*.pdf`
#pdfunite $f ../treedepthbestofgenind.pdf
#
#f=`ls -tr -b g*.pdf`
#pdfunite $f ../treesizeworstofgenind.pdf
#
#f=`ls -tr -b h*.pdf`
#pdfunite $f ../treedepthworstofgenind.pdf

f=`ls -tr -b i*.pdf`
pdfunite $f ../treesizebestofrunind.pdf

f=`ls -tr -b j*.pdf`
pdfunite $f ../treedepthbestofrunind.pdf

f=`ls -tr -b k*.pdf`
pdfunite $f ../treesizeworstofrunind.pdf

f=`ls -tr -b l*.pdf`
pdfunite $f ../treedepthworstofrunind.pdf

rm *.pdf
cd ..

./rungroupreports.bash
