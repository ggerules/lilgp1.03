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

#pblm <- c(12,26,11,25,13,27,14,28,23,24,15,16,17,18,30,31,50,51,32,33,34,35,36,37,40,41,42,43,44,45,46,47,60,61,70,71,80,81,82,83,84,85,86,87,90,91,92,93,94,95,96,97,103,104,205,206,207,208,209,210)
#pblm <- c(12,26,11,25,13,27,14,28,23,24,15,16,17,18,30,31,50,51,32,33,34,35,36,37,40,41,42,43,44,45,46,47,60,61,70,71,80,81,82,83,84,85,86,87,90,91,92,93,94,95,96,97)
pblm <- c(12,26,11,25,13,27,14,28,23,24,15,16,30,31,50,51,56,57,32,33,34,35,36,37,40,41,42,43,44,45,46,47,58,59,60,61,66,67,70,71,80,81,82,83,84,85,86,87,90,91,92,93,94,95,96,97,103,104,105,106)

#genrmp <- c(26,25,27,28,16,18,24,31,33,35,37,41,43,45,47,51,61,71,81,83,85,87,91,93,95,97)
genrmp <- c(26,25,27,28,16,24,31,33,35,37,41,43,45,47,51,57,59,61,67,71,81,83,85,87,91,93,95,97,104,106)

#nmpblm <- c(12,11,13,14,23,24,25,26,27,28,15,16,17,18,50,51)
nmpblm <- c(12,11,13,14,23,24,25,26,27,28,15,16,50,51,56,57,59)

#grp <- c("tb","lm","bb","k1","k2","k3","k12adf","all")
grp <- c("lm","bb","tb","all")

#lmpblm <- c(12,11,13,14,23,24,15,16,17,18,25,26,27,28)
lmpblm <- c(12,11,13,14,23,24,15,16,25,26,27,28)
bbpblm <- c(30,50,40,60,70,31,51,41,61,71,32,42,33,43,34,44,35,45,36,46,56,37,57,59,66,67,80,81,82,83,84,85,86,87,90,91,92,93,94,95,96,97)
koza1pblm  <- c(205,206)
koza2pblm  <- c(207,208)
koza3pblm  <- c(209,210)
koza2adfpblm  <- c(8)
tbpblm <- c(103,104,105,106)


inlist <- function(val, lst){
  res <- "FALSE" 
  for(x in lst){
    if(val == x){
      res <- "TRUE" 
    } 
  }
  return(res);
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

problem_desc <- function(f1pnum) {
  desc <- ""

#  printf("%d\n", f1pnum)
#  print(typeof(f1pnum))

  if ((as.numeric(f1pnum) > 10) && (as.numeric(f1pnum) < 30)) {
    desc <- str_c(desc, " Lawn Mower")
  } 

  if (as.numeric(f1pnum) > 29 && as.numeric(f1pnum) < 80) {
    desc <- str_c(desc, " Bumble Bee 2d ")
  }     

  if (as.numeric(f1pnum) > 79 && as.numeric(f1pnum) < 100) {
    desc <- str_c(desc, " Bumble Bee 3d ")
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


