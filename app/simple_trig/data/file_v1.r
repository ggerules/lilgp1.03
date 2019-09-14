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

attr(hs, "names")

hsg <- dplyr::group_by(hs, Framework, ProblemNum, wADF, ADF, useConstraints, acgpwhat)

attributes(hsg)

frmwrk_f <- factor(hsg$Framework)
prbnm_f <- factor(hsg$ProblemNum)
wadf_f <- factor(hsg$wADF)
adf_f <- factor(hsg$ADF)
usecons_f <- factor(hsg$useConstraints)
acgpwhat_f <- factor(hsg$acgpwhat)

levels(frmwrk_f)
levels(prbnm_f)
levels(acgpwhat_f)
levels(wadf_f)
levels(adf_f)
levels(usecons_f)

#hsg %>% filter(Framework == 0)
#hsg %>% filter(Framework == 1)
#hsg %>% filter(Framework == 3)
#hsg %>% filter(Framework == 4)
#hsg %>% filter(Framework == 5)
#hsg %>% filter(Framework == 6)
#hsg %>% filter(Framework == 7)

print("orig_noadf")
dim(hsg %>% filter(Framework == 0))

print("orig_adf")
dim(hsg %>% filter(Framework == 1))

#------
print("cgp2p1_no_adf_no_cons")
dim(hsg %>% filter(Framework == 2, wADF == 0, ADF == 0, useConstraints == 1))

print("cgp2p1_no_adf_cons")
dim(hsg %>% filter(Framework == 2, wADF == 0, ADF == 0, useConstraints == 2))

print("cgp2p1_wadf_no_adf_no_cons")
dim(hsg %>% filter(Framework == 3, wADF == 1, ADF == 0, useConstraints  == 1))

print("cgp2p1_wadf_no_adf_cons")
dim(hsg %>% filter(Framework == 3, wADF == 1, ADF == 0, useConstraints  == 2))

print("cgp2p1_wadf_adf_no_cons")
dim(hsg %>% filter(Framework == 4, wADF == 1, ADF == 1, useConstraints  == 1))

print("cgp2p1_wadf_adf_cons")
dim(hsg %>% filter(Framework == 4, wADF == 1, ADF == 1, useConstraints  == 2))

#------
print("acgp1p1p2_no_adf_no_cons what0")
dim(hsg %>% filter(Framework == 5, wADF == 0, ADF == 0, useConstraints == 1, acgpwhat == 0))

print("acgp1p1p2_no_adf_no_cons what1")
dim(hsg %>% filter(Framework == 5, wADF == 0, ADF == 0, useConstraints == 1, acgpwhat == 1))

print("acgp1p1p2_no_adf_no_cons what2")
dim(hsg %>% filter(Framework == 5, wADF == 0, ADF == 0, useConstraints == 1, acgpwhat == 2))

print("acgp1p1p2_no_adf_no_cons what3")
dim(hsg %>% filter(Framework == 5, wADF == 0, ADF == 0, useConstraints == 1, acgpwhat == 3))

print("acgp1p1p2_no_adf_cons what0")
dim(hsg %>% filter(Framework == 5, wADF == 0, ADF == 0, useConstraints == 2, acgpwhat == 0))

print("acgp1p1p2_no_adf_cons what1")
dim(hsg %>% filter(Framework == 5, wADF == 0, ADF == 0, useConstraints == 2, acgpwhat == 1))

print("acgp1p1p2_no_adf_cons what2")
dim(hsg %>% filter(Framework == 5, wADF == 0, ADF == 0, useConstraints == 2, acgpwhat == 2))

print("acgp1p1p2_no_adf_cons what3")
dim(hsg %>% filter(Framework == 5, wADF == 0, ADF == 0, useConstraints == 2, acgpwhat == 3))

#------
print("acgp1p1p2_wadf_no_adf_no_cons what0")
dim(hsg %>% filter(Framework == 6, wADF == 1, ADF == 0, useConstraints == 1, acgpwhat == 0))

print("acgp1p1p2_wadf_no_adf_no_cons what1")
dim(hsg %>% filter(Framework == 6, wADF == 1, ADF == 0, useConstraints == 1, acgpwhat == 1))

print("acgp1p1p2_wadf_no_adf_no_cons what2")
dim(hsg %>% filter(Framework == 6, wADF == 1, ADF == 0, useConstraints == 1, acgpwhat == 2))

print("acgp1p1p2_wadf_no_adf_no_cons what3")
dim(hsg %>% filter(Framework == 6, wADF == 1, ADF == 0, useConstraints == 1, acgpwhat == 3))

print("acgp1p1p2_wadf_no_adf_cons what0")
dim(hsg %>% filter(Framework == 6, wADF == 1, ADF == 0, useConstraints == 2, acgpwhat == 0))

print("acgp1p1p2_wadf_no_adf_cons what1")
dim(hsg %>% filter(Framework == 6, wADF == 1, ADF == 0, useConstraints == 2, acgpwhat == 1))

print("acgp1p1p2_wadf_no_adf_cons what2")
dim(hsg %>% filter(Framework == 6, wADF == 1, ADF == 0, useConstraints == 2, acgpwhat == 2))

print("acgp1p1p2_wadf_no_adf_cons what3")
dim(hsg %>% filter(Framework == 6, wADF == 1, ADF == 0, useConstraints == 2, acgpwhat == 3))

#------
print("acgp1p1p2_wadf_adf_no_cons what0")
dim(hsg %>% filter(Framework == 7, wADF == 1, ADF == 1, useConstraints == 1, acgpwhat == 0))

print("acgp1p1p2_wadf_adf_no_cons what1")
dim(hsg %>% filter(Framework == 7, wADF == 1, ADF == 1, useConstraints == 1, acgpwhat == 1))

print("acgp1p1p2_wadf_adf_no_cons what2")
dim(hsg %>% filter(Framework == 7, wADF == 1, ADF == 1, useConstraints == 1, acgpwhat == 2))

print("acgp1p1p2_wadf_adf_no_cons what3")
dim(hsg %>% filter(Framework == 7, wADF == 1, ADF == 1, useConstraints == 1, acgpwhat == 3))

print("acgp1p1p2_wadf_adf_cons what0")
dim(hsg %>% filter(Framework == 7, wADF == 1, ADF == 1, useConstraints == 2, acgpwhat == 0))

print("acgp1p1p2_wadf_adf_cons what1")
dim(hsg %>% filter(Framework == 7, wADF == 1, ADF == 1, useConstraints == 2, acgpwhat == 1))

print("acgp1p1p2_wadf_adf_cons what2")
dim(hsg %>% filter(Framework == 7, wADF == 1, ADF == 1, useConstraints == 2, acgpwhat == 2))

print("acgp1p1p2_wadf_adf_cons what3")
dim(hsg %>% filter(Framework == 7, wADF == 1, ADF == 1, useConstraints == 2, acgpwhat == 3))

