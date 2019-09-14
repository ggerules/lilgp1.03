library(ggplot2)
library(dplyr)
library(crayon)

printf <- function(...) cat(sprintf(...))

blue_printf   <- function(...) cat(blue(...))
white_printf <- function(...) cat(white(sprintf(...)))
silver_printf <- function(...) cat(silver(sprintf(...)))
 
# RowNum,Kernel,ProblemNum,IndRunNum,wADF,ADF,Types,Constraints,acgpwhat,MaxTreeDepth,GenNum,SubPopNum,MeanStdFitnessOfGen,StdFitnessBestOfGenInd,StdFitnessWorstOfGenInd,MeanTreeSizeOfGen,MeanTreeDepthOfGen,TreeSizeBestOfGenInd,TreeDepthBestOfGenInd,TreeSizeWorstOfGenInd,TreeDepthWorstOfGenInd,MeanStdFitnessOfRun,StdFitnessBestOfRunInd,StdFitnessWorstOfRunInd,MeanTreeSizeOfRun,MeanTreeDepthOfRun,TreeSizeBestOfRunInd,TreeDepthBestOfRunInd,TreeSizeWorstOfRunInd,TreeDepthWorstOfRunInd

hits <- read.table("/home/ggerules/lilgp1.02/app/prob004_koza1/data/sttlong.csv", header=TRUE, sep=",", na.strings="NA", dec=".", strip.white=TRUE)

hs <- with(hits, hits[order(Kernel, ProblemNum, wADF, ADF, Types, Constraints, acgpwhat, IndRunNum, decreasing=FALSE), ])

dim(hs)
str(hs)

#blue_printf("orig_ywadf_nadf_ntypes_ncons_nwhatn\n")
d1 <- hs %>% filter(Kernel == 0, wADF == "y", ADF == "n", Types == "n", Constraints == "n", acgpwhat == "n")
d2 <- hs %>% filter(Kernel == 0, wADF == "y", ADF == "y", Types == "n", Constraints == "n", acgpwhat == "n")
d3 <- rbind(d1, d2)
#dim(d1)
#str(d1)
#n <- attr(d1, "names")

#plot1 <- ggplot(d3) + labs(title="Koza3 - Mean Standard Fitness of Generation vs Generation Number", subtitle="for kernel orig_ywadf_nadf_ntypes_ncons_nwhatn", x="Generation", y="Mean Standard Fitness of Generation") + geom_smooth(aes(x=d3$GenNum, y=d3$MeanStdFitnessOfGen), method = "loess")  + scale_color_continuous(name="Independant Run Num") 

plot1 <- ggplot(data=d3, aes(x=d3$GenNum, y=d3$MeanStdFitnessOfGen, group=d3$ADF, colour=ADF)) + labs(title="Koza3 - Mean Standard Fitness of Generation vs Generation Number", subtitle="for kernel orig_ywadf_nadf_ntypes_ncons_nwhatn", x="Generation", y="Mean Standard Fitness of Generation") + geom_smooth(aes(x=d3$GenNum, y=d3$MeanStdFitnessOfGen), method = "loess")  + scale_color_discrete(name="Orig ADF Implemented") 


#plot1 <- ggplot(data=d3, aes(x=r.r500, y=sckT, ymin=sckT.lo, ymax=sckT.up, fill=type, linetype=type)) + geom_line() + geom_ribbon(alpha=0.5)  

ggsave(plot1, file="./aorig_ywadf_nadf_ntypes_ncons_nwhatn1.pdf")

