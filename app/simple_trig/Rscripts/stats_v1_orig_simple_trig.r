library(crayon)
printf <- function(...) cat(sprintf(...))

blue_printf   <- function(...) cat(blue(...))
white_printf <- function(...) cat(white(sprintf(...)))
silver_printf <- function(...) cat(silver(sprintf(...)))

#---------
printf("orig_simple_trig_no_adfs: ")

orignoadf <- read.table("/home/ggerules/lilgp1.02/app/simple_trig/data/orig_simple_trig_no_adf/tmp/hits.txt", header=FALSE, sep=",", na.strings="NA", dec=".", strip.white=TRUE)

orignoadf <- with(orignoadf, orignoadf[order(V3, decreasing=FALSE), ])

#saves to a pdf file
#hist(x=orignoadf$V9, freq=TRUE)

ona <- mean(x=orignoadf$V9)
ostdna <- sd(x=orignoadf$V9)
minona <- min(orignoadf[,9])
maxona <- max(orignoadf[,9])

printf("mean=%4.3f, stddev=%4.3f, min=%4.3f, max=%4.3f\n", ona, ostdna, minona, maxona)

#---------
printf("orig_simple_trig_adfs:    ")

origadf <- read.table("/home/ggerules/lilgp1.02/app/simple_trig/data/orig_simple_trig_adf/tmp/hits.txt", header=FALSE, sep=",", na.strings="NA", dec=".", strip.white=TRUE)

origadf <- with(origadf, origadf[order(V3, decreasing=FALSE), ])

#hist(x=origadf$V9,freq=TRUE)

oa <- mean(x=origadf$V9)
ostda <- sd(x=origadf$V9)
minoa <- min(origadf[,9])
maxoa <- max(origadf[,9])

printf("mean=%4.3f, stddev=%4.3f, min=%4.3f, max=%4.3f\n", oa,  ostda,  minoa,  maxoa)

