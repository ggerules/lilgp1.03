library(ggplot2)
library(dplyr)
hits <- read.table("/home/ggerules/lilgp1.02/app/simple_trig/data/hitslong.csv", header=TRUE, sep=",", na.strings="NA", dec=".", strip.white=TRUE)
#View(hits_sorted)
#dim(hits_sorted)
#attributes(hits_sorted)
#hits_sorted.name
#attr(hits_sorted, "names")
#a <- attr(hits_sorted, "names")[1]
#a
hs <- with(hits, hits[order(Framework, ProblemNum, wADF, ADF, acgpwhat, useConstraints, IndRunNum, decreasing=FALSE), ])
dim(hs)

#attr(hs, "names")

frmwrk_f <- factor(hs$Framework)
prbnm_f <- factor(hs$ProblemNum)
wadf_f <- factor(hs$wADF)
adf_f <- factor(hs$ADF)
usecons_f <- factor(hs$useConstraints)
acgpwhat_f <- factor(hs$acgpwhat)

levels(frmwrk_f)
levels(prbnm_f)
levels(acgpwhat_f)
levels(wadf_f)
levels(adf_f)
levels(usecons_f)

#hs %>% filter(Framework == 0)
#hs %>% filter(Framework == 1)
#hs %>% filter(Framework == 3)
#hs %>% filter(Framework == 4)
#hs %>% filter(Framework == 5)
#hs %>% filter(Framework == 6)
#hs %>% filter(Framework == 7)

print("orig_noadf")
dim(hs %>% filter(Framework == 0))
d <- hs %>% filter(Framework == 0)
d$Hits
h = d$Hits
data=data.frame(h)
plot=qplot(h, data=data, geom="histogram") 
ggsave(plot,file="./hist_pdfs/hist_orig_noadf.pdf")

print("orig_adf")
dim(hs %>% filter(Framework == 1))
d <- hs %>% filter(Framework == 1)
d$Hits
h = d$Hits
data=data.frame(h)
plot=qplot(h, data=data, geom="histogram") 
ggsave(plot,file="./hist_pdfs/hist_orig_adf.pdf")


#------
print("cgp2p1_no_adf_no_cons")
dim(hs %>% filter(Framework == 2, wADF == 0, ADF == 0, useConstraints == 1))
d <- hs %>% filter(Framework == 2, wADF == 0, ADF == 0, useConstraints == 1)
d$Hits
h = d$Hits
data=data.frame(h)
plot=qplot(h, data=data, geom="histogram") 
ggsave(plot,file="./hist_pdfs/hist_cgp2p1_no_adf_no_cons.pdf")

print("cgp2p1_no_adf_cons")
dim(hs %>% filter(Framework == 2, wADF == 0, ADF == 0, useConstraints == 2))
d <- hs %>% filter(Framework == 2, wADF == 0, ADF == 0, useConstraints == 2)
d$Hits
h = d$Hits
data=data.frame(h)
plot=qplot(h, data=data, geom="histogram") 
ggsave(plot,file="./hist_pdfs/hist_cgp2p1_no_adf_cons.pdf")

print("cgp2p1_wadf_no_adf_no_cons")
dim(hs %>% filter(Framework == 3, wADF == 1, ADF == 0, useConstraints  == 1))
d <- hs %>% filter(Framework == 3, wADF == 1, ADF == 0, useConstraints  == 1)
d$Hits
h = d$Hits
data=data.frame(h)
plot=qplot(h, data=data, geom="histogram") 
ggsave(plot,file="./hist_pdfs/hist_cgp2p1_wadf_no_adf_no_cons.pdf")

print("cgp2p1_wadf_no_adf_cons")
dim(hs %>% filter(Framework == 3, wADF == 1, ADF == 0, useConstraints  == 2))
d <- hs %>% filter(Framework == 3, wADF == 1, ADF == 0, useConstraints  == 2)
d$Hits
h = d$Hits
data=data.frame(h)
plot=qplot(h, data=data, geom="histogram") 
ggsave(plot,file="./hist_pdfs/hist_cgp2p1_wadf_no_adf_cons.pdf")

print("cgp2p1_wadf_adf_no_cons")
dim(hs %>% filter(Framework == 4, wADF == 1, ADF == 1, useConstraints  == 1))
d <- hs %>% filter(Framework == 4, wADF == 1, ADF == 1, useConstraints  == 1)
d$Hits
h = d$Hits
data=data.frame(h)
plot=qplot(h, data=data, geom="histogram") 
ggsave(plot,file="./hist_pdfs/hist_cgp2p1_wadf_adf_no_cons.pdf")

print("cgp2p1_wadf_adf_cons")
dim(hs %>% filter(Framework == 4, wADF == 1, ADF == 1, useConstraints  == 2))
d <- hs %>% filter(Framework == 4, wADF == 1, ADF == 1, useConstraints  == 2)
d$Hits
h = d$Hits
data=data.frame(h)
plot=qplot(h, data=data, geom="histogram") 
ggsave(plot,file="./hist_pdfs/hist_cgp2p1_wadf_adf_cons.pdf")

#------
print("acgp1p1p2_no_adf_no_cons_what0")
dim(hs %>% filter(Framework == 5, wADF == 0, ADF == 0, useConstraints == 1, acgpwhat == 0))
d <- hs %>% filter(Framework == 5, wADF == 0, ADF == 0, useConstraints == 1, acgpwhat == 0)
d$Hits
h = d$Hits
data=data.frame(h)
plot=qplot(h, data=data, geom="histogram") 
ggsave(plot,file="./hist_pdfs/hist_acgp1p1p2_no_adf_no_cons_what0.pdf")

print("acgp1p1p2_no_adf_no_cons_what1")
dim(hs %>% filter(Framework == 5, wADF == 0, ADF == 0, useConstraints == 1, acgpwhat == 1))
d <- hs %>% filter(Framework == 5, wADF == 0, ADF == 0, useConstraints == 1, acgpwhat == 1)
d$Hits
h = d$Hits
data=data.frame(h)
plot=qplot(h, data=data, geom="histogram") 
ggsave(plot,file="./hist_pdfs/hist_acgp1p1p2_no_adf_no_cons_what1.pdf")

print("acgp1p1p2_no_adf_no_cons_what2")
dim(hs %>% filter(Framework == 5, wADF == 0, ADF == 0, useConstraints == 1, acgpwhat == 2))
d <- hs %>% filter(Framework == 5, wADF == 0, ADF == 0, useConstraints == 1, acgpwhat == 2)
d$Hits
h = d$Hits
data=data.frame(h)
plot=qplot(h, data=data, geom="histogram") 
ggsave(plot,file="./hist_pdfs/hist_acgp1p1p2_no_adf_no_cons_what2.pdf")

print("acgp1p1p2_no_adf_no_cons_what3")
dim(hs %>% filter(Framework == 5, wADF == 0, ADF == 0, useConstraints == 1, acgpwhat == 3))
d <- hs %>% filter(Framework == 5, wADF == 0, ADF == 0, useConstraints == 1, acgpwhat == 3)
d$Hits
h = d$Hits
data=data.frame(h)
plot=qplot(h, data=data, geom="histogram") 
ggsave(plot,file="./hist_pdfs/hist_acgp1p1p2_no_adf_no_cons_what3.pdf")

print("acgp1p1p2_no_adf_cons_what0")
dim(hs %>% filter(Framework == 5, wADF == 0, ADF == 0, useConstraints == 2, acgpwhat == 0))
d <- hs %>% filter(Framework == 5, wADF == 0, ADF == 0, useConstraints == 2, acgpwhat == 0)
d$Hits
h = d$Hits
data=data.frame(h)
plot=qplot(h, data=data, geom="histogram") 
ggsave(plot,file="./hist_pdfs/hist_acgp1p1p2_no_adf_cons_what0.pdf")

print("acgp1p1p2_no_adf_cons_what1")
dim(hs %>% filter(Framework == 5, wADF == 0, ADF == 0, useConstraints == 2, acgpwhat == 1))
d <- hs %>% filter(Framework == 5, wADF == 0, ADF == 0, useConstraints == 2, acgpwhat == 1)
d$Hits
h = d$Hits
data=data.frame(h)
plot=qplot(h, data=data, geom="histogram") 
ggsave(plot,file="./hist_pdfs/hist_acgp1p1p2_no_adf_cons_what1.pdf")

print("acgp1p1p2_no_adf_cons_what2")
dim(hs %>% filter(Framework == 5, wADF == 0, ADF == 0, useConstraints == 2, acgpwhat == 2))
d <- hs %>% filter(Framework == 5, wADF == 0, ADF == 0, useConstraints == 2, acgpwhat == 2)
d$Hits
h = d$Hits
data=data.frame(h)
plot=qplot(h, data=data, geom="histogram") 
ggsave(plot,file="./hist_pdfs/hist_acgp1p1p2_no_adf_cons_what2.pdf")

print("acgp1p1p2_no_adf_cons_what3")
dim(hs %>% filter(Framework == 5, wADF == 0, ADF == 0, useConstraints == 2, acgpwhat == 3))
d <- hs %>% filter(Framework == 5, wADF == 0, ADF == 0, useConstraints == 2, acgpwhat == 3)
d$Hits
h = d$Hits
data=data.frame(h)
plot=qplot(h, data=data, geom="histogram") 
ggsave(plot,file="./hist_pdfs/hist_acgp1p1p2_no_adf_cons_what3.pdf")

#------
print("acgp1p1p2_wadf_no_adf_no_cons_what0")
dim(hs %>% filter(Framework == 6, wADF == 1, ADF == 0, useConstraints == 1, acgpwhat == 0))
d <- hs %>% filter(Framework == 6, wADF == 1, ADF == 0, useConstraints == 1, acgpwhat == 0)
d$Hits
h = d$Hits
data=data.frame(h)
plot=qplot(h, data=data, geom="histogram") 
ggsave(plot,file="./hist_pdfs/hist_acgp1p1p2_wadf_no_adf_no_cons_what0.pdf")

print("acgp1p1p2_wadf_no_adf_no_cons_what1")
dim(hs %>% filter(Framework == 6, wADF == 1, ADF == 0, useConstraints == 1, acgpwhat == 1))
d <- hs %>% filter(Framework == 6, wADF == 1, ADF == 0, useConstraints == 1, acgpwhat == 1)
d$Hits
h = d$Hits
data=data.frame(h)
plot=qplot(h, data=data, geom="histogram") 
ggsave(plot,file="./hist_pdfs/hist_acgp1p1p2_wadf_no_adf_no_cons_what1.pdf")

print("acgp1p1p2_wadf_no_adf_no_cons_what2")
dim(hs %>% filter(Framework == 6, wADF == 1, ADF == 0, useConstraints == 1, acgpwhat == 2))
d <- hs %>% filter(Framework == 6, wADF == 1, ADF == 0, useConstraints == 1, acgpwhat == 2)
d$Hits
h = d$Hits
data=data.frame(h)
plot=qplot(h, data=data, geom="histogram") 
ggsave(plot,file="./hist_pdfs/hist_acgp1p1p2_wadf_no_adf_no_cons_what2.pdf")

print("acgp1p1p2_wadf_no_adf_no_cons_what3")
dim(hs %>% filter(Framework == 6, wADF == 1, ADF == 0, useConstraints == 1, acgpwhat == 3))
d <- hs %>% filter(Framework == 6, wADF == 1, ADF == 0, useConstraints == 1, acgpwhat == 3)
d$Hits
h = d$Hits
data=data.frame(h)
plot=qplot(h, data=data, geom="histogram") 
ggsave(plot,file="./hist_pdfs/hist_acgp1p1p2_wadf_no_adf_no_cons_what3.pdf")

print("acgp1p1p2_wadf_no_adf_cons_what0")
dim(hs %>% filter(Framework == 6, wADF == 1, ADF == 0, useConstraints == 2, acgpwhat == 0))
d <- hs %>% filter(Framework == 6, wADF == 1, ADF == 0, useConstraints == 2, acgpwhat == 0)
d$Hits
h = d$Hits
data=data.frame(h)
plot=qplot(h, data=data, geom="histogram") 
ggsave(plot,file="./hist_pdfs/hist_acgp1p1p2_wadf_no_adf_cons_what0.pdf")

print("acgp1p1p2_wadf_no_adf_cons_what1")
dim(hs %>% filter(Framework == 6, wADF == 1, ADF == 0, useConstraints == 2, acgpwhat == 1))
d <- hs %>% filter(Framework == 6, wADF == 1, ADF == 0, useConstraints == 2, acgpwhat == 1)
d$Hits
h = d$Hits
data=data.frame(h)
plot=qplot(h, data=data, geom="histogram") 
ggsave(plot,file="./hist_pdfs/hist_acgp1p1p2_wadf_no_adf_cons_what1.pdf")

print("acgp1p1p2_wadf_no_adf_cons_what2")
dim(hs %>% filter(Framework == 6, wADF == 1, ADF == 0, useConstraints == 2, acgpwhat == 2))
d <- hs %>% filter(Framework == 6, wADF == 1, ADF == 0, useConstraints == 2, acgpwhat == 2)
d$Hits
h = d$Hits
data=data.frame(h)
plot=qplot(h, data=data, geom="histogram") 
ggsave(plot,file="./hist_pdfs/hist_acgp1p1p2_wadf_no_adf_cons_what2.pdf")

print("acgp1p1p2_wadf_no_adf_cons_what3")
dim(hs %>% filter(Framework == 6, wADF == 1, ADF == 0, useConstraints == 2, acgpwhat == 3))
d <- hs %>% filter(Framework == 6, wADF == 1, ADF == 0, useConstraints == 2, acgpwhat == 3)
d$Hits
h = d$Hits
data=data.frame(h)
plot=qplot(h, data=data, geom="histogram") 
ggsave(plot,file="./hist_pdfs/hist_acgp1p1p2_wadf_no_adf_cons_what3.pdf")

#------
print("acgp1p1p2_wadf_adf_no_cons_what0")
dim(hs %>% filter(Framework == 7, wADF == 1, ADF == 1, useConstraints == 1, acgpwhat == 0))
d <- hs %>% filter(Framework == 7, wADF == 1, ADF == 1, useConstraints == 1, acgpwhat == 0)
d$Hits
h = d$Hits
data=data.frame(h)
plot=qplot(h, data=data, geom="histogram") 
ggsave(plot,file="./hist_pdfs/hist_acgp1p1p2_wadf_adf_no_cons_what0.pdf")

print("acgp1p1p2_wadf_adf_no_cons_what1")
dim(hs %>% filter(Framework == 7, wADF == 1, ADF == 1, useConstraints == 1, acgpwhat == 1))
d <- hs %>% filter(Framework == 7, wADF == 1, ADF == 1, useConstraints == 1, acgpwhat == 1)
d$Hits
h = d$Hits
data=data.frame(h)
plot=qplot(h, data=data, geom="histogram") 
ggsave(plot,file="./hist_pdfs/hist_acgp1p1p2_wadf_adf_no_cons_what1.pdf")

print("acgp1p1p2_wadf_adf_no_cons_what2")
dim(hs %>% filter(Framework == 7, wADF == 1, ADF == 1, useConstraints == 1, acgpwhat == 2))
d <- hs %>% filter(Framework == 7, wADF == 1, ADF == 1, useConstraints == 1, acgpwhat == 2)
d$Hits
h = d$Hits
data=data.frame(h)
plot=qplot(h, data=data, geom="histogram") 
ggsave(plot,file="./hist_pdfs/hist_acgp1p1p2_wadf_adf_no_cons_what2.pdf")

print("acgp1p1p2_wadf_adf_no_cons_what3")
dim(hs %>% filter(Framework == 7, wADF == 1, ADF == 1, useConstraints == 1, acgpwhat == 3))
d <- hs %>% filter(Framework == 7, wADF == 1, ADF == 1, useConstraints == 1, acgpwhat == 3)
d$Hits
h = d$Hits
data=data.frame(h)
plot=qplot(h, data=data, geom="histogram") 
ggsave(plot,file="./hist_pdfs/hist_acgp1p1p2_wadf_adf_no_cons_what3.pdf")

print("acgp1p1p2_wadf_adf_cons_what0")
dim(hs %>% filter(Framework == 7, wADF == 1, ADF == 1, useConstraints == 2, acgpwhat == 0))
d <- hs %>% filter(Framework == 7, wADF == 1, ADF == 1, useConstraints == 2, acgpwhat == 0)
d$Hits
h = d$Hits
data=data.frame(h)
plot=qplot(h, data=data, geom="histogram") 
ggsave(plot,file="./hist_pdfs/hist_acgp1p1p2_wadf_adf_cons_what0.pdf")

print("acgp1p1p2_wadf_adf_cons_what1")
dim(hs %>% filter(Framework == 7, wADF == 1, ADF == 1, useConstraints == 2, acgpwhat == 1))
d <- hs %>% filter(Framework == 7, wADF == 1, ADF == 1, useConstraints == 2, acgpwhat == 1)
d$Hits
h = d$Hits
data=data.frame(h)
plot=qplot(h, data=data, geom="histogram") 
ggsave(plot,file="./hist_pdfs/hist_acgp1p1p2_wadf_adf_cons_what1.pdf")

print("acgp1p1p2_wadf_adf_cons_what2")
dim(hs %>% filter(Framework == 7, wADF == 1, ADF == 1, useConstraints == 2, acgpwhat == 2))
d <- hs %>% filter(Framework == 7, wADF == 1, ADF == 1, useConstraints == 2, acgpwhat == 2)
d$Hits
h = d$Hits
data=data.frame(h)
plot=qplot(h, data=data, geom="histogram") 
ggsave(plot,file="./hist_pdfs/hist_acgp1p1p2_wadf_adf_cons_what2.pdf")

print("acgp1p1p2_wadf_adf_cons_what3")
dim(hs %>% filter(Framework == 7, wADF == 1, ADF == 1, useConstraints == 2, acgpwhat == 3))
d <- hs %>% filter(Framework == 7, wADF == 1, ADF == 1, useConstraints == 2, acgpwhat == 3)
d$Hits
h = d$Hits
data=data.frame(h)
plot=qplot(h, data=data, geom="histogram") 
ggsave(plot,file="./hist_pdfs/hist_acgp1p1p2_wadf_adf_cons_what3.pdf")

