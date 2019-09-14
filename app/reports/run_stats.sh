#!/usr/bin/env Rscript

library(argparser, quietly=TRUE)
library(DBI)
library(RSQLite)
library(dplyr, quietly=TRUE, warn.conflicts = FALSE)
library(crayon)
library(stringr)

# Create a parser
p <- arg_parser("wilcoxon sign rank test")

# Add command line arguments
#p <- add_argument(p, "pnum", help="problem number", type="numeric")
p <- add_argument(p, "dispdata", help="display data y/n", type="character")

#p <- add_argument(p, "desc", help="description", type="character")

p <- add_argument(p, "f1pnum", help="framework 1 problem number", type="character")
p <- add_argument(p, "f1kerp1v ", help="framework 1 kernel number", type="character")
p <- add_argument(p, "f1wadfv", help="framework 1 wadf y/n", type="character")
p <- add_argument(p, "f1adfv ", help="framework 1 adf y/n", type="character")
p <- add_argument(p, "f1typesv ", help="framework 1 types y/n", type="character")
p <- add_argument(p, "f1consv ", help="framework 1 constraints y/n", type="character")
p <- add_argument(p, "f1acgpwhatv ", help="framework 1 what char n,0,1,2,3", type="character")

p <- add_argument(p, "f2pnum", help="framework 2 problem number", type="character")
p <- add_argument(p, "f2kerp1v ", help="framework 2 kernel number", type="character")
p <- add_argument(p, "f2wadfv", help="framework 2 wadf y/n", type="character")
p <- add_argument(p, "f2adfv ", help="framework 2 adf y/n", type="character")
p <- add_argument(p, "f2typesv ", help="framework 2 types y/n", type="character")
p <- add_argument(p, "f2consv ", help="framework 2 constraints y/n", type="character")
p <- add_argument(p, "f2acgpwhatv ", help="framework 2 what char n,0,1,2,3", type="character")

#p <- add_argument(p, "--digits", help="number of decimal places", default=0)

# Parse the command line arguments
argv <- parse_args(p)

printf <- function(...) cat(sprintf(...))
prnf <- function(...) cat(sprintf("%f ", ...))
prnd <- function(...) cat(sprintf("%d ", ...))
prln <- function(...) cat(sprintf("\n"))

blue_printf   <- function(...) cat(blue(...))
white_printf <- function(...) cat(white(sprintf(...)))
silver_printf <- function(...) cat(silver(sprintf(...)))

#RSQLite::rsqliteVersion()
# 
drv <- dbDriver("SQLite")
con <- dbConnect(drv, dbname = "/home/ggerules/lilgp1.02/app/reports/data.db")
#dbListTables(con)

f1pnv <- argv$f1pnum
f1wadfv <- argv$f1wadfv 
f1adfv <- argv$f1adfv 
f1kerp1v <- argv$f1kerp1v 
f1typesv <- argv$f1typesv 
f1consv <- argv$f1consv 
f1acgpwhatv <- argv$f1acgpwhatv 


#f1wadfv <- "y"
#f1adfv <- "n"
#f1kerp1v <- "0"
#f1typesv <- "n"
#f1consv <- "n"
#f1acgpwhatv <- "n"

sel <- "select Hits from beststatslong where "
wadf <- "wADF in ('"
ap1 <- "') and "
adf <- "ADF in ('"
types <- "Types in ('"
cons <- "Constraints in ('"
acgpwhat <- "acgpwhat in ('"
pn <- "ProblemNum = "
ap2 <- " and "
kerp1 <- "Kernel = "
e1 <- " )"

selstat1 <- str_c(sel,wadf,f1wadfv,ap1,adf,f1adfv,ap1,types,f1typesv,ap1,cons,f1consv,ap1,acgpwhat,f1acgpwhatv,ap1,pn,f1pnv,ap2,kerp1,f1kerp1v)
#selstat1

#rs <- dbSendQuery(con, "select Hits from beststatslong where (wADF in ('y')) and (ADF in ('n'))  and (ProblemNum = 37 and Kernel = 0 )")
rs <- dbSendQuery(con, selstat1)
d1 <- fetch(rs)
#dbHasCompleted(rs)
#d1
#d1$Hits
dbClearResult(rs)
#dim(d1)
#str(d1)
#class(d1)
#names(d1)

f2pnv <- argv$f2pnum
f2wadfv <- argv$f2wadfv 
f2adfv <- argv$f2adfv 
f2kerp1v <- argv$f2kerp1v 
f2typesv <- argv$f2typesv 
f2consv <- argv$f2consv 
f2acgpwhatv <- argv$f2acgpwhatv 


#f2pnv <- argv$f1pnum
#f2wadfv <- "y"
#f2adfv <- "y"
#f2kerp1v <- "4"
#f2typesv <- "n"
#f2consv <- "n"
#f2acgpwhatv <- "3"

selstat1 <- str_c(sel,wadf,f2wadfv,ap1,adf,f2adfv,ap1,types,f2typesv,ap1,cons,f2consv,ap1,acgpwhat,f2acgpwhatv,ap1,pn,f2pnv,ap2,kerp1,f2kerp1v)
#selstat1


#rs <- dbSendQuery(con, "select Hits from beststatslong where wADF in ('y') and ADF in ('y') and Types in ('n') and Constraints in ('n')  and ProblemNum = 37 and Kernel = 4 and acgpwhat = 3")
rs <- dbSendQuery(con, selstat1)
d2 <- fetch(rs)
#dbHasCompleted(rs)
#d2
#d2$Hits
dbClearResult(rs)
#dim(d2)
#str(d2)
#class(d2)
#names(d2)

desc <- "p" 
desc <- str_c(desc, argv$f1pnum, " ")

if(argv$f1pnum == "3") {
  desc <- str_c(desc, " two box ")
} else if (argv$f1pnum == "5") {
  desc <- str_c(desc, " koza1 regression ")
} else if (argv$f1pnum == "8") {
  desc <- str_c(desc, " koza1 regression 2adfs ")
} else if (argv$f1pnum == "11") {
  desc <- str_c(desc, " lawnmower_8x8_md_17 ")
} else if (argv$f1pnum == "12") {
  desc <- str_c(desc, " lawnmower_8x4_md_17 ")
} else if (argv$f1pnum == "13") {
  desc <- str_c(desc, " lawnmower_8x10_md_17 ")
} else if (argv$f1pnum == "14") {
  desc <- str_c(desc, " lawnmower_8x12_md_17 ")
} else if (argv$f1pnum == "23") {
  desc <- str_c(desc, " lawnmower_25x25_md_17 ")
} else if (argv$f1pnum == "24") {
  desc <- str_c(desc, " lawnmower_25x25_genramp ")
} else if (argv$f1pnum == "15") {
  desc <- str_c(desc, " lawnmower_50x50_md_17 ")
} else if (argv$f1pnum == "16") {
  desc <- str_c(desc, " lawnmower_50x50_genramp ")
} else if (argv$f1pnum == "30") {
  desc <- str_c(desc, " bumblebee_10f_md_17 ")
} else if (argv$f1pnum == "31") {
  desc <- str_c(desc, " bumblebee_10f_genramp ")
} else if (argv$f1pnum == "32") {
  desc <- str_c(desc, " bumblebee_15f_md_17 ")
} else if (argv$f1pnum == "33") {
  desc <- str_c(desc, " bumblebee_15f_genramp ")
} else if (argv$f1pnum == "34") {
  desc <- str_c(desc, " bumblebee_20f_md_17 ")
} else if (argv$f1pnum == "35") {
  desc <- str_c(desc, " bumblebee_20f_genramp ")
} else if (argv$f1pnum == "36") {
  desc <- str_c(desc, " bumblebee_25f_md_17 ")
} else if (argv$f1pnum == "37") {
  desc <- str_c(desc, " bumblebee_25f_genramp ")
} else {
}

kern1 <- argv$f1pnum

#gwgstart make if statement to mangle names for column info based on what was passed in
#right now if kern1 and kern2 aree same kernel number wilcoxson can't distinguish between groups 
if(f1kerp1v == "0" ) {
  kern1 <- str_c(kern1,"orig") 
  desc  <- str_c(desc, "orig ")
}
if(f1kerp1v == "1" ) {
  kern1 <- str_c(kern1,"cgp2.1") 
  desc  <- str_c(desc, "cgp2.1 ")
}
if(f1kerp1v == "2" ) {
  kern1 <- str_c(kern1,"acgp1.1.2") 
  desc  <- str_c(desc, "acgp1.1.2 ")
}
if(f1kerp1v == "3" ) {
  kern1 <- str_c(kern1,"cgpf2.1") 
  desc  <- str_c(desc, "cgpf2.1 ")
}
if(f1kerp1v == "4" ) {
  kern1 <- str_c(kern1,"acgpf2.1") 
  desc  <- str_c(desc, "acgpf2.1 ")
}

if( f1adfv == "y") {
  kern1 <- str_c(kern1, "_yadfs")
  desc <- str_c(desc, "with adfs ")
} else {
  kern1 <- str_c(kern1, "_nadfs")
  desc <- str_c(desc, "no adfs ")
}

if(f1typesv == 'y') {
  kern1 <- str_c(kern1, "_ytypes")
  desc <- str_c(desc, "using types ")
} else {
  kern1 <- str_c(kern1, "_ntypes")
  desc <- str_c(desc, "no types ")
}

if(f1consv == 'y') {
  kern1 <- str_c(kern1, "_ycons")
  desc <- str_c(desc, "using constraints ")
} else {
  kern1 <- str_c(kern1, "_ncons")
  desc <- str_c(desc, "no constraints ")
}

if(f1acgpwhatv == '0') {
  kern1 <- str_c(kern1, "_what0")
  desc <- str_c(desc, " what=0")
}
if(f1acgpwhatv == '1') {
  kern1 <- str_c(kern1, "_what1")
  desc <- str_c(desc, " what=1")
}
if(f1acgpwhatv == '2') {
  kern1 <- str_c(kern1, "_what2")
  desc <- str_c(desc, " what=2")
}
if(f1acgpwhatv == '3') {
  kern1 <- str_c(kern1, "_what3")
  desc <- str_c(desc, " what=3")
}

desc <- str_c(desc, " p")

desc  <- str_c(desc, argv$f2pnum, " ")

if(argv$f2pnum == "3") {
  desc <- str_c(desc, " two box ")
} else if (argv$f2pnum == "5") {
  desc <- str_c(desc, " koza1 regression ")
} else if (argv$f2pnum == "8") {
  desc <- str_c(desc, " koza1 regression 2adfs ")
} else if (argv$f2pnum == "11") {
  desc <- str_c(desc, " lawnmower_8x8_md_17 ")
} else if (argv$f2pnum == "12") {
  desc <- str_c(desc, " lawnmower_8x4_md_17 ")
} else if (argv$f2pnum == "13") {
  desc <- str_c(desc, " lawnmower_8x10_md_17 ")
} else if (argv$f2pnum == "14") {
  desc <- str_c(desc, " lawnmower_8x12_md_17 ")
} else if (argv$f2pnum == "23") {
  desc <- str_c(desc, " lawnmower_25x25_md_17 ")
} else if (argv$f2pnum == "24") {
  desc <- str_c(desc, " lawnmower_25x25_genramp ")
} else if (argv$f2pnum == "15") {
  desc <- str_c(desc, " lawnmower_50x50_md_17 ")
} else if (argv$f2pnum == "16") {
  desc <- str_c(desc, " lawnmower_50x50_genramp ")
} else if (argv$f2pnum == "30") {
  desc <- str_c(desc, " bumblebee_10f_md_17 ")
} else if (argv$f2pnum == "31") {
  desc <- str_c(desc, " bumblebee_10f_genramp ")
} else if (argv$f2pnum == "32") {
  desc <- str_c(desc, " bumblebee_15f_md_17 ")
} else if (argv$f2pnum == "33") {
  desc <- str_c(desc, " bumblebee_15f_genramp ")
} else if (argv$f2pnum == "34") {
  desc <- str_c(desc, " bumblebee_20f_md_17 ")
} else if (argv$f2pnum == "35") {
  desc <- str_c(desc, " bumblebee_20f_genramp ")
} else if (argv$f2pnum == "36") {
  desc <- str_c(desc, " bumblebee_25f_md_17 ")
} else if (argv$f2pnum == "37") {
  desc <- str_c(desc, " bumblebee_25f_genramp ")
} else {
}

kern2 <- argv$f2pnum

if(f2kerp1v == "0" ) {
  kern2 <- str_c(kern2,"orig") 
  desc  <- str_c(desc, "orig ")
}
if(f2kerp1v == "1" ) {
  kern2 <- str_c(kern2,"cgp2.1") 
  desc  <- str_c(desc, "cgp2.1 ")
}
if(f2kerp1v == "2" ) {
  kern2 <- str_c(kern2,"acgp1.1.2") 
  desc  <- str_c(desc, "acgp1.1.2 ")
}
if(f2kerp1v == "3" ) {
  kern2 <- str_c(kern2,"cgpf2.1") 
  desc  <- str_c(desc, "cgpf2.1 ")
}
if(f2kerp1v == "4" ) {
  kern2 <- str_c(kern2,"acgpf2.1") 
  desc  <- str_c(desc, "acgpf2.1 ")
}


if( f2adfv == "y") {
  kern2 <- str_c(kern2, "_yadfs")
  desc <- str_c(desc, "with adfs ")
} else {
  kern2 <- str_c(kern2, "_nadfs")
  desc <- str_c(desc, "no adfs ")
}

if(f2typesv == 'y') {
  kern2 <- str_c(kern2, "_ytypes")
  desc <- str_c(desc, "using types ")
} else {
  kern2 <- str_c(kern2, "_ntypes")
  desc <- str_c(desc, "no types ")
}

if(f2consv == 'y') {
  kern2 <- str_c(kern2, "_ycons")
  desc <- str_c(desc, "using constraints ")
} else {
  kern2 <- str_c(kern2, "_ncons")
  desc <- str_c(desc, "no constraints ")
}

if(f2acgpwhatv == '0') {
  kern2 <- str_c(kern2, "_what0")
  desc <- str_c(desc, " what=0")
}
if(f2acgpwhatv == '1') {
  kern2 <- str_c(kern2, "_what1")
  desc <- str_c(desc, " what=1")
}
if(f2acgpwhatv == '2') {
  kern2 <- str_c(kern2, "_what2")
  desc <- str_c(desc, " what=2")
}
if(f2acgpwhatv == '3') {
  kern2 <- str_c(kern2, "_what3")
  desc <- str_c(desc, " what=3")
}

#print(kern1)
#print(kern2)
my_data <- data.frame( 
                group = rep(c(kern1, kern2), each = 50),
                hits = c(d1$Hits,  d2$Hits)
                )
if(argv$dispdata == 'y')
  print(my_data)


#if you want to test whether the median orig hits is less than the median women’s weight, type this:
res <- wilcox.test(hits ~ group, data = my_data, exact = FALSE, alternative = "less")
#res$p.value

#Or, if you want to test whether the median orig hits is greater than the median women’s weight, type this
#res <- wilcox.test(hits ~ group, data = my_data, exact = FALSE, alternative = "greater")
#res$p.value

printf("%s  mean -> %f %f\n", desc, mean(d1$Hits),  mean(d2$Hits))

# clean up
dbDisconnect(con)

quit()
