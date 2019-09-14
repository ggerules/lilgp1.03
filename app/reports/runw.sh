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


#for x in 3 5 8 11 12 13 14 23 24 15 16 30 31 32 34 35 36 37
#for x in 3 5 
for x in 3  
do
./run_wilcox_stats.sh n $x 0 y n n n n $x 0 y y n n n

#./run_wilcox_stats.sh n $x 0 y n n n n $x 1 n n n n n
#./run_wilcox_stats.sh n $x 0 y n n n n $x 1 n n n y n
#./run_wilcox_stats.sh n $x 0 y n n n n $x 1 n n y n n
#./run_wilcox_stats.sh n $x 0 y n n n n $x 1 n n y y n

#./run_wilcox_stats.sh n $x 0 y y n n n $x 1 n n n n n
#./run_wilcox_stats.sh n $x 0 y y n n n $x 1 n n n y n
#./run_wilcox_stats.sh n $x 0 y y n n n $x 1 n n y n n
#./run_wilcox_stats.sh n $x 0 y y n n n $x 1 n n y y n

#./run_wilcox_stats.sh n $x 1 n n n n n $x 2 y n n n n
#./run_wilcox_stats.sh n $x 1 n n n y n $x 2 y n n y n
#./run_wilcox_stats.sh n $x 1 n n y n n $x 2 y n y n n
#./run_wilcox_stats.sh n $x 1 n n y y n $x 2 y n y y n

#./run_wilcox_stats.sh n $x 1 n n n n n $x 2 y y n n n
#./run_wilcox_stats.sh n $x 1 n n n y n $x 2 y y n y n
#./run_wilcox_stats.sh n $x 1 n n y n n $x 2 y y y n n
#./run_wilcox_stats.sh n $x 1 n n y y n $x 2 y y y y n

#./run_wilcox_stats.sh n $x 3 n n n n 0 $x 4 y n n n 0
#./run_wilcox_stats.sh n $x 3 n n n y 0 $x 4 y n n y 0
#./run_wilcox_stats.sh n $x 3 n n y n 0 $x 4 y n y n 0
#./run_wilcox_stats.sh n $x 3 n n y y 0 $x 4 y n y y 0
#./run_wilcox_stats.sh n $x 3 n y n n 0 $x 4 y y n n 0
#./run_wilcox_stats.sh n $x 3 n y n y 0 $x 4 y y n y 0
#./run_wilcox_stats.sh n $x 3 n y y n 0 $x 4 y y y n 0
#./run_wilcox_stats.sh n $x 3 n y y y 0 $x 4 y y y y 0

#./run_wilcox_stats.sh n $x 3 n n n n 1 $x 4 y n n n 1
#./run_wilcox_stats.sh n $x 3 n n n y 1 $x 4 y n n y 1
#./run_wilcox_stats.sh n $x 3 n n y n 1 $x 4 y n y n 1
#./run_wilcox_stats.sh n $x 3 n n y y 1 $x 4 y n y y 1
#./run_wilcox_stats.sh n $x 3 n y n n 1 $x 4 y y n n 1
#./run_wilcox_stats.sh n $x 3 n y n y 1 $x 4 y y n y 1
#./run_wilcox_stats.sh n $x 3 n y y n 1 $x 4 y y y n 1
#./run_wilcox_stats.sh n $x 3 n y y y 1 $x 4 y y y y 1

#./run_wilcox_stats.sh n $x 3 n n n n 2 $x 4 y n n n 2
#./run_wilcox_stats.sh n $x 3 n n n y 2 $x 4 y n n y 2
#./run_wilcox_stats.sh n $x 3 n n y n 2 $x 4 y n y n 2
#./run_wilcox_stats.sh n $x 3 n n y y 2 $x 4 y n y y 2
#./run_wilcox_stats.sh n $x 3 n y n n 2 $x 4 y y n n 2
#./run_wilcox_stats.sh n $x 3 n y n y 2 $x 4 y y n y 2
#./run_wilcox_stats.sh n $x 3 n y y n 2 $x 4 y y y n 2
#./run_wilcox_stats.sh n $x 3 n y y y 2 $x 4 y y y y 2

#./run_wilcox_stats.sh n $x 3 n n n n 3 $x 4 y n n n 3
#./run_wilcox_stats.sh n $x 3 n n n y 3 $x 4 y n n y 3
#./run_wilcox_stats.sh n $x 3 n n y n 3 $x 4 y n y n 3
#./run_wilcox_stats.sh n $x 3 n n y y 3 $x 4 y n y y 3
#./run_wilcox_stats.sh n $x 3 n y n n 3 $x 4 y y n n 3
#./run_wilcox_stats.sh n $x 3 n y n y 3 $x 4 y y n y 3
#./run_wilcox_stats.sh n $x 3 n y y n 3 $x 4 y y y n 3
#./run_wilcox_stats.sh n $x 3 n y y y 3 $x 4 y y y y 3

done


