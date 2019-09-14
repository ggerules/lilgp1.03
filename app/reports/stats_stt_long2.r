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

# RowNum,ProblemNum,Kernel,IndRunNum,wADF,ADF,Types,Constraints,acgpwhat,MaxTreeDepth,GenNum,SubPopNum,MeanStdFitnessOfGen,StdFitnessBestOfGenInd,StdFitnessWorstOfGenInd,MeanTreeSizeOfGen,MeanTreeDepthOfGen,TreeSizeBestOfGenInd,TreeDepthBestOfGenInd,TreeSizeWorstOfGenInd,TreeDepthWorstOfGenInd,MeanStdFitnessOfRun,StdFitnessBestOfRunInd,StdFitnessWorstOfRunInd,MeanTreeSizeOfRun,MeanTreeDepthOfRun,TreeSizeBestOfRunInd,TreeDepthBestOfRunInd,TreeSizeWorstOfRunInd,TreeDepthWorstOfRunInd

dat <- read.table("/home/ggerules/lilgp1.03/app/reports/sttlong.csv", header=TRUE, sep=",", na.strings="NA", dec=".", strip.white=TRUE)

#dat sorted
dats <- with(dat, dat[order(ProblemNum, Kernel, wADF, ADF, Types, Constraints, acgpwhat, IndRunNum, decreasing=FALSE), ])

#write.table(dats, file = "sttlongsorted.csv", sep = ",", col.names = TRUE, row.names = FALSE, qmethod = "double")

#dim(dats)
#str(dats)
#class(dat)
#class(dats)
names(dats$ProblemNum)

## test code 
#d <- dats %>% 
#      group_by(ProblemNum, Kernel,wADF,ADF,Types,Constraints,acgpwhat,GenNum) %>% 
#      #summarise(num = n()) %>%
#      summarise( meanStdFitnessBestOfRunInd = mean(StdFitnessBestOfRunInd),
#                 meanTreeSizeBestOfRunInd = mean(TreeSizeBestOfRunInd),
#                 meanTreeDepthBestOfRunInd = mean(TreeDepthBestOfRunInd),
#                 meanTreeSizeWorstOfRunInd = mean(TreeSizeWorstOfRunInd),
#                 meanTreeDepthWorstOfRunInd = mean(TreeDepthWorstOfRunInd)
#      ) %>%
#      #filter(Kernel == 0, wADF == "y", ADF == "n", Types == "n", Constraints == "n", acgpwhat == "n")
#      filter(ProblemNum == 3, Kernel == 0, wADF == "y", Types == "n", Constraints == "n", acgpwhat == "n")
#write.table(d, file = "3_groupby_orig_kern.csv", sep = ",", col.names = TRUE, row.names = FALSE, qmethod = "double")
#typeof(d)

#blue_printf("[+dirname+]\n")
#o1 <- dats %>% 
#      group_by(Kernel,wADF,ADF,Types,Constraints,acgpwhat,GenNum) %>% 
#      #summarise(num = n()) %>%
#      summarise( meanStdFitnessBestOfRunInd = mean(StdFitnessBestOfRunInd),
#                 meanTreeSizeBestOfRunInd = mean(TreeSizeBestOfRunInd),
#                 meanTreeDepthBestOfRunInd = mean(TreeDepthBestOfRunInd),
#                 meanTreeSizeWorstOfRunInd = mean(TreeSizeWorstOfRunInd),
#                 meanTreeDepthWorstOfRunInd = mean(TreeDepthWorstOfRunInd)
#      ) %>%
#      filter(Kernel == [+frmwrk+], wADF == "[+wadf+]", ADF == "[+adf+]", Types == "[+types+]", Constraints == "[+cons+]", acgpwhat == "[+what+]")
#
#x <- c(o1$GenNum) 
#str(x)
#framework <- c(rep("[+dirname+]",51))
#str(framework)
#val <- c(o1$meanStdFitnessBestOfRunInd)
#str(val)
#
#df <- data.frame(x, framework, val)
#
#plot <- ggplot(df, aes(x=x, y=val)) + geom_line(color="red") +
#  labs(title="[+prob.name+] - Mean of Standard Fitness of Best of Run Individuals\n by Generation Number", subtitle="Original kernel.orig Used\n 30 Independent Runs\n (Kernel == [+frmwrk+], wADF == [+wadf+], ADF == [+adf+], Types == [+types+], Constraints == [+cons+], acgpwhat == [+what+]) ", x="Generation Number", y="Mean Standard Fitness Best of Run Individuals") + ylim(0,1)
#ggsave(plot, file="./plots/agt_[+dirname+].pdf")

#x <- c(o1$GenNum) 
#str(x)
#framework <- c(rep("[+dirname+]",51))
#str(framework)
#val <- c(o1$meanTreeSizeBestOfRunInd)
#str(val)
#
#plot <- ggplot(df, aes(x=x, y=val)) + geom_line(color="red") +
#  labs(title="[+prob.name+] - Mean Tree Size Best of Run Individuals vs Generation Number\n by Generation Number", subtitle="Original kernel.orig Used\n 30 Independent Runs\n (Kernel == [+frmwrk+], wADF == [+wadf+], ADF == [+adf+], Types == [+types+], Constraints == [+cons+], acgpwhat == [+what+]) ", x="Generation Number", y="Mean Tree Size Best of Run Individuals") + ylim(0,50)
#ggsave(plot, file="./plots/igt_[+dirname+].pdf")
#
#x <- c(o1$GenNum) 
#str(x)
#framework <- c(rep("[+dirname+]",51))
#str(framework)
#val <- c(o1$meanTreeDepthWorstOfRunInd )
#str(val)
#
#plot <- ggplot(df, aes(x=x, y=val)) + geom_line(color="red") +
#  labs(title="[+prob.name+] - Mean Tree Depth Best of Run Individual vs Generation Number\n by Generation Number", subtitle="Original kernel.orig Used\n 30 Independent Runs\n (Kernel == [+frmwrk+], wADF == [+wadf+], ADF == [+adf+], Types == [+types+], Constraints == [+cons+], acgpwhat == [+what+]) ", x="Generation Number", y="Mean Tree Depth Best of Run Individuals") + ylim(0,10)
#ggsave(plot, file="./plots/jgt_[+dirname+].pdf")
#
#plot <- ggplot(df, aes(x=x, y=val)) + geom_line(color="red") +
