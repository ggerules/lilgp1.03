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
  if(f1pnum == "3") {
    desc <- str_c(desc, " two box md4 mg50 ")
  } else if (f1pnum == "5") {
    desc <- str_c(desc, " koza1 md4 mg50 ")
  } else if (f1pnum == "8") {
    desc <- str_c(desc, " koza1 2adfs md4 mg50 ")
  } else if (f1pnum == "11") {
    desc <- str_c(desc, " Lawn Mower 8x8 md17 mg50 ")
  } else if (f1pnum == "12") {
    desc <- str_c(desc, " Lawn Mower 8x4 md17 mg50 ")
  } else if (f1pnum == "13") {
    desc <- str_c(desc, " Lawn Mower 8x10 md17 mg50 ")
  } else if (f1pnum == "14") {
    desc <- str_c(desc, " Lawn Mower 8x12 md17 mg50 ")
  } else if (f1pnum == "23") {
    desc <- str_c(desc, " Lawn Mower 25x25 md17 mg52 ")
  } else if (f1pnum == "24") {
    desc <- str_c(desc, " Lawn Mower 25x25 generation ramp mg52 ")
  } else if (f1pnum == "15") {
    desc <- str_c(desc, " Lawn Mower 50x50 md17 mg52 ")
  } else if (f1pnum == "16") {
    desc <- str_c(desc, " Lawn Mower 50x50 generation ramp mg52 ")
  } else if (f1pnum == "30") {
    desc <- str_c(desc, " Bumble Bee 10f md17 mg52 ")
  } else if (f1pnum == "31") {
    desc <- str_c(desc, " Bumble Bee 10f generation ramp mg52 ")
  } else if (f1pnum == "32") {
    desc <- str_c(desc, " Bumble Bee 15f md17 mg52 ")
  } else if (f1pnum == "33") {
    desc <- str_c(desc, " Bumble Bee 15f generation ramp mg52 ")
  } else if (f1pnum == "34") {
    desc <- str_c(desc, " Bumble Bee 20f md17 mg52 ")
  } else if (f1pnum == "35") {
    desc <- str_c(desc, " Bumble Bee 20f generation ramp mg52 ")
  } else if (f1pnum == "36") {
    desc <- str_c(desc, " Bumble Bee 25f md17 mg52 ")
  } else if (f1pnum == "37") {
    desc <- str_c(desc, " Bumble Bee 25f generation ramp mg52 ")
  } else if (f1pnum == "40") {
    desc <- str_c(desc, " Bumble Bee 10f md17 mg104 ")
  } else if (f1pnum == "41") {
    desc <- str_c(desc, " Bumble Bee 10f generation ramp mg104 ")
  } else if (f1pnum == "42") {
    desc <- str_c(desc, " Bumble Bee 15f md17 mg104 ")
  } else if (f1pnum == "43") {
    desc <- str_c(desc, " Bumble Bee 15f generation ramp mg104 ")
  } else if (f1pnum == "44") {
    desc <- str_c(desc, " Bumble Bee 20f md17 mg104 ")
  } else if (f1pnum == "45") {
    desc <- str_c(desc, " Bumble Bee 20f generation ramp mg104 ")
  } else if (f1pnum == "46") {
    desc <- str_c(desc, " Bumble Bee 25f md17 mg104 ")
  } else if (f1pnum == "47") {
    desc <- str_c(desc, " Bumble Bee 25f generation ramp mg104 ")
  } else if (f1pnum == "50") {
    desc <- str_c(desc, " Bumble Bee 10f md17 mg52 nm ")
  } else if (f1pnum == "51") {
    desc <- str_c(desc, " Bumble Bee 10f generation ramp mg52 nm ")
  } else if (f1pnum == "52") {
    desc <- str_c(desc, " Bumble Bee 15f md17 mg52 nm ")
  } else if (f1pnum == "53") {
    desc <- str_c(desc, " Bumble Bee 15f generation ramp mg52 nm ")
  } else if (f1pnum == "54") {
    desc <- str_c(desc, " Bumble Bee 20f md17 mg52 nm ")
  } else if (f1pnum == "55") {
    desc <- str_c(desc, " Bumble Bee 20f generation ramp mg52 nm ")
  } else if (f1pnum == "56") {
    desc <- str_c(desc, " Bumble Bee 25f md17 mg52 nm ")
  } else if (f1pnum == "57") {
    desc <- str_c(desc, " Bumble Bee 25f generation ramp mg52 nm ")
  } else if (f1pnum == "60") {
    desc <- str_c(desc, " Bumble Bee 10f md17 mg156 ")
  } else if (f1pnum == "61") {
    desc <- str_c(desc, " Bumble Bee 10f generation ramp mg156 ")
  } else if (f1pnum == "62") {
    desc <- str_c(desc, " Bumble Bee 15f md17 mg156 ")
  } else if (f1pnum == "63") {
    desc <- str_c(desc, " Bumble Bee 15f generation ramp mg156 ")
  } else if (f1pnum == "64") {
    desc <- str_c(desc, " Bumble Bee 20f md17 mg156 ")
  } else if (f1pnum == "65") {
    desc <- str_c(desc, " Bumble Bee 20f generation ramp mg156 ")
  } else if (f1pnum == "66") {
    desc <- str_c(desc, " Bumble Bee 25f md17 mg156 ")
  } else if (f1pnum == "67") {
    desc <- str_c(desc, " Bumble Bee 25f generation ramp mg156 ")
  } else if (f1pnum == "70") {
    desc <- str_c(desc, " Bumble Bee 10f md17 mg208 ")
  } else if (f1pnum == "71") {
    desc <- str_c(desc, " Bumble Bee 10f generation ramp mg208 ")
  } else if (f1pnum == "72") {
    desc <- str_c(desc, " Bumble Bee 15f md17 mg208 ")
  } else if (f1pnum == "73") {
    desc <- str_c(desc, " Bumble Bee 15f generation ramp mg208 ")
  } else if (f1pnum == "74") {
    desc <- str_c(desc, " Bumble Bee 20f md17 mg208 ")
  } else if (f1pnum == "75") {
    desc <- str_c(desc, " Bumble Bee 20f generation ramp mg208 ")
  } else if (f1pnum == "76") {
    desc <- str_c(desc, " Bumble Bee 25f md17 mg208 ")
  } else if (f1pnum == "77") {
    desc <- str_c(desc, " Bumble Bee 25f generation ramp mg208 ")
  } else if (f1pnum == "103") {
    desc <- str_c(desc, " two box md17 mg52 ")
  } else if (f1pnum == "104") {
    desc <- str_c(desc, " two box generation ramp mg52 ")
  } else {
    desc <- ""
  }
  return(desc)
}

run_params <- function(displine, dispdata, f1pnum, f1kerp1v, f1wadfv, f1adfv, f1typesv, f1consv, f1acgpwhatv ) {
  #RSQLite::rsqliteVersion()
  # 
  drv <- dbDriver("SQLite")
  con <- dbConnect(drv, dbname = "/home/ggerules/lilgp1.03/app/reports/data.db")
  #dbListTables(con)
  
  sel <- "select ProblemNum, Kernel, wADF, ADF, Types, Constraints, acgpwhat, MaxTreeDepth, InitMethod, InitDepth, AppUseGenRamp, Tree0MaxDepth, Tree1MaxDepth, Tree2MaxDepth, AppGenRampMaxTreeDepth, AppGenRampInterval, InitDepthABS, InitRandomoAttempts, ACGPUseTreesPrct, ACGPSelectAll, ACGPGenStartPrct, ACGPGenStep, ACGPGenSlope, ACGPStopOnTerm, BreedOper1, BreedOper1Select, BreedOper1SelectSize, BreedOper1Depth, BreedOper1Rate, BreedOper2, BreedOper2Select, BreedOper2SelectSize, BreedOper2Depth, BreedOper2Rate, BreedOper3, BreedOper3Select, BreedOper3SelectSize, BreedOper3Depth, BreedOper3Rate, BreedOper4, BreedOper4Select, BreedOper4SelectSize, BreedOper4Depth, BreedOper4Rate from runparams_inputfile where "
  wadf <- "wADF in ('"
  ap1 <- "') and "
  adf <- "ADF in ('"
  types <- "Types in ('"
  cons <- "Constraints in ('"
  acgpwhat <- "acgpwhat in ('"
  pn <- "ProblemNum = "
  ap2 <- " and "
  kerp1 <- "Kernel = "
  
  selstat1 <- str_c(sel,wadf,f1wadfv,ap1,adf,f1adfv,ap1,types,f1typesv,ap1,cons,f1consv,ap1,acgpwhat,f1acgpwhatv,ap1,pn,f1pnum,ap2,kerp1,f1kerp1v)
  #selstat1
  
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
  
  #my_data <- data.frame( 
  #                group = rep(c(kern1, kern2), each = 50),
  #                hits = c(d1$Hits,  d2$Hits)
  #                )
  
  #my_data <- data.frame( 
  #                group = rep(c(kern1), each = 50),
  #                hits = c(d1$Hits)
  #                )
  
  #if(dispdata == 'y')
  #  print(my_data)
  
  desc <- str_c(desc, " & ",  mean(d1$Hits), " & ", mean(d1$Gen), " & ",  mean(d1$Nodes), " & ", mean(d1$Depth), "\\\\")
  printf("p %s %s & %f & %f & %f & %f\n", f1pnum, desc, mean(d1$Hits), mean(d1$Gen), mean(d1$Nodes), mean(d1$Depth))
  #printf("%s\n", desc)
  
  fl <- "p"
  fl <- str_c(fl, f1pnum)
  fl <- str_c(fl, "tablrp1.tex")
  
  write.table(desc, file=fl, append=TRUE, quote = FALSE, row.names = FALSE, col.names = FALSE) 
  if(displine == 'y') {
    desc <- str_c("\\hline")
  }
  
  # clean up
  dbDisconnect(con)

}

## start of main program

#pblm <- c(15,16)
#pblm <- c(5,8,12,11,13,14,23,24,15,16,30,31,32,33,34,35,36,37,50,51,40,41,42,43,44,45,46,47,60,61,70,71,3,103,104)
pblm <- c(5,8,12,11,13,14,23,24,15,16,30,50,40,60,70,31,51,41,61,71,32,42,33,43,34,44,35,45,36,46,37,47,3,103,104)
genrmp <- c(16,24,31,33,35,37,41,43,45,47,51,61,71)

fl0 <- "./runparamstable1.tex"
unlink(fl0)

for (x in pblm ) {

  fl1 <- "p"
  fl1 <- str_c(fl1, x)
  fl1 <- str_c(fl1, "tablrp1.tex")
  unlink(fl1) 

  fl2 <- "p"
  fl2 <- str_c(fl2, x)
  fl2 <- str_c(fl2, "runparamstable1.tex")
  unlink(fl2) 

  row <- str_c("\\input{")
  row <- str_c(row, fl2)
  row <- str_c(row, "}")
  write.table(row, file=fl0, append=TRUE, quote = FALSE, row.names = FALSE, col.names = FALSE) 

  row <- str_c("\\begin{table}[H]\n")
  row <- str_c(row, "\\caption{Problem ")
  #row <- str_c(row, x)
  row <- str_c(row, problem_desc(x))
  row <- str_c(row, "}\n")
  row <- str_c(row, "\\begin{center}\n")
  row <- str_c(row,"\\scalebox{0.8} % Change this value to rescale the drawing.\n")
  row <- str_c(row,"{\n")
  #row <- str_c(row,"\\begin{tabular}{llllllllllll}\n")
  if((x < 11) || (x > 100)) {
    row <- str_c(row,"\\begin{tabular}{llllllllll}\n")
  } else {
    row <- str_c(row,"\\begin{tabular}{llllllll}\n")
  }
  row <- str_c(row,"\\hline\n")
  #row <- str_c(row,"probn & pdesc & kern & adfs & types & cons & what & mean hits & mean gen & mean nodes & mean depth \\\\\n")
  if((x < 11) || (x > 100)) {
    row <- str_c(row,"kern & adfs & types & cons & what & mean hits & mean gen & mean nodes & mean depth \\\\\n")
  } else {
    row <- str_c(row,"kern & adfs & what & mean hits & mean gen & mean nodes & mean depth \\\\\n")
  }
  row <- str_c(row,"\\hline\n")
  row <- str_c(row,"\\input{")
  row <- str_c(row,fl1)
  row <- str_c(row,"}\n")
  write.table(row, file=fl2, append=TRUE, quote = FALSE, row.names = FALSE, col.names = FALSE) 

  if (inlist(x,genrmp) == "FALSE"){
    run_params('n','n', x,'0','y','n','n','n','n') 
    run_params('n','n', x,'0','y','y','n','n','n') 
  
    # cgp2.1 kernel
    run_params('n','n', x,'1','n','n','n','n','n') 
    if((x < 11) || (x > 100)) {
      run_params('n','n', x,'1','n','n','y','n','n') 
      run_params('n','n', x,'1','n','n','n','y','n') 
      run_params('n','n', x,'1','n','n','y','y','n') 
    }
  }

  #printf("***")
  # cgpf2.1 kernel
  run_params('n','n', x,'2','y','n','n','n','n') 
  if((x < 11) || (x > 100)) {
    run_params('n','n', x,'2','y','n','y','n','n') 
    run_params('n','n', x,'2','y','n','n','y','n') 
    run_params('n','n', x,'2','y','n','y','y','n') 
  }
  run_params('n','n', x,'2','y','y','n','n','n') 
  if((x < 11) || (x > 100)) {
    run_params('n','n', x,'2','y','y','y','n','n') 
    run_params('n','n', x,'2','y','y','n','y','n') 
    run_params('n','n', x,'2','y','y','y','y','n') 
  }

  if (inlist(x,genrmp) == "FALSE"){
    # acgp1.1.2 kernel
    run_params('n','n', x,'3','n','n','n','n','0') 
    if((x < 11) || (x > 100)) {
      run_params('n','n', x,'3','n','n','n','y','0') 
      run_params('n','n', x,'3','n','n','n','n','1') 
      run_params('n','n', x,'3','n','n','n','y','1') 
      run_params('n','n', x,'3','n','n','n','n','2') 
      run_params('n','n', x,'3','n','n','n','y','2') 
      run_params('n','n', x,'3','n','n','n','n','3') 
      run_params('n','n', x,'3','n','n','n','y','3') 
    }
  }
  
  # acgp2.1 kernel
  
  what_arr <- c(0,1,2,3)
  for (w in what_arr) {
    run_params('n','n', x,'4','y','n','n','n',w) 
    if((x < 11) || (x > 100)) {
      run_params('n','n', x,'4','y','n','y','n',w) 
      run_params('n','n', x,'4','y','n','n','y',w) 
      run_params('n','n', x,'4','y','n','y','y',w) 
    }
    run_params('n','n', x,'4','y','y','n','n',w) 
    if((x < 11) || (x > 100)) {
      run_params('n','n', x,'4','y','y','y','n',w) 
      run_params('n','n', x,'4','y','y','n','y',w) 
      run_params('n','n', x,'4','y','y','y','y',w) 
    }
  }

  row <- str_c("\\end{tabular}\n")
  row <- str_c(row, "}\n")
  row <- str_c(row, "\\end{center}\n")
  #row <- str_c(row, "\\caption{Problem ")
  #row <- str_c(row, x)
  #row <- str_c(row, "}\n")
  row <- str_c(row, "\\end{table}\n")
  write.table(row, file=fl2, append=TRUE, quote = FALSE, row.names = FALSE, col.names = FALSE) 
}

cmd <- str_c("lualatex mainrp1")
system(cmd)
quit()
