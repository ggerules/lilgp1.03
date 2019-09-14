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


pblm <- c(12,26,11,25,13,27,14,28,23,24,15,16,17,18,30,31,50,51,32,33,34,35,36,37,40,41,42,43,44,45,46,47,60,61,70,71,80,81,82,83,84,85,86,87,90,91,92,93,94,95,96,97,103,104,205,206,207,208,209,210)
#pblm <- c(12,11,13,14,23,24,15,16,30,50,40,60,70,31,51,41,61,71,32,42,33,43,34,44,35,45,36,46,37,47,3,103,104,205,206,207,208,209,210)

#genrmp <- c(16,24,31,33,35,37,41,43,45,47,51,61,71)

runpar0 <- c("maxdepth", "savepop", "useercs", "pop", "maxgen", "numindruns", "lawnwidth", "lawnheight", "lawndepth", "nflowers", "fitcases")

runpar1 <- c("init.method", "init.depth", "app.use_genramp", "tree.0..max_depth", "tree.1..max_depth", "tree.2..max_depth", "app.genramp_max_tree_depth", "app.genram_interval", "init.depth_abs", "init.random_attempts", "acgp.use_trees_prct", "acgp.select_all", "acgp.gen_start_pct", "acgp.gen_step", "acgp.gen_slope", "acgp.stop_on_term", "breed_phases", "breed.1..operator", "breed.1..rate", "breed.2..operator", "breed.2..rate", "breed.3..operator", "breed.3..rate", "breed.4..operator", "breed.4..rate")

fl0 <- "./runparams0.csv"
unlink(fl0)
fl1 <- "./runparams1.csv"
unlink(fl1)

#fn <- system("find .. -name \"info.def\"", intern = TRUE)

fp <- system("find .. -maxdepth 1 -type d | grep prob | sort", intern = TRUE)

#this for loop gets the max gen statistic from the info def file 
#grep -H  \"maxgen=\"  ../prob077_bumblebee_25f_genramptree_mg208/info.def
for (f in fp) {
  printf("%s\n",f)

  maxdepth <- ""
  savepop <- ""
  useercs <- ""
  pop <- ""
  maxgen <- ""
  numindruns <- ""
  nflowers <- ""
  lawnwidth <- ""
  lawnheight <- ""
  lawndepth <- ""
  fitcases <- ""

  for (rp in runpar0) {
    cmd <- str_c("grep -H ")
    cmd <- str_c(cmd, " \"") 
    cmd <- str_c(cmd, rp) 
    cmd <- str_c(cmd, "\"  ") 
    cmd <- str_c(cmd, f)
    cmd <- str_c(cmd, "/info.def")
  
    #print(cmd)
    mg <- system(cmd, intern = TRUE)
    rval <- attr(mg,"status")
    #print(val)
    if(is.null(rval)) {
      #print(attr(mg,"status"))
      sp <- str_split(mg, "=")
    
      #print(typeof(sp))
      #print(sp[[c(1,1)]])
      str0 <- sp[[c(1,1)]]
      #print(typeof(str0))
      #prnd( strtoi(str_sub(str0, 8, 10), base = 10))
      pn <- strtoi(str_sub(str0, 8, 10), base = 10)
      #sp will be two rows, next line prints out second row
      #print(sp[[c(1,2)]])
      v <- str_split(sp[[c(1,2)]], ";")
      #print(v[[c(1,1)]])
      #vn <- strtoi(v[[c(1,1)]], base = 10)
      #prnd(vn) 
      #printf("p%d %s %s\n", pn, rp, v)

      if (str_detect(rp, "maxdepth"))
        maxdepth <- v[[c(1,1)]]

      if (str_detect(rp, "savepop"))
        savepop <- v[[c(1,1)]]

      if (str_detect(rp, "useercs"))
        useercs<- v[[c(1,1)]]

      if (str_detect(rp, "pop"))
        pop<- v[[c(1,1)]]

      if (str_detect(rp, "maxgen"))
        maxgen<- v[[c(1,1)]]

      if (str_detect(rp, "numindruns"))
        numindruns<- v[[c(1,1)]]

      if (str_detect(rp, "nflowers"))
        nflowers <- v[[c(1,1)]]

      if (str_detect(rp, "lawnwidth"))
        lawnwidth<- v[[c(1,1)]]

      if (str_detect(rp, "lawnheight"))
        lawnheight<- v[[c(1,1)]]

      if (str_detect(rp, "lawndepth"))
        lawndepth <- v[[c(1,1)]]

      if (str_detect(rp, "fitcases"))
        fitcases<- v[[c(1,1)]]

      printf("p%d %s %s\n", pn, rp, v[[c(1,1)]])

    }
  }

  df <- data.frame( 
             pn, maxdepth, savepop, useercs, pop, maxgen, numindruns, lawnwidth, lawnheight, lawndepth, nflowers, fitcases
                  )
  #print(df)

  write.table(df, file=fl0, append=TRUE, sep = ",", quote = FALSE, row.names = FALSE, col.names = FALSE)
}


#RowNum,
#ProblemNum,
#Kernel,
#IndRunNum,
#wADF,
#ADF,
#Types,
#Constraints,
#acgpwhat,
#MaxTreeDepth,
#Pop,
#NumIndRuns,
#LawnWidth,
#LawnHeight,
#FitCases,
#InitMethod,
#InitDepth,
#AppUseGenRamp,
#Tree0MaxDepth,
#Tree1MaxDepth,
#Tree2MaxDepth,
#AppGenRampMaxTreeDepth,
#AppGenRampInterval,
#InitDepthABS,
#InitRandomoAttempts,
#ACGPUseTreesPrct,
#ACGPSelectAll,
#ACGPGenStartPrct,
#ACGPGenStep,
#ACGPGenSlope,
#ACGPStopOnTerm,
#BreedOper1, 
#BreedOper1Select, 
#BreedOper1SelectSize, 
#BreedOper1Depth, 
#BreedOper1Rate, 
#BreedOper2, 
#BreedOper2Select, 
#BreedOper2SelectSize, 
#BreedOper2Depth, 
#BreedOper2Rate, 
#BreedOper3, 
#BreedOper3Select, 
#BreedOper3SelectSize, 
#BreedOper3Depth, 
#BreedOper3Rate, 
#BreedOper4, 
#BreedOper4Select,
#BreedOper4SelectSize, 
#BreedOper4Depth, 
#BreedOper4Rate, 


#from input.file acgpf2.1
#breed[1].operator = crossover, select=(tournament, size=7) 
#breed[2].operator = mutation, select=(tournament, size=7), depth=0-3
#breed[3].operator = reproduction, select=(tournament, size=7)
#breed[4].operator = regrow, select=(worst )

#from run.sh
#  acgpwhat=3
#  maxdepth=5
#  savepop=1
#  useercs=0
#  exe=gp
#  pop=1000
#  maxgen=52
#  lw=50
#  lh=50
 
#runpar1 <- c("init.method", "init.depth", "app.use_genramp", "tree.0..max_depth", "tree.1..max_depth", "tree.2..max_depth", "app.genramp_max_tree_depth", "app.genram_interval", "init.depth_abs", "init.random_attempts", "acgp.use_trees_prct", "acgp.select_all", "acgp.gen_start_pct", "acgp.gen_step", "acgp.gen_slope", "acgp.stop_on_term", "breed_phases", "breed.1..operator", "breed.1..rate", "breed.2..operator", "breed.2..rate", "breed.3..operator", "breed.3..rate", "breed.4..operator", "breed.4..rate")

fp <- system("find .. -name \"input.file\" | grep prob | grep -v qt | sort", intern = TRUE)

for (f in fp) {
  ll <- readLines(f)
  print(f)

  pn <- strtoi(str_sub(f, 8, 10), base = 10)

  wadf <- ""
  kern <- ""
  adf <- ""
  types <- ""
  cons <- ""
  what <- ""
  init_method <- ""
  init_depth <- ""
  app_use_genramp <- ""
  tree_0_max_depth <- ""
  tree_1_max_depth <- ""
  tree_2_max_depth <- ""
  app_genramp_max_tree_depth <- ""
  app_genram_interval <- ""
  init_depth_abs <- ""
  init_random_attempts <- ""
  acgp_use_trees_prct <- ""
  acgp_select_all <- ""
  acgp_gen_start_pct <- ""
  acgp_gen_step <- ""
  acgp_gen_slope <- ""
  acgp_stop_on_term <- ""
  breed_phases <- ""
  breedoper1 <- ""
  breedoper1select <- ""
  breedoper1selectsize <- ""
  breedoper1depth <- ""
  breedoper1rate <- ""
  breedoper2 <- ""
  breedoper2select <- ""
  breedoper2selectsize <- ""
  breedoper2depth <- ""
  breedoper2rate <- ""
  breedoper3 <- ""
  breedoper3select <- ""
  breedoper3selectsize <- ""
  breedoper3depth <- ""
  breedoper3rate <- ""
  breedoper4 <- ""
  breedoper4select <- ""
  breedoper4selectsize <- ""
  breedoper4depth <- ""
  breedoper4rate <- ""

  #get kernel type
  if (str_detect(f,"orig"))
    kern = "0"

  if (str_detect(f,"cgp2p1"))
    kern = "1"

  if (str_detect(f,"cgpf2p1"))
    kern = "2"

  if (str_detect(f,"acgp1p"))
    kern = "3"

  if (str_detect(f,"acgpf"))
    kern = "4"

  #get wadf
  if (str_detect(f,"ywadf"))
    wadf <- "y"
  else
    wadf <- "n"

  #get adf
  if (str_detect(f,"yadf"))
    adf <- "y"
  else
    adf <- "n"

  #get types
  if (str_detect(f,"ytypes"))
    types <- "y"
  else
    types <- "n"

  #get cons
  if (str_detect(f,"ycons"))
    cons <- "y"
  else
    cons <- "n"

  #get what
  if (str_detect(f,"nwhatn"))
    what <- "n"

  if (str_detect(f,"ywhat0"))
    what <- "0"

  if (str_detect(f,"ywhat1"))
    what <- "1"

  if (str_detect(f,"ywhat2"))
    what <- "2"

  if (str_detect(f,"ywhat3"))
    what <- "3"

  for (row in ll) {
    #print(row)
    #print(typeof(row))

    if (str_length(row) < 2) {
      next
    }

    s1 <- ""

    if (str_detect(row,"init.method")){
      s0 <- str_split(row, "= |=|,|\\(|\\)")
      init_depth <- sapply(s0, "[", 2)
    }

    if (str_detect(row,"app.use_genramp")){
      s0 <- str_split(row, "= |=|,|\\(|\\)")
      app_use_genramp <- sapply(s0, "[", 2)
    }

    if (str_detect(row,"tree.0..max_depth")){
      s0 <- str_split(row, "= |=|,|\\(|\\)")
      tree_0_max_depth <- sapply(s0, "[", 2)
    }

    if (str_detect(row,"tree.1..max_depth")){
      s0 <- str_split(row, "= |=|,|\\(|\\)")
      tree_1_max_depth <- sapply(s0, "[", 2)
    }

    if (str_detect(row,"tree.2..max_depth")){
      s0 <- str_split(row, "= |=|,|\\(|\\)")
      tree_2_max_depth <- sapply(s0, "[", 2)
    }

    if (str_detect(row,"app.genramp_max_tree_depth")){
      s0 <- str_split(row, "= |=|,|\\(|\\)")
      app_genramp_max_tree_depth <- sapply(s0, "[", 2)
    }

    if (str_detect(row,"app.genram_interval")){
      s0 <- str_split(row, "= |=|,|\\(|\\)")
      app_genram_interval <- sapply(s0, "[", 2)
    }

    if (str_detect(row,"init.depth_abs")){
      s0 <- str_split(row, "= |=|,|\\(|\\)")
      init_depth_abs <- sapply(s0, "[", 2)
    }

    if (str_detect(row,"init.random_attempts")){
      s0 <- str_split(row, "= |=|,|\\(|\\)")
      init.random_attempts <- sapply(s0, "[", 2)
    }

    if (str_detect(row,"acgp.use_trees_prct")){
      s0 <- str_split(row, "= |=|,|\\(|\\)")
      acgp_use_trees_prct <- sapply(s0, "[", 2)
    }

    if (str_detect(row,"acgp.select_all")){
      s0 <- str_split(row, "= |=|,|\\(|\\)")
      acgp_select_all <- sapply(s0, "[", 2)
    }

    if (str_detect(row,"acgp.gen_start_pct")){
      s0 <- str_split(row, "= |=|,|\\(|\\)")
      acgp_gen_start_pct <- sapply(s0, "[", 2)
    }

    if (str_detect(row,"acgp.gen_step")){
      s0 <- str_split(row, "= |=|,|\\(|\\)")
      acgp_gen_step <- sapply(s0, "[", 2)
    }

    if (str_detect(row,"acgp.gen_slope")){
      s0 <- str_split(row, "= |=|,|\\(|\\)")
      acgp_gen_slope <- sapply(s0, "[", 2)
    }

    if (str_detect(row,"acgp.stop_on_term")){
      s0 <- str_split(row, "= |=|,|\\(|\\)")
      acgp_stop_on_term <- sapply(s0, "[", 2)
    }

    if (str_detect(row,"breed_phases")){
      s0 <- str_split(row, "= |=|,|\\(|\\)")
      breed_phases <- sapply(s0, "[", 2)
    }

    if (str_detect(row,"breed")){
      if (str_detect(row, ".1.")) {
        if (str_detect(row, "operator" )) {
          s0 <- str_split(row, "= |=|,|\\(|\\)")
          #printf("%s,", x)
          breedoper1 <- sapply(s0,"[",2)
          breedoper1select <- sapply(s0,"[",5)
          breedoper1selectsize <- sapply(s0,"[",7)
          breedoper1depth <- sapply(s0,"[",9)
        } else if (str_detect(row, "rate" )) {
          s0 <- str_split(row, "= |=|,|\\(|\\)")
          breedoper1rate = sapply(s0, "[", 2)
        } else {
          print("something else")
        }
      } 
    }

    if (str_detect(row,"breed")){
      if (str_detect(row, ".2.")) {
        if (str_detect(row, "operator" )) {
          s0 <- str_split(row, "= |=|,|\\(|\\)")
          #printf("%s,", x)
          breedoper2 <- sapply(s0,"[",2)
          breedoper2select <- sapply(s0,"[",5)
          breedoper2selectsize <- sapply(s0,"[",7)
          breedoper2depth <- sapply(s0,"[",9)
        } else if (str_detect(row, "rate" )) {
          s0 <- str_split(row, "= |=|,|\\(|\\)")
          breedoper2rate = sapply(s0, "[", 2)
        } else {
          print("something else")
        }
      } 
    }

    if (str_detect(row,"breed")){
      if (str_detect(row, ".3.")) {
        if (str_detect(row, "operator" )) {
          s0 <- str_split(row, "= |=|,|\\(|\\)")
          #printf("%s,", x)
          breedoper3 <- sapply(s0,"[",2)
          breedoper3select <- sapply(s0,"[",5)
          breedoper3selectsize <- sapply(s0,"[",7)
          breedoper3depth <- sapply(s0,"[",9)
        } else if (str_detect(row, "rate" )) {
          s0 <- str_split(row, "= |=|,|\\(|\\)")
          breedoper3rate = sapply(s0, "[", 2)
        } else {
          print("something else")
        }
      } 
    }

    if (str_detect(row,"breed")){
      if (str_detect(row, ".4.")) {
        if (str_detect(row, "operator" )) {
          s0 <- str_split(row, "= |=|,|\\(|\\)")
          #printf("%s,", x)
          breedoper4 <- sapply(s0,"[",2)
          breedoper4select <- sapply(s0,"[",5)
          breedoper4selectsize <- sapply(s0,"[",7)
          breedoper4depth <- sapply(s0,"[",9)
        } else if (str_detect(row, "rate" )) {
          s0 <- str_split(row, "= |=|,|\\(|\\)")
          breedoper4rate = sapply(s0, "[", 2)
        } else {
          print("something else")
        }
      } 
    }

  }

  #printf("%s", s1)
  #printf("p%d %s %s %s %s %s %s %s \n", pn, kern, wadf, adf, types, cons, what, s1)

  df <- data.frame( 
          pn,  kern, wadf, adf, types, cons, what, 
          init_method, init_depth, app_use_genramp, tree_0_max_depth, tree_1_max_depth, tree_2_max_depth, 
          app_genramp_max_tree_depth, app_genram_interval, init_depth_abs, init_random_attempts, 
          acgp_use_trees_prct, acgp_select_all, acgp_gen_start_pct, acgp_gen_step, acgp_gen_slope, acgp_stop_on_term, 
          breed_phases, 
          breedoper1, breedoper1select, breedoper1selectsize, breedoper1depth, breedoper1rate, 
          breedoper2, breedoper2select, breedoper2selectsize, breedoper2depth, breedoper2rate, 
          breedoper3, breedoper3select, breedoper3selectsize, breedoper3depth, breedoper3rate, 
          breedoper4, breedoper4select, breedoper4selectsize, breedoper4depth, breedoper4rate
       )
  #print(df)

  write.table(df, file=fl1, append=TRUE, sep = ",", quote = FALSE, row.names = FALSE, col.names = FALSE)

}

quit()
