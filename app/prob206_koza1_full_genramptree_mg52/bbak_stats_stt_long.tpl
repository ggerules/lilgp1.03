[+ AutoGen5 template r +]
library(ggplot2)
library(dplyr)
library(crayon)

printf <- function(...) cat(sprintf(...))

blue_printf   <- function(...) cat(blue(...))
white_printf <- function(...) cat(white(sprintf(...)))
silver_printf <- function(...) cat(silver(sprintf(...)))
 
# RowNum,Kernel,ProblemNum,IndRunNum,wADF,ADF,Types,Constraints,acgpwhat,MaxTreeDepth,GenNum,SubPopNum,MeanStdFitnessOfGen,StdFitnessBestOfGenInd,StdFitnessWorstOfGenInd,MeanTreeSizeOfGen,MeanTreeDepthOfGen,TreeSizeBestOfGenInd,TreeDepthBestOfGenInd,TreeSizeWorstOfGenInd,TreeDepthWorstOfGenInd,MeanStdFitnessOfRun,StdFitnessBestOfRunInd,StdFitnessWorstOfRunInd,MeanTreeSizeOfRun,MeanTreeDepthOfRun,TreeSizeBestOfRunInd,TreeDepthBestOfRunInd,TreeSizeWorstOfRunInd,TreeDepthWorstOfRunInd

hits <- read.table("[+homedir+][+probname+][+sttlongdata+]", header=TRUE, sep=",", na.strings="NA", dec=".", strip.white=TRUE)
hs <- with(hits, hits[order(Kernel, ProblemNum, wADF, ADF, Types, Constraints, acgpwhat, IndRunNum, decreasing=FALSE), ])

dim(hs)
str(hs)

[+ FOR objlst +][+IF (exist? "kname")+][+ FOR dirname +]
blue_printf("[+dirname+]\n")
d <- hs %>% filter(Kernel == [+frmwrk+], wADF == "[+wadf+]", ADF == "[+adf+]", Types == "[+types+]", Constraints == "[+cons+]", acgpwhat == "[+what+]")
dim(d)
n <- attr(d, "names")
#plot <- ggplot(d) + labs(title="[+prob.name+] - Mean Standard Fitness of Generation vs Generation Number", subtitle="for kernel [+dirname+]", x="Generation", y="Mean Standard Fitness of Generation") + geom_point(aes(x=d$GenNum, y=d$MeanStdFitnessOfGen, color=d$IndRunNum)) + geom_smooth(aes(x=d$GenNum, y=d$MeanStdFitnessOfGen))  + scale_color_continuous(name="Independant Run Num") 
plot <- ggplot(d) + labs(title="[+prob.name+] - Mean Standard Fitness of Generation vs Generation Number", subtitle="for kernel [+dirname+]", x="Generation", y="Mean Standard Fitness of Generation") + geom_smooth(aes(x=d$GenNum, y=d$MeanStdFitnessOfGen))  + scale_color_continuous(name="Independant Run Num") 
ggsave(plot,file="./plots/a[+dirname+].pdf")
[+ ENDFOR dirname +][+ENDIF+][+ ENDFOR objlst +]

[+ FOR objlst +][+IF (exist? "kname")+][+ FOR dirname +]
blue_printf("[+dirname+]\n")
d <- hs %>% filter(Kernel == [+frmwrk+], wADF == "[+wadf+]", ADF == "[+adf+]", Types == "[+types+]", Constraints == "[+cons+]", acgpwhat == "[+what+]")
dim(d)
n <- attr(d, "names")
#plot <- ggplot(d) + labs(title="[+prob.name+] - Mean Standard Fitness of Run vs Generation Number", subtitle="for kernel [+dirname+]", x="Generation", y="Mean Standard Fitness of Run") + geom_point(aes(x=d$GenNum, y=d$MeanStdFitnessOfRun, color=d$IndRunNum)) + geom_smooth(aes(x=d$GenNum, y=d$MeanStdFitnessOfRun)) + scale_color_continuous(name="Independant Run Num") 
plot <- ggplot(d) + labs(title="[+prob.name+] - Mean Standard Fitness of Run vs Generation Number", subtitle="for kernel [+dirname+]", x="Generation", y="Mean Standard Fitness of Run") + scale_color_continuous(name="Independant Run Num") 
ggsave(plot,file="./plots/b[+dirname+].pdf")
[+ ENDFOR dirname +][+ENDIF+][+ ENDFOR objlst +]

[+ FOR objlst +][+IF (exist? "kname")+][+ FOR dirname +]
blue_printf("[+dirname+]\n")
d <- hs %>% filter(Kernel == [+frmwrk+], wADF == "[+wadf+]", ADF == "[+adf+]", Types == "[+types+]", Constraints == "[+cons+]", acgpwhat == "[+what+]")
dim(d)
n <- attr(d, "names")
#plot <- ggplot(d) + labs(title="[+prob.name+] - Standard Fitness Best Individual of Generation vs Generation Number", subtitle="for kernel [+dirname+]", x="Generation", y="Standard Fitness Best Individual of Generation") + geom_point(aes(x=d$GenNum, y=d$StdFitnessBestOfGenInd, color=d$IndRunNum)) + geom_smooth(aes(x=d$GenNum, y=d$StdFitnessBestOfGenInd))  + scale_color_continuous(name="Independant Run") 
plot <- ggplot(d) + labs(title="[+prob.name+] - Standard Fitness Best Individual of Generation vs Generation Number", subtitle="for kernel [+dirname+]", x="Generation", y="Standard Fitness Best Individual of Generation") + geom_smooth(aes(x=d$GenNum, y=d$StdFitnessBestOfGenInd))  + scale_color_continuous(name="Independant Run") 
ggsave(plot,file="./plots/c[+dirname+].pdf")
[+ ENDFOR dirname +][+ENDIF+][+ ENDFOR objlst +]

[+ FOR objlst +][+IF (exist? "kname")+][+ FOR dirname +]
blue_printf("[+dirname+]\n")
d <- hs %>% filter(Kernel == [+frmwrk+], wADF == "[+wadf+]", ADF == "[+adf+]", Types == "[+types+]", Constraints == "[+cons+]", acgpwhat == "[+what+]")
dim(d)
n <- attr(d, "names")
#plot <- ggplot(d) + labs(title="[+prob.name+] - Standard Fitness of Best Individual of Run vs Generation Number", subtitle="for kernel [+dirname+]", x="Generation", y="Standard Fitness Best Individual of Run") + geom_point(aes(x=d$GenNum, y=d$StdFitnessBestOfRunInd, color=d$IndRunNum)) + geom_smooth(aes(x=d$GenNum, y=d$StdFitnessBestOfRunInd)) + scale_color_continuous(name="Independent Run Num")  
plot <- ggplot(d) + labs(title="[+prob.name+] - Standard Fitness of Best Individual of Run vs Generation Number", subtitle="for kernel [+dirname+]", x="Generation", y="Standard Fitness Best Individual of Run") + scale_color_continuous(name="Independent Run Num")  
ggsave(plot,file="./plots/d[+dirname+].pdf")
[+ ENDFOR dirname +][+ENDIF+][+ ENDFOR objlst +]

[+ FOR objlst +][+IF (exist? "kname")+][+ FOR dirname +]
blue_printf("[+dirname+]\n")
d <- hs %>% filter(Kernel == [+frmwrk+], wADF == "[+wadf+]", ADF == "[+adf+]", Types == "[+types+]", Constraints == "[+cons+]", acgpwhat == "[+what+]")
dim(d)
n <- attr(d, "names")
#plot <- ggplot(d) + labs(title="[+prob.name+] - Tree Size Best of Gen Individual vs Generation Number", subtitle="for kernel [+dirname+]", x="Generation", y="Tree Size Best of Gen Individual") + geom_point(aes(x=d$GenNum, y=d$TreeSizeBestOfGenInd, color=d$IndRunNum)) + geom_smooth(aes(x=d$GenNum, y=d$TreeSizeBestOfGenInd)) + scale_color_continuous(name="Independent Run Num")  
plot <- ggplot(d) + labs(title="[+prob.name+] - Tree Size Best of Gen Individual vs Generation Number", subtitle="for kernel [+dirname+]", x="Generation", y="Tree Size Best of Gen Individual") + scale_color_continuous(name="Independent Run Num")  
ggsave(plot,file="./plots/e[+dirname+].pdf")
[+ ENDFOR dirname +][+ENDIF+][+ ENDFOR objlst +]

[+ FOR objlst +][+IF (exist? "kname")+][+ FOR dirname +]
blue_printf("[+dirname+]\n")
d <- hs %>% filter(Kernel == [+frmwrk+], wADF == "[+wadf+]", ADF == "[+adf+]", Types == "[+types+]", Constraints == "[+cons+]", acgpwhat == "[+what+]")
dim(d)
n <- attr(d, "names")
#plot <- ggplot(d) + labs(title="[+prob.name+] - Tree Depth Best of Gen Individual vs Generation Number", subtitle="for kernel [+dirname+]", x="Generation", y="Tree Depth Best of Gen Individual") + geom_point(aes(x=d$GenNum, y=d$TreeDepthBestOfGenInd, color=d$IndRunNum)) + geom_smooth(aes(x=d$GenNum, y=d$TreeDepthBestOfGenInd)) + scale_color_continuous(name="Independent Run Num")  
plot <- ggplot(d) + labs(title="[+prob.name+] - Tree Depth Best of Gen Individual vs Generation Number", subtitle="for kernel [+dirname+]", x="Generation", y="Tree Depth Best of Gen Individual") + scale_color_continuous(name="Independent Run Num")  
ggsave(plot,file="./plots/f[+dirname+].pdf")
[+ ENDFOR dirname +][+ENDIF+][+ ENDFOR objlst +]

[+ FOR objlst +][+IF (exist? "kname")+][+ FOR dirname +]
blue_printf("[+dirname+]\n")
d <- hs %>% filter(Kernel == [+frmwrk+], wADF == "[+wadf+]", ADF == "[+adf+]", Types == "[+types+]", Constraints == "[+cons+]", acgpwhat == "[+what+]")
dim(d)
n <- attr(d, "names")
#plot <- ggplot(d) + labs(title="[+prob.name+] - Tree Size Worst of Gen Individual vs Generation Number", subtitle="for kernel [+dirname+]", x="Generation", y="Tree Size Worst of Gen Individual") + geom_point(aes(x=d$GenNum, y=d$TreeSizeWorstOfGenInd, color=d$IndRunNum)) + geom_smooth(aes(x=d$GenNum, y=d$TreeSizeWorstOfGenInd)) + scale_color_continuous(name="Independent Run Num")  
plot <- ggplot(d) + labs(title="[+prob.name+] - Tree Size Worst of Gen Individual vs Generation Number", subtitle="for kernel [+dirname+]", x="Generation", y="Tree Size Worst of Gen Individual") + scale_color_continuous(name="Independent Run Num")  
ggsave(plot,file="./plots/g[+dirname+].pdf")
[+ ENDFOR dirname +][+ENDIF+][+ ENDFOR objlst +]

[+ FOR objlst +][+IF (exist? "kname")+][+ FOR dirname +]
blue_printf("[+dirname+]\n")
d <- hs %>% filter(Kernel == [+frmwrk+], wADF == "[+wadf+]", ADF == "[+adf+]", Types == "[+types+]", Constraints == "[+cons+]", acgpwhat == "[+what+]")
dim(d)
n <- attr(d, "names")
#plot <- ggplot(d) + labs(title="[+prob.name+] - Tree Depth Worst of Gen Individual vs Generation Number", subtitle="for kernel [+dirname+]", x="Generation", y="Tree Depth Worst of Gen Individual") + geom_point(aes(x=d$GenNum, y=d$TreeDepthWorstOfGenInd, color=d$IndRunNum)) + geom_smooth(aes(x=d$GenNum, y=d$TreeDepthWorstOfGenInd)) + scale_color_continuous(name="Independent Run Num")  
plot <- ggplot(d) + labs(title="[+prob.name+] - Tree Depth Worst of Gen Individual vs Generation Number", subtitle="for kernel [+dirname+]", x="Generation", y="Tree Depth Worst of Gen Individual") + scale_color_continuous(name="Independent Run Num")  
ggsave(plot,file="./plots/h[+dirname+].pdf")
[+ ENDFOR dirname +][+ENDIF+][+ ENDFOR objlst +]

[+ FOR objlst +][+IF (exist? "kname")+][+ FOR dirname +]
blue_printf("[+dirname+]\n")
d <- hs %>% filter(Kernel == [+frmwrk+], wADF == "[+wadf+]", ADF == "[+adf+]", Types == "[+types+]", Constraints == "[+cons+]", acgpwhat == "[+what+]")
dim(d)
n <- attr(d, "names")
#plot <- ggplot(d) + labs(title="[+prob.name+] - Tree Size Best of Run Individual vs Generation Number", subtitle="for kernel [+dirname+]", x="Generation", y="Tree Size Best of Run Individual") + geom_point(aes(x=d$GenNum, y=d$TreeSizeBestOfRunInd, color=d$IndRunNum)) + geom_smooth(aes(x=d$GenNum, y=d$TreeSizeBestOfRunInd)) + scale_color_continuous(name="Independent Run Num")  
plot <- ggplot(d) + labs(title="[+prob.name+] - Tree Size Best of Run Individual vs Generation Number", subtitle="for kernel [+dirname+]", x="Generation", y="Tree Size Best of Run Individual") + scale_color_continuous(name="Independent Run Num")  
ggsave(plot,file="./plots/i[+dirname+].pdf")
[+ ENDFOR dirname +][+ENDIF+][+ ENDFOR objlst +]

[+ FOR objlst +][+IF (exist? "kname")+][+ FOR dirname +]
blue_printf("[+dirname+]\n")
d <- hs %>% filter(Kernel == [+frmwrk+], wADF == "[+wadf+]", ADF == "[+adf+]", Types == "[+types+]", Constraints == "[+cons+]", acgpwhat == "[+what+]")
dim(d)
n <- attr(d, "names")
#plot <- ggplot(d) + labs(title="[+prob.name+] - Tree Depth Best of Run Individual vs Generation Number", subtitle="for kernel [+dirname+]", x="Generation", y="Tree Depth Best of Run Individual") + geom_point(aes(x=d$GenNum, y=d$TreeDepthBestOfRunInd, color=d$IndRunNum)) + geom_smooth(aes(x=d$GenNum, y=d$TreeDepthBestOfRunInd)) + scale_color_continuous(name="Independent Run Num")  
plot <- ggplot(d) + labs(title="[+prob.name+] - Tree Depth Best of Run Individual vs Generation Number", subtitle="for kernel [+dirname+]", x="Generation", y="Tree Depth Best of Run Individual") + scale_color_continuous(name="Independent Run Num")  
ggsave(plot,file="./plots/j[+dirname+].pdf")
[+ ENDFOR dirname +][+ENDIF+][+ ENDFOR objlst +]

[+ FOR objlst +][+IF (exist? "kname")+][+ FOR dirname +]
blue_printf("[+dirname+]\n")
d <- hs %>% filter(Kernel == [+frmwrk+], wADF == "[+wadf+]", ADF == "[+adf+]", Types == "[+types+]", Constraints == "[+cons+]", acgpwhat == "[+what+]")
dim(d)
n <- attr(d, "names")
#plot <- ggplot(d) + labs(title="[+prob.name+] - Tree Size Worst of Run Individual vs Generation Number", subtitle="for kernel [+dirname+]", x="Generation", y="Tree Size Worst of Run Individual") + geom_point(aes(x=d$GenNum, y=d$TreeSizeWorstOfRunInd, color=d$IndRunNum)) + geom_smooth(aes(x=d$GenNum, y=d$TreeSizeWorstOfRunInd)) + scale_color_continuous(name="Independent Run Num")  
plot <- ggplot(d) + labs(title="[+prob.name+] - Tree Size Worst of Run Individual vs Generation Number", subtitle="for kernel [+dirname+]", x="Generation", y="Tree Size Worst of Run Individual") + scale_color_continuous(name="Independent Run Num")  
ggsave(plot,file="./plots/k[+dirname+].pdf")
[+ ENDFOR dirname +][+ENDIF+][+ ENDFOR objlst +]

[+ FOR objlst +][+IF (exist? "kname")+][+ FOR dirname +]
blue_printf("[+dirname+]\n")
d <- hs %>% filter(Kernel == [+frmwrk+], wADF == "[+wadf+]", ADF == "[+adf+]", Types == "[+types+]", Constraints == "[+cons+]", acgpwhat == "[+what+]")
dim(d)
n <- attr(d, "names")
#plot <- ggplot(d) + labs(title="[+prob.name+] - Tree Depth Worst of Run Individual vs Generation Number", subtitle="for kernel [+dirname+]", x="Generation", y="Tree Depth Worst of Run Individual") + geom_point(aes(x=d$GenNum, y=d$TreeDepthWorstOfRunInd, color=d$IndRunNum)) + geom_smooth(aes(x=d$GenNum, y=d$TreeDepthWorstOfRunInd)) + scale_color_continuous(name="Independent Run Num")  
plot <- ggplot(d) + labs(title="[+prob.name+] - Tree Depth Worst of Run Individual vs Generation Number", subtitle="for kernel [+dirname+]", x="Generation", y="Tree Depth Worst of Run Individual") + scale_color_continuous(name="Independent Run Num")  
ggsave(plot,file="./plots/l[+dirname+].pdf")
[+ ENDFOR dirname +][+ENDIF+][+ ENDFOR objlst +]


