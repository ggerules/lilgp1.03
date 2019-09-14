library(ggplot2)
library(dplyr)
library(crayon)

printf <- function(...) cat(sprintf(...))
prnf <- function(...) cat(sprintf("%f ", ...))
prnd <- function(...) cat(sprintf("%d ", ...))
prln <- function(...) cat(sprintf("\n"))

blue_printf   <- function(...) cat(blue(...))
white_printf <- function(...) cat(white(sprintf(...)))
silver_printf <- function(...) cat(silver(sprintf(...)))

# RowNum,Kernel,ProblemNum,IndRunNum,wADF,ADF,Types,Constraints,acgpwhat,MaxTreeDepth,GenNum,SubPopNum,MeanStdFitnessOfGen,StdFitnessBestOfGenInd,StdFitnessWorstOfGenInd,MeanTreeSizeOfGen,MeanTreeDepthOfGen,TreeSizeBestOfGenInd,TreeDepthBestOfGenInd,TreeSizeWorstOfGenInd,TreeDepthWorstOfGenInd,MeanStdFitnessOfRun,StdFitnessBestOfRunInd,StdFitnessWorstOfRunInd,MeanTreeSizeOfRun,MeanTreeDepthOfRun,TreeSizeBestOfRunInd,TreeDepthBestOfRunInd,TreeSizeWorstOfRunInd,TreeDepthWorstOfRunInd

dat <- read.table("/home/ggerules/lilgp1.02/app/prob007_koza1_cuda/data/sttlong.csv", header=TRUE, sep=",", na.strings="NA", dec=".", strip.white=TRUE)

#dat sorted
dats <- with(dat, dat[order(Kernel, ProblemNum, wADF, ADF, Types, Constraints, acgpwhat, IndRunNum, decreasing=FALSE), ])

#dim(dats)
#str(dats)

cnt <- 0
sum <- 0
va_1 = NULL
va_2 = NULL
adf_1 = NULL
adf_2 = NULL
for(gn in 0:49)
{
 #make a data frame that is all of one particular generation
 d_1 <- dats %>% filter(Kernel == 0, wADF == "y", ADF == "n", Types == "n", Constraints == "n", acgpwhat == "n", GenNum == gn, )
 d_2 <- dats %>% filter(Kernel == 0, wADF == "y", ADF == "y", Types == "n", Constraints == "n", acgpwhat == "n", GenNum == gn, )
 #next line is mean of all ind run for a generation(row number)
 val_1 <- mean(d_1$StdFitnessBestOfRunInd)
 val_2 <- mean(d_2$StdFitnessBestOfRunInd)
 #building double array so we can plot
 va_1 <- append(va_1, val_1)
 va_2 <- append(va_2, val_2)
 adf_1 <- append(adf_1, "n")
 adf_2 <- append(adf_2, "y")
 #printf(typeof(val))
 prnf (val_1)
 prln()
}
#str(d_1)
#print(rownames(d_1))
#examples of what can be done with 
#print(names(va_1))
#print(typeof(va_1))
ddva_1 <- data.frame(va_1)
ddadf_1 <- data.frame(adf_1)
ddgn_1 <- data.frame(seq.int(0, 49, 1))
dd_1 <- data.frame(c(ddgn_1, ddadf_1, ddva_1))
ddva_2 <- data.frame(va_2)
ddadf_2 <- data.frame(adf_2)
ddgn_2 <- data.frame(seq.int(0, 49, 1))
dd_2 <- data.frame(c(ddgn_2, ddadf_2, ddva_2))
#print(ddgn)
colnames(dd_1) <- c("GenNum", "ADF", "MeanStdFitnessBestOfRunInd")
colnames(dd_2) <- c("GenNum", "ADF", "MeanStdFitnessBestOfRunInd")
dd <- rbind(dd_1, dd_2)
colnames(dd) <- c("GenNum", "ADF", "MeanStdFitnessBestOfRunInd")
#print(colnames(dd_1))
#prnd(dd_1$GenNum[1])
#print(dd_1$GenNum)
#print(dd_1$StdFitnessBestOfRunInd)
#print(typeof(dd_1))
#print(dim(dd_1))
#print(names(dd_1))
##x = dim(dd_1[0])
##print(typeof(x))
##prnd(x)
#print(is.data.frame(dd_1))
#print(rownames(dd_1))
#print(colnames(dd_1))
#print(dd_1$va[2])
str(dd)

#plot <- ggplot(va) + labs(title="Koza1 - Mean Standard Fitness of Run vs Generation Number", subtitle="for kernel orig_ywadf_nadf_ntypes_ncons_nwhatn", x="Generation", y="Mean Standard Fitness of Run") + geom_point(aes(x=d$GenNum, y=d$MeanStdFitnessOfRun, color=d$IndRunNum)) + geom_smooth(aes(x=d$GenNum, y=d$MeanStdFitnessOfRun)) + scale_color_continuous(name="Independant Run Num")

#plot <- ggplot(dd_1) + labs(title="Koza1 - Mean Standard Fitness Best Of Run Individual", subtitle="for kernel orig_ywadf_nadf_ntypes_ncons_nwhatn", x="Generation", y="Mean Standard Fitness Best Of Run Individual") + geom_line(aes(x=dd_1$GenNum, y=dd_1$MeanStdFitnessBestOfRunInd)) 
plot <- ggplot(dd,aes(x=dd$GenNum, y=dd$MeanStdFitnessBestOfRunInd, color=dd$ADF)) + labs(title="Koza1 - Mean Standard Fitness of Run vs Generation Number", subtitle="for kernel orig_ywadf_nadf_ntypes_ncons_nwhatn", x="Generation", y="Mean Standard Fitness of Run") + geom_line() + guides(fill = guide_legend(title="Independant Run Num"))


#ggsave(plot,file="./plots/borig_ywadf_nadf_ntypes_ncons_nwhatn.pdf")
ggsave(plot,file="./teststt.pdf")

