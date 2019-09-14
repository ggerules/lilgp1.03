#!/usr/bin/env Rscript

library(argparser, quietly=TRUE)
library(DBI)
library(RSQLite)
library(dplyr, quietly=TRUE, warn.conflicts = FALSE)
library(crayon)
library(stringr)
library(lubridate)

source("common.r")

run_evaltime <- function(displine, dispdata, f1pnum, f1kerp1v, f1wadfv, f1adfv, f1typesv, f1consv, f1acgpwhatv ) {
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
  
  tm <- seconds_to_period(sum(d1$EvalTime))

  #desc <- str_c(desc, " & ",  mean(d1$EvalTime), " & ",  tm, "\\\\")
  desc <- str_c(desc, " & ",  tm, "\\\\")
  #printf("p %s %s & %f & %s \n", f1pnum, desc, mean(d1$EvalTime), tm)
  printf("%s\n", desc)
  
  fl <- "./tables/p"
  fl <- str_c(fl, f1pnum)
  fl <- str_c(fl, "tablevaltime.tex")
  
  write.table(desc, file=fl, append=TRUE, quote = FALSE, row.names = FALSE, col.names = FALSE) 
  if(displine == 'y') {
    desc <- str_c("\\hline")
  }
  
  # clean up
  dbDisconnect(con)

}

## start of main program

fl0 <- "./tables/evaltimestatstable.tex"
unlink(fl0)

for (x in pblm ) {

  fl1 <- "./tables/p"
  fl1 <- str_c(fl1, x)
  fl1 <- str_c(fl1, "tablevaltime.tex")
  unlink(fl1) 

  fl2 <- "./tables/p"
  fl2 <- str_c(fl2, x)
  fl2 <- str_c(fl2, "evaltimestatstable.tex")
  unlink(fl2) 

  row <- str_c("\\input{")
  row <- str_c(row, fl2)
  row <- str_c(row, "}")
  write.table(row, file=fl0, append=TRUE, quote = FALSE, row.names = FALSE, col.names = FALSE) 

  row <- str_c("\\begin{table}[H]\n")
  row <- str_c(row, "\\caption{Problem ")
  row <- str_c(row, problem_desc(x))
  if (x > 10 && x < 30 ) {
    row <- str_c(row," ",get_params_infodef(x,"LawnWidth"),"x",get_params_infodef(x,"LawnHeight"),"\\\\") 
  } else if (x > 29 && x < 100) {
    row <- str_c(row," ","Flowers ", get_params_infodef(x,"NFlowers"),"\\\\") 
  } else {
    row <- str_c(row, "\\\\")
  }
  row <- str_c(row,"Total Evaluation Time per Problem " ,"\\\\")
  if (inlist(x,genrmp) == "TRUE"){
    row <- str_c(row," ", "Use Generation Ramp ", " Max Generations ", get_params_infodef(x, "MaxGen"), "\\\\") 
  } else {
    row <- str_c(row," ", "Max Depth ", get_params_infodef(x, "MaxTreeDepth"),  " Max Generations ", get_params_infodef(x, "MaxGen"), "\\\\") 
  }
  if (inlist(x,nmpblm) == "TRUE"){
    row <- str_c(row," ","No Mutation ","\\\\") 
  }
  row <- str_c(row, "}\n")
  row <- str_c(row, "\\begin{center}\n")
  row <- str_c(row,"\\scalebox{1.0} % Change this value to rescale the drawing.\n")
  row <- str_c(row,"{\n")
  #row <- str_c(row,"\\begin{tabular}{llllllllllll}\n")
  if((x < 11) || (x > 100)) {
    row <- str_c(row,"\\begin{tabular}{lllllr}\n")
  } else if((x > 10) && (x < 30)) {
    row <- str_c(row,"\\begin{tabular}{llllr}\n")
  } else {
    row <- str_c(row,"\\begin{tabular}{lllr}\n")
  }
  row <- str_c(row,"\\hline\n")
  #row <- str_c(row,"probn & pdesc & kern & adfs & types & cons & what & mean hits & mean gen & mean nodes & mean depth \\\\\n")
  if((x < 11) || (x > 100)) {
    row <- str_c(row,"kern & adfs & types & cons & what & total eval time \\\\\n")
  } else if((x > 10) && (x < 30)) {
    row <- str_c(row,"kern & adfs & cons & what & total eval time \\\\\n")
  } else {
    row <- str_c(row,"kern & adfs & what & total eval time \\\\\n")
  }
  row <- str_c(row,"\\hline\n")
  row <- str_c(row,"\\input{")
  row <- str_c(row,fl1)
  row <- str_c(row,"}\n")
  write.table(row, file=fl2, append=TRUE, quote = FALSE, row.names = FALSE, col.names = FALSE) 

  if (inlist(x,genrmp) == "FALSE"){
    run_evaltime('n','n', x,'0','y','n','n','n','n') 
    run_evaltime('n','n', x,'0','y','y','n','n','n') 
  
    # cgp2.1 kernel
    run_evaltime('n','n', x,'1','n','n','n','n','n') 
    if((x < 11) || (x > 100)) {
      run_evaltime('n','n', x,'1','n','n','y','n','n') 
      run_evaltime('n','n', x,'1','n','n','n','y','n') 
      run_evaltime('n','n', x,'1','n','n','y','y','n') 
    }
    if((x > 10) && (x < 30)) {
      run_evaltime('n','n', x,'1','n','n','n','y','n') 
    }
  }

  #printf("***")
  # cgpf2.1 kernel
  run_evaltime('n','n', x,'2','y','n','n','n','n') 
  if((x < 11) || (x > 100)) {
    run_evaltime('n','n', x,'2','y','n','y','n','n') 
    run_evaltime('n','n', x,'2','y','n','n','y','n') 
    run_evaltime('n','n', x,'2','y','n','y','y','n') 
  }
  if((x > 10) && (x < 30)) {
    run_evaltime('n','n', x,'2','y','n','n','y','n') 
  }

  run_evaltime('n','n', x,'2','y','y','n','n','n') 
  if((x < 11) || (x > 100)) {
    run_evaltime('n','n', x,'2','y','y','y','n','n') 
    run_evaltime('n','n', x,'2','y','y','n','y','n') 
    run_evaltime('n','n', x,'2','y','y','y','y','n') 
  }
  if((x > 10) && (x < 30)) {
    run_evaltime('n','n', x,'2','y','y','n','y','n') 
  }

  if (inlist(x,genrmp) == "FALSE"){
    # acgp1.1.2 kernel
    run_evaltime('n','n', x,'3','n','n','n','n','0') 
    if((x < 30) || (x > 100)) {
      run_evaltime('n','n', x,'3','n','n','n','y','0') 
    }
    run_evaltime('n','n', x,'3','n','n','n','n','1') 
    if((x < 30) || (x > 100)) {
      run_evaltime('n','n', x,'3','n','n','n','y','1') 
    }
    run_evaltime('n','n', x,'3','n','n','n','n','2') 
    if((x < 30) || (x > 100)) {
      run_evaltime('n','n', x,'3','n','n','n','y','2') 
    }
    run_evaltime('n','n', x,'3','n','n','n','n','3') 
    if((x < 30) || (x > 100)) {
      run_evaltime('n','n', x,'3','n','n','n','y','3') 
    }
  }
  
  # acgp2.1 kernel
  
  what_arr <- c(0,1,2,3)
  for (w in what_arr) {
    run_evaltime('n','n', x,'4','y','n','n','n',w) 
    if((x < 11) || (x > 100)) {
      run_evaltime('n','n', x,'4','y','n','y','n',w) 
      run_evaltime('n','n', x,'4','y','n','n','y',w) 
      run_evaltime('n','n', x,'4','y','n','y','y',w) 
    }
    if((x < 30) || (x > 100)) {
      run_evaltime('n','n', x,'4','y','n','n','y',w) 
    }

    run_evaltime('n','n', x,'4','y','y','n','n',w) 
    if((x < 11) || (x > 100)) {
      run_evaltime('n','n', x,'4','y','y','y','n',w) 
      run_evaltime('n','n', x,'4','y','y','n','y',w) 
      run_evaltime('n','n', x,'4','y','y','y','y',w) 
    }
    if((x < 30) || (x > 100)) {
      run_evaltime('n','n', x,'4','y','y','n','y',w) 
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

cmd <- str_c("lualatex mainet")
system(cmd)
quit()

