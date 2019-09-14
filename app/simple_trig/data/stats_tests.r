library(ggplot2)
library(dplyr)
library(crayon)

printf <- function(...) cat(sprintf(...))

blue_printf   <- function(...) cat(blue(...))
white_printf <- function(...) cat(white(sprintf(...)))
silver_printf <- function(...) cat(silver(sprintf(...)))
 

info <- function(dd) 
{
  vv <- dim(dd)
  silver_printf(" rows: %d\n",vv[1])
  silver_printf(" hits: ")
   silver_printf("%s", d$Hits)
   printf("\n")

  ona <- mean(x=dd$Hits)
  ostdna <- sd(x=dd$Hits)
  minona <- min(dd$Hits)
  maxona <- max(dd$Hits)
  silver_printf(" mean=%4.3f, stddev=%4.3f, min=%4.3f, max=%4.3f\n", ona, ostdna, minona, maxona)
}

hits <- read.table("/home/ggerules/lilgp1.02/app/simple_trig/data/hitslong.csv", header=TRUE, sep=",", na.strings="NA", dec=".", strip.white=TRUE)
hs <- with(hits, hits[order(Framework, ProblemNum, wADF, ADF, acgpwhat, useConstraints, IndRunNum, decreasing=FALSE), ])

blue_printf("orig_noadf\n")
d <- hs %>% filter(Framework == 0)
info(d)
orig_no_adf= d$Hits

blue_printf("orig_adf\n")
d <- hs %>% filter(Framework == 1)
info(d)
orig_adf = d$Hits

#blue_printf("cgp2p1_no_adf_no_cons\n")
#d <- hs %>% filter(Framework == 2, wADF == 0, ADF == 0, useConstraints == 1)
#info(d)
#cgp2p1_no_adf_no_cons = d$Hits
#
#blue_printf("cgp2p1_no_adf_cons\n")
#d <- hs %>% filter(Framework == 2, wADF == 0, ADF == 0, useConstraints == 2)
#info(d)
#cgp2p1_no_adf_cons = d$Hits
#
#blue_printf("cgp2p1_wadf_no_adf_no_cons\n")
#d <- hs %>% filter(Framework == 3, wADF == 1, ADF == 0, useConstraints  == 1)
#info(d)
#cgp2p1_wadf_no_adf_no_cons = d$Hits
#
#blue_printf("cgp2p1_wadf_no_adf_cons\n")
#d <- hs %>% filter(Framework == 3, wADF == 1, ADF == 0, useConstraints  == 2)
#info(d)
#cgp2p1_wadf_no_adf_cons = d$Hits
#
#blue_printf("cgp2p1_wadf_adf_no_cons\n")
#d <- hs %>% filter(Framework == 4, wADF == 1, ADF == 1, useConstraints  == 1)
#info(d)
#cgp2p1_wadf_adf_no_cons = d$Hits
#
#blue_printf("cgp2p1_wadf_adf_cons\n")
#d <- hs %>% filter(Framework == 4, wADF == 1, ADF == 1, useConstraints  == 2)
#info(d)
#cgp2p1_wadf_adf_cons = d$Hits

#------
blue_printf("acgp1p1p2_no_adf_no_cons_what0\n")
d <- hs %>% filter(Framework == 5, wADF == 0, ADF == 0, useConstraints == 1, acgpwhat == 0)
info(d)
acgp1p1p2_no_adf_no_cons_what0 = d$Hits

blue_printf("acgp1p1p2_no_adf_no_cons_what1\n")
d <- hs %>% filter(Framework == 5, wADF == 0, ADF == 0, useConstraints == 1, acgpwhat == 1)
info(d)
acgp1p1p2_no_adf_no_cons_what1 = d$Hits

blue_printf("acgp1p1p2_no_adf_no_cons_what2\n")
d <- hs %>% filter(Framework == 5, wADF == 0, ADF == 0, useConstraints == 1, acgpwhat == 2)
info(d)
acgp1p1p2_no_adf_no_cons_what2 = d$Hits

blue_printf("acgp1p1p2_no_adf_no_cons_what3\n")
d <- hs %>% filter(Framework == 5, wADF == 0, ADF == 0, useConstraints == 1, acgpwhat == 3)
info(d)
acgp1p1p2_no_adf_no_cons_what3 = d$Hits

blue_printf("acgp1p1p2_no_adf_cons_what0\n")
d <- hs %>% filter(Framework == 5, wADF == 0, ADF == 0, useConstraints == 2, acgpwhat == 0)
info(d)
acgp1p1p2_no_adf_cons_what0 = d$Hits

blue_printf("acgp1p1p2_no_adf_cons_what1\n")
d <- hs %>% filter(Framework == 5, wADF == 0, ADF == 0, useConstraints == 2, acgpwhat == 1)
info(d)
acgp1p1p2_no_adf_cons_what1 = d$Hits

blue_printf("acgp1p1p2_no_adf_cons_what2\n")
d <- hs %>% filter(Framework == 5, wADF == 0, ADF == 0, useConstraints == 2, acgpwhat == 2)
info(d)
acgp1p1p2_no_adf_cons_what2 = d$Hits

blue_printf("acgp1p1p2_no_adf_cons_what3\n")
d <- hs %>% filter(Framework == 5, wADF == 0, ADF == 0, useConstraints == 2, acgpwhat == 3)
info(d)
acgp1p1p2_no_adf_cons_what3 = d$Hits

#------
blue_printf("acgp1p1p2_wadf_types_no_adf_no_cons_what0\n")
d <- hs %>% filter(Framework == 6, wADF == 1, ADF == 0, useConstraints == 1, acgpwhat == 0)
info(d)
acgp1p1p2_wadf_types_no_adf_no_cons_what0 = d$Hits

blue_printf("acgp1p1p2_wadf_types_no_adf_no_cons_what1\n")
d <- hs %>% filter(Framework == 6, wADF == 1, ADF == 0, useConstraints == 1, acgpwhat == 1)
info(d)
acgp1p1p2_wadf_types_no_adf_no_cons_what1 = d$Hits

blue_printf("acgp1p1p2_wadf_types_no_adf_no_cons_what2\n")
d <- hs %>% filter(Framework == 6, wADF == 1, ADF == 0, useConstraints == 1, acgpwhat == 2)
info(d)
acgp1p1p2_wadf_types_no_adf_no_cons_what2 = d$Hits

blue_printf("acgp1p1p2_wadf_types_no_adf_no_cons_what3\n")
d <- hs %>% filter(Framework == 6, wADF == 1, ADF == 0, useConstraints == 1, acgpwhat == 3)
info(d)
acgp1p1p2_wadf_types_no_adf_no_cons_what3 = d$Hits

blue_printf("acgp1p1p2_wadf_types_no_adf_cons_what0\n")
d <- hs %>% filter(Framework == 6, wADF == 1, ADF == 0, useConstraints == 2, acgpwhat == 0)
info(d)
acgp1p1p2_wadf_types_no_adf_cons_what0 = d$Hits

blue_printf("acgp1p1p2_wadf_types_no_adf_cons_what1\n")
d <- hs %>% filter(Framework == 6, wADF == 1, ADF == 0, useConstraints == 2, acgpwhat == 1)
info(d)
acgp1p1p2_wadf_types_no_adf_cons_what1 = d$Hits

blue_printf("acgp1p1p2_wadf_types_no_adf_cons_what2\n")
d <- hs %>% filter(Framework == 6, wADF == 1, ADF == 0, useConstraints == 2, acgpwhat == 2)
info(d)
acgp1p1p2_wadf_types_no_adf_cons_what2 = d$Hits

blue_printf("acgp1p1p2_wadf_types_no_adf_cons_what3\n")
d <- hs %>% filter(Framework == 6, wADF == 1, ADF == 0, useConstraints == 2, acgpwhat == 3)
info(d)
acgp1p1p2_wadf_types_no_adf_cons_what3 = d$Hits

#------
blue_printf("acgp1p1p2_wadf_types_adf_no_cons_what0\n")
d <- hs %>% filter(Framework == 7, wADF == 1, ADF == 1, useConstraints == 1, acgpwhat == 0)
info(d)
acgp1p1p2_wadf_types_adf_no_cons_what0 = d$Hits

blue_printf("acgp1p1p2_wadf_types_adf_no_cons_what1\n")
d <- hs %>% filter(Framework == 7, wADF == 1, ADF == 1, useConstraints == 1, acgpwhat == 1)
info(d)
acgp1p1p2_wadf_types_adf_no_cons_what1 = d$Hits

blue_printf("acgp1p1p2_wadf_types_adf_no_cons_what2\n")
d <- hs %>% filter(Framework == 7, wADF == 1, ADF == 1, useConstraints == 1, acgpwhat == 2)
info(d)
acgp1p1p2_wadf_types_adf_no_cons_what2 = d$Hits

blue_printf("acgp1p1p2_wadf_types_adf_no_cons_what3\n")
d <- hs %>% filter(Framework == 7, wADF == 1, ADF == 1, useConstraints == 1, acgpwhat == 3)
info(d)
acgp1p1p2_wadf_types_adf_no_cons_what3 = d$Hits

blue_printf("acgp1p1p2_wadf_types_adf_cons_what0\n")
d <- hs %>% filter(Framework == 7, wADF == 1, ADF == 1, useConstraints == 2, acgpwhat == 0)
info(d)
acgp1p1p2_wadf_types_adf_cons_what0 = d$Hits

blue_printf("acgp1p1p2_wadf_types_adf_cons_what1\n")
d <- hs %>% filter(Framework == 7, wADF == 1, ADF == 1, useConstraints == 2, acgpwhat == 1)
info(d)
acgp1p1p2_wadf_types_adf_cons_what1 = d$Hits

blue_printf("acgp1p1p2_wadf_types_adf_cons_what2\n")
d <- hs %>% filter(Framework == 7, wADF == 1, ADF == 1, useConstraints == 2, acgpwhat == 2)
info(d)
acgp1p1p2_wadf_types_adf_cons_what2 = d$Hits

blue_printf("acgp1p1p2_wadf_types_adf_cons_what3\n")
d <- hs %>% filter(Framework == 7, wADF == 1, ADF == 1, useConstraints == 2, acgpwhat == 3)
info(d)
acgp1p1p2_wadf_types_adf_cons_what3 = d$Hits

#orig_no_adf
#orig_adf 
#printf("This is from: http://r-statistics.co/Statistical-Tests-in-R.html")
wilcox.test(orig_no_adf,orig_adf, alternative="g")
#ks.test(orig_no_adf, orig_adf)

#original acgp1p1p2 code 
#acgp1p1p2_no_adf_no_cons_what0 
#acgp1p1p2_no_adf_no_cons_what1 
#acgp1p1p2_no_adf_no_cons_what2 
#acgp1p1p2_no_adf_no_cons_what3 

wilcox.test(acgp1p1p2_no_adf_no_cons_what0 ,acgp1p1p2_no_adf_no_cons_what3,  alternative="g")

#acgp1p1p2_no_adf_cons_what0 
#acgp1p1p2_no_adf_cons_what1 
#acgp1p1p2_no_adf_cons_what2 
#acgp1p1p2_no_adf_cons_what3 

wilcox.test(acgp1p1p2_no_adf_cons_what0 ,acgp1p1p2_no_adf_cons_what3,  alternative="g")

#acgp1p1p2 that has new adf and types code
#acgp1p1p2_wadf_types_no_adf_no_cons_what0 
#acgp1p1p2_wadf_types_no_adf_no_cons_what1 
#acgp1p1p2_wadf_types_no_adf_no_cons_what2 
#acgp1p1p2_wadf_types_no_adf_no_cons_what3 
#acgp1p1p2_wadf_types_no_adf_cons_what0 
#acgp1p1p2_wadf_types_no_adf_cons_what1 
#acgp1p1p2_wadf_types_no_adf_cons_what2 
#acgp1p1p2_wadf_types_no_adf_cons_what3 
#acgp1p1p2_wadf_types_adf_no_cons_what0 
#acgp1p1p2_wadf_types_adf_no_cons_what1 
#acgp1p1p2_wadf_types_adf_no_cons_what2 
#acgp1p1p2_wadf_types_adf_no_cons_what3 
#acgp1p1p2_wadf_types_adf_cons_what0 
#acgp1p1p2_wadf_types_adf_cons_what1 
#acgp1p1p2_wadf_types_adf_cons_what2 
#acgp1p1p2_wadf_types_adf_cons_what3 
