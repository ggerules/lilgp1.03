printf <- function(...) cat(sprintf(...))

# acgp1p1p2_wadf_simple_trig_no_adf_types

# ----------- what=0
acgp1p1p2_no_constraints <- read.table("/home/ggerules/lilgp1.02/app/simple_trig/data/acgp1p1p2_wadf_simple_trig_no_adf_types/no_constraints/tmp_w0/hits.txt", header=FALSE, sep=",", na.strings="NA", dec=".", strip.white=TRUE)

acgp1p1p2_no_constraints <- with(acgp1p1p2_no_constraints, acgp1p1p2_no_constraints[order(V3, decreasing=FALSE), ])

#saves to a pdf file
#hist(x=origadf$V9,freq=TRUE)

printf("%s", "acgp1p1p2_wadf_simple_trig_no_adf_types_no_constraints, what=0: " )
acnanc_mean <- mean(x=acgp1p1p2_no_constraints$V9)
acnanc_std <- sd(x=acgp1p1p2_no_constraints$V9)
acnanc_min <- min(acgp1p1p2_no_constraints[,9])
acnanc_max <- max(acgp1p1p2_no_constraints[,9])

printf("  mean=%4.3f, stddev=%4.3f, min=%4.3f, max=%4.3f\n", acnanc_mean,  acnanc_std,  acnanc_min,  acnanc_max)

# ----------- what=1
acgp1p1p2_no_constraints <- read.table("/home/ggerules/lilgp1.02/app/simple_trig/data/acgp1p1p2_wadf_simple_trig_no_adf_types/no_constraints/tmp_w1/hits.txt", header=FALSE, sep=",", na.strings="NA", dec=".", strip.white=TRUE)

acgp1p1p2_no_constraints <- with(acgp1p1p2_no_constraints, acgp1p1p2_no_constraints[order(V3, decreasing=FALSE), ])

#saves to a pdf file
#hist(x=origadf$V9,freq=TRUE)

printf("%s", "acgp1p1p2_wadf_simple_trig_no_adf_types_no_constraints, what=1: " )
acnanc_mean <- mean(x=acgp1p1p2_no_constraints$V9)
acnanc_std <- sd(x=acgp1p1p2_no_constraints$V9)
acnanc_min <- min(acgp1p1p2_no_constraints[,9])
acnanc_max <- max(acgp1p1p2_no_constraints[,9])

printf("  mean=%4.3f, stddev=%4.3f, min=%4.3f, max=%4.3f\n", acnanc_mean,  acnanc_std,  acnanc_min,  acnanc_max)

# ----------- what=2
acgp1p1p2_no_constraints <- read.table("/home/ggerules/lilgp1.02/app/simple_trig/data/acgp1p1p2_wadf_simple_trig_no_adf_types/no_constraints/tmp_w2/hits.txt", header=FALSE, sep=",", na.strings="NA", dec=".", strip.white=TRUE)

acgp1p1p2_no_constraints <- with(acgp1p1p2_no_constraints, acgp1p1p2_no_constraints[order(V3, decreasing=FALSE), ])

#saves to a pdf file
#hist(x=origadf$V9,freq=TRUE)

printf("%s", "acgp1p1p2_wadf_simple_trig_no_adf_types_no_constraints, what=2: " )
acnanc_mean <- mean(x=acgp1p1p2_no_constraints$V9)
acnanc_std <- sd(x=acgp1p1p2_no_constraints$V9)
acnanc_min <- min(acgp1p1p2_no_constraints[,9])
acnanc_max <- max(acgp1p1p2_no_constraints[,9])

printf("  mean=%4.3f, stddev=%4.3f, min=%4.3f, max=%4.3f\n", acnanc_mean,  acnanc_std,  acnanc_min,  acnanc_max)

# ----------- what=3
acgp1p1p2_no_constraints <- read.table("/home/ggerules/lilgp1.02/app/simple_trig/data/acgp1p1p2_wadf_simple_trig_no_adf_types/no_constraints/tmp_w3/hits.txt", header=FALSE, sep=",", na.strings="NA", dec=".", strip.white=TRUE)

acgp1p1p2_no_constraints <- with(acgp1p1p2_no_constraints, acgp1p1p2_no_constraints[order(V3, decreasing=FALSE), ])

#saves to a pdf file
#hist(x=origadf$V9,freq=TRUE)

printf("%s", "acgp1p1p2_wadf_simple_trig_no_adf_types_no_constraints, what=3: " )
acnanc_mean <- mean(x=acgp1p1p2_no_constraints$V9)
acnanc_std <- sd(x=acgp1p1p2_no_constraints$V9)
acnanc_min <- min(acgp1p1p2_no_constraints[,9])
acnanc_max <- max(acgp1p1p2_no_constraints[,9])

printf("  mean=%4.3f, stddev=%4.3f, min=%4.3f, max=%4.3f\n", acnanc_mean,  acnanc_std,  acnanc_min,  acnanc_max)


# ----------- what=0

acgp1p1p2_constraints <- read.table("/home/ggerules/lilgp1.02/app/simple_trig/data/acgp1p1p2_wadf_simple_trig_no_adf_types/constraints/tmp_w0/hits.txt", header=FALSE, sep=",", na.strings="NA", dec=".", strip.white=TRUE)

acgp1p1p2_constraints <- with(acgp1p1p2_constraints, acgp1p1p2_constraints[order(V3, decreasing=FALSE), ])

#hist(x=orignoadf$V9, freq=TRUE)

printf("%s", "acgp1p1p2_wadf_simple_trig_no_adf_types_constraints, what=0: " )
acnac_mean <- mean(x=acgp1p1p2_constraints$V9)
acnac_std <- sd(x=acgp1p1p2_constraints$V9)
acnac_min <- min(acgp1p1p2_constraints[,9])
acnac_max <- max(acgp1p1p2_constraints[,9])

printf("  mean=%4.3f, stddev=%4.3f, min=%4.3f, max=%4.3f\n", acnac_mean,  acnac_std,  acnac_min,  acnac_max)

# ----------- what=1

acgp1p1p2_constraints <- read.table("/home/ggerules/lilgp1.02/app/simple_trig/data/acgp1p1p2_wadf_simple_trig_no_adf_types/constraints/tmp_w1/hits.txt", header=FALSE, sep=",", na.strings="NA", dec=".", strip.white=TRUE)

acgp1p1p2_constraints <- with(acgp1p1p2_constraints, acgp1p1p2_constraints[order(V3, decreasing=FALSE), ])

#hist(x=orignoadf$V9, freq=TRUE)

printf("%s", "acgp1p1p2_wadf_simple_trig_no_adf_types_constraints, what=1: " )
acnac_mean <- mean(x=acgp1p1p2_constraints$V9)
acnac_std <- sd(x=acgp1p1p2_constraints$V9)
acnac_min <- min(acgp1p1p2_constraints[,9])
acnac_max <- max(acgp1p1p2_constraints[,9])

printf("  mean=%4.3f, stddev=%4.3f, min=%4.3f, max=%4.3f\n", acnac_mean,  acnac_std,  acnac_min,  acnac_max)

# ----------- what=2

acgp1p1p2_constraints <- read.table("/home/ggerules/lilgp1.02/app/simple_trig/data/acgp1p1p2_wadf_simple_trig_no_adf_types/constraints/tmp_w2/hits.txt", header=FALSE, sep=",", na.strings="NA", dec=".", strip.white=TRUE)

acgp1p1p2_constraints <- with(acgp1p1p2_constraints, acgp1p1p2_constraints[order(V3, decreasing=FALSE), ])

#hist(x=orignoadf$V9, freq=TRUE)

printf("%s", "acgp1p1p2_wadf_simple_trig_no_adf_types_constraints, what=2: " )
acnac_mean <- mean(x=acgp1p1p2_constraints$V9)
acnac_std <- sd(x=acgp1p1p2_constraints$V9)
acnac_min <- min(acgp1p1p2_constraints[,9])
acnac_max <- max(acgp1p1p2_constraints[,9])

printf("  mean=%4.3f, stddev=%4.3f, min=%4.3f, max=%4.3f\n", acnac_mean,  acnac_std,  acnac_min,  acnac_max)

# ----------- what=3

acgp1p1p2_constraints <- read.table("/home/ggerules/lilgp1.02/app/simple_trig/data/acgp1p1p2_wadf_simple_trig_no_adf_types/constraints/tmp_w3/hits.txt", header=FALSE, sep=",", na.strings="NA", dec=".", strip.white=TRUE)

acgp1p1p2_constraints <- with(acgp1p1p2_constraints, acgp1p1p2_constraints[order(V3, decreasing=FALSE), ])

#hist(x=orignoadf$V9, freq=TRUE)

printf("%s", "acgp1p1p2_wadf_simple_trig_no_adf_types_constraints, what=3: " )
acnac_mean <- mean(x=acgp1p1p2_constraints$V9)
acnac_std <- sd(x=acgp1p1p2_constraints$V9)
acnac_min <- min(acgp1p1p2_constraints[,9])
acnac_max <- max(acgp1p1p2_constraints[,9])

printf("  mean=%4.3f, stddev=%4.3f, min=%4.3f, max=%4.3f\n", acnac_mean,  acnac_std,  acnac_min,  acnac_max)

