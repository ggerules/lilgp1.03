[+ AutoGen5 template r +]
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

hits <- read.table("[+homedir+][+probname+][+hitslongdata+]", header=TRUE, sep=",", na.strings="NA", dec=".", strip.white=TRUE)
hs <- with(hits, hits[order(Kernel, ProblemNum, wADF, ADF, Types, Constraints, acgpwhat, IndRunNum, decreasing=FALSE), ])

[+ FOR objlst +][+IF (exist? "kname")+][+ FOR dirname +]
blue_printf("[+dirname+]\n")
d <- hs %>% filter(Kernel == [+frmwrk+], wADF == "[+wadf+]", ADF == "[+adf+]", Types == "[+types+]", Constraints == "[+cons+]", acgpwhat == "[+what+]")
info(d)
#orig_no_adf= d$Hits[+
ENDFOR dirname +][+ENDIF+][+ ENDFOR objlst +]

#blue_printf("orig_adf\n")
#d <- hs %>% filter(Kernel == 0, wADF == "y", ADF == "y")
#info(d)
#orig_adf = d$Hits

#orig_no_adf
#orig_adf 
#printf("This is from: http://r-statistics.co/Statistical-Tests-in-R.html")
#wilcox.test(orig_no_adf,orig_adf, alternative="g")
#ks.test(orig_no_adf, orig_adf)


