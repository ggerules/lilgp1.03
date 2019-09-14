
hits <- read.table("/home/ggerules/lilgp1.02/app/simple_trig/data/hitslong.csv", header=TRUE, sep=",", 
  na.strings="NA", dec=".", strip.white=TRUE)
hits_sorted <- with(hits, hits[order(Framework, ProblemNum, wADF, ADF, acgpwhat, 
  useConstraints, IndRunNum, decreasing=FALSE), ])

