#!/usr/bin/env Rscript

library(argparser, quietly=TRUE)
library(DBI)
library(RSQLite)
library(dplyr, quietly=TRUE, warn.conflicts = FALSE)
library(crayon)
library(stringr)

source("common.r")


run_params_infodef <- function(displine, dispdata, f1pnum) {
  #RSQLite::rsqliteVersion()
   
  drv <- dbDriver("SQLite")
  con <- dbConnect(drv, dbname = "/home/ggerules/lilgp1.03/app/reports/data.db")
  #dbListTables(con)
  
#runparams_infodef( RowNum,ProblemNum,MaxTreeDepth,SavePop,UseERCS,Pop,MaxGen,NumIndRuns,LawnWidth,LawnHeight,LawnDepth,FitCases);

  sel <- "select ProblemNum,MaxTreeDepth,SavePop,UseERCS,Pop,MaxGen,NumIndRuns,LawnWidth,LawnHeight,LawnDepth,NFlowers,FitCases from runparams_infodef where "
  pn <- "ProblemNum = "
 
  selstat1 <- str_c(sel,pn,f1pnum)
  #printf("%s\n", selstat1)


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

  fl <- str_c("./tables/tablrp0.tex")

  #if(dispdata == 'y')
  #  print(my_data)

  if (d1$ProblemNum < 11 || d1$ProblemNum > 100 ) {
    maxhits <-  d1$FitCases
  } else if (d1$ProblemNum > 10 || d1$ProblemNum < 30) {
    maxhits <-  d1$LawnWidth * d1$LawnHeight
  } else {
    maxhits <-  d1$FitCases * d1$NFlowers
  }

  desc <- str_c( problem_desc(d1$ProblemNum))

  if (x > 10 && x < 30 ) {
    desc <- str_c(desc,get_params_infodef(x,"LawnWidth"),"x",get_params_infodef(x,"LawnHeight")) 
  } else if (x > 29 && x < 100) {
    desc <- str_c(desc," ", get_params_infodef(x,"NFlowers"), " Flowers") 
  } else { }

  if (inlist(f1pnum,nmpblm) == "FALSE"){
    desc <- str_c(desc, " & n ")
  } else {
    desc <- str_c(desc, " & y ")
  }

  if (inlist(f1pnum,genrmp) == "FALSE"){
    desc <- str_c(desc, " & n ", " & ")
  } else {
    desc <- str_c(desc, " & y ", " & ")
  }

  desc <- str_c(desc, d1$MaxGen, " & ", d1$MaxTreeDepth, " & ",  d1$Pop, " & ",  d1$NumIndRuns, " & ", d1$FitCases, " & ", maxhits, "\\\\")

  printf("%s\n", desc)
  write.table(desc, file=fl, append=TRUE, quote = FALSE, row.names = FALSE, col.names = FALSE) 
  if(displine == 'y') {
    desc <- str_c("\\hline\n")
  }
 
  # clean up
  dbDisconnect(con)
}


## start of main program


fl0 <- "./tables/./runparamstable0.tex"
unlink(fl0)

fl1 <- str_c("./tables/tablrp0.tex")
unlink(fl1) 

row <- str_c("\\begin{table}[H]\n")
row <- str_c(row, "\\caption{Global Run Parameters Per Problem")
#row <- str_c(row, x)
#row <- str_c(row, problem_desc(x))
row <- str_c(row, "}\n")
row <- str_c(row, "\\begin{center}\n")
row <- str_c(row,"\\scalebox{0.8} % Change this value to rescale the drawing.\n")
row <- str_c(row,"{\n")
#row <- str_c(row,"\\begin{tabular}{lrrrrrrrrrr}\n")
row <- str_c(row,"\\begin{tabular}{lrrrrrrrr}\n")
row <- str_c(row,"\\hline\n")
#row <- str_c(row,"Problem & Mutation & GenRamp & MaxDepth & SavePop & ERCS & Population & MaxGen & NumIndRuns & FitCases & MaxHits \\\\\n")
row <- str_c(row,"Problem & Mutation & GenRamp & MaxDepth & MaxGen & Population & NumIndRuns & FitCases & MaxHits \\\\\n")
row <- str_c(row,"\\hline\n")
row <- str_c(row,"\\input{./tables/tablrp0.tex}\n")
write.table(row, file=fl0, append=TRUE, quote = FALSE, row.names = FALSE, col.names = FALSE) 

#table body stuff goes here
for (x in pblm ) {

  run_params_infodef('n','n', x) 

}

row <- str_c("\\end{tabular}\n")
row <- str_c(row, "}\n")
row <- str_c(row, "\\end{center}\n")
#row <- str_c(row, "\\caption{Problem ")
#row <- str_c(row, x)
#row <- str_c(row, "}\n")
row <- str_c(row, "\\end{table}\n")
write.table(row, file=fl0, append=TRUE, quote = FALSE, row.names = FALSE, col.names = FALSE) 

cmd <- str_c("lualatex mainrp0")
system(cmd)

quit()

