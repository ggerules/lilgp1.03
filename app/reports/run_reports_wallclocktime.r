#!/usr/bin/env Rscript

library(argparser, quietly=TRUE)
library(DBI)
library(RSQLite)
library(dplyr, quietly=TRUE, warn.conflicts = FALSE)
library(crayon)
library(stringr)
library(lubridate, quietly=TRUE, warn.conflicts = FALSE)

source("common.r")

hts <- function(x) {
  s <- x * 3600
}

mts <- function(x) {
  s <- x * 60
}

totaltime <- function(ptype) {
  drv <- dbDriver("SQLite")
  con <- dbConnect(drv, dbname = "/home/ggerules/lilgp1.03/app/reports/data.db")
  #dbListTables(con)
  
  tothours   <- 0
  totminutes <- 0 
  totseconds <- 0 
  desc <- ""

  if(ptype == "all") {
    pb <- pblm
    desc <- c(" all ")
  } else if (ptype == "lm") {
    pb <- lmpblm 
    desc <- c(" lawn mower ")
  } else if (ptype == "bb") {
    pb <- bbpblm 
    desc <- c(" bumble bee ")
  } else if (ptype == "k1") {
    pb <- koza1pblm  
    desc <- c(" koza1 ")
  } else if (ptype == "k2") {
    pb <- koza2pblm  
    desc <- c(" koza2 ")
  } else if (ptype == "k3") {
    pb <- koza3pblm  
    desc <- c(" koza3 ")
  } else if (ptype == "k12adf") {
    pb <- koza2adfpblm  
    desc <- c(" koza1 2adf ")
  } else if (ptype == "tb") {
    pb <- tbpblm 
    desc <- c(" two box ")
  } else {
    return 
  }

  for (x in pb) {
    sel <- "select Hours,Min,Sec from wallclocktimes where "
    pn <- "ProblemNum = "
 
    selstat1 <- str_c(sel,pn,x)
    #printf("%s\n", selstat1)

    rs <- dbSendQuery(con, selstat1)
    d1 <- fetch(rs)
    dbClearResult(rs)

    tothours <- d1$Hours + tothours
    totminutes <- d1$Min + totminutes
    totseconds <- d1$Sec + totseconds

    #printf("h:%d m:%d s:%d\n", d1$Hours, d1$Min, d1$Sec)
  }

  #printf("total h:%d m:%d s:%d\n", tothours, totminutes, totseconds)

  ts <- hts(tothours) + mts(totminutes) + totseconds
  tm <- seconds_to_period(ts)

  printf("total %s %s\n", desc, tm )

  # clean up
  dbDisconnect(con)
  return(tm)
}

run_totaltime <- function(displine, ptype) {
  drv <- dbDriver("SQLite")
  con <- dbConnect(drv, dbname = "/home/ggerules/lilgp1.03/app/reports/data.db")
  #dbListTables(con)
  
  tothours   <- 0
  totminutes <- 0 
  totseconds <- 0 
  desc <- ""

  fl <- str_c("./tables/tablwctsum.tex")

  if(ptype == "all") {
    pb <- pblm
    desc <- str_c(" All ")
  } else if (ptype == "lm") {
    pb <- lmpblm 
    desc <- str_c(" Lawn Mower ")
  } else if (ptype == "bb") {
    pb <- bbpblm 
    desc <- str_c(" Bumble Bee ")
  } else if (ptype == "k1") {
    pb <- koza1pblm  
    desc <- str_c(" Koza1 ")
  } else if (ptype == "k2") {
    pb <- koza2pblm  
    desc <- c(" Koza2 ")
  } else if (ptype == "k3") {
    pb <- koza3pblm  
    desc <- c(" Koza3 ")
  } else if (ptype == "k12adf") {
    pb <- koza2adfpblm  
    desc <- str_c(" Koza1 2adfs ")
  } else if (ptype == "tb") {
    pb <- tbpblm 
    desc <- str_c(" Two Box ")
  } else {
    return 
  }

  for (x in pb) {
    sel <- "select Hours,Min,Sec from wallclocktimes where "
    pn <- "ProblemNum = "
 
    selstat1 <- str_c(sel,pn,x)
    #printf("%s\n", selstat1)

    rs <- dbSendQuery(con, selstat1)
    d1 <- fetch(rs)
    dbClearResult(rs)

    tothours <- d1$Hours + tothours
    totminutes <- d1$Min + totminutes
    totseconds <- d1$Sec + totseconds

    #printf("h:%d m:%d s:%d\n", d1$Hours, d1$Min, d1$Sec)
  }

  #printf("total h:%d m:%d s:%d\n", tothours, totminutes, totseconds)

  ts <- hts(tothours) + mts(totminutes) + totseconds
  tm <- seconds_to_period(ts)

  #printf("total %s %s\n", desc, tm )
  desc <- str_c(desc, " & ", tm, "\\\\")

  # clean up
  dbDisconnect(con)

  #printf("%s\n", desc)
  write.table(desc, file=fl, append=TRUE, quote = FALSE, row.names = FALSE, col.names = FALSE) 
  if(displine == 'y') {
    desc <- str_c("\\hline\n")
  }
}


run_wallclocktimes <- function(displine, dispdata, f1pnum) {
  #RSQLite::rsqliteVersion()
   
  drv <- dbDriver("SQLite")
  con <- dbConnect(drv, dbname = "/home/ggerules/lilgp1.03/app/reports/data.db")
  #dbListTables(con)
  
#runwallclocktimes( RowNum,ProblemNum,MaxTreeDepth,SavePop,UseERCS,Pop,MaxGen,NumIndRuns,LawnWidth,LawnHeight,LawnDepth,FitCases);

  #RowNum,ProblemNum,Hours,Min,Sec,MicroSec
  sel <- "select ProblemNum,Hours,Min,Sec,MicroSec from wallclocktimes where "
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

  fl <- str_c("./tables/tablwct.tex")

  #if(dispdata == 'y')
  #  print(my_data)
  maxgen <- get_params_infodef(f1pnum, "MaxGen") 

  #print(d1)
  desc <- str_c("p", d1$ProblemNum )
  desc <- str_c( desc, problem_desc(f1pnum) )

  if (x > 10 && x < 30 ) {
    desc <- str_c(desc,get_params_infodef(x,"LawnWidth"),"x",get_params_infodef(x,"LawnHeight")) 
  } else if (x > 29 && x < 100) {
    desc <- str_c(desc," ", get_params_infodef(x,"NFlowers"), " Flowers") 
  } else { }

  if (inlist(f1pnum,nmpblm) == "FALSE"){
    desc <- str_c(desc, " & ", maxgen, " & y ")
  } else {
    desc <- str_c(desc, " & ", maxgen, " & n ")
  }

  #RowNum,ProblemNum,Hours,Min,Sec,MicroSec
  if (inlist(f1pnum,genrmp) == "FALSE"){
    desc <- str_c(desc, " & n ")
  } else {
    desc <- str_c(desc, " & y ")
  }

  eltime <- sprintf("%02d:%02d:%02d", d1$Hours, d1$Min, d1$Sec)

  #d1$Hours, " & ",  d1$Min, " & ",  d1$Sec, " & ",  d1$MicroSec

  desc <- str_c(desc, " & ", eltime, "\\\\") 

  printf("%s\n", desc)
  write.table(desc, file=fl, append=TRUE, quote = FALSE, row.names = FALSE, col.names = FALSE) 
  if(displine == 'y') {
    desc <- str_c("\\hline\n")
  }
 
  # clean up
  dbDisconnect(con)
}


## start of main program

fl0 <- "./tables/wallclocktimes.tex"
unlink(fl0)

fl1 <- str_c("./tables/tablwct.tex")
unlink(fl1) 

row <- str_c("\\begin{center}\n")
row <- str_c(row, "\\begin{longtable}{lrrrr}\n")
row <- str_c(row, "\\caption{Wall Clock Times Per Problem}\\\\\n")
row <- str_c(row, "\\hline\n")
row <- str_c(row, "Problem & MaxGen & Mutation & GenRamp & HH:MM:SS \\\\\n")
row <- str_c(row, "\\hline\n")
row <- str_c(row, "\\endfirsthead\n")
row <- str_c(row, "\\multicolumn{5}{c}%\n")
row <- str_c(row, "{\\tablename\\ \\thetable\\ -- \\textit{Continued from previous page}} \\\\\n")
row <- str_c(row, "\\hline\n")
row <- str_c(row, "Problem & MaxGen & Mutation & GenRamp & HH:MM:SS \\\\\n")
row <- str_c(row, "\\hline\n")
row <- str_c(row, "\\endhead\n")
row <- str_c(row, "\\hline \\multicolumn{5}{r}{\\textit{Continued on next page}} \n")
row <- str_c(row, "\\endfoot\n")
row <- str_c(row, "\\hline\n")
row <- str_c(row, "\\endlastfoot\n")
row <- str_c(row, "\\input{./tables/tablwct.tex}\n")
write.table(row, file=fl0, append=TRUE, quote = FALSE, row.names = FALSE, col.names = FALSE) 

#table body stuff goes here
for (x in pblm ) {

  run_wallclocktimes('n','n', x) 

}

row <- str_c("\\end{longtable}\n")
row <- str_c(row, "\\end{center}\n")
write.table(row, file=fl0, append=TRUE, quote = FALSE, row.names = FALSE, col.names = FALSE) 

########### next table 

fl0 <- "./tables/wallclocktimessum.tex"
unlink(fl0)

fl1 <- str_c("./tables/tablwctsum.tex")
unlink(fl1) 

row <- str_c("\\begin{table}[H]\n")
row <- str_c(row, "\\caption{Wall Clock Times Per Problem Category")
#row <- str_c(row, x)
#row <- str_c(row, problem_desc(x))
row <- str_c(row, "}\n")
row <- str_c(row, "\\begin{center}\n")
row <- str_c(row,"\\scalebox{0.8} % Change this value to rescale the drawing.\n")
row <- str_c(row,"{\n")
row <- str_c(row,"\\begin{tabular}{lrrrrrr}\n")
row <- str_c(row,"\\hline\n")
  #RowNum,ProblemNum,Hours,Min,Sec,MicroSec
row <- str_c(row,"Problem Category & Time \\\\\n")
row <- str_c(row,"\\hline\n")
row <- str_c(row,"\\input{./tables/tablwctsum.tex}\n")
write.table(row, file=fl0, append=TRUE, quote = FALSE, row.names = FALSE, col.names = FALSE) 

#table body stuff goes here
for (g in grp) {

  run_totaltime("n", g) 

}

row <- str_c("\\end{tabular}\n")
row <- str_c(row, "}\n")
row <- str_c(row, "\\end{center}\n")
#row <- str_c(row, "\\caption{Problem ")
#row <- str_c(row, x)
#row <- str_c(row, "}\n")
row <- str_c(row, "\\end{table}\n")
write.table(row, file=fl0, append=TRUE, quote = FALSE, row.names = FALSE, col.names = FALSE) 


for (g in grp) {
  totaltime(g)
}

cmd <- str_c("lualatex mainwct")
system(cmd)

quit()


