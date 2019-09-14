printf <- function(...) cat(sprintf(...))

# cgp2p1p_wadf_simple_trig_adf

# -----------
cgp2p1_no_constraints <- read.table("/home/ggerules/lilgp1.02/app/simple_trig/data/cgp2p1_wadf_simple_trig_adf/no_constraints/tmp/hits.txt", header=FALSE, sep=",", na.strings="NA", dec=".", strip.white=TRUE)

cgp2p1_no_constraints <- with(cgp2p1_no_constraints, cgp2p1_no_constraints[order(V3, decreasing=FALSE), ])

#saves to a pdf file
#hist(x=origadf$V9,freq=TRUE)

printf("%s", "cgp2p1_wadf_simple_trig_adf_no_constraints: " )
cnanc_mean <- mean(x=cgp2p1_no_constraints$V9)
cnanc_std <- sd(x=cgp2p1_no_constraints$V9)
cnanc_min <- min(cgp2p1_no_constraints[,9])
cnanc_max <- max(cgp2p1_no_constraints[,9])

printf("mean=%4.3f, stddev=%4.3f, min=%4.3f, max=%4.3f\n", cnanc_mean,  cnanc_std,  cnanc_min,  cnanc_max)

# -----------

cgp2p1_constraints <- read.table("/home/ggerules/lilgp1.02/app/simple_trig/data/cgp2p1_wadf_simple_trig_adf/constraints/tmp/hits.txt", header=FALSE, sep=",", na.strings="NA", dec=".", strip.white=TRUE)

cgp2p1_constraints <- with(cgp2p1_constraints, cgp2p1_constraints[order(V3, decreasing=FALSE), ])

#hist(x=orignoadf$V9, freq=TRUE)

printf("%s", "cgp2p1_wadf_simple_trig_adf_constraints:    " )
cnac_mean <- mean(x=cgp2p1_constraints$V9)
cnac_std <- sd(x=cgp2p1_constraints$V9)
cnac_min <- min(cgp2p1_constraints[,9])
cnac_max <- max(cgp2p1_constraints[,9])

printf("mean=%4.3f, stddev=%4.3f, min=%4.3f, max=%4.3f\n", cnac_mean,  cnac_std,  cnac_min,  cnac_max)

