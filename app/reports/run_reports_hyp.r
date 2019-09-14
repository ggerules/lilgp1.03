#!/usr/bin/env Rscript

library(argparser, quietly=TRUE)
library(DBI)
library(RSQLite)
library(dplyr, quietly=TRUE, warn.conflicts = FALSE)
library(crayon)
library(stringr)
library(lubridate)

source("common.r")


rwilcox <- function(datkind, f1pnum, f1kerp1v, f1wadfv, f1adfv, f1typesv, f1consv, f1acgpwhatv,
                             f2pnum, f2kerp1v, f2wadfv, f2adfv, f2typesv, f2consv, f2acgpwhatv ) {
  #RSQLite::rsqliteVersion()
  # 
  drv <- dbDriver("SQLite")
  con <- dbConnect(drv, dbname = "/home/ggerules/lilgp1.03/app/reports/data.db")
  #dbListTables(con)
  
  sel <- "select Hits,Gen,Nodes,Depth from beststatslong where "
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
  
  selstat1 <- str_c(sel,wadf,f1wadfv,ap1,adf,f1adfv,ap1,types,f1typesv,ap1,cons,f1consv,ap1,acgpwhat,f1acgpwhatv,ap1,pn,f1pnum,ap2,kerp1,f1kerp1v)
  #printf("%s\n", selstat1)
  
  #rs <- dbSendQuery(con, "select Hits from beststatslong where (wADF in ('y')) and (ADF in ('n'))  and (ProblemNum = 37 and Kernel = 0 )")
  rs <- dbSendQuery(con, selstat1)
  d1 <- fetch(rs)
  dbClearResult(rs)
 
  sel <- "select Hits,Gen,Nodes,Depth from beststatslong where "
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
  
  selstat2 <- str_c(sel,wadf,f2wadfv,ap1,adf,f2adfv,ap1,types,f2typesv,ap1,cons,f2consv,ap1,acgpwhat,f2acgpwhatv,ap1,pn,f2pnum,ap2,kerp1,f2kerp1v)
  #printf("%s\n", selstat2)
  
  rs <- dbSendQuery(con, selstat2)
  d2 <- fetch(rs)
  dbClearResult(rs)
 
  #desc <- "p" 
  desc <- "" 

  if(f1kerp1v == "0" ) {
    desc  <- str_c(desc, " orig ")
  }
  if(f1kerp1v == "1" ) {
    desc  <- str_c(desc, "cgp2.1 ")
  }
  if(f1kerp1v == "2" ) {
    desc  <- str_c(desc, "cgpf2.1 ")
  }
  if(f1kerp1v == "3" ) {
    desc  <- str_c(desc, "acgp1.1.2 ")
  }
  if(f1kerp1v == "4" ) {
    desc  <- str_c(desc, "acgpf2.1 ")
  }

  if (inlist(f1pnum,genrmp) == "FALSE"){
    desc <- str_c(desc, " & n ")
  } else {
    desc <- str_c(desc, " & y ")
  }

  if( f1adfv == "y") {
    desc <- str_c(desc, " & y ")
  } else {
    desc <- str_c(desc, " & n ")
  }
  
  if((f1pnum < 11) || (f1pnum > 100)) {
    if(f1typesv == 'y') {
      desc <- str_c(desc, " & y ")
    } else {
      desc <- str_c(desc, " & n ")
    }
    
    if(f1consv == 'y') {
      desc <- str_c(desc, " & y ")
    } else {
      desc <- str_c(desc, " & n ")
    }
  }

  if((f1pnum > 10) && (f1pnum < 30)) {
    if(f1consv == 'y') {
      desc <- str_c(desc, " & y ")
    } else {
      desc <- str_c(desc, " & n ")
    }
  }
  
  if(f1acgpwhatv == '0') {
    desc <- str_c(desc, " & 0 ")
  }
  if(f1acgpwhatv == '1') {
    desc <- str_c(desc, " & 1 ")
  }
  if(f1acgpwhatv == '2') {
    desc <- str_c(desc, " & 2 ")
  }
  if(f1acgpwhatv == '3') {
    desc <- str_c(desc, " & 3 ")
  }
  if(f1acgpwhatv == 'n') {
    desc <- str_c(desc, " & na ")
  }

  if(f2kerp1v == "0" ) {
    desc  <- str_c(desc, " & orig ")
  }
  if(f2kerp1v == "1" ) {
    desc  <- str_c(desc, " & cgp2.1 ")
  }
  if(f2kerp1v == "2" ) {
    desc  <- str_c(desc, " & cgpf2.1 ")
  }
  if(f2kerp1v == "3" ) {
    desc  <- str_c(desc, " & acgp1.1.2 ")
  }
  if(f2kerp1v == "4" ) {
    desc  <- str_c(desc, " & acgpf2.1 ")
  }
  
  if (inlist(f2pnum,genrmp) == "FALSE"){
    desc <- str_c(desc, " & n ")
  } else {
    desc <- str_c(desc, " & y ")
  }

  if( f2adfv == "y") {
    desc <- str_c(desc, " & y ")
  } else {
    desc <- str_c(desc, " & n ")
  }
  
  if((f2pnum < 11) || (f2pnum > 100)) {
    if(f2typesv == 'y') {
      desc <- str_c(desc, " & y ")
    } else {
      desc <- str_c(desc, " & n ")
    }
    
    if(f2consv == 'y') {
      desc <- str_c(desc, " & y ")
    } else {
      desc <- str_c(desc, " & n ")
    }
  }

  if((f2pnum > 10) && (f2pnum < 30)) {
    if(f2consv == 'y') {
      desc <- str_c(desc, " & y ")
    } else {
      desc <- str_c(desc, " & n ")
    }
  }

  if(f2acgpwhatv == '0') {
    desc <- str_c(desc, " & 0 ")
  }
  if(f2acgpwhatv == '1') {
    desc <- str_c(desc, " & 1 ")
  }
  if(f2acgpwhatv == '2') {
    desc <- str_c(desc, " & 2 ")
  }
  if(f2acgpwhatv == '3') {
    desc <- str_c(desc, " & 3 ")
  }
  if(f2acgpwhatv == 'n') {
    desc <- str_c(desc, " & na ")
  }

  nothing   <- " "
  wc_hits  <-  wilcox.test(d1$Hits, d2$Hits, exact = FALSE, alternative = "less")
  wc_gen   <-  wilcox.test(d1$Gen, d2$Gen, exact = FALSE, alternative = "greater")
  wc_nodes <-  wilcox.test(d1$Nodes, d2$Nodes, exact = FALSE, alternative = "greater")
  wc_depth <-  wilcox.test(d1$Depth, d2$Depth, exact = FALSE, alternative = "greater")

  if (mean(d1$Hits) == mean(d2$Hits)) {
    wc_hitsv  <- "avs" 
  } else {
    #wc_hitsv  <-  sprintf("%.8f",wc_hits$p.value)
    wc_hitsv  <-  wc_hits$p.value
  }

  if (mean(d1$Gen) == mean(d2$Gen)) {
    wc_genv  <- "avs" 
  } else { 
    #wc_genv   <-  sprintf("%.8f",wc_gen$p.value)
    wc_genv   <-  wc_gen$p.value
  }

  if (mean(d1$Nodes) == mean(d2$Nodes)) {
    wc_nodesv  <- "avs" 
  } else { 
    #wc_nodesv <-  sprintf("%.8f",wc_nodes$p.value)
    wc_nodesv <-  wc_nodes$p.value
  }
  
  if (mean(d1$Depth) == mean(d2$Depth)) {
    wc_depthv  <- "avs" 
  } else { 
    #wc_depthv <-  sprintf("%.8f",wc_depth$p.value)
    wc_depthv <-  wc_depth$p.value
  }

 
  # clean up
  dbDisconnect(con)

  rv <- " "
  if(datkind == "mhit") {
    if(wc_hitsv < 0.001) {
      rv <- "***"   
    } else if(wc_hitsv < 0.01) {
      rv <- "**"   
    } else if(wc_hitsv < 0.05) {
      rv <- "**"   
    } else {
      rv <- " "
    }
  } else if (datkind == "mgen") {
    if(wc_genv < 0.001) {
      rv <- "***"   
    } else if(wc_genv < 0.01) {
      rv <- "**"   
    } else if(wc_genv < 0.05) {
      rv <- "**"   
    } else {
      rv <- " "
    }
  } else if (datkind == "mnod") {
    if(wc_nodesv < 0.001) {
      rv <- "***"   
    } else if(wc_nodesv < 0.01) {
      rv <- "**"   
    } else if(wc_nodesv < 0.05) {
      rv <- "**"   
    } else {
      rv <- " "
    }
  } else if (datkind == "mdep") {
    if(wc_depthv < 0.001) {
      rv <- "***"   
    } else if(wc_depthv < 0.01) {
      rv <- "**"   
    } else if(wc_depthv < 0.05) {
      rv <- "**"   
    } else {
      rv <- " "
    }
  } else {
    rv <- " "
  }
  return(rv)
}



getet <- function(f1pnum, f1kerp1v, f1wadfv, f1adfv, f1typesv, f1consv, f1acgpwhatv ) {
  #RSQLite::rsqliteVersion()
  # 
  drv <- dbDriver("SQLite")
  con <- dbConnect(drv, dbname = "/home/ggerules/lilgp1.03/app/reports/data.db")
  #dbListTables(con)
  
  
  #evaltimelong(ProblemNum,Kernel,IndRunNum,wADF,ADF,Types,Constraints,acgpwhat,MaxTreeDepth,EvalTime"); 

  sel <- "select EvalTime from evaltimelong where "
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
  
  selstat1 <- str_c(sel,wadf,f1wadfv,ap1,adf,f1adfv,ap1,types,f1typesv,ap1,cons,f1consv,ap1,acgpwhat,f1acgpwhatv,ap1,pn,f1pnum,ap2,kerp1,f1kerp1v)
  #selstat1
  
  rs <- dbSendQuery(con, selstat1)
  d1 <- fetch(rs)
  dbClearResult(rs)
  
  #desc <- "p" 
  desc <- ""
  #desc <- str_c(desc, f1pnum, " &")
 
  #desc <- str_c(desc, problem_desc(f1pnum))
 
  kern1 <- f1pnum
  
  #gwgstart make if statement to mangle names for column info based on what was passed in
  #right now if kern1 and kern2 aree same kernel number wilcoxson can't distinguish between groups 
  if(f1kerp1v == "0" ) {
    kern1 <- str_c(kern1,"orig") 
    #desc  <- str_c(desc, " & orig ")
    desc  <- str_c(desc, " orig ")
  }
  if(f1kerp1v == "1" ) {
    kern1 <- str_c(kern1,"cgp2.1") 
    #desc  <- str_c(desc, " & cgp2.1 ")
    desc  <- str_c(desc, "cgp2.1 ")
  }
  if(f1kerp1v == "2" ) {
    kern1 <- str_c(kern1,"cgpf2.1") 
    #desc  <- str_c(desc, " & cgpf2.1 ")
    desc  <- str_c(desc, "cgpf2.1 ")
  }
  if(f1kerp1v == "3" ) {
    kern1 <- str_c(kern1,"acgp1.1.2") 
    #desc  <- str_c(desc, " & acgp1.1.2 ")
    desc  <- str_c(desc, "acgp1.1.2 ")
  }
  if(f1kerp1v == "4" ) {
    kern1 <- str_c(kern1,"acgpf2.1") 
    #desc  <- str_c(desc, " & acgpf2.1 ")
    desc  <- str_c(desc, "acgpf2.1 ")
  }
  
  if( f1adfv == "y") {
    kern1 <- str_c(kern1, "_yadfs")
    desc <- str_c(desc, " & y ")
  } else {
    kern1 <- str_c(kern1, "_nadfs")
    desc <- str_c(desc, " & n ")
  }
 
  if((f1pnum >= 11) && (f1pnum < 30)) {
    if(f1consv == 'y') {
      kern1 <- str_c(kern1, "_ycons")
      desc <- str_c(desc, " & y ")
    } else {
      kern1 <- str_c(kern1, "_ncons")
      desc <- str_c(desc, " & n ")
    }
  } else if((f1pnum < 11) || (f1pnum > 100)) {
    if(f1typesv == 'y') {
      kern1 <- str_c(kern1, "_ytypes")
      desc <- str_c(desc, " & y ")
    } else {
      kern1 <- str_c(kern1, "_ntypes")
      desc <- str_c(desc, " & n ")
    }
    
    if(f1consv == 'y') {
      kern1 <- str_c(kern1, "_ycons")
      desc <- str_c(desc, " & y ")
    } else {
      kern1 <- str_c(kern1, "_ncons")
      desc <- str_c(desc, " & n ")
    }
  }
 
  if(f1acgpwhatv == '0') {
    kern1 <- str_c(kern1, "_what0")
    desc <- str_c(desc, " & 0 ")
  }
  if(f1acgpwhatv == '1') {
    kern1 <- str_c(kern1, "_what1")
    desc <- str_c(desc, " & 1 ")
  }
  if(f1acgpwhatv == '2') {
    kern1 <- str_c(kern1, "_what2")
    desc <- str_c(desc, " & 2 ")
  }
  if(f1acgpwhatv == '3') {
    kern1 <- str_c(kern1, "_what3")
    desc <- str_c(desc, " & 3 ")
  }
  if(f1acgpwhatv == 'n') {
    kern1 <- str_c(kern1, "_whatn")
    desc <- str_c(desc, " & n ")
  }
  
  tm <- seconds_to_period(sum(d1$EvalTime))

  #desc <- str_c(desc, " & ",  mean(d1$EvalTime), " & ",  tm, "\\\\")
  desc <- str_c(desc, " & ",  tm, "\\\\")
  #printf("p %s %s & %f & %s \n", f1pnum, desc, mean(d1$EvalTime), tm)
  printf("%s\n", desc)
  
  
  # clean up
  dbDisconnect(con)

  return(tm)
}

getdat <- function(datkind, f1pnum, f1kerp1v, f1wadfv, f1adfv, f1typesv, f1consv, f1acgpwhatv ) {
  #RSQLite::rsqliteVersion()
  # 
  drv <- dbDriver("SQLite")
  con <- dbConnect(drv, dbname = "/home/ggerules/lilgp1.03/app/reports/data.db")
  #dbListTables(con)
  
  
  sel <- "select Hits,Gen,Nodes,Depth from beststatslong where "
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
  
  selstat1 <- str_c(sel,wadf,f1wadfv,ap1,adf,f1adfv,ap1,types,f1typesv,ap1,cons,f1consv,ap1,acgpwhat,f1acgpwhatv,ap1,pn,f1pnum,ap2,kerp1,f1kerp1v)
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
  
  #desc <- "p" 
  desc <- ""
  #desc <- str_c(desc, f1pnum, " &")
 
  #desc <- str_c(desc, problem_desc(f1pnum))
 
  kern1 <- f1pnum
  
  #gwgstart make if statement to mangle names for column info based on what was passed in
  #right now if kern1 and kern2 aree same kernel number wilcoxson can't distinguish between groups 
  if(f1kerp1v == "0" ) {
    kern1 <- str_c(kern1,"orig") 
    #desc  <- str_c(desc, " & orig ")
    desc  <- str_c(desc, " orig ")
  }
  if(f1kerp1v == "1" ) {
    kern1 <- str_c(kern1,"cgp2.1") 
    #desc  <- str_c(desc, " & cgp2.1 ")
    desc  <- str_c(desc, "cgp2.1 ")
  }
  if(f1kerp1v == "2" ) {
    kern1 <- str_c(kern1,"cgpf2.1") 
    #desc  <- str_c(desc, " & cgpf2.1 ")
    desc  <- str_c(desc, "cgpf2.1 ")
  }
  if(f1kerp1v == "3" ) {
    kern1 <- str_c(kern1,"acgp1.1.2") 
    #desc  <- str_c(desc, " & acgp1.1.2 ")
    desc  <- str_c(desc, "acgp1.1.2 ")
  }
  if(f1kerp1v == "4" ) {
    kern1 <- str_c(kern1,"acgpf2.1") 
    #desc  <- str_c(desc, " & acgpf2.1 ")
    desc  <- str_c(desc, "acgpf2.1 ")
  }
  
  if( f1adfv == "y") {
    kern1 <- str_c(kern1, "_yadfs")
    desc <- str_c(desc, " & y ")
  } else {
    kern1 <- str_c(kern1, "_nadfs")
    desc <- str_c(desc, " & n ")
  }
  
  if((f1pnum < 11) || (f1pnum > 100)) {
    if(f1typesv == 'y') {
      kern1 <- str_c(kern1, "_ytypes")
      desc <- str_c(desc, " & y ")
    } else {
      kern1 <- str_c(kern1, "_ntypes")
      desc <- str_c(desc, " & n ")
    }
    
    if(f1consv == 'y') {
      kern1 <- str_c(kern1, "_ycons")
      desc <- str_c(desc, " & y ")
    } else {
      kern1 <- str_c(kern1, "_ncons")
      desc <- str_c(desc, " & n ")
    }
  }
  
  if((f1pnum > 10) && (f1pnum < 30)) {
    if(f1consv == 'y') {
      kern1 <- str_c(kern1, "_ycons")
      desc <- str_c(desc, " & y ")
    } else {
      kern1 <- str_c(kern1, "_ncons")
      desc <- str_c(desc, " & n ")
    }
  }
  if(f1acgpwhatv == '0') {
    kern1 <- str_c(kern1, "_what0")
    desc <- str_c(desc, " & 0 ")
  }
  if(f1acgpwhatv == '1') {
    kern1 <- str_c(kern1, "_what1")
    desc <- str_c(desc, " & 1 ")
  }
  if(f1acgpwhatv == '2') {
    kern1 <- str_c(kern1, "_what2")
    desc <- str_c(desc, " & 2 ")
  }
  if(f1acgpwhatv == '3') {
    kern1 <- str_c(kern1, "_what3")
    desc <- str_c(desc, " & 3 ")
  }
  if(f1acgpwhatv == 'n') {
    kern1 <- str_c(kern1, "_whatn")
    desc <- str_c(desc, " & na ")
  }
  
  nothing <- " "
  mh <- sprintf("%.2f",mean(d1$Hits)) 
  mg <- sprintf("%.2f",mean(d1$Gen)) 
  mn <- sprintf("%.2f",mean(d1$Nodes)) 
  md <- sprintf("%.2f",mean(d1$Depth)) 

  desc <- str_c(desc, " & ",  mh, " & ", mg, " & ",  mn , " & ", md, "\\\\")
  printf("p %s %s & %f & %f & %f & %f\n", f1pnum, desc, mean(d1$Hits), mean(d1$Gen), mean(d1$Nodes), mean(d1$Depth))
  #printf("%s\n", desc)
  
  # clean up
  dbDisconnect(con)

  if(datkind == "mhit") {
    return(mh)
  } else if (datkind == "mgen") {
    return(mg)
  } else if (datkind == "mnod") {
    return(mn)
  } else if (datkind == "mdep") {
    return(md)
  } else {
    return(nothing)
  }
}

fl1 <- "./tables/bestrunhyp1table.tex"
unlink(fl1)
fl2 <- "./tables/bestrunhyp2table.tex"
unlink(fl2)
fl3 <- "./tables/bestrunhyp3table.tex"
unlink(fl3)
fl4a <- "./tables/bestrunhyp4atable.tex"
unlink(fl4a)
fl4b <- "./tables/bestrunhyp4btable.tex"
unlink(fl4b)

#hyp1
#row <- str_c("\\begin{sidewaystable}[htb]\n")
row <- str_c("\\begin{sidewaystable}\n")
row <- str_c(row, "\\centering\n")
row <- str_c(row, "\\caption{Hypothesis 1: Compared to SGP (with no ADFs), ACGPF Shows Improved Performance}\n")
row <- str_c(row, "\\scalebox{0.60} % Change this value to rescale the drawing.\n")
row <- str_c(row, "{\n")
row <- str_c(row, "\\begin{tabular}{|c|c|c|c|c|c|c|c|c|c|c|c|c|c|c|c|}\n")
row <- str_c(row, " \\hline\n")
row <- str_c(row, "% \\rowcolor{ltgray}\n")
row <- str_c(row, " \\multicolumn{1}{|c|}{\\multirow{4}{0.75in}{Outcome Variable}} & \\multicolumn{6}{|c|}{Lawn Mower Problem}\n")
row <- str_c(row, "                                                              & \\multicolumn{6}{|c|}{Bumble Bee Problem}\n")
row <- str_c(row, "							      & \\multicolumn{3}{|c|}{Two Box Problem}\\\\\n")
row <- str_c(row, " \\cline{2-16}\n")
row <- str_c(row, "% \\rowcolor{ltgray}\n")
row <- str_c(row, " \\multicolumn{1}{|c|}{} & \\multicolumn{3}{|c|}{25x25} & \\multicolumn{3}{|c|}{50x50} \n")
row <- str_c(row, "                        & \\multicolumn{3}{|c|}{2D} & \\multicolumn{3}{|c|}{3D}\n")
row <- str_c(row, "                        & \\multicolumn{3}{|c|}{3D} \n")
row <- str_c(row, "			\\\\ \n")
row <- str_c(row, " \\cline{2-16}\n")
row <- str_c(row, "% \\rowcolor{ltgray}\n")
row <- str_c(row, " \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{SGP} & \\multicolumn{1}{|c|}{ACGPF} & \\multicolumn{1}{|c|}{ACGPF} \n")
row <- str_c(row, "			& \\multicolumn{1}{|c|}{SGP} & \\multicolumn{1}{|c|}{ACGPF} & \\multicolumn{1}{|c|}{ACGPF} \n")
row <- str_c(row, "                        & \\multicolumn{1}{|c|}{SGP} & \\multicolumn{1}{|c|}{ACGPF} & \\multicolumn{1}{|c|}{ACGPF} \n")
row <- str_c(row, "			& \\multicolumn{1}{|c|}{SGP} & \\multicolumn{1}{|c|}{ACGPF} & \\multicolumn{1}{|c|}{ACGPF} \n")
row <- str_c(row, "                        & \\multicolumn{1}{|c|}{SGP} & \\multicolumn{1}{|c|}{ACGPF} & \\multicolumn{1}{|c|}{ACGPF} \n")
row <- str_c(row, "			\\\\ \n")
row <- str_c(row, " \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{(what=2)} & \\multicolumn{1}{|c|}{(what=3)} \n")
row <- str_c(row, "			& \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{(what=2)} & \\multicolumn{1}{|c|}{(what=3)} \n")
row <- str_c(row, "                        & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{(what=2)} & \\multicolumn{1}{|c|}{(what=3)} \n")
row <- str_c(row, "			& \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{(what=2)} & \\multicolumn{1}{|c|}{(what=3)} \n")
row <- str_c(row, "                        & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{(what=2)} & \\multicolumn{1}{|c|}{(what=3)} \n")
row <- str_c(row, "			\\\\ \n")
row <- str_c(row, " \\hline\n")
row <- str_c(row, " \\multicolumn{1}{|c|}{\\multirow{1}{0.75in}{Mean $\\#$ Hits}} \n")
row <- str_c(row, "			& \\multicolumn{1}{|c|}{")
row <- str_c(row, getdat('mhit', 23,'0','y','n','n','n','n'))
row <- str_c(row, "} \n")
row <- str_c(row, "                        & \\multicolumn{1}{|c|}{")
row <- str_c(row, getdat('mhit', 23,'4','y','y','n','y','2'), " ", rwilcox('mhit', 23,'0','y','n','n','n','n',23,'4','y','y','n','y','2'))
row <- str_c(row, "} \n")
row <- str_c(row, "			& \\multicolumn{1}{|c|}{")
row <- str_c(row,getdat('mhit', 23,'4','y','y','n','y','3'), " ", rwilcox('mhit', 23,'0','y','n','n','n','n',23,'4','y','y','n','y','3'))
row <- str_c(row,"} \n")
row <- str_c(row, "			& \\multicolumn{1}{|c|}{")
row <- str_c(row,getdat('mhit', 15,'0','y','n','n','n','n'))
row <- str_c(row, "} \n")
row <- str_c(row, "			& \\multicolumn{1}{|c|}{")
row <- str_c(row, getdat('mhit', 15,'4','y','y','n','y','2'), " ", rwilcox('mhit', 15,'0','y','n','n','n','n',15,'4','y','y','n','y','2'))
row <- str_c(row, "} \n")
row <- str_c(row, "			& \\multicolumn{1}{|c|}{")
row <- str_c(row, getdat('mhit', 15,'4','y','y','n','y','3'), " ", rwilcox('mhit', 15,'0','y','n','n','n','n',15,'4','y','y','n','y','3'))
row <- str_c(row, "} \n")
row <- str_c(row, "                        & \\multicolumn{1}{|c|}{")
row <- str_c(row, getdat('mhit', 36,'0','y','n','n','n','n'))
row <- str_c(row, "} \n")
row <- str_c(row, "			& \\multicolumn{1}{|c|}{")
row <- str_c(row, getdat('mhit', 36,'4','y','y','n','n','2'), " ", rwilcox('mhit', 36,'0','y','n','n','n','n',36,'4','y','y','n','n','2'))
row <- str_c(row, "} \n")
row <- str_c(row, "			& \\multicolumn{1}{|c|}{")
row <- str_c(row, getdat('mhit', 36,'4','y','y','n','n','3'), " ", rwilcox('mhit', 36,'0','y','n','n','n','n',36,'4','y','y','n','n','3'))
row <- str_c(row, "} \n")
row <- str_c(row, "			& \\multicolumn{1}{|c|}{")
row <- str_c(row, getdat('mhit', 86,'0','y','n','n','n','n'))
row <- str_c(row, "} \n")
row <- str_c(row, "			& \\multicolumn{1}{|c|}{")
row <- str_c(row, getdat('mhit', 86,'4','y','y','n','n','2'), " ", rwilcox('mhit', 86,'0','y','n','n','n','n',86,'4','y','y','n','n','2'))
row <- str_c(row, "} \n")
row <- str_c(row, "			& \\multicolumn{1}{|c|}{")
row <- str_c(row, getdat('mhit', 86,'4','y','y','n','n','3'), " ", rwilcox('mhit', 86,'0','y','n','n','n','n',86,'4','y','y','n','n','3'))
row <- str_c(row, "} \n")
row <- str_c(row, "                        & \\multicolumn{1}{|c|}{")
row <- str_c(row, getdat('mhit',103,'0','y','n','n','n','n'))
row <- str_c(row, "} \n")
row <- str_c(row, "			& \\multicolumn{1}{|c|}{")
row <- str_c(row, getdat('mhit',103,'4','y','y','y','y','2'), " ", rwilcox('mhit',103,'0','y','n','n','n','n',103,'4','y','y','y','y','2'))
row <- str_c(row, "} \n")
row <- str_c(row, "			& \\multicolumn{1}{|c|}{")
row <- str_c(row, getdat('mhit',103,'4','y','y','y','y','3'), " ", rwilcox('mhit',103,'0','y','n','n','n','n',103,'4','y','y','y','y','3'))
row <- str_c(row, "} \n")
row <- str_c(row, "			\\\\ \n")
row <- str_c(row, " \\hline\n")
row <- str_c(row, " \\multicolumn{1}{|c|}{\\multirow{5}{0.75in}{Mean Generation Where Best Individual Appeared}} \n")
row <- str_c(row, "			& \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} \n")
row <- str_c(row, "			& \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} \n")
row <- str_c(row, "                        & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} \n")
row <- str_c(row, "			& \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} \n")
row <- str_c(row, "                        & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} \n")
row <- str_c(row, "			\\\\ \n")
row <- str_c(row, " \\multicolumn{1}{|c|}{}\n")
row <- str_c(row, "			& \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} \n")
row <- str_c(row, "			& \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} \n")
row <- str_c(row, "                        & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} \n")
row <- str_c(row, "			& \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} \n")
row <- str_c(row, "                        & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} \n")
row <- str_c(row, "			\\\\ \n")
row <- str_c(row, " \\multicolumn{1}{|c|}{} \n")
row <- str_c(row, "			& \\multicolumn{1}{|c|}{")
row <- str_c(row, getdat('mgen', 23,'0','y','n','n','n','n'))
row <- str_c(row, "} \n")
row <- str_c(row, "                        & \\multicolumn{1}{|c|}{")
row <- str_c(row, getdat('mgen', 23,'4','y','y','n','y','2'), " ", rwilcox('mgen', 23,'0','y','n','n','n','n',23,'4','y','y','n','y','2'))
row <- str_c(row, "} \n")
row <- str_c(row, "			& \\multicolumn{1}{|c|}{")
row <- str_c(row, getdat('mgen', 23,'4','y','y','n','y','3'), " ", rwilcox('mgen', 23,'0','y','n','n','n','n',23,'4','y','y','n','y','3'))
row <- str_c(row, "} \n")
row <- str_c(row, "			& \\multicolumn{1}{|c|}{")
row <- str_c(row, getdat('mgen', 15,'0','y','n','n','n','n'))
row <- str_c(row, "} \n")
row <- str_c(row, "			& \\multicolumn{1}{|c|}{")
row <- str_c(row, getdat('mgen', 15,'4','y','y','n','y','2'), " ", rwilcox('mgen', 15,'0','y','n','n','n','n',15,'4','y','y','n','y','2'))
row <- str_c(row, "} \n")
row <- str_c(row, "			& \\multicolumn{1}{|c|}{")
row <- str_c(row, getdat('mgen', 15,'4','y','y','n','y','3'), " ", rwilcox('mgen', 15,'0','y','n','n','n','n',15,'4','y','y','n','y','3'))
row <- str_c(row, "} \n")
row <- str_c(row, "                        & \\multicolumn{1}{|c|}{")
row <- str_c(row, getdat('mgen', 36,'0','y','n','n','n','n'))
row <- str_c(row, "} \n")
row <- str_c(row, "			& \\multicolumn{1}{|c|}{")
row <- str_c(row, getdat('mgen', 36,'4','y','y','n','n','2'), " ", rwilcox('mgen', 36,'0','y','n','n','n','n',36,'4','y','y','n','n','2'))
row <- str_c(row, "} \n")
row <- str_c(row, "			& \\multicolumn{1}{|c|}{")
row <- str_c(row, getdat('mgen', 36,'4','y','y','n','n','3'), " ", rwilcox('mgen', 36,'0','y','n','n','n','n',36,'4','y','y','n','n','3'))
row <- str_c(row, "} \n")
row <- str_c(row, "			& \\multicolumn{1}{|c|}{")
row <- str_c(row, getdat('mgen', 86,'0','y','n','n','n','n'))
row <- str_c(row, "} \n")
row <- str_c(row, "			& \\multicolumn{1}{|c|}{")
row <- str_c(row, getdat('mgen', 86,'4','y','y','n','n','2'), " ", rwilcox('mgen', 86,'0','y','n','n','n','n',86,'4','y','y','n','n','2'))
row <- str_c(row, "} \n")
row <- str_c(row, "			& \\multicolumn{1}{|c|}{")
row <- str_c(row, getdat('mgen', 86,'4','y','y','n','n','3'), " ", rwilcox('mgen', 86,'0','y','n','n','n','n',86,'4','y','y','n','n','3'))
row <- str_c(row, "} \n")
row <- str_c(row, "                        & \\multicolumn{1}{|c|}{")
row <- str_c(row, getdat('mgen',103,'0','y','n','n','n','n'))
row <- str_c(row, "} \n")
row <- str_c(row, "			& \\multicolumn{1}{|c|}{")
row <- str_c(row, getdat('mgen',103,'4','y','y','y','y','2'), " ", rwilcox('mgen',103,'0','y','n','n','n','n',103,'4','y','y','y','y','2'))
row <- str_c(row, "} \n")
row <- str_c(row, "			& \\multicolumn{1}{|c|}{")
row <- str_c(row, getdat('mgen',103,'4','y','y','y','y','3'), " ", rwilcox('mgen',103,'0','y','n','n','n','n',103,'4','y','y','y','y','3'))
row <- str_c(row, "} \n")
row <- str_c(row, "			\\\\ \n")
row <- str_c(row, " \\multicolumn{1}{|c|}{} \n")
row <- str_c(row, "			& \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} \n")
row <- str_c(row, "			& \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} \n")
row <- str_c(row, "                        & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} \n")
row <- str_c(row, "			& \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} \n")
row <- str_c(row, "                        & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} \n")
row <- str_c(row, "			\\\\ \n")
row <- str_c(row, " \\multicolumn{1}{|c|}{}\n")
row <- str_c(row, "			& \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} \n")
row <- str_c(row, "			& \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} \n")
row <- str_c(row, "                        & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} \n")
row <- str_c(row, "			& \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} \n")
row <- str_c(row, "                        & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} \n")
row <- str_c(row, "			\\\\ \n")
row <- str_c(row, " \\hline\n")
row <- str_c(row, " \\multicolumn{1}{|c|}{\\multirow{2}{0.75in}{Mean $\\#$ Nodes}} \n")
row <- str_c(row, "			& \\multicolumn{1}{|c|}{")
row <- str_c(row, getdat('mnod', 23,'0','y','n','n','n','n'))
row <- str_c(row, "} \n")
row <- str_c(row, "                        & \\multicolumn{1}{|c|}{")
row <- str_c(row, getdat('mnod', 23,'4','y','y','n','y','2'), " ", rwilcox('mnod', 23,'0','y','n','n','n','n',23,'4','y','y','n','y','2'))
row <- str_c(row, "} \n")
row <- str_c(row, "			& \\multicolumn{1}{|c|}{")
row <- str_c(row, getdat('mnod', 23,'4','y','y','n','y','3'), " ", rwilcox('mnod', 23,'0','y','n','n','n','n',23,'4','y','y','n','y','3'))
row <- str_c(row, "} \n")
row <- str_c(row, "			& \\multicolumn{1}{|c|}{")
row <- str_c(row, getdat('mnod', 15,'0','y','n','n','n','n'))
row <- str_c(row, "} \n")
row <- str_c(row, "			& \\multicolumn{1}{|c|}{")
row <- str_c(row, getdat('mnod', 15,'4','y','y','n','y','2'), " ", rwilcox('mnod', 15,'0','y','n','n','n','n',15,'4','y','y','n','y','2'))
row <- str_c(row, "} \n")
row <- str_c(row, "			& \\multicolumn{1}{|c|}{")
row <- str_c(row, getdat('mnod', 15,'4','y','y','n','y','3'), " ", rwilcox('mnod', 15,'0','y','n','n','n','n',15,'4','y','y','n','y','3'))
row <- str_c(row, "} \n")
row <- str_c(row, "                        & \\multicolumn{1}{|c|}{")
row <- str_c(row, getdat('mnod', 36,'0','y','n','n','n','n'))
row <- str_c(row, "} \n")
row <- str_c(row, "			& \\multicolumn{1}{|c|}{")
row <- str_c(row, getdat('mnod', 36,'4','y','y','n','n','2'), " ", rwilcox('mnod', 36,'0','y','n','n','n','n',36,'4','y','y','n','n','2'))
row <- str_c(row, "} \n")
row <- str_c(row, "			& \\multicolumn{1}{|c|}{")
row <- str_c(row, getdat('mnod', 36,'4','y','y','n','n','3'), " ", rwilcox('mnod', 36,'0','y','n','n','n','n',36,'4','y','y','n','n','3'))
row <- str_c(row, "} \n")
row <- str_c(row, "			& \\multicolumn{1}{|c|}{")
row <- str_c(row, getdat('mnod', 86,'0','y','n','n','n','n'))
row <- str_c(row, "} \n")
row <- str_c(row, "			& \\multicolumn{1}{|c|}{")
row <- str_c(row, getdat('mnod', 86,'4','y','y','n','n','2'), " ", rwilcox('mnod', 86,'0','y','n','n','n','n',86,'4','y','y','n','n','2'))
row <- str_c(row, "} \n")
row <- str_c(row, "			& \\multicolumn{1}{|c|}{")
row <- str_c(row, getdat('mnod', 86,'4','y','y','n','n','3'), " ", rwilcox('mnod', 86,'0','y','n','n','n','n',86,'4','y','y','n','n','3'))
row <- str_c(row, "} \n")
row <- str_c(row, "                        & \\multicolumn{1}{|c|}{")
row <- str_c(row, getdat('mnod',103,'0','y','n','n','n','n'))
row <- str_c(row, "} \n")
row <- str_c(row, "			& \\multicolumn{1}{|c|}{")
row <- str_c(row, getdat('mnod',103,'4','y','y','y','y','2'), " ", rwilcox('mnod',103,'0','y','n','n','n','n',103,'4','y','y','y','y','2'))
row <- str_c(row, "} \n")
row <- str_c(row, "			& \\multicolumn{1}{|c|}{")
row <- str_c(row, getdat('mnod',103,'4','y','y','y','y','3'), " ", rwilcox('mnod',103,'0','y','n','n','n','n',103,'4','y','y','y','y','3'))
row <- str_c(row, "} \n")
row <- str_c(row, "			\\\\ \n")
row <- str_c(row, " \\multicolumn{1}{|c|}{}\n")
row <- str_c(row, "			& \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} \n")
row <- str_c(row, "			& \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} \n")
row <- str_c(row, "                        & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} \n")
row <- str_c(row, "			& \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} \n")
row <- str_c(row, "                        & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} \n")
row <- str_c(row, "			\\\\ \n")
row <- str_c(row, " \\hline\n")
row <- str_c(row, " \\multicolumn{1}{|c|}{\\multirow{3}{0.75in}{Mean Tree Depth (entire run)}} \n")
row <- str_c(row, "			& \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} \n")
row <- str_c(row, "			& \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} \n")
row <- str_c(row, "                        & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} \n")
row <- str_c(row, "			& \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} \n")
row <- str_c(row, "                        & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} \n")
row <- str_c(row, "			\\\\ \n")
row <- str_c(row, " \\multicolumn{1}{|c|}{}\n")
row <- str_c(row, "			& \\multicolumn{1}{|c|}{")
row <- str_c(row, getdat('mdep', 23,'0','y','n','n','n','n'))
row <- str_c(row, "} \n")
row <- str_c(row, "                        & \\multicolumn{1}{|c|}{")
row <- str_c(row, getdat('mdep', 23,'4','y','y','n','y','2'), " ", rwilcox('mdep', 23,'0','y','n','n','n','n',23,'4','y','y','n','y','2'))
row <- str_c(row, "} \n")
row <- str_c(row, "			& \\multicolumn{1}{|c|}{")
row <- str_c(row, getdat('mdep', 23,'4','y','y','n','y','3'), " ", rwilcox('mdep', 23,'0','y','n','n','n','n',23,'4','y','y','n','y','3'))
row <- str_c(row, "} \n")
row <- str_c(row, "			& \\multicolumn{1}{|c|}{")
row <- str_c(row, getdat('mdep', 15,'0','y','n','n','n','n'))
row <- str_c(row, "} \n")
row <- str_c(row, "			& \\multicolumn{1}{|c|}{")
row <- str_c(row, getdat('mdep', 15,'4','y','y','n','y','2'), " ", rwilcox('mdep', 15,'0','y','n','n','n','n',15,'4','y','y','n','y','2'))
row <- str_c(row, "} \n")
row <- str_c(row, "			& \\multicolumn{1}{|c|}{")
row <- str_c(row, getdat('mdep', 15,'4','y','y','n','y','3'), " ", rwilcox('mdep', 15,'0','y','n','n','n','n',15,'4','y','y','n','y','3'))
row <- str_c(row, "} \n")
row <- str_c(row, "                        & \\multicolumn{1}{|c|}{")
row <- str_c(row, getdat('mdep', 36,'0','y','n','n','n','n'))
row <- str_c(row, "} \n")
row <- str_c(row, "			& \\multicolumn{1}{|c|}{")
row <- str_c(row, getdat('mdep', 36,'4','y','y','n','n','2'), " ", rwilcox('mdep', 36,'0','y','n','n','n','n',36,'4','y','y','n','n','2'))
row <- str_c(row, "} \n")
row <- str_c(row, "			& \\multicolumn{1}{|c|}{")
row <- str_c(row, getdat('mdep', 36,'4','y','y','n','n','3'), " ", rwilcox('mdep', 36,'0','y','n','n','n','n',36,'4','y','y','n','n','3'))
row <- str_c(row, "} \n")
row <- str_c(row, "			& \\multicolumn{1}{|c|}{")
row <- str_c(row, getdat('mdep', 86,'0','y','n','n','n','n'))
row <- str_c(row, "} \n")
row <- str_c(row, "			& \\multicolumn{1}{|c|}{")
row <- str_c(row, getdat('mdep', 86,'4','y','y','n','n','2'), " ", rwilcox('mdep', 86,'0','y','n','n','n','n',86,'4','y','y','n','n','2'))
row <- str_c(row, "} \n")
row <- str_c(row, "			& \\multicolumn{1}{|c|}{")
row <- str_c(row, getdat('mdep', 86,'4','y','y','n','n','3'), " ", rwilcox('mdep', 86,'0','y','n','n','n','n',86,'4','y','y','n','n','3'))
row <- str_c(row, "} \n")
row <- str_c(row, "                        & \\multicolumn{1}{|c|}{")
row <- str_c(row, getdat('mdep',103,'0','y','n','n','n','n'))
row <- str_c(row, "} \n")
row <- str_c(row, "			& \\multicolumn{1}{|c|}{")
row <- str_c(row, getdat('mdep',103,'4','y','y','y','y','2'), " ", rwilcox('mdep',103,'0','y','n','n','n','n',103,'4','y','y','y','y','2'))
row <- str_c(row, "} \n")
row <- str_c(row, "			& \\multicolumn{1}{|c|}{")
row <- str_c(row, getdat('mdep',103,'4','y','y','y','y','3'), " ", rwilcox('mdep',103,'0','y','n','n','n','n',103,'4','y','y','y','y','3'))
row <- str_c(row, "} \n")
row <- str_c(row, "			\\\\ \n")
row <- str_c(row, " \\multicolumn{1}{|c|}{}\n")
row <- str_c(row, "			& \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} \n")
row <- str_c(row, "			& \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} \n")
row <- str_c(row, "                        & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} \n")
row <- str_c(row, "			& \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} \n")
row <- str_c(row, "                        & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} \n")
row <- str_c(row, "			\\\\ \n")
row <- str_c(row, " \\hline\n")
row <- str_c(row, " \\multicolumn{1}{|c|}{\\multirow{3}{0.75in}{Total Execution Time (all runs)}} \n")
row <- str_c(row, "			& \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} \n")
row <- str_c(row, "			& \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} \n")
row <- str_c(row, "                        & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} \n")
row <- str_c(row, "			& \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} \n")
row <- str_c(row, "                        & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} \n")
row <- str_c(row, "			\\\\ \n")
row <- str_c(row, " \\multicolumn{1}{|c|}{}\n")
row <- str_c(row, "			& \\multicolumn{1}{|c|}{")
row <- str_c(row, getet( 23,'0','y','n','n','n','n'))
row <- str_c(row, "} \n")
row <- str_c(row, "                        & \\multicolumn{1}{|c|}{")
row <- str_c(row, getet( 23,'4','y','y','n','y','2'))
row <- str_c(row, "} \n")
row <- str_c(row, "			& \\multicolumn{1}{|c|}{")
row <- str_c(row, getet( 23,'4','y','y','n','y','3'))
row <- str_c(row, "} \n")
row <- str_c(row, "			& \\multicolumn{1}{|c|}{")
row <- str_c(row, getet( 15,'0','y','n','n','n','n'))
row <- str_c(row, "} \n")
row <- str_c(row, "			& \\multicolumn{1}{|c|}{")
row <- str_c(row, getet( 15,'4','y','y','n','y','2'))
row <- str_c(row, "} \n")
row <- str_c(row, "			& \\multicolumn{1}{|c|}{")
row <- str_c(row, getet( 15,'4','y','y','n','y','3'))
row <- str_c(row, "} \n")
row <- str_c(row, "                        & \\multicolumn{1}{|c|}{")
row <- str_c(row, getet( 36,'0','y','n','n','n','n'))
row <- str_c(row, "} \n")
row <- str_c(row, "			& \\multicolumn{1}{|c|}{")
row <- str_c(row, getet( 36,'4','y','y','n','n','2'))
row <- str_c(row, "} \n")
row <- str_c(row, "			& \\multicolumn{1}{|c|}{")
row <- str_c(row, getet( 36,'4','y','y','n','n','3'))
row <- str_c(row, "} \n")
row <- str_c(row, "			& \\multicolumn{1}{|c|}{")
row <- str_c(row, getet( 86,'0','y','n','n','n','n'))
row <- str_c(row, "} \n")
row <- str_c(row, "			& \\multicolumn{1}{|c|}{")
row <- str_c(row, getet( 86,'4','y','y','n','n','2'))
row <- str_c(row, "} \n")
row <- str_c(row, "			& \\multicolumn{1}{|c|}{")
row <- str_c(row, getet( 86,'4','y','y','n','n','3'))
row <- str_c(row, "} \n")
row <- str_c(row, "                        & \\multicolumn{1}{|c|}{")
row <- str_c(row, getet(103,'0','y','n','n','n','n'))
row <- str_c(row, "} \n")
row <- str_c(row, "			& \\multicolumn{1}{|c|}{")
row <- str_c(row, getet(103,'4','y','y','y','y','2'))
row <- str_c(row, "} \n")
row <- str_c(row, "			& \\multicolumn{1}{|c|}{")
row <- str_c(row, getet(103,'4','y','y','y','y','3'))
row <- str_c(row, "} \n")
row <- str_c(row, "			\\\\ \n")
row <- str_c(row, " \\multicolumn{1}{|c|}{}\n")
row <- str_c(row, "			& \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} \n")
row <- str_c(row, "			& \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} \n")
row <- str_c(row, "                        & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} \n")
row <- str_c(row, "			& \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} \n")
row <- str_c(row, "                        & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} \n")
row <- str_c(row, "			\\\\ \n")
row <- str_c(row, " \\multicolumn{1}{|c|}{}\n")
row <- str_c(row, "			& \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} \n")
row <- str_c(row, "			& \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} \n")
row <- str_c(row, "                        & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} \n")
row <- str_c(row, "			& \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} \n")
row <- str_c(row, "                        & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} \n")
row <- str_c(row, "			\\\\ \n")
row <- str_c(row, " \\hline\n")
row <- str_c(row, "\\end{tabular}\n")
row <- str_c(row, "} \n")
row <- str_c(row, "\\\\\\texttt{$* p < 0.05$, $** p < 0.01$, $*** p < 0.001$}\n")
row <- str_c(row, "\\label{tab:ch5:hyp1}\n")
row <- str_c(row, "%\\end{table}\n")
row <- str_c(row, "\\end{sidewaystable}\n")

write.table(row, file=fl1, append=FALSE, quote = FALSE, row.names = FALSE, col.names = FALSE) 

#hyp2
row <- str_c("\\begin{sidewaystable}\n")
row <- str_c(row, "\\centering\n")
row <- str_c(row, "\\caption{Hypothesis 2: Compared to SGP (with ADFs), ACGPF Shows Improved Performance}\n")
row <- str_c(row, "\\scalebox{0.60} % Change this value to rescale the drawing.\n")
row <- str_c(row, "{\n")
row <- str_c(row, "\\begin{tabular}{|c|c|c|c|c|c|c|c|c|c|c|c|c|c|c|c|}\n")
row <- str_c(row, " \\hline\n")
row <- str_c(row, "% \\rowcolor{ltgray}\n")
row <- str_c(row, " \\multicolumn{1}{|c|}{\\multirow{4}{0.75in}{Outcome Variable}} & \\multicolumn{6}{|c|}{Lawn Mower Problem}\n")
row <- str_c(row, "                                                              & \\multicolumn{6}{|c|}{Bumble Bee Problem}\n")
row <- str_c(row, "							      & \\multicolumn{3}{|c|}{Two Box Problem}\\\\\n")
row <- str_c(row, " \\cline{2-16}\n")
row <- str_c(row, "% \\rowcolor{ltgray}\n")
row <- str_c(row, " \\multicolumn{1}{|c|}{} & \\multicolumn{3}{|c|}{25x25} & \\multicolumn{3}{|c|}{50x50} \n")
row <- str_c(row, "                        & \\multicolumn{3}{|c|}{2D} & \\multicolumn{3}{|c|}{3D}\n")
row <- str_c(row, "                        & \\multicolumn{3}{|c|}{3D} \n")
row <- str_c(row, "			\\\\ \n")
row <- str_c(row, " \\cline{2-16}\n")
row <- str_c(row, "% \\rowcolor{ltgray}\n")
row <- str_c(row, " \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{SGP} & \\multicolumn{1}{|c|}{ACGPF} & \\multicolumn{1}{|c|}{ACGPF} \n")
row <- str_c(row, "			& \\multicolumn{1}{|c|}{SGP} & \\multicolumn{1}{|c|}{ACGPF} & \\multicolumn{1}{|c|}{ACGPF} \n")
row <- str_c(row, "                        & \\multicolumn{1}{|c|}{SGP} & \\multicolumn{1}{|c|}{ACGPF} & \\multicolumn{1}{|c|}{ACGPF} \n")
row <- str_c(row, "			& \\multicolumn{1}{|c|}{SGP} & \\multicolumn{1}{|c|}{ACGPF} & \\multicolumn{1}{|c|}{ACGPF} \n")
row <- str_c(row, "                        & \\multicolumn{1}{|c|}{SGP} & \\multicolumn{1}{|c|}{ACGPF} & \\multicolumn{1}{|c|}{ACGPF} \n")
row <- str_c(row, "			\\\\ \n")
row <- str_c(row, " \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{(what=2)} & \\multicolumn{1}{|c|}{(what=3)} \n")
row <- str_c(row, "			& \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{(what=2)} & \\multicolumn{1}{|c|}{(what=3)} \n")
row <- str_c(row, "                        & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{(what=2)} & \\multicolumn{1}{|c|}{(what=3)} \n")
row <- str_c(row, "			& \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{(what=2)} & \\multicolumn{1}{|c|}{(what=3)} \n")
row <- str_c(row, "                        & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{(what=2)} & \\multicolumn{1}{|c|}{(what=3)} \n")
row <- str_c(row, "			\\\\ \n")
row <- str_c(row, " \\hline\n")
row <- str_c(row, " \\multicolumn{1}{|c|}{\\multirow{1}{0.75in}{Mean $\\#$ Hits}} \n")
row <- str_c(row, "			& \\multicolumn{1}{|c|}{")
row <- str_c(row, getdat('mhit', 23,'0','y','y','n','n','n'))
row <- str_c(row, "} \n")
row <- str_c(row, "                        & \\multicolumn{1}{|c|}{")
row <- str_c(row, getdat('mhit', 23,'4','y','y','n','y','2'), " ", rwilcox('mhit', 23,'0','y','y','n','n','n',23,'4','y','y','n','y','2'))
row <- str_c(row, "} \n")
row <- str_c(row, "			& \\multicolumn{1}{|c|}{")
row <- str_c(row, getdat('mhit', 23,'4','y','y','n','y','3'), " ", rwilcox('mhit', 23,'0','y','y','n','n','n',23,'4','y','y','n','y','3'))
row <- str_c(row, "} \n")
row <- str_c(row, "			& \\multicolumn{1}{|c|}{")
row <- str_c(row, getdat('mhit', 15,'0','y','y','n','n','n'))
row <- str_c(row, "} \n")
row <- str_c(row, "			& \\multicolumn{1}{|c|}{")
row <- str_c(row, getdat('mhit', 15,'4','y','y','n','y','2'), " ", rwilcox('mhit', 15,'0','y','y','n','n','n',15,'4','y','y','n','y','2'))
row <- str_c(row, "} \n")
row <- str_c(row, "			& \\multicolumn{1}{|c|}{")
row <- str_c(row, getdat('mhit', 15,'4','y','y','n','y','3'), " ", rwilcox('mhit', 15,'0','y','y','n','n','n',15,'4','y','y','n','y','3'))
row <- str_c(row, "} \n")
row <- str_c(row, "                        & \\multicolumn{1}{|c|}{")
row <- str_c(row, getdat('mhit', 36,'0','y','y','n','n','n'))
row <- str_c(row, "} \n")
row <- str_c(row, "			& \\multicolumn{1}{|c|}{")
row <- str_c(row, getdat('mhit', 36,'4','y','y','n','n','2'), " ", rwilcox('mhit', 36,'0','y','y','n','n','n',36,'4','y','y','n','n','2'))
row <- str_c(row, "} \n")
row <- str_c(row, "			& \\multicolumn{1}{|c|}{")
row <- str_c(row, getdat('mhit', 36,'4','y','y','n','n','3'), " ", rwilcox('mhit', 36,'0','y','y','n','n','n',36,'4','y','y','n','n','3'))
row <- str_c(row, "} \n")
row <- str_c(row, "			& \\multicolumn{1}{|c|}{")
row <- str_c(row, getdat('mhit', 86,'0','y','y','n','n','n'))
row <- str_c(row, "} \n")
row <- str_c(row, "			& \\multicolumn{1}{|c|}{")
row <- str_c(row, getdat('mhit', 86,'4','y','y','n','n','2'), " ", rwilcox('mhit', 86,'0','y','y','n','n','n',86,'4','y','y','n','n','2'))
row <- str_c(row, "} \n")
row <- str_c(row, "			& \\multicolumn{1}{|c|}{")
row <- str_c(row, getdat('mhit', 86,'4','y','y','n','n','3'), " ", rwilcox('mhit', 86,'0','y','y','n','n','n',86,'4','y','y','n','n','3'))
row <- str_c(row, "} \n")
row <- str_c(row, "                        & \\multicolumn{1}{|c|}{")
row <- str_c(row, getdat('mhit',103,'0','y','y','n','n','n'))
row <- str_c(row, "} \n")
row <- str_c(row, "			& \\multicolumn{1}{|c|}{")
row <- str_c(row, getdat('mhit',103,'4','y','y','y','y','2'), " ", rwilcox('mhit',103,'0','y','y','n','n','n',103,'4','y','y','y','y','2'))
row <- str_c(row, "} \n")
row <- str_c(row, "			& \\multicolumn{1}{|c|}{")
row <- str_c(row, getdat('mhit',103,'4','y','y','y','y','3'), " ", rwilcox('mhit',103,'0','y','y','n','n','n',103,'4','y','y','y','y','3'))
row <- str_c(row, "} \n")
row <- str_c(row, "			\\\\ \n")
row <- str_c(row, " \\hline\n")
row <- str_c(row, " \\multicolumn{1}{|c|}{\\multirow{5}{0.75in}{Mean Generation Where Best Individual Appeared}} \n")
row <- str_c(row, "			& \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} \n")
row <- str_c(row, "			& \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} \n")
row <- str_c(row, "                        & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} \n")
row <- str_c(row, "			& \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} \n")
row <- str_c(row, "                        & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} \n")
row <- str_c(row, "			\\\\ \n")
row <- str_c(row, " \\multicolumn{1}{|c|}{}\n")
row <- str_c(row, "			& \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} \n")
row <- str_c(row, "			& \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} \n")
row <- str_c(row, "                        & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} \n")
row <- str_c(row, "			& \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} \n")
row <- str_c(row, "                        & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} \n")
row <- str_c(row, "			\\\\ \n")
row <- str_c(row, " \\multicolumn{1}{|c|}{} \n")
row <- str_c(row, "			& \\multicolumn{1}{|c|}{")
row <- str_c(row, getdat('mgen', 23,'0','y','y','n','n','n'))
row <- str_c(row, "} \n")
row <- str_c(row, "                        & \\multicolumn{1}{|c|}{")
row <- str_c(row, getdat('mgen', 23,'4','y','y','n','y','2'), " ", rwilcox('mgen', 23,'0','y','y','n','n','n',23,'4','y','y','n','y','2'))
row <- str_c(row, "} \n")
row <- str_c(row, "			& \\multicolumn{1}{|c|}{")
row <- str_c(row, getdat('mgen', 23,'4','y','y','n','y','3'), " ", rwilcox('mgen', 23,'0','y','y','n','n','n',23,'4','y','y','n','y','3'))
row <- str_c(row, "} \n")
row <- str_c(row, "			& \\multicolumn{1}{|c|}{")
row <- str_c(row, getdat('mgen', 15,'0','y','y','n','n','n'))
row <- str_c(row, "} \n")
row <- str_c(row, "			& \\multicolumn{1}{|c|}{")
row <- str_c(row, getdat('mgen', 15,'4','y','y','n','y','2'), " ", rwilcox('mgen', 15,'0','y','y','n','n','n',15,'4','y','y','n','y','2'))
row <- str_c(row, "} \n")
row <- str_c(row, "			& \\multicolumn{1}{|c|}{")
row <- str_c(row, getdat('mgen', 15,'4','y','y','n','y','3'), " ", rwilcox('mgen', 15,'0','y','y','n','n','n',15,'4','y','y','n','y','3'))
row <- str_c(row, "} \n")
row <- str_c(row, "                        & \\multicolumn{1}{|c|}{")
row <- str_c(row, getdat('mgen', 36,'0','y','y','n','n','n'))
row <- str_c(row, "} \n")
row <- str_c(row, "			& \\multicolumn{1}{|c|}{")
row <- str_c(row, getdat('mgen', 36,'4','y','y','n','n','2'), " ", rwilcox('mgen', 36,'0','y','y','n','n','n',36,'4','y','y','n','n','2'))
row <- str_c(row, "} \n")
row <- str_c(row, "			& \\multicolumn{1}{|c|}{")
row <- str_c(row, getdat('mgen', 36,'4','y','y','n','n','3'), " ", rwilcox('mgen', 36,'0','y','y','n','n','n',36,'4','y','y','n','n','3'))
row <- str_c(row, "} \n")
row <- str_c(row, "			& \\multicolumn{1}{|c|}{")
row <- str_c(row, getdat('mgen', 86,'0','y','y','n','n','n'))
row <- str_c(row, "} \n")
row <- str_c(row, "			& \\multicolumn{1}{|c|}{")
row <- str_c(row, getdat('mgen', 86,'4','y','y','n','n','2'), " ", rwilcox('mgen', 86,'0','y','y','n','n','n',86,'4','y','y','n','n','2'))
row <- str_c(row, "} \n")
row <- str_c(row, "			& \\multicolumn{1}{|c|}{")
row <- str_c(row, getdat('mgen', 86,'4','y','y','n','n','3'), " ", rwilcox('mgen', 86,'0','y','y','n','n','n',86,'4','y','y','n','n','3'))
row <- str_c(row, "} \n")
row <- str_c(row, "                        & \\multicolumn{1}{|c|}{")
row <- str_c(row, getdat('mgen',103,'0','y','y','n','n','n'))
row <- str_c(row, "} \n")
row <- str_c(row, "			& \\multicolumn{1}{|c|}{")
row <- str_c(row, getdat('mgen',103,'4','y','y','y','y','2'), " ", rwilcox('mgen',103,'0','y','y','n','n','n',103,'4','y','y','y','y','2'))
row <- str_c(row, "} \n")
row <- str_c(row, "			& \\multicolumn{1}{|c|}{")
row <- str_c(row, getdat('mgen',103,'4','y','y','y','y','3'), " ", rwilcox('mgen',103,'0','y','y','n','n','n',103,'4','y','y','y','y','3'))
row <- str_c(row, "} \n")
row <- str_c(row, "			\\\\ \n")
row <- str_c(row, " \\multicolumn{1}{|c|}{} \n")
row <- str_c(row, "			& \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} \n")
row <- str_c(row, "			& \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} \n")
row <- str_c(row, "                        & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} \n")
row <- str_c(row, "			& \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} \n")
row <- str_c(row, "                        & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} \n")
row <- str_c(row, "			\\\\ \n")
row <- str_c(row, " \\multicolumn{1}{|c|}{}\n")
row <- str_c(row, "			& \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} \n")
row <- str_c(row, "			& \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} \n")
row <- str_c(row, "                        & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} \n")
row <- str_c(row, "			& \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} \n")
row <- str_c(row, "                        & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} \n")
row <- str_c(row, "			\\\\ \n")
row <- str_c(row, " \\hline\n")
row <- str_c(row, " \\multicolumn{1}{|c|}{\\multirow{2}{0.75in}{Mean $\\#$ Nodes}} \n")
row <- str_c(row, "			& \\multicolumn{1}{|c|}{")
row <- str_c(row, getdat('mnod', 23,'0','y','y','n','n','n'))
row <- str_c(row, "} \n")
row <- str_c(row, "                        & \\multicolumn{1}{|c|}{")
row <- str_c(row, getdat('mnod', 23,'4','y','y','n','y','2'), " ", rwilcox('mnod', 23,'0','y','y','n','n','n',23,'4','y','y','n','y','2'))
row <- str_c(row, "} \n")
row <- str_c(row, "			& \\multicolumn{1}{|c|}{")
row <- str_c(row, getdat('mnod', 23,'4','y','y','n','y','3'), " ", rwilcox('mnod', 23,'0','y','y','n','n','n',23,'4','y','y','n','y','3'))
row <- str_c(row, "} \n")
row <- str_c(row, "			& \\multicolumn{1}{|c|}{")
row <- str_c(row, getdat('mnod', 15,'0','y','y','n','n','n'))
row <- str_c(row, "} \n")
row <- str_c(row, "			& \\multicolumn{1}{|c|}{")
row <- str_c(row, getdat('mnod', 15,'4','y','y','n','y','2'), " ", rwilcox('mnod', 15,'0','y','y','n','n','n',15,'4','y','y','n','y','2'))
row <- str_c(row, "} \n")
row <- str_c(row, "			& \\multicolumn{1}{|c|}{")
row <- str_c(row, getdat('mnod', 15,'4','y','y','n','y','3'), " ", rwilcox('mnod', 15,'0','y','y','n','n','n',15,'4','y','y','n','y','3'))
row <- str_c(row, "} \n")
row <- str_c(row, "                        & \\multicolumn{1}{|c|}{")
row <- str_c(row, getdat('mnod', 36,'0','y','y','n','n','n'))
row <- str_c(row, "} \n")
row <- str_c(row, "			& \\multicolumn{1}{|c|}{")
row <- str_c(row, getdat('mnod', 36,'4','y','y','n','n','2'), " ", rwilcox('mnod', 36,'0','y','y','n','n','n',36,'4','y','y','n','n','2'))
row <- str_c(row, "} \n")
row <- str_c(row, "			& \\multicolumn{1}{|c|}{")
row <- str_c(row, getdat('mnod', 36,'4','y','y','n','n','3'), " ", rwilcox('mnod', 36,'0','y','y','n','n','n',36,'4','y','y','n','n','3'))
row <- str_c(row, "} \n")
row <- str_c(row, "			& \\multicolumn{1}{|c|}{")
row <- str_c(row, getdat('mnod', 86,'0','y','y','n','n','n'))
row <- str_c(row, "} \n")
row <- str_c(row, "			& \\multicolumn{1}{|c|}{")
row <- str_c(row, getdat('mnod', 86,'4','y','y','n','n','2'), " ", rwilcox('mnod', 86,'0','y','y','n','n','n',86,'4','y','y','n','n','2'))
row <- str_c(row, "} \n")
row <- str_c(row, "			& \\multicolumn{1}{|c|}{")
row <- str_c(row, getdat('mnod', 86,'4','y','y','n','n','3'), " ", rwilcox('mnod', 86,'0','y','y','n','n','n',86,'4','y','y','n','n','3'))
row <- str_c(row, "} \n")
row <- str_c(row, "                        & \\multicolumn{1}{|c|}{")
row <- str_c(row, getdat('mnod',103,'0','y','y','n','n','n'))
row <- str_c(row, "} \n")
row <- str_c(row, "			& \\multicolumn{1}{|c|}{")
row <- str_c(row, getdat('mnod',103,'4','y','y','y','y','2'), " ", rwilcox('mnod',103,'0','y','y','n','n','n',103,'4','y','y','y','y','2'))
row <- str_c(row, "} \n")
row <- str_c(row, "			& \\multicolumn{1}{|c|}{")
row <- str_c(row, getdat('mnod',103,'4','y','y','y','y','3'), " ", rwilcox('mnod',103,'0','y','y','n','n','n',103,'4','y','y','y','y','3'))
row <- str_c(row, "} \n")
row <- str_c(row, "			\\\\ \n")
row <- str_c(row, " \\multicolumn{1}{|c|}{}\n")
row <- str_c(row, "			& \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} \n")
row <- str_c(row, "			& \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} \n")
row <- str_c(row, "                        & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} \n")
row <- str_c(row, "			& \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} \n")
row <- str_c(row, "                        & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} \n")
row <- str_c(row, "			\\\\ \n")
row <- str_c(row, " \\hline\n")
row <- str_c(row, " \\multicolumn{1}{|c|}{\\multirow{3}{0.75in}{Mean Tree Depth (entire run)}} \n")
row <- str_c(row, "			& \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} \n")
row <- str_c(row, "			& \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} \n")
row <- str_c(row, "                        & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} \n")
row <- str_c(row, "			& \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} \n")
row <- str_c(row, "                        & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} \n")
row <- str_c(row, "			\\\\ \n")
row <- str_c(row, " \\multicolumn{1}{|c|}{}\n")
row <- str_c(row, "			& \\multicolumn{1}{|c|}{")
row <- str_c(row, getdat('mdep', 23,'0','y','n','n','n','n'))
row <- str_c(row, "} \n")
row <- str_c(row, "                        & \\multicolumn{1}{|c|}{")
row <- str_c(row, getdat('mdep', 23,'4','y','y','n','y','2'), " ", rwilcox('mdep', 23,'0','y','n','n','n','n',23,'4','y','y','n','y','2'))
row <- str_c(row, "} \n")
row <- str_c(row, "			& \\multicolumn{1}{|c|}{")
row <- str_c(row, getdat('mdep', 23,'4','y','y','n','y','3'), " ", rwilcox('mdep', 23,'0','y','n','n','n','n',23,'4','y','y','n','y','3'))
row <- str_c(row, "} \n")
row <- str_c(row, "			& \\multicolumn{1}{|c|}{")
row <- str_c(row, getdat('mdep', 15,'0','y','n','n','n','n'))
row <- str_c(row, "} \n")
row <- str_c(row, "			& \\multicolumn{1}{|c|}{")
row <- str_c(row, getdat('mdep', 15,'4','y','y','n','y','2'), " ", rwilcox('mdep', 15,'0','y','n','n','n','n',15,'4','y','y','n','y','2'))
row <- str_c(row, "} \n")
row <- str_c(row, "			& \\multicolumn{1}{|c|}{")
row <- str_c(row, getdat('mdep', 15,'4','y','y','n','y','3'), " ", rwilcox('mdep', 15,'0','y','n','n','n','n',15,'4','y','y','n','y','3'))
row <- str_c(row, "} \n")
row <- str_c(row, "                        & \\multicolumn{1}{|c|}{")
row <- str_c(row, getdat('mdep', 36,'0','y','n','n','n','n'))
row <- str_c(row, "} \n")
row <- str_c(row, "			& \\multicolumn{1}{|c|}{")
row <- str_c(row, getdat('mdep', 36,'4','y','y','n','n','2'), " ", rwilcox('mdep', 36,'0','y','n','n','n','n',36,'4','y','y','n','n','2'))
row <- str_c(row, "} \n")
row <- str_c(row, "			& \\multicolumn{1}{|c|}{")
row <- str_c(row, getdat('mdep', 36,'4','y','y','n','n','3'), " ", rwilcox('mdep', 36,'0','y','n','n','n','n',36,'4','y','y','n','n','3'))
row <- str_c(row, "} \n")
row <- str_c(row, "			& \\multicolumn{1}{|c|}{")
row <- str_c(row, getdat('mdep', 86,'0','y','n','n','n','n'))
row <- str_c(row, "} \n")
row <- str_c(row, "			& \\multicolumn{1}{|c|}{")
row <- str_c(row, getdat('mdep', 86,'4','y','y','n','n','2'), " ", rwilcox('mdep', 86,'0','y','n','n','n','n',86,'4','y','y','n','n','2'))
row <- str_c(row, "} \n")
row <- str_c(row, "			& \\multicolumn{1}{|c|}{")
row <- str_c(row, getdat('mdep', 86,'4','y','y','n','n','3'), " ", rwilcox('mdep', 86,'0','y','n','n','n','n',86,'4','y','y','n','n','3'))
row <- str_c(row, "} \n")
row <- str_c(row, "                        & \\multicolumn{1}{|c|}{")
row <- str_c(row, getdat('mdep',103,'0','y','n','n','n','n'))
row <- str_c(row, "} \n")
row <- str_c(row, "			& \\multicolumn{1}{|c|}{")
row <- str_c(row, getdat('mdep',103,'4','y','y','y','y','2'), " ", rwilcox('mdep',103,'0','y','n','n','n','n',103,'4','y','y','y','y','2'))
row <- str_c(row, "} \n")
row <- str_c(row, "			& \\multicolumn{1}{|c|}{")
row <- str_c(row, getdat('mdep',103,'4','y','y','y','y','3'), " ", rwilcox('mdep',103,'0','y','n','n','n','n',103,'4','y','y','y','y','3'))
row <- str_c(row, "} \n")
row <- str_c(row, "			\\\\ \n")
row <- str_c(row, " \\multicolumn{1}{|c|}{}\n")
row <- str_c(row, "			& \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} \n")
row <- str_c(row, "			& \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} \n")
row <- str_c(row, "                        & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} \n")
row <- str_c(row, "			& \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} \n")
row <- str_c(row, "                        & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} \n")
row <- str_c(row, "			\\\\ \n")
row <- str_c(row, " \\hline\n")
row <- str_c(row, " \\multicolumn{1}{|c|}{\\multirow{3}{0.75in}{Total Execution Time (all runs)}} \n")
row <- str_c(row, "			& \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} \n")
row <- str_c(row, "			& \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} \n")
row <- str_c(row, "                        & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} \n")
row <- str_c(row, "			& \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} \n")
row <- str_c(row, "                        & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} \n")
row <- str_c(row, "			\\\\ \n")
row <- str_c(row, " \\multicolumn{1}{|c|}{}\n")
row <- str_c(row, "			& \\multicolumn{1}{|c|}{")
row <- str_c(row, getet( 23,'0','y','y','n','n','n'))
row <- str_c(row, "} \n")
row <- str_c(row, "                        & \\multicolumn{1}{|c|}{")
row <- str_c(row, getet( 23,'4','y','y','n','y','2'))
row <- str_c(row, "} \n")
row <- str_c(row, "			& \\multicolumn{1}{|c|}{")
row <- str_c(row, getet( 23,'4','y','y','n','y','3'))
row <- str_c(row, "} \n")
row <- str_c(row, "			& \\multicolumn{1}{|c|}{")
row <- str_c(row, getet( 15,'0','y','y','n','n','n'))
row <- str_c(row, "} \n")
row <- str_c(row, "			& \\multicolumn{1}{|c|}{")
row <- str_c(row, getet( 15,'4','y','y','n','y','2'))
row <- str_c(row, "} \n")
row <- str_c(row, "			& \\multicolumn{1}{|c|}{")
row <- str_c(row, getet( 15,'4','y','y','n','y','3'))
row <- str_c(row, "} \n")
row <- str_c(row, "                        & \\multicolumn{1}{|c|}{")
row <- str_c(row, getet( 36,'0','y','y','n','n','n'))
row <- str_c(row, "} \n")
row <- str_c(row, "			& \\multicolumn{1}{|c|}{")
row <- str_c(row, getet( 36,'4','y','y','n','n','2'))
row <- str_c(row, "} \n")
row <- str_c(row, "			& \\multicolumn{1}{|c|}{")
row <- str_c(row, getet( 36,'4','y','y','n','n','3'))
row <- str_c(row, "} \n")
row <- str_c(row, "			& \\multicolumn{1}{|c|}{")
row <- str_c(row, getet( 86,'0','y','y','n','n','n'))
row <- str_c(row, "} \n")
row <- str_c(row, "			& \\multicolumn{1}{|c|}{")
row <- str_c(row, getet( 86,'4','y','y','n','n','2'))
row <- str_c(row, "} \n")
row <- str_c(row, "			& \\multicolumn{1}{|c|}{")
row <- str_c(row, getet( 86,'4','y','y','n','n','3'))
row <- str_c(row, "} \n")
row <- str_c(row, "                        & \\multicolumn{1}{|c|}{")
row <- str_c(row, getet(103,'0','y','y','n','n','n'))
row <- str_c(row, "} \n")
row <- str_c(row, "			& \\multicolumn{1}{|c|}{")
row <- str_c(row, getet(103,'4','y','y','y','y','2'))
row <- str_c(row, "} \n")
row <- str_c(row, "			& \\multicolumn{1}{|c|}{")
row <- str_c(row, getet(103,'4','y','y','y','y','3'))
row <- str_c(row, "} \n")
row <- str_c(row, "			\\\\ \n")
row <- str_c(row, " \\multicolumn{1}{|c|}{}\n")
row <- str_c(row, "			& \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} \n")
row <- str_c(row, "			& \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} \n")
row <- str_c(row, "                        & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} \n")
row <- str_c(row, "			& \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} \n")
row <- str_c(row, "                        & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} \n")
row <- str_c(row, "			\\\\ \n")
row <- str_c(row, " \\multicolumn{1}{|c|}{}\n")
row <- str_c(row, "			& \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} \n")
row <- str_c(row, "			& \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} \n")
row <- str_c(row, "                        & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} \n")
row <- str_c(row, "			& \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} \n")
row <- str_c(row, "                        & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} \n")
row <- str_c(row, "			\\\\ \n")
row <- str_c(row, " \\hline\n")
row <- str_c(row, "\\end{tabular}\n")
row <- str_c(row, "} \n")
row <- str_c(row, "\\\\\\texttt{$* p < 0.05$, $** p < 0.01$, $*** p < 0.001$}\n")
row <- str_c(row, "\\label{tab:ch5:hyp2}\n")
row <- str_c(row, "%\\end{table}\n")
row <- str_c(row, "\\end{sidewaystable}\n")

write.table(row, file=fl2, append=FALSE, quote = FALSE, row.names = FALSE, col.names = FALSE) 

#hyp3
row <- str_c("\\begin{sidewaystable}\n")
row <- str_c(row, "\\centering\n")
row <- str_c(row, "\\caption{Hypothesis 3: Compared to CGP (with Types, with Constraints, with no ADFs), ACGPF Shows Improved Performance}\n")
row <- str_c(row, "\\scalebox{0.60} % Change this value to rescale the drawing.\n")
row <- str_c(row, "{\n")
row <- str_c(row, "\\begin{tabular}{|c|c|c|c|c|c|c|c|c|c|c|c|c|c|c|c|}\n")
row <- str_c(row, " \\hline\n")
row <- str_c(row, "% \\rowcolor{ltgray}\n")
row <- str_c(row, " \\multicolumn{1}{|c|}{\\multirow{4}{0.75in}{Outcome Variable}} & \\multicolumn{6}{|c|}{Lawn Mower Problem}\n")
row <- str_c(row, "                                                              & \\multicolumn{6}{|c|}{Bumble Bee Problem}\n")
row <- str_c(row, "							      & \\multicolumn{3}{|c|}{Two Box Problem}\\\\\n")
row <- str_c(row, " \\cline{2-16}\n")
row <- str_c(row, "% \\rowcolor{ltgray}\n")
row <- str_c(row, " \\multicolumn{1}{|c|}{} & \\multicolumn{3}{|c|}{25x25} & \\multicolumn{3}{|c|}{50x50} \n")
row <- str_c(row, "                        & \\multicolumn{3}{|c|}{2D} & \\multicolumn{3}{|c|}{3D}\n")
row <- str_c(row, "                        & \\multicolumn{3}{|c|}{3D} \n")
row <- str_c(row, "			\\\\ \n")
row <- str_c(row, " \\cline{2-16}\n")
row <- str_c(row, "% \\rowcolor{ltgray}\n")
row <- str_c(row, " \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{CGP} & \\multicolumn{1}{|c|}{ACGPF} & \\multicolumn{1}{|c|}{ACGPF} \n")
row <- str_c(row, "			& \\multicolumn{1}{|c|}{CGP} & \\multicolumn{1}{|c|}{ACGPF} & \\multicolumn{1}{|c|}{ACGPF} \n")
row <- str_c(row, "                        & \\multicolumn{1}{|c|}{CGP} & \\multicolumn{1}{|c|}{ACGPF} & \\multicolumn{1}{|c|}{ACGPF} \n")
row <- str_c(row, "			& \\multicolumn{1}{|c|}{CGP} & \\multicolumn{1}{|c|}{ACGPF} & \\multicolumn{1}{|c|}{ACGPF} \n")
row <- str_c(row, "                        & \\multicolumn{1}{|c|}{CGP} & \\multicolumn{1}{|c|}{ACGPF} & \\multicolumn{1}{|c|}{ACGPF} \n")
row <- str_c(row, "			\\\\ \n")
row <- str_c(row, " \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{(what=2)} & \\multicolumn{1}{|c|}{(what=3)} \n")
row <- str_c(row, "			& \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{(what=2)} & \\multicolumn{1}{|c|}{(what=3)} \n")
row <- str_c(row, "                        & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{(what=2)} & \\multicolumn{1}{|c|}{(what=3)} \n")
row <- str_c(row, "			& \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{(what=2)} & \\multicolumn{1}{|c|}{(what=3)} \n")
row <- str_c(row, "                        & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{(what=2)} & \\multicolumn{1}{|c|}{(what=3)} \n")
row <- str_c(row, "			\\\\ \n")
row <- str_c(row, " \\hline\n")
row <- str_c(row, " \\multicolumn{1}{|c|}{\\multirow{1}{0.75in}{Mean $\\#$ Hits}} \n")
row <- str_c(row, "			& \\multicolumn{1}{|c|}{")
row <- str_c(row, getdat('mhit', 23,'1','n','n','n','n','n'))
row <- str_c(row, "} \n")
row <- str_c(row, "                        & \\multicolumn{1}{|c|}{")
row <- str_c(row, getdat('mhit', 23,'4','y','y','n','y','2'), " ", rwilcox('mhit', 23,'1','n','n','n','n','n',23,'4','y','y','n','y','2'))
row <- str_c(row, "} \n")
row <- str_c(row, "			& \\multicolumn{1}{|c|}{")
row <- str_c(row, getdat('mhit', 23,'4','y','y','n','y','3'), " ", rwilcox('mhit', 23,'1','n','n','n','n','n',23,'4','y','y','n','y','3'))
row <- str_c(row, "} \n")
row <- str_c(row, "			& \\multicolumn{1}{|c|}{")
row <- str_c(row, getdat('mhit', 15,'1','n','n','n','n','n'))
row <- str_c(row, "} \n")
row <- str_c(row, "			& \\multicolumn{1}{|c|}{")
row <- str_c(row, getdat('mhit', 15,'4','y','y','n','y','2'), " ", rwilcox('mhit', 15,'1','n','n','n','n','n',15,'4','y','y','n','y','2'))
row <- str_c(row, "} \n")
row <- str_c(row, "			& \\multicolumn{1}{|c|}{")
row <- str_c(row, getdat('mhit', 15,'4','y','y','n','y','3'), " ", rwilcox('mhit', 15,'1','n','n','n','n','n',15,'4','y','y','n','y','3'))
row <- str_c(row, "} \n")
row <- str_c(row, "                        & \\multicolumn{1}{|c|}{")
row <- str_c(row, getdat('mhit', 36,'1','n','n','n','n','n'))
row <- str_c(row, "} \n")
row <- str_c(row, "			& \\multicolumn{1}{|c|}{")
row <- str_c(row, getdat('mhit', 36,'4','y','y','n','n','2'), " ", rwilcox('mhit', 36,'1','n','n','n','n','n',36,'4','y','y','n','n','2'))
row <- str_c(row, "} \n")
row <- str_c(row, "			& \\multicolumn{1}{|c|}{")
row <- str_c(row, getdat('mhit', 36,'4','y','y','n','n','3'), " ", rwilcox('mhit', 36,'1','n','n','n','n','n',36,'4','y','y','n','n','3'))
row <- str_c(row, "} \n")
row <- str_c(row, "			& \\multicolumn{1}{|c|}{")
row <- str_c(row, getdat('mhit', 86,'1','n','n','n','n','n'))
row <- str_c(row, "} \n")
row <- str_c(row, "			& \\multicolumn{1}{|c|}{")
row <- str_c(row, getdat('mhit', 86,'4','y','y','n','n','2'), " ", rwilcox('mhit', 86,'1','n','n','n','n','n',86,'4','y','y','n','n','2'))
row <- str_c(row, "} \n")
row <- str_c(row, "			& \\multicolumn{1}{|c|}{")
row <- str_c(row, getdat('mhit', 86,'4','y','y','n','n','3'), " ", rwilcox('mhit', 86,'1','n','n','n','n','n',86,'4','y','y','n','n','3'))
row <- str_c(row, "} \n")
row <- str_c(row, "                        & \\multicolumn{1}{|c|}{")
row <- str_c(row, getdat('mhit',103,'1','n','n','y','y','n'))
row <- str_c(row, "} \n")
row <- str_c(row, "			& \\multicolumn{1}{|c|}{")
row <- str_c(row, getdat('mhit',103,'4','y','y','y','y','2'), " ", rwilcox('mhit',103,'1','n','n','y','y','n',103,'4','y','y','y','y','2'))
row <- str_c(row, "} \n")
row <- str_c(row, "			& \\multicolumn{1}{|c|}{")
row <- str_c(row, getdat('mhit',103,'4','y','y','y','y','3'), " ", rwilcox('mhit',103,'1','n','n','y','y','n',103,'4','y','y','y','y','3'))
row <- str_c(row, "} \n")
row <- str_c(row, "			\\\\ \n")
row <- str_c(row, " \\hline\n")
row <- str_c(row, " \\multicolumn{1}{|c|}{\\multirow{5}{0.75in}{Mean Generation Where Best Individual Appeared}} \n")
row <- str_c(row, "			& \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} \n")
row <- str_c(row, "			& \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} \n")
row <- str_c(row, "                        & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} \n")
row <- str_c(row, "			& \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} \n")
row <- str_c(row, "                        & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} \n")
row <- str_c(row, "			\\\\ \n")
row <- str_c(row, " \\multicolumn{1}{|c|}{}\n")
row <- str_c(row, "			& \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} \n")
row <- str_c(row, "			& \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} \n")
row <- str_c(row, "                        & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} \n")
row <- str_c(row, "			& \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} \n")
row <- str_c(row, "                        & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} \n")
row <- str_c(row, "			\\\\ \n")
row <- str_c(row, " \\multicolumn{1}{|c|}{} \n")
row <- str_c(row, "			& \\multicolumn{1}{|c|}{")
row <- str_c(row, getdat('mgen', 23,'1','n','n','n','n','n'))
row <- str_c(row, "} \n")
row <- str_c(row, "                        & \\multicolumn{1}{|c|}{")
row <- str_c(row, getdat('mgen', 23,'4','y','y','n','y','2'), " ", rwilcox('mgen', 23,'1','n','n','n','n','n',23,'4','y','y','n','y','2'))
row <- str_c(row, "} \n")
row <- str_c(row, "			& \\multicolumn{1}{|c|}{")
row <- str_c(row, getdat('mgen', 23,'4','y','y','n','y','3'), " ", rwilcox('mgen', 23,'1','n','n','n','n','n',23,'4','y','y','n','y','3'))
row <- str_c(row, "} \n")
row <- str_c(row, "			& \\multicolumn{1}{|c|}{")
row <- str_c(row, getdat('mgen', 15,'1','n','n','n','n','n'))
row <- str_c(row, "} \n")
row <- str_c(row, "			& \\multicolumn{1}{|c|}{")
row <- str_c(row, getdat('mgen', 15,'4','y','y','n','y','2'), " ", rwilcox('mgen', 15,'1','n','n','n','n','n',15,'4','y','y','n','y','2'))
row <- str_c(row, "} \n")
row <- str_c(row, "			& \\multicolumn{1}{|c|}{")
row <- str_c(row, getdat('mgen', 15,'4','y','y','n','y','3'), " ", rwilcox('mgen', 15,'1','n','n','n','n','n',15,'4','y','y','n','y','3'))
row <- str_c(row, "} \n")
row <- str_c(row, "                        & \\multicolumn{1}{|c|}{")
row <- str_c(row, getdat('mgen', 36,'1','n','n','n','n','n'))
row <- str_c(row, "} \n")
row <- str_c(row, "			& \\multicolumn{1}{|c|}{")
row <- str_c(row, getdat('mgen', 36,'4','y','y','n','n','2'), " ", rwilcox('mgen', 36,'1','n','n','n','n','n',36,'4','y','y','n','n','2'))
row <- str_c(row, "} \n")
row <- str_c(row, "			& \\multicolumn{1}{|c|}{")
row <- str_c(row, getdat('mgen', 36,'4','y','y','n','n','3'), " ", rwilcox('mgen', 36,'1','n','n','n','n','n',36,'4','y','y','n','n','3'))
row <- str_c(row, "} \n")
row <- str_c(row, "			& \\multicolumn{1}{|c|}{")
row <- str_c(row, getdat('mgen', 86,'1','n','n','n','n','n'))
row <- str_c(row, "} \n")
row <- str_c(row, "			& \\multicolumn{1}{|c|}{")
row <- str_c(row, getdat('mgen', 86,'4','y','y','n','n','2'), " ", rwilcox('mgen', 86,'1','n','n','n','n','n',86,'4','y','y','n','n','2'))
row <- str_c(row, "} \n")
row <- str_c(row, "			& \\multicolumn{1}{|c|}{")
row <- str_c(row, getdat('mgen', 86,'4','y','y','n','n','3'), " ", rwilcox('mgen', 86,'1','n','n','n','n','n',86,'4','y','y','n','n','3'))
row <- str_c(row, "} \n")
row <- str_c(row, "                        & \\multicolumn{1}{|c|}{")
row <- str_c(row, getdat('mgen',103,'1','n','n','y','y','n'))
row <- str_c(row, "} \n")
row <- str_c(row, "			& \\multicolumn{1}{|c|}{")
row <- str_c(row, getdat('mgen',103,'4','y','y','y','y','2'), " ", rwilcox('mgen',103,'1','n','n','y','y','n',103,'4','y','y','y','y','2'))
row <- str_c(row, "} \n")
row <- str_c(row, "			& \\multicolumn{1}{|c|}{")
row <- str_c(row, getdat('mgen',103,'4','y','y','y','y','3'), " ", rwilcox('mgen',103,'1','n','n','y','y','n',103,'4','y','y','y','y','3'))
row <- str_c(row, "} \n")
row <- str_c(row, "			\\\\ \n")
row <- str_c(row, " \\multicolumn{1}{|c|}{} \n")
row <- str_c(row, "			& \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} \n")
row <- str_c(row, "			& \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} \n")
row <- str_c(row, "                        & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} \n")
row <- str_c(row, "			& \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} \n")
row <- str_c(row, "                        & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} \n")
row <- str_c(row, "			\\\\ \n")
row <- str_c(row, " \\multicolumn{1}{|c|}{}\n")
row <- str_c(row, "			& \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} \n")
row <- str_c(row, "			& \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} \n")
row <- str_c(row, "                        & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} \n")
row <- str_c(row, "			& \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} \n")
row <- str_c(row, "                        & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} \n")
row <- str_c(row, "			\\\\ \n")
row <- str_c(row, " \\hline\n")
row <- str_c(row, " \\multicolumn{1}{|c|}{\\multirow{2}{0.75in}{Mean $\\#$ Nodes}} \n")
row <- str_c(row, "			& \\multicolumn{1}{|c|}{")
row <- str_c(row, getdat('mnod', 23,'1','n','n','n','n','n'))
row <- str_c(row, "} \n")
row <- str_c(row, "                        & \\multicolumn{1}{|c|}{")
row <- str_c(row, getdat('mnod', 23,'4','y','y','n','y','2'), " ", rwilcox('mnod', 23,'1','n','n','n','n','n',23,'4','y','y','n','y','2'))
row <- str_c(row, "} \n")
row <- str_c(row, "			& \\multicolumn{1}{|c|}{")
row <- str_c(row, getdat('mnod', 23,'4','y','y','n','y','3'), " ", rwilcox('mnod', 23,'1','n','n','n','n','n',23,'4','y','y','n','y','3'))
row <- str_c(row, "} \n")
row <- str_c(row, "			& \\multicolumn{1}{|c|}{")
row <- str_c(row, getdat('mnod', 15,'1','n','n','n','n','n'))
row <- str_c(row, "} \n")
row <- str_c(row, "			& \\multicolumn{1}{|c|}{")
row <- str_c(row, getdat('mnod', 15,'4','y','y','n','y','2'), " ", rwilcox('mnod', 15,'1','n','n','n','n','n', 15,'4','y','y','n','y','2'))
row <- str_c(row, "} \n")
row <- str_c(row, "			& \\multicolumn{1}{|c|}{")
row <- str_c(row, getdat('mnod', 15,'4','y','y','n','y','3'), " ", rwilcox('mnod', 15,'1','n','n','n','n','n', 15,'4','y','y','n','y','3'))
row <- str_c(row, "} \n")
row <- str_c(row, "                        & \\multicolumn{1}{|c|}{")
row <- str_c(row, getdat('mnod', 36,'1','n','n','n','n','n'))
row <- str_c(row, "} \n")
row <- str_c(row, "			& \\multicolumn{1}{|c|}{")
row <- str_c(row, getdat('mnod', 36,'4','y','y','n','n','2'), " ", rwilcox('mnod', 36,'1','n','n','n','n','n', 36,'4','y','y','n','n','2'))
row <- str_c(row, "} \n")
row <- str_c(row, "			& \\multicolumn{1}{|c|}{")
row <- str_c(row, getdat('mnod', 36,'4','y','y','n','n','3'), " ", rwilcox('mnod', 36,'1','n','n','n','n','n', 36,'4','y','y','n','n','3'))
row <- str_c(row, "} \n")
row <- str_c(row, "			& \\multicolumn{1}{|c|}{")
row <- str_c(row, getdat('mnod', 86,'1','n','n','n','n','n'))
row <- str_c(row, "} \n")
row <- str_c(row, "			& \\multicolumn{1}{|c|}{")
row <- str_c(row, getdat('mnod', 86,'4','y','y','n','n','2'), " ", rwilcox('mnod', 86,'1','n','n','n','n','n', 86,'4','y','y','n','n','2'))
row <- str_c(row, "} \n")
row <- str_c(row, "			& \\multicolumn{1}{|c|}{")
row <- str_c(row, getdat('mnod', 86,'4','y','y','n','n','3'), " ", rwilcox('mnod', 86,'1','n','n','n','n','n', 86,'4','y','y','n','n','3'))
row <- str_c(row, "} \n")
row <- str_c(row, "                        & \\multicolumn{1}{|c|}{")
row <- str_c(row, getdat('mnod',103,'1','n','n','y','y','n'))
row <- str_c(row, "} \n")
row <- str_c(row, "			& \\multicolumn{1}{|c|}{")
row <- str_c(row, getdat('mnod',103,'4','y','y','y','y','2'), " ", rwilcox('mnod',103,'1','n','n','y','y','n',103,'4','y','y','y','y','2'))
row <- str_c(row, "} \n")
row <- str_c(row, "			& \\multicolumn{1}{|c|}{")
row <- str_c(row, getdat('mnod',103,'4','y','y','y','y','3'), " ", rwilcox('mnod',103,'1','n','n','y','y','n',103,'4','y','y','y','y','3'))
row <- str_c(row, "} \n")
row <- str_c(row, "			\\\\ \n")
row <- str_c(row, " \\multicolumn{1}{|c|}{}\n")
row <- str_c(row, "			& \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} \n")
row <- str_c(row, "			& \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} \n")
row <- str_c(row, "                        & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} \n")
row <- str_c(row, "			& \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} \n")
row <- str_c(row, "                        & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} \n")
row <- str_c(row, "			\\\\ \n")
row <- str_c(row, " \\hline\n")
row <- str_c(row, " \\multicolumn{1}{|c|}{\\multirow{3}{0.75in}{Mean Tree Depth (entire run)}} \n")
row <- str_c(row, "			& \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} \n")
row <- str_c(row, "			& \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} \n")
row <- str_c(row, "                        & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} \n")
row <- str_c(row, "			& \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} \n")
row <- str_c(row, "                        & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} \n")
row <- str_c(row, "			\\\\ \n")
row <- str_c(row, " \\multicolumn{1}{|c|}{}\n")
row <- str_c(row, "			& \\multicolumn{1}{|c|}{")
row <- str_c(row, getdat('mdep', 23,'1','n','n','n','n','n'))
row <- str_c(row, "} \n")
row <- str_c(row, "                        & \\multicolumn{1}{|c|}{")
row <- str_c(row, getdat('mdep', 23,'4','y','y','n','y','2'), " ", rwilcox('mdep', 23,'1','n','n','n','n','n', 23,'4','y','y','n','y','2'))
row <- str_c(row, "} \n")
row <- str_c(row, "			& \\multicolumn{1}{|c|}{")
row <- str_c(row, getdat('mdep', 23,'4','y','y','n','y','3'), " ", rwilcox('mdep', 23,'1','n','n','n','n','n', 23,'4','y','y','n','y','3'))
row <- str_c(row, "} \n")
row <- str_c(row, "			& \\multicolumn{1}{|c|}{")
row <- str_c(row, getdat('mdep', 15,'1','n','n','n','n','n'))
row <- str_c(row, "} \n")
row <- str_c(row, "			& \\multicolumn{1}{|c|}{")
row <- str_c(row, getdat('mdep', 15,'4','y','y','n','y','2'), " ", rwilcox('mdep', 15,'1','n','n','n','n','n', 15,'4','y','y','n','y','2'))
row <- str_c(row, "} \n")
row <- str_c(row, "			& \\multicolumn{1}{|c|}{")
row <- str_c(row, getdat('mdep', 15,'4','y','y','n','y','3'), " ", rwilcox('mdep', 15,'1','n','n','n','n','n', 15,'4','y','y','n','y','3'))
row <- str_c(row, "} \n")
row <- str_c(row, "                        & \\multicolumn{1}{|c|}{")
row <- str_c(row, getdat('mdep', 36,'1','n','n','n','n','n'))
row <- str_c(row, "} \n")
row <- str_c(row, "			& \\multicolumn{1}{|c|}{")
row <- str_c(row, getdat('mdep', 36,'4','y','y','n','n','2'), " ", rwilcox('mdep', 36,'1','n','n','n','n','n', 36,'4','y','y','n','n','2'))
row <- str_c(row, "} \n")
row <- str_c(row, "			& \\multicolumn{1}{|c|}{")
row <- str_c(row, getdat('mdep', 36,'4','y','y','n','n','3'), " ", rwilcox('mdep', 36,'1','n','n','n','n','n', 36,'4','y','y','n','n','3'))
row <- str_c(row, "} \n")
row <- str_c(row, "			& \\multicolumn{1}{|c|}{")
row <- str_c(row, getdat('mdep', 86,'1','n','n','n','n','n'))
row <- str_c(row, "} \n")
row <- str_c(row, "			& \\multicolumn{1}{|c|}{")
row <- str_c(row, getdat('mdep', 86,'4','y','y','n','n','2'), " ", rwilcox('mdep', 86,'1','n','n','n','n','n', 86,'4','y','y','n','n','2'))
row <- str_c(row, "} \n")
row <- str_c(row, "			& \\multicolumn{1}{|c|}{")
row <- str_c(row, getdat('mdep', 86,'4','y','y','n','n','3'), " ", rwilcox('mdep', 86,'1','n','n','n','n','n', 86,'4','y','y','n','n','3'))
row <- str_c(row, "} \n")
row <- str_c(row, "                        & \\multicolumn{1}{|c|}{")
row <- str_c(row, getdat('mdep',103,'1','n','n','y','y','n'))
row <- str_c(row, "} \n")
row <- str_c(row, "			& \\multicolumn{1}{|c|}{")
row <- str_c(row, getdat('mdep',103,'4','y','y','y','y','2'), " ", rwilcox('mdep',103,'1','n','n','y','y','n',103,'4','y','y','y','y','2'))
row <- str_c(row, "} \n")
row <- str_c(row, "			& \\multicolumn{1}{|c|}{")
row <- str_c(row, getdat('mdep',103,'4','y','y','y','y','3'), " ", rwilcox('mdep',103,'1','n','n','y','y','n',103,'4','y','y','y','y','3'))
row <- str_c(row, "} \n")
row <- str_c(row, "			\\\\ \n")
row <- str_c(row, " \\multicolumn{1}{|c|}{}\n")
row <- str_c(row, "			& \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} \n")
row <- str_c(row, "			& \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} \n")
row <- str_c(row, "                        & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} \n")
row <- str_c(row, "			& \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} \n")
row <- str_c(row, "                        & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} \n")
row <- str_c(row, "			\\\\ \n")
row <- str_c(row, " \\hline\n")
row <- str_c(row, " \\multicolumn{1}{|c|}{\\multirow{3}{0.75in}{Total Execution Time (all runs)}} \n")
row <- str_c(row, "			& \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} \n")
row <- str_c(row, "			& \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} \n")
row <- str_c(row, "                        & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} \n")
row <- str_c(row, "			& \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} \n")
row <- str_c(row, "                        & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} \n")
row <- str_c(row, "			\\\\ \n")
row <- str_c(row, " \\multicolumn{1}{|c|}{}\n")
row <- str_c(row, "			& \\multicolumn{1}{|c|}{")
row <- str_c(row, getet( 23,'1','n','n','n','n','n'))
row <- str_c(row, "} \n")
row <- str_c(row, "                        & \\multicolumn{1}{|c|}{")
row <- str_c(row, getet( 23,'4','y','y','n','y','2'))
row <- str_c(row, "} \n")
row <- str_c(row, "			& \\multicolumn{1}{|c|}{")
row <- str_c(row, getet( 23,'4','y','y','n','y','3'))
row <- str_c(row, "} \n")
row <- str_c(row, "			& \\multicolumn{1}{|c|}{")
row <- str_c(row, getet( 15,'1','n','n','n','n','n'))
row <- str_c(row, "} \n")
row <- str_c(row, "			& \\multicolumn{1}{|c|}{")
row <- str_c(row, getet( 15,'4','y','y','n','y','2'))
row <- str_c(row, "} \n")
row <- str_c(row, "			& \\multicolumn{1}{|c|}{")
row <- str_c(row, getet( 15,'4','y','y','n','y','3'))
row <- str_c(row, "} \n")
row <- str_c(row, "                        & \\multicolumn{1}{|c|}{")
row <- str_c(row, getet( 36,'1','n','n','n','n','n'))
row <- str_c(row, "} \n")
row <- str_c(row, "			& \\multicolumn{1}{|c|}{")
row <- str_c(row, getet( 36,'4','y','y','n','n','2'))
row <- str_c(row, "} \n")
row <- str_c(row, "			& \\multicolumn{1}{|c|}{")
row <- str_c(row, getet( 36,'4','y','y','n','n','3'))
row <- str_c(row, "} \n")
row <- str_c(row, "			& \\multicolumn{1}{|c|}{")
row <- str_c(row, getet( 86,'1','n','n','n','n','n'))
row <- str_c(row, "} \n")
row <- str_c(row, "			& \\multicolumn{1}{|c|}{")
row <- str_c(row, getet( 86,'4','y','y','n','n','2'))
row <- str_c(row, "} \n")
row <- str_c(row, "			& \\multicolumn{1}{|c|}{")
row <- str_c(row, getet( 86,'4','y','y','n','n','3'))
row <- str_c(row, "} \n")
row <- str_c(row, "                        & \\multicolumn{1}{|c|}{")
row <- str_c(row, getet(103,'1','n','n','y','y','n'))
row <- str_c(row, "} \n")
row <- str_c(row, "			& \\multicolumn{1}{|c|}{")
row <- str_c(row, getet(103,'4','y','y','y','y','2'))
row <- str_c(row, "} \n")
row <- str_c(row, "			& \\multicolumn{1}{|c|}{")
row <- str_c(row, getet(103,'4','y','y','y','y','3'))
row <- str_c(row, "} \n")
row <- str_c(row, "			\\\\ \n")
row <- str_c(row, " \\multicolumn{1}{|c|}{}\n")
row <- str_c(row, "			& \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} \n")
row <- str_c(row, "			& \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} \n")
row <- str_c(row, "                        & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} \n")
row <- str_c(row, "			& \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} \n")
row <- str_c(row, "                        & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} \n")
row <- str_c(row, "			\\\\ \n")
row <- str_c(row, " \\multicolumn{1}{|c|}{}\n")
row <- str_c(row, "			& \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} \n")
row <- str_c(row, "			& \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} \n")
row <- str_c(row, "                        & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} \n")
row <- str_c(row, "			& \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} \n")
row <- str_c(row, "                        & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} \n")
row <- str_c(row, "			\\\\ \n")
row <- str_c(row, " \\hline\n")
row <- str_c(row, "\\end{tabular}\n")
row <- str_c(row, "} \n")
row <- str_c(row, "\\\\\\texttt{$* p < 0.05$, $** p < 0.01$, $*** p < 0.001$}\n")
row <- str_c(row, "\\label{tab:ch5:hyp3}\n")
row <- str_c(row, "%\\end{table}\n")
row <- str_c(row, "\\end{sidewaystable}\n")

write.table(row, file=fl3, append=FALSE, quote = FALSE, row.names = FALSE, col.names = FALSE) 

#hyp4a
row <- str_c("\\begin{sidewaystable}\n")
row <- str_c(row, "\\centering\n")
row <- str_c(row, "\\caption{Hypothesis 4: Part A: Compared to ACGP (with Constraints, with no ADFs), ACGPF Shows Improved Performance}\n")
row <- str_c(row, "\\scalebox{0.60} % Change this value to rescale the drawing.\n")
row <- str_c(row, "{\n")
row <- str_c(row, "\\begin{tabular}{|c|c|c|c|c|c|c|c|c|c|c|c|c|c|c|c|c|}\n")
row <- str_c(row, " \\hline\n")
row <- str_c(row, " % \\rowcolor{ltgray}\n")
row <- str_c(row, " \\multicolumn{1}{|c|}{\\multirow{4}{0.75in}{Outcome Variable}} & \\multicolumn{8}{|c|}{Lawn Mower Problem}\n")
row <- str_c(row, "                                                                & \\multicolumn{8}{|c|}{Bumble Bee Problem}\n")
row <- str_c(row, "                                                                \\\\\n")
row <- str_c(row, " \\cline{2-17}\n")
row <- str_c(row, " % \\rowcolor{ltgray}\n")
row <- str_c(row, " \\multicolumn{1}{|c|}{} & \\multicolumn{4}{|c|}{25x25} & \\multicolumn{4}{|c|}{50x50} \n")
row <- str_c(row, "                         & \\multicolumn{4}{|c|}{2D}    & \\multicolumn{4}{|c|}{3D}\n")
row <- str_c(row, "                         \\\\ \n")
row <- str_c(row, " \\cline{2-17}\n")
row <- str_c(row, " \\multicolumn{1}{|c|}{} & \\multicolumn{2}{|c|}{what=2} & \\multicolumn{2}{|c|}{what=3}\n")
row <- str_c(row, "                         & \\multicolumn{2}{|c|}{what=2} & \\multicolumn{2}{|c|}{what=3}\n")
row <- str_c(row, "                         & \\multicolumn{2}{|c|}{what=2} & \\multicolumn{2}{|c|}{what=3}\n")
row <- str_c(row, "                         & \\multicolumn{2}{|c|}{what=2} & \\multicolumn{2}{|c|}{what=3}\n")
row <- str_c(row, "                         \\\\ \n")
row <- str_c(row, " \\cline{2-17}\n")
row <- str_c(row, " % \\rowcolor{ltgray}\n")
row <- str_c(row, " \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{ACGP} & \\multicolumn{1}{|c|}{ACGPF} \n")
row <- str_c(row, "                         & \\multicolumn{1}{|c|}{ACGP} & \\multicolumn{1}{|c|}{ACGPF} \n")
row <- str_c(row, "                         & \\multicolumn{1}{|c|}{ACGP} & \\multicolumn{1}{|c|}{ACGPF} \n")
row <- str_c(row, "                         & \\multicolumn{1}{|c|}{ACGP} & \\multicolumn{1}{|c|}{ACGPF} \n")
row <- str_c(row, "                         & \\multicolumn{1}{|c|}{ACGP} & \\multicolumn{1}{|c|}{ACGPF} \n")
row <- str_c(row, "                         & \\multicolumn{1}{|c|}{ACGP} & \\multicolumn{1}{|c|}{ACGPF} \n")
row <- str_c(row, "                         & \\multicolumn{1}{|c|}{ACGP} & \\multicolumn{1}{|c|}{ACGPF} \n")
row <- str_c(row, "                         & \\multicolumn{1}{|c|}{ACGP} & \\multicolumn{1}{|c|}{ACGPF} \n")
row <- str_c(row, "                         \\\\ \n")
row <- str_c(row, " \\hline\n")
row <- str_c(row, " \\multicolumn{1}{|c|}{\\multirow{1}{0.75in}{Mean $\\#$ Hits}} \n")
row <- str_c(row, "                         & \\multicolumn{1}{|c|}{")
row <- str_c(row, getdat('mhit', 23,'3','n','n','n','y','2'))
row <- str_c(row, "}\n")
row <- str_c(row, "                         & \\multicolumn{1}{|c|}{")
row <- str_c(row, getdat('mhit', 23,'4','y','y','n','y','2'), " ", rwilcox('mhit', 23,'3','n','n','n','y','2', 23,'4','y','y','n','y','2'))
row <- str_c(row, "}\n")
row <- str_c(row, "                         & \\multicolumn{1}{|c|}{")
row <- str_c(row, getdat('mhit', 23,'3','n','n','n','y','3'))
row <- str_c(row, "}\n")
row <- str_c(row, "                         & \\multicolumn{1}{|c|}{")
row <- str_c(row, getdat('mhit', 23,'4','y','y','n','y','3'), " ", rwilcox('mhit', 23,'3','n','n','n','y','3', 23,'4','y','y','n','y','3'))
row <- str_c(row, "}\n")
row <- str_c(row, "                         & \\multicolumn{1}{|c|}{")
row <- str_c(row, getdat('mhit', 15,'3','n','n','n','y','2'))
row <- str_c(row, "}\n")
row <- str_c(row, "                         & \\multicolumn{1}{|c|}{")
row <- str_c(row, getdat('mhit', 15,'4','y','y','n','y','2'), " ", rwilcox('mhit', 15,'3','n','n','n','y','2', 15,'4','y','y','n','y','2'))
row <- str_c(row, "}\n")
row <- str_c(row, "                         & \\multicolumn{1}{|c|}{")
row <- str_c(row, getdat('mhit', 15,'3','n','n','n','y','3'))
row <- str_c(row, "}\n")
row <- str_c(row, "                         & \\multicolumn{1}{|c|}{")
row <- str_c(row, getdat('mhit', 15,'4','y','y','n','y','3'), " ", rwilcox('mhit', 15,'3','n','n','n','y','3', 15,'4','y','y','n','y','3'))
row <- str_c(row, "}\n")
row <- str_c(row, "                         & \\multicolumn{1}{|c|}{")
row <- str_c(row, getdat('mhit', 36,'3','n','n','n','n','2'))
row <- str_c(row, "}\n")
row <- str_c(row, "                         & \\multicolumn{1}{|c|}{")
row <- str_c(row, getdat('mhit', 36,'4','y','y','n','n','2'), " ", rwilcox('mhit', 36,'3','n','n','n','n','2', 36,'4','y','y','n','n','2'))
row <- str_c(row, "}\n")
row <- str_c(row, "                         & \\multicolumn{1}{|c|}{")
row <- str_c(row, getdat('mhit', 36,'3','n','n','n','n','3'))
row <- str_c(row, "}\n")
row <- str_c(row, "                         & \\multicolumn{1}{|c|}{")
row <- str_c(row, getdat('mhit', 36,'4','y','y','n','n','3'), " ", rwilcox('mhit', 36,'3','n','n','n','n','3', 36,'4','y','y','n','n','3'))
row <- str_c(row, "}\n")
row <- str_c(row, "                         & \\multicolumn{1}{|c|}{")
row <- str_c(row, getdat('mhit', 86,'3','n','n','n','n','2'))
row <- str_c(row, "}\n")
row <- str_c(row, "                         & \\multicolumn{1}{|c|}{")
row <- str_c(row, getdat('mhit', 86,'4','y','y','n','n','2'), " ", rwilcox('mhit', 86,'3','n','n','n','n','2', 86,'4','y','y','n','n','2'))
row <- str_c(row, "}\n")
row <- str_c(row, "                         & \\multicolumn{1}{|c|}{")
row <- str_c(row, getdat('mhit', 86,'3','n','n','n','n','3'))
row <- str_c(row, "}\n")
row <- str_c(row, "                         & \\multicolumn{1}{|c|}{")
row <- str_c(row, getdat('mhit', 86,'4','y','y','n','n','3'), " ", rwilcox('mhit', 86,'3','n','n','n','n','3', 86,'4','y','y','n','n','3'))
row <- str_c(row, "}\n")
row <- str_c(row, "                         \\\\\n")
row <- str_c(row, " \\hline\n")
row <- str_c(row, " \\multicolumn{1}{|c|}{\\multirow{5}{0.75in}{Mean Generation Where Best Individual Appeared}} \n")
row <- str_c(row, "                        & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} \n")
row <- str_c(row, "                        & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} \n")
row <- str_c(row, "                        & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} \n")
row <- str_c(row, "                        & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} \n")
row <- str_c(row, "                        & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} \n")
row <- str_c(row, "                        & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} \n")
row <- str_c(row, "                        & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} \n")
row <- str_c(row, "                        & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} \n")
row <- str_c(row, "                        \\\\ \n")
row <- str_c(row, " \\multicolumn{1}{|c|}{}\n")
row <- str_c(row, "                        & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} \n")
row <- str_c(row, "                        & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} \n")
row <- str_c(row, "                        & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} \n")
row <- str_c(row, "                        & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} \n")
row <- str_c(row, "                        & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} \n")
row <- str_c(row, "                        & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} \n")
row <- str_c(row, "                        & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} \n")
row <- str_c(row, "                        & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} \n")
row <- str_c(row, "                        \\\\ \n")
row <- str_c(row, " \\multicolumn{1}{|c|}{} \n")
row <- str_c(row, "                        & \\multicolumn{1}{|c|}{")
row <- str_c(row, getdat('mgen', 23,'3','n','n','n','y','2'))
row <- str_c(row, "}\n")
row <- str_c(row, "                        & \\multicolumn{1}{|c|}{")
row <- str_c(row, getdat('mgen', 23,'4','y','y','n','y','2'), " ", rwilcox('mgen', 23,'3','n','n','n','y','2', 23,'4','y','y','n','y','2'))
row <- str_c(row, "}\n")
row <- str_c(row, "                        & \\multicolumn{1}{|c|}{")
row <- str_c(row, getdat('mgen', 23,'3','n','n','n','y','3'))
row <- str_c(row, "}\n")
row <- str_c(row, "                        & \\multicolumn{1}{|c|}{")
row <- str_c(row, getdat('mgen', 23,'4','y','y','n','y','3'), " ", rwilcox('mgen', 23,'3','n','n','n','y','3', 23,'4','y','y','n','y','3'))
row <- str_c(row, "}\n")
row <- str_c(row, "                        & \\multicolumn{1}{|c|}{")
row <- str_c(row, getdat('mgen', 15,'3','n','n','n','y','2'))
row <- str_c(row, "}\n")
row <- str_c(row, "                        & \\multicolumn{1}{|c|}{")
row <- str_c(row, getdat('mgen', 15,'4','y','y','n','y','2'), " ", rwilcox('mgen', 15,'3','n','n','n','y','2', 15,'4','y','y','n','y','2'))
row <- str_c(row, "}\n")
row <- str_c(row, "                        & \\multicolumn{1}{|c|}{")
row <- str_c(row, getdat('mgen', 15,'3','n','n','n','y','3'))
row <- str_c(row, "}\n")
row <- str_c(row, "                        & \\multicolumn{1}{|c|}{")
row <- str_c(row, getdat('mgen', 15,'4','y','y','n','y','3'), " ", rwilcox('mgen', 15,'3','n','n','n','y','3', 15,'4','y','y','n','y','3'))
row <- str_c(row, "}\n")
row <- str_c(row, "                        & \\multicolumn{1}{|c|}{")
row <- str_c(row, getdat('mgen', 36,'3','n','n','n','n','2'))
row <- str_c(row, "}\n")
row <- str_c(row, "                        & \\multicolumn{1}{|c|}{")
row <- str_c(row, getdat('mgen', 36,'4','y','y','n','n','2'), " ", rwilcox('mgen', 36,'3','n','n','n','n','2', 36,'4','y','y','n','n','2'))
row <- str_c(row, "}\n")
row <- str_c(row, "                        & \\multicolumn{1}{|c|}{")
row <- str_c(row, getdat('mgen', 36,'3','n','n','n','n','3'))
row <- str_c(row, "}\n")
row <- str_c(row, "                        & \\multicolumn{1}{|c|}{")
row <- str_c(row, getdat('mgen', 36,'4','y','y','n','n','3'), " ", rwilcox('mgen', 36,'3','n','n','n','n','3', 36,'4','y','y','n','n','3'))
row <- str_c(row, "}\n")
row <- str_c(row, "                        & \\multicolumn{1}{|c|}{")
row <- str_c(row, getdat('mgen', 86,'3','n','n','n','n','2'))
row <- str_c(row, "}\n")
row <- str_c(row, "                        & \\multicolumn{1}{|c|}{")
row <- str_c(row, getdat('mgen', 86,'4','y','y','n','n','2'), " ", rwilcox('mgen', 86,'3','n','n','n','n','2', 86,'4','y','y','n','n','2'))
row <- str_c(row, "}\n")
row <- str_c(row, "                        & \\multicolumn{1}{|c|}{")
row <- str_c(row, getdat('mgen', 86,'3','n','n','n','n','3'))
row <- str_c(row, "}\n")
row <- str_c(row, "                        & \\multicolumn{1}{|c|}{")
row <- str_c(row, getdat('mgen', 86,'4','y','y','n','n','3'), " ", rwilcox('mgen', 86,'3','n','n','n','n','3', 86,'4','y','y','n','n','3'))
row <- str_c(row, "}\n")
row <- str_c(row, "                        \\\\ \n")
row <- str_c(row, " \\multicolumn{1}{|c|}{} \n")
row <- str_c(row, "                        & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} \n")
row <- str_c(row, "                        & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} \n")
row <- str_c(row, "                        & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} \n")
row <- str_c(row, "                        & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} \n")
row <- str_c(row, "                        & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} \n")
row <- str_c(row, "                        & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} \n")
row <- str_c(row, "                        & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} \n")
row <- str_c(row, "                        & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} \n")
row <- str_c(row, "                        \\\\ \n")
row <- str_c(row, " \\multicolumn{1}{|c|}{}\n")
row <- str_c(row, "                        & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} \n")
row <- str_c(row, "                        & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} \n")
row <- str_c(row, "                        & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} \n")
row <- str_c(row, "                        & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} \n")
row <- str_c(row, "                        & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} \n")
row <- str_c(row, "                        & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} \n")
row <- str_c(row, "                        & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} \n")
row <- str_c(row, "                        & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} \n")
row <- str_c(row, "                        \\\\ \n")
row <- str_c(row, " \\hline\n")
row <- str_c(row, " \\multicolumn{1}{|c|}{\\multirow{2}{0.75in}{Mean $\\#$ Nodes}} \n")
row <- str_c(row, "                        & \\multicolumn{1}{|c|}{")
row <- str_c(row, getdat('mnod', 23,'3','n','n','n','y','2'))
row <- str_c(row, "}\n")
row <- str_c(row, "                        & \\multicolumn{1}{|c|}{")
row <- str_c(row, getdat('mnod', 23,'4','y','y','n','y','2'), " ", rwilcox('mnod', 23,'3','n','n','n','y','2', 23,'4','y','y','n','y','2'))
row <- str_c(row, "}\n")
row <- str_c(row, "                        & \\multicolumn{1}{|c|}{")
row <- str_c(row, getdat('mnod', 23,'3','n','n','n','y','3'))
row <- str_c(row, "}\n")
row <- str_c(row, "                        & \\multicolumn{1}{|c|}{")
row <- str_c(row, getdat('mnod', 23,'4','y','y','n','y','3'), " ", rwilcox('mnod', 23,'3','n','n','n','y','3', 23,'4','y','y','n','y','3'))
row <- str_c(row, "}\n")
row <- str_c(row, "                        & \\multicolumn{1}{|c|}{")
row <- str_c(row, getdat('mnod', 15,'3','n','n','n','y','2'))
row <- str_c(row, "}\n")
row <- str_c(row, "                        & \\multicolumn{1}{|c|}{")
row <- str_c(row, getdat('mnod', 15,'4','y','y','n','y','2'), " ", rwilcox('mnod', 15,'3','n','n','n','y','2', 15,'4','y','y','n','y','2'))
row <- str_c(row, "}\n")
row <- str_c(row, "                        & \\multicolumn{1}{|c|}{")
row <- str_c(row, getdat('mnod', 15,'3','n','n','n','y','3'))
row <- str_c(row, "}\n")
row <- str_c(row, "                        & \\multicolumn{1}{|c|}{")
row <- str_c(row, getdat('mnod', 15,'4','y','y','n','y','3'), " ", rwilcox('mnod', 15,'3','n','n','n','y','3', 15,'4','y','y','n','y','3'))
row <- str_c(row, "}\n")
row <- str_c(row, "                        & \\multicolumn{1}{|c|}{")
row <- str_c(row, getdat('mnod', 36,'3','n','n','n','n','2'))
row <- str_c(row, "}\n")
row <- str_c(row, "                        & \\multicolumn{1}{|c|}{")
row <- str_c(row, getdat('mnod', 36,'4','y','y','n','n','2'), " ", rwilcox('mnod', 36,'3','n','n','n','n','2', 36,'4','y','y','n','n','2'))
row <- str_c(row, "}\n")
row <- str_c(row, "                        & \\multicolumn{1}{|c|}{")
row <- str_c(row, getdat('mnod', 36,'3','n','n','n','n','3'))
row <- str_c(row, "}\n")
row <- str_c(row, "                        & \\multicolumn{1}{|c|}{")
row <- str_c(row, getdat('mnod', 36,'4','y','y','n','n','3'), " ", rwilcox('mnod', 36,'3','n','n','n','n','3', 36,'4','y','y','n','n','3'))
row <- str_c(row, "}\n")
row <- str_c(row, "                        & \\multicolumn{1}{|c|}{")
row <- str_c(row, getdat('mnod', 86,'3','n','n','n','n','2'))
row <- str_c(row, "}\n")
row <- str_c(row, "                        & \\multicolumn{1}{|c|}{")
row <- str_c(row, getdat('mnod', 86,'4','y','y','n','n','2'), " ", rwilcox('mnod', 86,'3','n','n','n','n','2', 86,'4','y','y','n','n','2'))
row <- str_c(row, "}\n")
row <- str_c(row, "                        & \\multicolumn{1}{|c|}{")
row <- str_c(row, getdat('mnod', 86,'3','n','n','n','n','3'))
row <- str_c(row, "}\n")
row <- str_c(row, "                        & \\multicolumn{1}{|c|}{")
row <- str_c(row, getdat('mnod', 86,'4','y','y','n','n','3'), " ", rwilcox('mnod', 86,'3','n','n','n','n','3', 86,'4','y','y','n','n','3'))
row <- str_c(row, "}\n")
row <- str_c(row, "                        \\\\ \n")
row <- str_c(row, " \\multicolumn{1}{|c|}{}\n")
row <- str_c(row, "                        & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} \n")
row <- str_c(row, "                        & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} \n")
row <- str_c(row, "                        & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} \n")
row <- str_c(row, "                        & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} \n")
row <- str_c(row, "                        & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} \n")
row <- str_c(row, "                        & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} \n")
row <- str_c(row, "                        & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} \n")
row <- str_c(row, "                        & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} \n")
row <- str_c(row, "                        \\\\ \n")
row <- str_c(row, " \\hline\n")
row <- str_c(row, " \\multicolumn{1}{|c|}{\\multirow{3}{0.75in}{Mean Tree Depth (entire run)}} \n")
row <- str_c(row, "                        & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} \n")
row <- str_c(row, "                        & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} \n")
row <- str_c(row, "                        & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} \n")
row <- str_c(row, "                        & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} \n")
row <- str_c(row, "                        & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} \n")
row <- str_c(row, "                        & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} \n")
row <- str_c(row, "                        & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} \n")
row <- str_c(row, "                        & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} \n")
row <- str_c(row, "                        \\\\ \n")
row <- str_c(row, " \\multicolumn{1}{|c|}{}\n")
row <- str_c(row, "                        & \\multicolumn{1}{|c|}{")
row <- str_c(row, getdat('mdep', 23,'3','n','n','n','y','2'))
row <- str_c(row, "}\n")
row <- str_c(row, "                        & \\multicolumn{1}{|c|}{")
row <- str_c(row, getdat('mdep', 23,'4','y','y','n','y','2'), " ", rwilcox('mdep', 23,'3','n','n','n','y','2', 23,'4','y','y','n','y','2'))
row <- str_c(row, "}\n")
row <- str_c(row, "                        & \\multicolumn{1}{|c|}{")
row <- str_c(row, getdat('mdep', 23,'3','n','n','n','y','3'))
row <- str_c(row, "}\n")
row <- str_c(row, "                        & \\multicolumn{1}{|c|}{")
row <- str_c(row, getdat('mdep', 23,'4','y','y','n','y','3'), " ", rwilcox('mdep', 23,'3','n','n','n','y','3', 23,'4','y','y','n','y','3'))
row <- str_c(row, "}\n")
row <- str_c(row, "                        & \\multicolumn{1}{|c|}{")
row <- str_c(row, getdat('mdep', 15,'3','n','n','n','y','2'))
row <- str_c(row, "}\n")
row <- str_c(row, "                        & \\multicolumn{1}{|c|}{")
row <- str_c(row, getdat('mdep', 15,'4','y','y','n','y','2'), " ", rwilcox('mdep', 15,'3','n','n','n','y','2', 15,'4','y','y','n','y','2'))
row <- str_c(row, "}\n")
row <- str_c(row, "                        & \\multicolumn{1}{|c|}{")
row <- str_c(row, getdat('mdep', 15,'3','n','n','n','y','3'))
row <- str_c(row, "}\n")
row <- str_c(row, "                        & \\multicolumn{1}{|c|}{")
row <- str_c(row, getdat('mdep', 15,'4','y','y','n','y','3'), " ", rwilcox('mdep', 15,'3','n','n','n','y','3', 15,'4','y','y','n','y','3'))
row <- str_c(row, "}\n")
row <- str_c(row, "                        & \\multicolumn{1}{|c|}{")
row <- str_c(row, getdat('mdep', 36,'3','n','n','n','n','2'))
row <- str_c(row, "}\n")
row <- str_c(row, "                        & \\multicolumn{1}{|c|}{")
row <- str_c(row, getdat('mdep', 36,'4','y','y','n','n','2'), " ", rwilcox('mdep', 36,'3','n','n','n','n','2', 36,'4','y','y','n','n','2'))
row <- str_c(row, "}\n")
row <- str_c(row, "                        & \\multicolumn{1}{|c|}{")
row <- str_c(row, getdat('mdep', 36,'3','n','n','n','n','3'))
row <- str_c(row, "}\n")
row <- str_c(row, "                        & \\multicolumn{1}{|c|}{")
row <- str_c(row, getdat('mdep', 36,'4','y','y','n','n','3'), " ", rwilcox('mdep', 36,'3','n','n','n','n','3', 36,'4','y','y','n','n','3'))
row <- str_c(row, "}\n")
row <- str_c(row, "                        & \\multicolumn{1}{|c|}{")
row <- str_c(row, getdat('mdep', 86,'3','n','n','n','n','2'))
row <- str_c(row, "}\n")
row <- str_c(row, "                        & \\multicolumn{1}{|c|}{")
row <- str_c(row, getdat('mdep', 86,'4','y','y','n','n','2'), " ", rwilcox('mdep', 86,'3','n','n','n','n','2', 86,'4','y','y','n','n','2'))
row <- str_c(row, "}\n")
row <- str_c(row, "                        & \\multicolumn{1}{|c|}{")
row <- str_c(row, getdat('mdep', 86,'3','n','n','n','n','3'))
row <- str_c(row, "}\n")
row <- str_c(row, "                        & \\multicolumn{1}{|c|}{")
row <- str_c(row, getdat('mdep', 86,'4','y','y','n','n','3'), " ", rwilcox('mdep', 86,'3','n','n','n','n','3', 86,'4','y','y','n','n','3'))
row <- str_c(row, "}\n")
row <- str_c(row, "                        \\\\ \n")
row <- str_c(row, " \\multicolumn{1}{|c|}{}\n")
row <- str_c(row, "                        & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} \n")
row <- str_c(row, "                        & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} \n")
row <- str_c(row, "                        & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} \n")
row <- str_c(row, "                        & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} \n")
row <- str_c(row, "                        & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} \n")
row <- str_c(row, "                        & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} \n")
row <- str_c(row, "                        & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} \n")
row <- str_c(row, "                        & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} \n")
row <- str_c(row, "                        \\\\ \n")
row <- str_c(row, " \\hline\n")
row <- str_c(row, " \\multicolumn{1}{|c|}{\\multirow{3}{0.75in}{Total Execution Time (all runs)}} \n")
row <- str_c(row, "                        & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} \n")
row <- str_c(row, "                        & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} \n")
row <- str_c(row, "                        & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} \n")
row <- str_c(row, "                        & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} \n")
row <- str_c(row, "                        & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} \n")
row <- str_c(row, "                        & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} \n")
row <- str_c(row, "                        & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} \n")
row <- str_c(row, "                        & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} \n")
row <- str_c(row, "                        \\\\ \n")
row <- str_c(row, " \\multicolumn{1}{|c|}{}\n")
row <- str_c(row, "                        & \\multicolumn{1}{|c|}{")
row <- str_c(row, getet( 23,'3','n','n','n','y','2'))
row <- str_c(row, "}\n")
row <- str_c(row, "                        & \\multicolumn{1}{|c|}{")
row <- str_c(row, getet( 23,'4','y','y','n','y','2'))
row <- str_c(row, "}\n")
row <- str_c(row, "                        & \\multicolumn{1}{|c|}{")
row <- str_c(row, getet( 23,'3','n','n','n','y','3'))
row <- str_c(row, "}\n")
row <- str_c(row, "                        & \\multicolumn{1}{|c|}{")
row <- str_c(row, getet( 23,'4','y','y','n','y','3'))
row <- str_c(row, "}\n")
row <- str_c(row, "                        & \\multicolumn{1}{|c|}{")
row <- str_c(row, getet( 15,'3','n','n','n','y','2'))
row <- str_c(row, "}\n")
row <- str_c(row, "                        & \\multicolumn{1}{|c|}{")
row <- str_c(row, getet( 15,'4','y','y','n','y','2'))
row <- str_c(row, "}\n")
row <- str_c(row, "                        & \\multicolumn{1}{|c|}{")
row <- str_c(row, getet( 15,'3','n','n','n','y','3'))
row <- str_c(row, "}\n")
row <- str_c(row, "                        & \\multicolumn{1}{|c|}{")
row <- str_c(row, getet( 15,'4','y','y','n','y','3'))
row <- str_c(row, "}\n")
row <- str_c(row, "                        & \\multicolumn{1}{|c|}{")
row <- str_c(row, getet( 36,'3','n','n','n','n','2'))
row <- str_c(row, "}\n")
row <- str_c(row, "                        & \\multicolumn{1}{|c|}{")
row <- str_c(row, getet( 36,'4','y','y','n','n','2'))
row <- str_c(row, "}\n")
row <- str_c(row, "                        & \\multicolumn{1}{|c|}{")
row <- str_c(row, getet( 36,'3','n','n','n','n','3'))
row <- str_c(row, "}\n")
row <- str_c(row, "                        & \\multicolumn{1}{|c|}{")
row <- str_c(row, getet( 36,'4','y','y','n','n','3'))
row <- str_c(row, "}\n")
row <- str_c(row, "                        & \\multicolumn{1}{|c|}{")
row <- str_c(row, getet( 86,'3','n','n','n','n','2'))
row <- str_c(row, "}\n")
row <- str_c(row, "                        & \\multicolumn{1}{|c|}{")
row <- str_c(row, getet( 86,'4','y','y','n','n','2'))
row <- str_c(row, "}\n")
row <- str_c(row, "                        & \\multicolumn{1}{|c|}{")
row <- str_c(row, getet( 86,'3','n','n','n','n','3'))
row <- str_c(row, "}\n")
row <- str_c(row, "                        & \\multicolumn{1}{|c|}{")
row <- str_c(row, getet( 86,'4','y','y','n','n','3'))
row <- str_c(row, "}\n")
row <- str_c(row, "			\\\\ \n")
row <- str_c(row, " \\multicolumn{1}{|c|}{}\n")
row <- str_c(row, "                        & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} \n")
row <- str_c(row, "                        & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} \n")
row <- str_c(row, "                        & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} \n")
row <- str_c(row, "                        & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} \n")
row <- str_c(row, "                        & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} \n")
row <- str_c(row, "                        & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} \n")
row <- str_c(row, "                        & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} \n")
row <- str_c(row, "                        & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} \n")
row <- str_c(row, "                        \\\\ \n")
row <- str_c(row, " \\multicolumn{1}{|c|}{}\n")
row <- str_c(row, "                        & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} \n")
row <- str_c(row, "                        & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} \n")
row <- str_c(row, "                        & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} \n")
row <- str_c(row, "                        & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} \n")
row <- str_c(row, "                        & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} \n")
row <- str_c(row, "                        & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} \n")
row <- str_c(row, "                        & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} \n")
row <- str_c(row, "                        & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} \n")
row <- str_c(row, "                        \\\\ \n")
row <- str_c(row, " \\hline\n")
row <- str_c(row, "\\end{tabular}\n")
row <- str_c(row, "} \n")
row <- str_c(row, "\\\\\\texttt{$* p < 0.05$, $** p < 0.01$, $*** p < 0.001$}\n")
row <- str_c(row, "\\label{tab:ch5:hyp4a}\n")
row <- str_c(row, "%\\end{table}\n")
row <- str_c(row, "\\end{sidewaystable}\n")

write.table(row, file=fl4a, append=FALSE, quote = FALSE, row.names = FALSE, col.names = FALSE) 

#hyp4b
row <- str_c("\\begin{sidewaystable}\n")
row <- str_c(row, "\\centering\n")
row <- str_c(row, "\\caption{Hypothesis 4: Part B: Compared to ACGP (with Constraints, with no ADFs), ACGPF Shows Improved Performance}\n")
row <- str_c(row, "\\scalebox{0.60} % Change this value to rescale the drawing.\n")
row <- str_c(row, "{\n")
#row <- str_c(row, "\\begin{tabular}{|c|c|c|c|c|c|c|c|c|c|c|c|c|c|c|c|c|c|c|c|c|}\n")
row <- str_c(row, "\\begin{tabular}{|c|c|c|c|c|}\n")
row <- str_c(row, " \\hline\n")
row <- str_c(row, " % \\rowcolor{ltgray}\n")
row <- str_c(row, " \\multicolumn{1}{|c|}{\\multirow{4}{0.75in}{Outcome Variable}} & \\multicolumn{4}{|c|}{Two Box Problem}\n")
row <- str_c(row, "                                                                \\\\\n")
row <- str_c(row, " \\cline{2-5}\n")
row <- str_c(row, " % \\rowcolor{ltgray}\n")
row <- str_c(row, " \\multicolumn{1}{|c|}{} & \\multicolumn{4}{|c|}{3D} \n")
row <- str_c(row, "                         \\\\ \n")
row <- str_c(row, " \\cline{2-5}\n")
row <- str_c(row, " \\multicolumn{1}{|c|}{} & \\multicolumn{2}{|c|}{what=2} & \\multicolumn{2}{|c|}{what=3}\n")
row <- str_c(row, "                         \\\\ \n")
row <- str_c(row, " \\cline{2-5}\n")
row <- str_c(row, " % \\rowcolor{ltgray}\n")
row <- str_c(row, " \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{ACGP} & \\multicolumn{1}{|c|}{ACGPF} \n")
row <- str_c(row, "                         & \\multicolumn{1}{|c|}{ACGP} & \\multicolumn{1}{|c|}{ACGPF} \n")
row <- str_c(row, "                         \\\\ \n")
row <- str_c(row, " \\hline\n")
row <- str_c(row, " \\multicolumn{1}{|c|}{\\multirow{1}{0.75in}{Mean $\\#$ Hits}} \n")
row <- str_c(row, "                         & \\multicolumn{1}{|c|}{")
row <- str_c(row, getdat('mhit',103,'3','n','n','n','y','2'))
row <- str_c(row, "}\n")
row <- str_c(row, "                         & \\multicolumn{1}{|c|}{")
row <- str_c(row, getdat('mhit',103,'4','y','y','y','y','2'), " ", rwilcox('mhit',103,'3','n','n','n','y','2',103,'4','y','y','y','y','2'))
row <- str_c(row, "}\n")
row <- str_c(row, "                         & \\multicolumn{1}{|c|}{")
row <- str_c(row, getdat('mhit',103,'3','n','n','n','y','3'))
row <- str_c(row, "}\n")
row <- str_c(row, "                         & \\multicolumn{1}{|c|}{")
row <- str_c(row, getdat('mhit',103,'4','y','y','y','y','3'), " ", rwilcox('mhit',103,'3','n','n','n','y','3',103,'4','y','y','y','y','3'))
row <- str_c(row, "}\n")
row <- str_c(row, "                         \\\\\n")
row <- str_c(row, " \\hline\n")
row <- str_c(row, " \\multicolumn{1}{|c|}{\\multirow{5}{0.75in}{Mean Generation Where Best Individual Appeared}} \n")
row <- str_c(row, "                        & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} \n")
row <- str_c(row, "                        & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} \n")
row <- str_c(row, "                        \\\\ \n")
row <- str_c(row, " \\multicolumn{1}{|c|}{}\n")
row <- str_c(row, "                        & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} \n")
row <- str_c(row, "                        & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} \n")
row <- str_c(row, "                        \\\\ \n")
row <- str_c(row, " \\multicolumn{1}{|c|}{} \n")
row <- str_c(row, "                        & \\multicolumn{1}{|c|}{")
row <- str_c(row, getdat('mgen',103,'3','n','n','n','y','2'))
row <- str_c(row, "}\n")
row <- str_c(row, "                        & \\multicolumn{1}{|c|}{")
row <- str_c(row, getdat('mgen',103,'4','y','y','y','y','2'), " ", rwilcox('mgen',103,'3','n','n','n','y','2',103,'4','y','y','y','y','2'))
row <- str_c(row, "}\n")
row <- str_c(row, "                        & \\multicolumn{1}{|c|}{")
row <- str_c(row, getdat('mgen',103,'3','n','n','n','y','3'))
row <- str_c(row, "}\n")
row <- str_c(row, "                        & \\multicolumn{1}{|c|}{")
row <- str_c(row, getdat('mgen',103,'4','y','y','y','y','3'), " ", rwilcox('mgen',103,'3','n','n','n','y','3',103,'4','y','y','y','y','3'))
row <- str_c(row, "}\n")
row <- str_c(row, "                        \\\\ \n")
row <- str_c(row, " \\multicolumn{1}{|c|}{} \n")
row <- str_c(row, "                        & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} \n")
row <- str_c(row, "                        & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} \n")
row <- str_c(row, "                        \\\\ \n")
row <- str_c(row, " \\multicolumn{1}{|c|}{}\n")
row <- str_c(row, "                        & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} \n")
row <- str_c(row, "                        & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} \n")
row <- str_c(row, "                        \\\\ \n")
row <- str_c(row, " \\hline\n")
row <- str_c(row, " \\multicolumn{1}{|c|}{\\multirow{2}{0.75in}{Mean $\\#$ Nodes}} \n")
row <- str_c(row, "                        & \\multicolumn{1}{|c|}{")
row <- str_c(row, getdat('mnod',103,'3','n','n','n','y','2'))
row <- str_c(row, "}\n")
row <- str_c(row, "                        & \\multicolumn{1}{|c|}{")
row <- str_c(row, getdat('mnod',103,'4','y','y','y','y','2'), " ", rwilcox('mnod',103,'3','n','n','n','y','2',103,'4','y','y','y','y','2'))
row <- str_c(row, "}\n")
row <- str_c(row, "                        & \\multicolumn{1}{|c|}{")
row <- str_c(row, getdat('mnod',103,'3','n','n','n','y','3'))
row <- str_c(row, "}\n")
row <- str_c(row, "                        & \\multicolumn{1}{|c|}{")
row <- str_c(row, getdat('mnod',103,'4','y','y','y','y','3'), " ", rwilcox('mnod',103,'3','n','n','n','y','3',103,'4','y','y','y','y','3'))
row <- str_c(row, "}\n")
row <- str_c(row, "                        \\\\ \n")
row <- str_c(row, " \\multicolumn{1}{|c|}{}\n")
row <- str_c(row, "                        & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} \n")
row <- str_c(row, "                        & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} \n")
row <- str_c(row, "                        \\\\ \n")
row <- str_c(row, " \\hline\n")
row <- str_c(row, " \\multicolumn{1}{|c|}{\\multirow{3}{0.75in}{Mean Tree Depth (entire run)}} \n")
row <- str_c(row, "                        & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} \n")
row <- str_c(row, "                        & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} \n")
row <- str_c(row, "                        \\\\ \n")
row <- str_c(row, " \\multicolumn{1}{|c|}{}\n")
row <- str_c(row, "                        & \\multicolumn{1}{|c|}{")
row <- str_c(row, getdat('mdep',103,'3','n','n','n','y','2'))
row <- str_c(row, "}\n")
row <- str_c(row, "                        & \\multicolumn{1}{|c|}{")
row <- str_c(row, getdat('mdep',103,'4','y','y','y','y','2'), " ", rwilcox('mdep',103,'3','n','n','n','y','2',103,'4','y','y','y','y','2'))
row <- str_c(row, "}\n")
row <- str_c(row, "                        & \\multicolumn{1}{|c|}{")
row <- str_c(row, getdat('mdep',103,'3','n','n','n','y','3'))
row <- str_c(row, "}\n")
row <- str_c(row, "                        & \\multicolumn{1}{|c|}{")
row <- str_c(row, getdat('mdep',103,'4','y','y','y','y','3'), " ", rwilcox('mdep',103,'3','n','n','n','y','3',103,'4','y','y','y','y','3'))
row <- str_c(row, "}\n")
row <- str_c(row, "                        \\\\ \n")
row <- str_c(row, " \\multicolumn{1}{|c|}{}\n")
row <- str_c(row, "                        & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} \n")
row <- str_c(row, "                        & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} \n")
row <- str_c(row, "                        \\\\ \n")
row <- str_c(row, " \\hline\n")
row <- str_c(row, " \\multicolumn{1}{|c|}{\\multirow{3}{0.75in}{Total Execution Time (all runs)}} \n")
row <- str_c(row, "                        & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} \n")
row <- str_c(row, "                        & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} \n")
row <- str_c(row, "                        \\\\ \n")
row <- str_c(row, " \\multicolumn{1}{|c|}{}\n")
row <- str_c(row, "                        & \\multicolumn{1}{|c|}{")
row <- str_c(row, getet(103,'3','n','n','n','y','2'))
row <- str_c(row, "}\n")
row <- str_c(row, "                        & \\multicolumn{1}{|c|}{")
row <- str_c(row, getet(103,'4','y','y','y','y','2'))
row <- str_c(row, "}\n")
row <- str_c(row, "                        & \\multicolumn{1}{|c|}{")
row <- str_c(row, getet(103,'3','n','n','n','y','3'))
row <- str_c(row, "}\n")
row <- str_c(row, "                        & \\multicolumn{1}{|c|}{")
row <- str_c(row, getet(103,'4','y','y','y','y','3'))
row <- str_c(row, "}\n")
row <- str_c(row, "			\\\\ \n")
row <- str_c(row, " \\multicolumn{1}{|c|}{}\n")
row <- str_c(row, "                        & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} \n")
row <- str_c(row, "                        & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} \n")
row <- str_c(row, "                        \\\\ \n")
row <- str_c(row, " \\hline\n")
row <- str_c(row, " \\multicolumn{1}{|c|}{}\n")
row <- str_c(row, "                        & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} \n")
row <- str_c(row, "                        & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} \n")
row <- str_c(row, "                        \\\\ \n")
row <- str_c(row, " \\hline\n")
row <- str_c(row, "\\end{tabular}\n")
row <- str_c(row, "} \\\n")
row <- str_c(row, "\\\\\\texttt{$* p < 0.05$, $** p < 0.01$, $*** p < 0.001$}\n")
row <- str_c(row, "\\label{tab:ch5:hyp4b}\n")
row <- str_c(row, "%\\end{table}\n")
row <- str_c(row, "\\end{sidewaystable}\n")


write.table(row, file=fl4b, append=FALSE, quote = FALSE, row.names = FALSE, col.names = FALSE) 

cmd <- str_c("lualatex mainhyp")
system(cmd)

cmd <- str_c("/bin/cp -v ./tables/bestrunhyp*.tex ../dissertation/tables/")
system(cmd)
quit()


#hyp4
\\begin{sidewaystable}[htb]
\\centering
\\caption{Hypothesis 4: Compared to ACGP (with Constraints, with no ADFs), ACGPF Shows Improved Performance}
\\scalebox{0.7} % Change this value to rescale the drawing.
{
\\begin{tabular}{|c|c|c|c|c|c|c|c|c|c|c|c|c|c|c|c|c|c|c|c|c|}
 \\hline
 % \\rowcolor{ltgray}
 \\multicolumn{1}{|c|}{\\multirow{4}{0.75in}{Outcome Variable}} & \\multicolumn{8}{|c|}{Lawn Mower Problem}
                                                                & \\multicolumn{8}{|c|}{Bumble Bee Problem}
                                                                & \\multicolumn{4}{|c|}{Two Box Problem}
                                                                \\\\
 \\cline{2-21}
 % \\rowcolor{ltgray}
 \\multicolumn{1}{|c|}{} & \\multicolumn{4}{|c|}{25x25} & \\multicolumn{4}{|c|}{50x50} 
                         & \\multicolumn{4}{|c|}{2D}    & \\multicolumn{4}{|c|}{3D}
                         & \\multicolumn{4}{|c|}{3D} 
                         \\\\ 
 \\cline{2-21}
 \\multicolumn{1}{|c|}{} & \\multicolumn{2}{|c|}{what=2} & \\multicolumn{2}{|c|}{what=3}
                         & \\multicolumn{2}{|c|}{what=2} & \\multicolumn{2}{|c|}{what=3}
                         & \\multicolumn{2}{|c|}{what=2} & \\multicolumn{2}{|c|}{what=3}
                         & \\multicolumn{2}{|c|}{what=2} & \\multicolumn{2}{|c|}{what=3}
                         & \\multicolumn{2}{|c|}{what=2} & \\multicolumn{2}{|c|}{what=3}
                         \\\\ 
 \\cline{2-21}
 % \\rowcolor{ltgray}
 \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{ACGP}  & \\multicolumn{1}{|c|}{ACGP} 
                         & \\multicolumn{1}{|c|}{ACGPF} & \\multicolumn{1}{|c|}{ACGPF} 
                         & \\multicolumn{1}{|c|}{ACGP}  & \\multicolumn{1}{|c|}{ACGP} 
                         & \\multicolumn{1}{|c|}{ACGPF} & \\multicolumn{1}{|c|}{ACGPF} 
                         & \\multicolumn{1}{|c|}{ACGP}  & \\multicolumn{1}{|c|}{ACGP} 
                         & \\multicolumn{1}{|c|}{ACGPF} & \\multicolumn{1}{|c|}{ACGPF} 
                         & \\multicolumn{1}{|c|}{ACGP}  & \\multicolumn{1}{|c|}{ACGP} 
                         & \\multicolumn{1}{|c|}{ACGPF} & \\multicolumn{1}{|c|}{ACGPF} 
                         & \\multicolumn{1}{|c|}{ACGP}  & \\multicolumn{1}{|c|}{ACGP} 
                         & \\multicolumn{1}{|c|}{ACGPF} & \\multicolumn{1}{|c|}{ACGPF} 
                         \\\\ 
 \\hline
 \\multicolumn{1}{|c|}{\\multirow{1}{0.75in}{Mean $\\#$ Hits}} 
                         & \\multicolumn{1}{|c|}{getdat('mhit', 23,'3','n','n','n','y','2')}
                         & \\multicolumn{1}{|c|}{getdat('mhit', 23,'4','y','y','n','y','2')}
                         & \\multicolumn{1}{|c|}{getdat('mhit', 23,'3','n','n','n','y','3')}
                         & \\multicolumn{1}{|c|}{getdat('mhit', 23,'4','y','y','n','y','3')}
                         & \\multicolumn{1}{|c|}{getdat('mhit', 15,'3','n','n','n','y','2')}
                         & \\multicolumn{1}{|c|}{getdat('mhit', 15,'4','y','y','n','y','2')}
                         & \\multicolumn{1}{|c|}{getdat('mhit', 15,'3','n','n','n','y','3')}
                         & \\multicolumn{1}{|c|}{getdat('mhit', 15,'4','y','y','n','y','3')}
                         & \\multicolumn{1}{|c|}{getdat('mhit', 36,'3','n','n','n','n','2')}
                         & \\multicolumn{1}{|c|}{getdat('mhit', 36,'4','y','y','n','n','2')}
                         & \\multicolumn{1}{|c|}{getdat('mhit', 36,'3','n','n','n','n','3')}
                         & \\multicolumn{1}{|c|}{getdat('mhit', 36,'4','y','y','n','n','3')}
                         & \\multicolumn{1}{|c|}{getdat('mhit', 86,'3','n','n','n','n','2')}
                         & \\multicolumn{1}{|c|}{getdat('mhit', 86,'4','y','y','n','n','2')}
                         & \\multicolumn{1}{|c|}{getdat('mhit', 86,'3','n','n','n','n','3')}
                         & \\multicolumn{1}{|c|}{getdat('mhit', 86,'4','y','y','n','n','3')}
                         & \\multicolumn{1}{|c|}{getdat('mhit',103,'3','n','n','y','y','2')}
                         & \\multicolumn{1}{|c|}{getdat('mhit',103,'4','y','y','y','y','2')}
                         & \\multicolumn{1}{|c|}{getdat('mhit',103,'3','n','n','y','y','3')}
                         & \\multicolumn{1}{|c|}{getdat('mhit',103,'4','y','y','y','y','3')}
                         \\\\
 \\hline
 \\multicolumn{1}{|c|}{\\multirow{5}{0.75in}{Mean Generation Where Best Individual Appeared}} 
                        & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} 
                        & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} 
                        & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} 
                        & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} 
                        & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} 
                        & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} 
                        & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} 
                        & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} 
                        & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} 
                        & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} 
                        \\\\ 
 \\multicolumn{1}{|c|}{}
                        & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} 
                        & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} 
                        & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} 
                        & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} 
                        & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} 
                        & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} 
                        & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} 
                        & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} 
                        & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} 
                        & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} 
                        \\\\ 
 \\multicolumn{1}{|c|}{} 
                        & \\multicolumn{1}{|c|}{getdat('mgen', 23,'3','n','n','n','y','2')}
                        & \\multicolumn{1}{|c|}{getdat('mgen', 23,'4','y','y','n','y','2')}
                        & \\multicolumn{1}{|c|}{getdat('mgen', 23,'3','n','n','n','y','3')}
                        & \\multicolumn{1}{|c|}{getdat('mgen', 23,'4','y','y','n','y','3')}
                        & \\multicolumn{1}{|c|}{getdat('mgen', 15,'3','n','n','n','y','2')}
                        & \\multicolumn{1}{|c|}{getdat('mgen', 15,'4','y','y','n','y','2')}
                        & \\multicolumn{1}{|c|}{getdat('mgen', 15,'3','n','n','n','y','3')}
                        & \\multicolumn{1}{|c|}{getdat('mgen', 15,'4','y','y','n','y','3')}
                        & \\multicolumn{1}{|c|}{getdat('mgen', 36,'3','n','n','n','n','2')}
                        & \\multicolumn{1}{|c|}{getdat('mgen', 36,'4','y','y','n','n','2')}
                        & \\multicolumn{1}{|c|}{getdat('mgen', 36,'3','n','n','n','n','3')}
                        & \\multicolumn{1}{|c|}{getdat('mgen', 36,'4','y','y','n','n','3')}
                        & \\multicolumn{1}{|c|}{getdat('mgen', 86,'3','n','n','n','n','2')}
                        & \\multicolumn{1}{|c|}{getdat('mgen', 86,'4','y','y','n','n','2')}
                        & \\multicolumn{1}{|c|}{getdat('mgen', 86,'3','n','n','n','n','3')}
                        & \\multicolumn{1}{|c|}{getdat('mgen', 86,'4','y','y','n','n','3')}
                        & \\multicolumn{1}{|c|}{getdat('mgen',103,'3','n','n','y','y','2')}
                        & \\multicolumn{1}{|c|}{getdat('mgen',103,'4','y','y','y','y','2')}
                        & \\multicolumn{1}{|c|}{getdat('mgen',103,'3','n','n','y','y','3')}
                        & \\multicolumn{1}{|c|}{getdat('mgen',103,'4','y','y','y','y','3')}
                        \\\\ 
 \\multicolumn{1}{|c|}{} 
                        & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} 
                        & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} 
                        & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} 
                        & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} 
                        & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} 
                        & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} 
                        & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} 
                        & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} 
                        & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} 
                        & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} 
                        \\\\ 
 \\multicolumn{1}{|c|}{}
                        & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} 
                        & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} 
                        & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} 
                        & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} 
                        & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} 
                        & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} 
                        & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} 
                        & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} 
                        & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} 
                        & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} 
                        \\\\ 
 \\hline
 \\multicolumn{1}{|c|}{\\multirow{2}{0.75in}{Mean $\\#$ Nodes}} 
                        & \\multicolumn{1}{|c|}{getdat('mnod', 23,'3','n','n','n','y','2')}
                        & \\multicolumn{1}{|c|}{getdat('mnod', 23,'4','y','y','n','y','2')}
                        & \\multicolumn{1}{|c|}{getdat('mnod', 23,'3','n','n','n','y','3')}
                        & \\multicolumn{1}{|c|}{getdat('mnod', 23,'4','y','y','n','y','3')}
                        & \\multicolumn{1}{|c|}{getdat('mnod', 15,'3','n','n','n','y','2')}
                        & \\multicolumn{1}{|c|}{getdat('mnod', 15,'4','y','y','n','y','2')}
                        & \\multicolumn{1}{|c|}{getdat('mnod', 15,'3','n','n','n','y','3')}
                        & \\multicolumn{1}{|c|}{getdat('mnod', 15,'4','y','y','n','y','3')}
                        & \\multicolumn{1}{|c|}{getdat('mnod', 36,'3','n','n','n','n','2')}
                        & \\multicolumn{1}{|c|}{getdat('mnod', 36,'4','y','y','n','n','2')}
                        & \\multicolumn{1}{|c|}{getdat('mnod', 36,'3','n','n','n','n','3')}
                        & \\multicolumn{1}{|c|}{getdat('mnod', 36,'4','y','y','n','n','3')}
                        & \\multicolumn{1}{|c|}{getdat('mnod', 86,'3','n','n','n','n','2')}
                        & \\multicolumn{1}{|c|}{getdat('mnod', 86,'4','y','y','n','n','2')}
                        & \\multicolumn{1}{|c|}{getdat('mnod', 86,'3','n','n','n','n','3')}
                        & \\multicolumn{1}{|c|}{getdat('mnod', 86,'4','y','y','n','n','3')}
                        & \\multicolumn{1}{|c|}{getdat('mnod',103,'3','n','n','y','y','2')}
                        & \\multicolumn{1}{|c|}{getdat('mnod',103,'4','y','y','y','y','2')}
                        & \\multicolumn{1}{|c|}{getdat('mnod',103,'3','n','n','y','y','3')}
                        & \\multicolumn{1}{|c|}{getdat('mnod',103,'4','y','y','y','y','3')}
                        \\\\ 
 \\multicolumn{1}{|c|}{}
                        & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} 
                        & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} 
                        & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} 
                        & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} 
                        & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} 
                        & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} 
                        & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} 
                        & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} 
                        & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} 
                        & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} 
                        \\\\ 
 \\hline
 \\multicolumn{1}{|c|}{\\multirow{3}{0.75in}{Mean Tree Depth (entire run)}} 
                        & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} 
                        & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} 
                        & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} 
                        & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} 
                        & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} 
                        & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} 
                        & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} 
                        & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} 
                        & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} 
                        & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} 
                        \\\\ 
 \\multicolumn{1}{|c|}{}
                        & \\multicolumn{1}{|c|}{getdat('mdep', 23,'3','n','n','n','y','2')}
                        & \\multicolumn{1}{|c|}{getdat('mdep', 23,'4','y','y','n','y','2')}
                        & \\multicolumn{1}{|c|}{getdat('mdep', 23,'3','n','n','n','y','3')}
                        & \\multicolumn{1}{|c|}{getdat('mdep', 23,'4','y','y','n','y','3')}
                        & \\multicolumn{1}{|c|}{getdat('mdep', 15,'3','n','n','n','y','2')}
                        & \\multicolumn{1}{|c|}{getdat('mdep', 15,'4','y','y','n','y','2')}
                        & \\multicolumn{1}{|c|}{getdat('mdep', 15,'3','n','n','n','y','3')}
                        & \\multicolumn{1}{|c|}{getdat('mdep', 15,'4','y','y','n','y','3')}
                        & \\multicolumn{1}{|c|}{getdat('mdep', 36,'3','n','n','n','n','2')}
                        & \\multicolumn{1}{|c|}{getdat('mdep', 36,'4','y','y','n','n','2')}
                        & \\multicolumn{1}{|c|}{getdat('mdep', 36,'3','n','n','n','n','3')}
                        & \\multicolumn{1}{|c|}{getdat('mdep', 36,'4','y','y','n','n','3')}
                        & \\multicolumn{1}{|c|}{getdat('mdep', 86,'3','n','n','n','n','2')}
                        & \\multicolumn{1}{|c|}{getdat('mdep', 86,'4','y','y','n','n','2')}
                        & \\multicolumn{1}{|c|}{getdat('mdep', 86,'3','n','n','n','n','3')}
                        & \\multicolumn{1}{|c|}{getdat('mdep', 86,'4','y','y','n','n','3')}
                        & \\multicolumn{1}{|c|}{getdat('mdep',103,'3','n','n','y','y','2')}
                        & \\multicolumn{1}{|c|}{getdat('mdep',103,'4','y','y','y','y','2')}
                        & \\multicolumn{1}{|c|}{getdat('mdep',103,'3','n','n','y','y','3')}
                        & \\multicolumn{1}{|c|}{getdat('mdep',103,'4','y','y','y','y','3')}
                        \\\\ 
 \\multicolumn{1}{|c|}{}
                        & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} 
                        & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} 
                        & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} 
                        & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} 
                        & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} 
                        & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} 
                        & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} 
                        & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} 
                        & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} 
                        & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} 
                        \\\\ 
 \\hline
 \\multicolumn{1}{|c|}{\\multirow{3}{0.75in}{Total Execution Time (entire run)}} 
                        & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} 
                        & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} 
                        & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} 
                        & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} 
                        & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} 
                        & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} 
                        & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} 
                        & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} 
                        & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} 
                        & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} 
                        \\\\ 
 \\multicolumn{1}{|c|}{}
                        & \\multicolumn{1}{|c|}{getet( 23,'3','n','n','n','y','2')}
                        & \\multicolumn{1}{|c|}{getet( 23,'4','y','y','n','y','2')}
                        & \\multicolumn{1}{|c|}{getet( 23,'3','n','n','n','y','3')}
                        & \\multicolumn{1}{|c|}{getet( 23,'4','y','y','n','y','3')}
                        & \\multicolumn{1}{|c|}{getet( 15,'3','n','n','n','y','2')}
                        & \\multicolumn{1}{|c|}{getet( 15,'4','y','y','n','y','2')}
                        & \\multicolumn{1}{|c|}{getet( 15,'3','n','n','n','y','3')}
                        & \\multicolumn{1}{|c|}{getet( 15,'4','y','y','n','y','3')}
                        & \\multicolumn{1}{|c|}{getet( 36,'3','n','n','n','n','2')}
                        & \\multicolumn{1}{|c|}{getet( 36,'4','y','y','n','n','2')}
                        & \\multicolumn{1}{|c|}{getet( 36,'3','n','n','n','n','3')}
                        & \\multicolumn{1}{|c|}{getet( 36,'4','y','y','n','n','3')}
                        & \\multicolumn{1}{|c|}{getet( 86,'3','n','n','n','n','2')}
                        & \\multicolumn{1}{|c|}{getet( 86,'4','y','y','n','n','2')}
                        & \\multicolumn{1}{|c|}{getet( 86,'3','n','n','n','n','3')}
                        & \\multicolumn{1}{|c|}{getet( 86,'4','y','y','n','n','3')}
                        & \\multicolumn{1}{|c|}{getet(103,'3','n','n','y','y','2')}
                        & \\multicolumn{1}{|c|}{getet(103,'4','y','y','y','y','2')}
                        & \\multicolumn{1}{|c|}{getet(103,'3','n','n','y','y','3')}
                        & \\multicolumn{1}{|c|}{getet(103,'4','y','y','y','y','3')}
			\\\\ 
 \\multicolumn{1}{|c|}{}
                        & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} 
                        & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} 
                        & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} 
                        & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} 
                        & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} 
                        & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} 
                        & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} 
                        & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} 
                        & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} 
                        & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} 
                        \\\\ 
 \\hline
\\end{tabular}
} 
\\label{tab:ch5:hyp4}
%\\end{table}
\\end{sidewaystable}

% \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{(what=2)} & \\multicolumn{1}{|c|}{(what=3)} 
%                         & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{(what=2)} & \\multicolumn{1}{|c|}{(what=3)} 
%                         & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{(what=2)} & \\multicolumn{1}{|c|}{(what=3)} 
%                         & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{(what=2)} & \\multicolumn{1}{|c|}{(what=3)} 
%                         & \\multicolumn{1}{|c|}{} & \\multicolumn{1}{|c|}{(what=2)} & \\multicolumn{1}{|c|}{(what=3)} 
%                         \\\\ 
