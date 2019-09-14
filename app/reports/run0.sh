#!/bin/bash
#f2pnv <- argv$pnum
#f1wadfv <- "y"
#f1adfv <- "n"
#f1kerp1v <- "0"
#f1typesv <- "n"
#f1consv <- "n"
#f1acgpwhatv <- "n"

#f2pnv <- argv$pnum
#f2wadfv <- "y"
#f2adfv <- "y"
#f2kerp1v <- "4"
#f2typesv <- "n"
#f2consv <- "n"
#f2acgpwhatv <- "3"


#./prob003_tb
#./prob005_koza1_full
#./prob008_koza1_full_2adfs
#./prob011_lawnmower_8x8_md_17
#./prob012_lawnmower_8x4_md_17
#./prob013_lawnmower_8x10_md_17
#./prob014_lawnmower_8x12_md_17
#./prob023_lawnmower_25x25_md_17  
#./prob024_lawnmower_25x25_genramptree
#./prob015_lawnmower_50x50_md_17  
#./prob016_lawnmower_50x50_genramptreesize
#./prob030_bumblebee_10f_md_17
#./prob031_bumblebee_10f_genramptree
#./prob032_bumblebee_15f_md_17
#./prob033_bumblebee_15f_genramptree
#./prob034_bumblebee_20f_md_17
#./prob035_bumblebee_20f_genramptree
#./prob036_bumblebee_25f_md_17

#./prob037_bumblebee_25f_genramptree
#./run_wilcox_stats.sh n "p37 hyp: orig no adfs less hits than orig with adfs" 37 0 y n n n n 0 y y n n 3
#./run_wilcox_stats.sh n "p37 hyp: orig no adfs less hits than cgp2.1 no types no const " 37 0 y n n n n 1 n n n n n
#./run_wilcox_stats.sh n "p37 hyp: orig no adfs less hits than cgp2.1 no types with const " 37 0 y n n n n 1 n n n y n
#./run_wilcox_stats.sh n "p37 hyp: orig no adfs less hits than cgp2.1 with types no const " 37 0 y n n n n 1 n n y n n
#./run_wilcox_stats.sh n "p37 hyp: orig no adfs less hits than cgp2.1 with types with const " 37 0 y n n n n 1 n n y y n
#./run_wilcox_stats.sh n "p37 hyp: cgp2.1 no types no const less hits than acgp1.1.2 what=0 " 37 1 n n n n n 2 n n n n 0
#./run_wilcox_stats.sh n "p37 hyp: cgp2.1 no types no const less hits than acgp1.1.2 what=1 " 37 1 n n n n n 2 n n n n 1
#./run_wilcox_stats.sh n "p37 hyp: cgp2.1 no types no const less hits than acgp1.1.2 what=2 " 37 1 n n n n n 2 n n n n 2
#./run_wilcox_stats.sh n "p37 hyp: cgp2.1 no types no const less hits than acgp1.1.2 what=3 " 37 1 n n n n n 2 n n n n 3
#./run_wilcox_stats.sh n "p37 hyp: orig no adfs less hits than acgpf2.1 with adfs" 37 0 y n n n n 4 y y n n 3
#./run_wilcox_stats.sh n "p37 hyp: orig yadfs less hits than acgpf2.1 with adfs" 37 0 y y n n n 4 y y n n 3

#./run_wilcox_stats.sh n 37 0 y n n n n 0 y y n n n

#./run_wilcox_stats.sh n 37 0 y n n n n 1 n n n n n
#./run_wilcox_stats.sh n 37 0 y n n n n 1 n n n y n
#./run_wilcox_stats.sh n 37 0 y n n n n 1 n n y n n
#./run_wilcox_stats.sh n 37 0 y n n n n 1 n n y y n

#./run_wilcox_stats.sh n 37 0 y y n n n 1 n n n n n
#./run_wilcox_stats.sh n 37 0 y y n n n 1 n n n y n
#./run_wilcox_stats.sh n 37 0 y y n n n 1 n n y n n
#./run_wilcox_stats.sh n 37 0 y y n n n 1 n n y y n

#./run_wilcox_stats.sh n 37 2 n n n n 0 4 y n n n 0
#./run_wilcox_stats.sh n 37 2 n n n n 0 4 y y n n 2

#for x in 3 5 8 11 12 13 14 23 24 15 16 30 31 32 34 35 36 37
for x in 3 5 8 11 12 13 14 
#for x in 3 5 
do
#./run_wilcox_stats.sh n $x 0 y n n n n 4 y n n n 2
#./run_wilcox_stats.sh n $x 0 y y n n n 4 y n n n 2
#./run_wilcox_stats.sh n $x 1 n n n n n 4 y n n n 2
#./run_wilcox_stats.sh n $x 1 n n n n n 4 y y n n 2
#./run_wilcox_stats.sh n $x 2 n n n n 2 4 y y n n 2

./run_wilcox_stats.sh n $x 0 y n n n n $x 4 y n n n 3
./run_wilcox_stats.sh n $x 0 y y n n n $x 4 y n n n 3
./run_wilcox_stats.sh n $x 1 n n n n n $x 4 y n n n 3
./run_wilcox_stats.sh n $x 1 n n n n n $x 4 y y n n 3
./run_wilcox_stats.sh n $x 2 n n n n 3 $x 4 y y n n 3
done

#gwgnote need to figure out how to compare md17 to genramp
#23 24 15 16 30 31 32 34 35 36 37
#like the following
#./run_wilcox_stats.sh n 36 2 n n n n 3 37 4 y y n n 3
