#!/bin/bash
#StdFitnessBestOfRunInd
#Rscript group_sfbri1.r
Rscript group_sfbri2.r
#Rscript group_sfbri3.r
./p1unite.bash

#StdFitnessBestOfGenInd
#Rscript group_sfbgi1.r
Rscript group_sfbgi2.r
#Rscript group_sfbgi3.r
./p2unite.bash

#TreeSizeBestOfRunInd
#Rscript group_tsbri1.r
Rscript group_tsbri2.r
#Rscript group_tsbri3.r
./p3unite.bash

#TreeSizeBestOfGenInd
#Rscript group_tsbgi1.r
Rscript group_tsbgi2.r
#Rscript group_tsbgi3.r
./p4unite.bash

#TreeSizeWorstOfRunInd
#Rscript group_tswri1.r
Rscript group_tswri2.r
#Rscript group_tswri3.r
./p5unite.bash

#TreeSizeWorstOfGenInd
#Rscript group_tswgi1.r
Rscript group_tswgi2.r
#Rscript group_tswgi3.r
./p6unite.bash
