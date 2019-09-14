#!/usr/bin/env Rscript

library(argparser, quietly=TRUE)
library(DBI)
library(RSQLite)
library(dplyr, quietly=TRUE, warn.conflicts = FALSE)
library(crayon)
library(stringr)

printf <- function(...) cat(sprintf(...))
prnf <- function(...) cat(sprintf("%f ", ...))
prnd <- function(...) cat(sprintf("%d ", ...))
prln <- function(...) cat(sprintf("\n"))

blue_printf   <- function(...) cat(blue(...))
white_printf <- function(...) cat(white(sprintf(...)))
silver_printf <- function(...) cat(silver(sprintf(...)))

#pblm <- c(15,16)
#pblm <- c(12,11,13,14,23,24,15,16,30,31,50,51,32,33,34,35,36,37,40,41,42,43,44,45,46,47,60,61,70,71,3,103,104,205,206,207,208,209,210)
#pblm <- c(12,11,13,14,23,24,15,16,30,31,50,51,32,33,34,35,36,37,40,41,42,43,44,45,46,47,60,61,70,71,103,104)
#pblm <- c(12,11,13,14,23,15,17,30,50,32,34,36,40,42,44,46,60,70,103,205,207,209)
#pblm <- c(12,11,13,14,23,15,30,50,32,34,36,40,42,44,46,60,70,103,205,207,209)
#pblm <- c(12,11,13,14,23,15,17,30,50,32,34,36,40,42,44,46,60,70)
pblm <- c(12,11,13,14,23,15,30,50,32,34,36,40,42,44,46,58,60,66,70,103,104,105,106)

probset1 <- c(12,11,13,14)
#probset2 <- c(23,15,17,30,50,32,34,36,40,42,44,46,60,70,80,82,84,86,90,92,94,96,103,205,207,209)
#probset2 <- c(23,15,17,30,50,32,34,36,40,42,44,46,60,70,80,82,84,86,90,92,94,96)
probset2 <- c(23,15,30,50,56,32,34,36,40,42,44,46,56,60,66,70,80,82,84,86,90,92,94,96,103,105)

#genrmp <- c(16,18,24,31,33,35,37,41,43,45,47,51,61,71,81,83,85,87,91,93,95,97,25,26,27,28,206,208,210)
#genrmp <- c(16,18,24,31,33,35,37,41,43,45,47,51,61,71,81,83,85,87,91,93,95,97,25,26,27,28)
genrmp <- c(16,24,31,33,35,37,41,43,45,47,51,57,59,61,67,71,81,83,85,87,91,93,95,97,25,26,27,28,104,106)


inlist <- function(val, lst){
  res <- "FALSE" 
  for(x in lst){
    if(val == x){
      res <- "TRUE" 
    } 
  }
  return(res);
}

problem_desc <- function(f1pnum) {
  desc <- ""

  if (as.numeric(f1pnum) > 10 && as.numeric(f1pnum) < 30) {
    desc <- str_c(desc, " Lawn Mower")
  } 

  if (as.numeric(f1pnum) > 29 && as.numeric(f1pnum) < 100) {
    desc <- str_c(desc, " Bumble Bee ")
  }     

  if (as.numeric(f1pnum) >= 103 && as.numeric(f1pnum) <= 106) {
    desc <- str_c(desc, " Two Box ")
  } 

  if (as.numeric(f1pnum) >= 205 && as.numeric(f1pnum) <= 206) {
    desc <- str_c(desc, " Koza1 ")
  }

  if (as.numeric(f1pnum) >= 207 && as.numeric(f1pnum) <= 208) {
    desc <- str_c(desc, " Koza2 ")
  }

  if (as.numeric(f1pnum) >= 209 && as.numeric(f1pnum) <= 210) {
    desc <- str_c(desc, " Koza3 ")
  }

  return(desc)
}

get_params_infodef <- function(pnum, getv) {
  #RSQLite::rsqliteVersion()
   
  drv <- dbDriver("SQLite")
  con <- dbConnect(drv, dbname = "/home/ggerules/lilgp1.03/app/reports/data.db")
  #dbListTables(con)
  
#runparams_infodef( RowNum,ProblemNum,MaxTreeDepth,SavePop,UseERCS,Pop,MaxGen,NumIndRuns,LawnWidth,LawnHeight,LawnDepth,FitCases);

  sel <- "select ProblemNum,MaxTreeDepth,SavePop,UseERCS,Pop,MaxGen,NumIndRuns,LawnWidth,LawnHeight,LawnDepth,NFlowers,FitCases from runparams_infodef where "
  pn <- "ProblemNum = "
 
  selstat1 <- str_c(sel,pn,pnum)
  #printf("%s\n", selstat1)

  rs <- dbSendQuery(con, selstat1)
  d1 <- fetch(rs)
  dbClearResult(rs)

  retv <- 0

  if ("MaxTreeDepth" ==  getv) {
    retv <- d1$MaxTreeDepth
  } else if ("SavePop" == getv) {
    retv <- d1$SavePop
  } else if ("UseERCS" == getv) {
    retv <- d1$UseERCS
  } else if ("Pop" == getv) {
    retv <- d1$Pop
  } else if ("MaxGen" == getv) {
    retv <- d1$MaxGen
  } else if ("NumIndRuns" == getv) {
    retv <- d1$NumIndRuns
  } else if ("LawnWidth" == getv) {
    retv <- d1$LawnWidth
  } else if ("LawnHeight" == getv) {
    retv <- d1$LawnHeight
  } else if ("LawnDepth" == getv) {
    retv <- d1$LawnDepth
  } else if ("NFlowers" == getv) {
    retv <- d1$NFlowers
  } else if ("FitCases " == getv) {
    retv <- d1$FitCases 
  } else {
    retv <- 0
  }

  # clean up
  dbDisconnect(con)

  return(retv) 
}

run_wilcox <- function(displine, dispdata, f1pnum, f1kerp1v, f1wadfv, f1adfv, f1typesv, f1consv, f1acgpwhatv,
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

  wc_hits  <-  wilcox.test(d1$Hits, d2$Hits, exact = FALSE, alternative = "less")
  wc_gen   <-  wilcox.test(d1$Gen, d2$Gen, exact = FALSE, alternative = "greater")
  wc_nodes <-  wilcox.test(d1$Nodes, d2$Nodes, exact = FALSE, alternative = "greater")
  wc_depth <-  wilcox.test(d1$Depth, d2$Depth, exact = FALSE, alternative = "greater")
  #wc_hits  <-  wilcox.test(d1$Hits, conf.int = TRUE, d2$Hits, exact = FALSE, alternative = "less")
  #wc_gen   <-  wilcox.test(d1$Gen, conf.int = TRUE, d2$Gen, exact = FALSE, alternative = "greater")
  #wc_nodes <-  wilcox.test(d1$Nodes, conf.int = TRUE, d2$Nodes, exact = FALSE, alternative = "greater")
  #wc_depth <-  wilcox.test(d1$Depth, conf.int = TRUE, d2$Depth, exact = FALSE, alternative = "greater")
  #print(wc_hits, wc_gen, wc_nodes, wc_depth)

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

  desc <- str_c(desc, " & ", wc_hitsv , " & ", wc_genv, " & ",  wc_nodesv, " & ", wc_depthv, "\\\\")


  printf("%s\n", desc)
  
  fl <- "./tables/p"
  fl <- str_c(fl, f1pnum)
  fl <- str_c(fl, "tablwilcox.tex")
  
  write.table(desc, file=fl, append=TRUE, quote = FALSE, row.names = FALSE, col.names = FALSE) 
  if(displine == 'y') {
    desc <- str_c("\\hline")
  }
  
  # clean up
  dbDisconnect(con)

}



## start of main program

fl0 <- "./tables/bestrunwilcoxtable.tex"
unlink(fl0)

for (x in pblm ) {

  fl1 <- "./tables/p"
  fl1 <- str_c(fl1, x)
  fl1 <- str_c(fl1, "tablwilcox.tex")
  unlink(fl1) 

  fl2 <- "./tables/p"
  fl2 <- str_c(fl2, x)
  fl2 <- str_c(fl2, "bestrunwilcoxtable.tex")
  unlink(fl2) 

  row <- str_c("\\input{")
  row <- str_c(row, fl2)
  row <- str_c(row, "}")
  write.table(row, file=fl0, append=TRUE, quote = FALSE, row.names = FALSE, col.names = FALSE) 

  row <- str_c("\\begin{sidewaystable}[ht]\n")
#  row <- str_c("\\begin{table}[H]\n")
  row <- str_c(row, "\\caption{Problem ")
  #row <- str_c(row, x)
  row <- str_c(row, problem_desc(x))
  if (x > 10 && x < 30 ) {
    row <- str_c(row," ",get_params_infodef(x,"LawnWidth"),"x",get_params_infodef(x,"LawnHeight"),"\\\\") 
  } else if (x > 79 && x < 90) {
    row <- str_c(row," ",get_params_infodef(x,"LawnWidth"),"x",get_params_infodef(x,"LawnHeight"),"x",get_params_infodef(x,"LawnDepth"),"\\\\") 
  } else if (x > 29 && x < 80) {
    row <- str_c(row," ","Number of Flowers ", get_params_infodef(x,"NFlowers"),"\\\\") 
  } else {}
  row <- str_c(row,"Best of Run Individuals " ,"\\\\")
  row <- str_c(row, " ", "Max Generations ",get_params_infodef(x, "MaxGen"),"\\\\")
  row <- str_c(row, "Wilcoxson Sign Rank Test","\\\\","Significant If PVal < 0.05") 
 
  row <- str_c(row, "}\n")
  row <- str_c(row, "\\begin{center}\n")
  row <- str_c(row,"\\scalebox{0.7} % Change this value to rescale the drawing.\n")
  row <- str_c(row,"{\n")
  #row <- str_c(row,"\\begin{tabular}{llllllllllll}\n")
  if((x < 11) || (x > 100)) {
    row <- str_c(row,"\\begin{tabular}{|llllll|llllll|rrrr|}\n")
  } else if((x > 10) && (x < 30)) {
    row <- str_c(row,"\\begin{tabular}{|lllll|lllll|rrrr|}\n")
  } else {
    row <- str_c(row,"\\begin{tabular}{|llll|llll|rrrr|}\n")
  }
  row <- str_c(row,"\\hline\n")
  if((x < 11) || (x > 100)) {
    row <- str_c(row,"kern & GenRamp & adfs & Types & Cons & what & kern & GenRamp & adfs & Types & Cons & what & PVal Hits & PVal Gen & PVal Nodes & PVal Depth \\\\\n")
  } else if((x > 10) && (x < 30)) {
    row <- str_c(row,"kern & GenRamp & adfs & Cons & what & kern & GenRamp & adfs & Cons & what & PVal Hits & PVal Gen & PVal Nodes & PVal Depth \\\\\n")
  } else {
    row <- str_c(row,"Kern & GenRamp & adfs & What & Kern & GenRamp & adfs & what & PVal Hits & PVal Gen & PVal Nodes & PVal Depth \\\\\n")
  }
  row <- str_c(row,"\\hline\n")
  row <- str_c(row,"\\input{")
  row <- str_c(row,fl1)
  row <- str_c(row,"}\n")
  write.table(row, file=fl2, append=TRUE, quote = FALSE, row.names = FALSE, col.names = FALSE) 

  #if (inlist(x,genrmp) == "FALSE"){

  
  if(x > 10 && x < 100) {
    # orig kernel 0
    run_wilcox('n','n', x,'0','y','n','n','n','n', x,'0','y','y','n','n','n') 

    # cgp2.1 kernel 1
    run_wilcox('n','n', x,'0','y','n','n','n','n', x,'1','n','n','n','y','n') 
    #run_wilcox('n','n', x,'0','y','y','n','n','n', x,'1','n','n','n','n','n') 

    # cgpf2.1 kernel 2
    #run_wilcox('n','n', x,'1','n','n','n','n','n', x,'2','y','n','n','n','n') 
    run_wilcox('n','n', x,'1','n','n','n','n','n', x,'2','y','y','n','n','n') 
    run_wilcox('n','n', x,'2','y','n','n','n','n', x,'2','y','y','n','n','n') 

    if((x > 10) && (x < 30)) {
      run_wilcox('n','n', x,'2','y','y','n','n','n', x,'2','y','y','n','y','n') 
    }

    #run_wilcox('n','n', x,'3','n','n','n','n','0', x,'4','y','y','n','n','0') 
    #run_wilcox('n','n', x,'3','n','n','n','n','1', x,'4','y','y','n','n','1') 
    #run_wilcox('n','n', x,'3','n','n','n','n','2', x,'4','y','y','n','n','2') 
    #run_wilcox('n','n', x,'3','n','n','n','n','3', x,'4','y','y','n','n','3') 

    what_arr <- c(2,3)
    for (w in what_arr) {
      #run_wilcox('n','n', x,'0','y','n','n','n','n', x,'4','y','y','n','n',w) 
      #run_wilcox('n','n', x,'0','y','y','n','n','n', x,'4','y','y','n','n',w) 
      #run_wilcox('n','n', x,'1','n','n','n','n','n', x,'4','y','y','n','n',w) 
      run_wilcox('n','n', x,'2','y','y','n','n','n', x,'4','y','y','n','n',w) 
      if((x > 10) && (x < 30)) {
        run_wilcox('n','n', x,'2','y','y','n','n','n', x,'4','y','y','n','y',w) 
      }
      run_wilcox('n','n', x,'3','n','n','n','n',  w, x,'4','y','y','n','n',w) 
      if((x > 10) && (x < 30)) {
        run_wilcox('n','n', x,'3','n','n','n','n',  w, x,'4','y','y','n','y',w) 
      }
    }

    if (inlist(x,probset1) == "TRUE"){
      y <- 0
      #if statements are to help map correct gen ramp problem to correct problem
      if(x == 11) {
        y <- 25
      }
      if(x == 12) {
        y <- 26
      }
      if(x == 13) {
        y <- 27
      }
      if(x == 14) {
        y <- 28
      }

      what_arr <- c(1,2,3)
      for (w in what_arr) {#  kn                         kn
        run_wilcox('n','n', x,'0','y','n','n','n','n', y,'4','y','y','n','n',w) 
        run_wilcox('n','n', x,'0','y','y','n','n','n', y,'4','y','y','n','n',w) 
        run_wilcox('n','n', x,'1','n','n','n','n','n', y,'4','y','y','n','n',w) 
        if((x > 10) && (x < 30)) {
          run_wilcox('n','n', x,'1','n','n','n','y','n', y,'4','y','y','n','y',w) 
	}
        run_wilcox('n','n', x,'3','n','n','n','n', w , y,'4','y','y','n','n',w) 
        if((x > 10) && (x < 30)) {
          run_wilcox('n','n', x,'3','n','n','n','y', w , y,'4','y','y','n','y',w) 
	}
        run_wilcox('n','n', x,'4','y','y','n','n', w , y,'4','y','y','n','n',w) 
        if((x > 10) && (x < 30)) {
          run_wilcox('n','n', x,'4','y','y','n','y', w , y,'4','y','y','n','y',w) 
	}
        run_wilcox('n','n', x,'2','y','y','n','n','n', y,'4','y','y','n','n',w) 
        if((x > 10) && (x < 30)) {
          run_wilcox('n','n', x,'2','y','y','n','y','n', y,'4','y','y','n','y',w) 
	}
      }
    }

    if (inlist(x,probset2) == "TRUE"){
      y <- x + 1
      what_arr <- c(1,2,3)
      for (w in what_arr) {
        run_wilcox('n','n', x,'0','y','n','n','n','n', y,'4','y','y','n','n',w) 
        run_wilcox('n','n', x,'0','y','y','n','n','n', y,'4','y','y','n','n',w) 
        run_wilcox('n','n', x,'1','n','n','n','n','n', y,'4','y','y','n','n',w) 
        if((x > 10) && (x < 30)) {
          run_wilcox('n','n', x,'1','n','n','n','y','n', y,'4','y','y','n','y',w) 
	}
        run_wilcox('n','n', x,'3','n','n','n','n', w , y,'4','y','y','n','n',w) 
        if((x > 10) && (x < 30)) {
          run_wilcox('n','n', x,'3','n','n','n','y', w , y,'4','y','y','n','y',w) 
	}
        run_wilcox('n','n', x,'4','y','y','n','n', w , y,'4','y','y','n','n',w) 
        if((x > 10) && (x < 30)) {
          run_wilcox('n','n', x,'4','y','y','n','y', w , y,'4','y','y','n','y',w) 
	}
        run_wilcox('n','n', x,'2','y','y','n','n','n', y,'4','y','y','n','n',w) 
        if((x > 10) && (x < 30)) {
          run_wilcox('n','n', x,'2','y','y','n','y','n', y,'4','y','y','n','y',w) 
	}
      }
    }
  } else {
    # orig kernel 0
    run_wilcox('n','n', x,'0','y','n','n','n','n', x,'0','y','y','n','n','n') 

    # cgp2.1 kernel 1
    run_wilcox('n','n', x,'0','y','n','n','n','n', x,'1','n','n','n','n','n') 
    #run_wilcox('n','n', x,'0','y','y','n','n','n', x,'1','n','n','n','n','n') 

    # cgpf2.1 kernel 2
    #run_wilcox('n','n', x,'1','n','n','n','n','n', x,'2','y','n','n','n','n') 
    run_wilcox('n','n', x,'1','n','n','n','n','n', x,'2','y','y','n','n','n') 
    run_wilcox('n','n', x,'2','y','n','n','n','n', x,'2','y','y','n','n','n') 

    run_wilcox('n','n', x,'3','n','n','n','n','0', x,'4','y','y','n','n','0') 
    run_wilcox('n','n', x,'3','n','n','n','n','1', x,'4','y','y','n','n','1') 
    run_wilcox('n','n', x,'3','n','n','n','n','2', x,'4','y','y','n','n','2') 

    what_arr <- c(2,3)
    for (w in what_arr) {
      run_wilcox('n','n', x,'0','y','n','n','n','n', x,'4','y','y','n','n',w) 
      run_wilcox('n','n', x,'0','y','y','n','n','n', x,'4','y','y','n','n',w) 
      run_wilcox('n','n', x,'1','n','n','n','n','n', x,'4','y','y','n','n',w) 
      run_wilcox('n','n', x,'2','y','y','n','n','n', x,'4','y','y','n','n',w) 
      run_wilcox('n','n', x,'3','n','n','n','n',  w, x,'4','y','y','n','n',w) 
    }

  }


  row <- str_c("\\hline\n")
  row <- str_c(row, "\\end{tabular}\n")
  row <- str_c(row, "}\n")
  row <- str_c(row, "\\end{center}\n")
  #row <- str_c(row, "\\caption{Problem ")
  #row <- str_c(row, x)
  #row <- str_c(row, "}\n")
  #row <- str_c(row, "\\end{table}\n")
  row <- str_c(row, "\\end{sidewaystable}\n")
  write.table(row, file=fl2, append=TRUE, quote = FALSE, row.names = FALSE, col.names = FALSE) 
}


cmd <- str_c("lualatex mainwilcox")
system(cmd)

quit()

