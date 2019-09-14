#!/usr/bin/env Rscript

library(argparser, quietly=TRUE)
library(DBI)
library(RSQLite)
library(dplyr, quietly=TRUE, warn.conflicts = FALSE)
library(crayon)
library(stringr)
library(ggplot2, quietly=TRUE, warn.conflicts = FALSE)
library(rlist)
library(extrafont, quietly=TRUE, warn.conflicts = FALSE)
library(tikzDevice)
#loadfonts()

source("common.r")

#get_sttlong <- function(f1pnum, f1kerp1v, f1wadfv, f1adfv, f1typesv, f1consv, f1acgpwhatv, genv ) {
get_sttlong <- function(f1pnum, f1kerp1v, f1wadfv, f1adfv, f1typesv, f1consv, f1acgpwhatv ) {
  #RSQLite::rsqliteVersion()
  # 
  drv <- dbDriver("SQLite")
  con <- dbConnect(drv, dbname = "/home/ggerules/lilgp1.03/app/reports/data.db")
  #dbListTables(con)

 # sel <- "select Hits,Gen,Nodes,Depth from beststatslong where "


   sel <- "select  IndRunNum,GenNum,ProblemNum,Kernel,wADF,ADF,Types,Constraints,acgpwhat,MaxTreeDepth,MeanStdFitnessOfGen,StdFitnessBestOfGenInd,StdFitnessWorstOfGenInd,MeanTreeSizeOfGen,MeanTreeDepthOfGen,TreeSizeBestOfGenInd,TreeDepthBestOfGenInd,TreeSizeWorstOfGenInd,TreeDepthWorstOfGenInd,MeanStdFitnessOfRun,StdFitnessBestOfRunInd,StdFitnessWorstOfRunInd,MeanTreeSizeOfRun,MeanTreeDepthOfRun,TreeSizeBestOfRunInd,TreeDepthBestOfRunInd,TreeSizeWorstOfRunInd,TreeDepthWorstOfRunInd from sttlong where "

  wadf <- "wADF in ('"
  ap1 <- "') and "
  adf <- "ADF in ('"
  types <- "Types in ('"
  cons <- "Constraints in ('"
  acgpwhat <- "acgpwhat in ('"
  pn <- "ProblemNum = "
  ap2 <- " and "
  kerp1 <- "Kernel = "
#  gennum <- "GenNum = "
  e1 <- " )"
  ord <-"  order by IndRunNum asc" 
#  selstat1 <- str_c(sel,wadf,f1wadfv,ap1,adf,f1adfv,ap1,types,f1typesv,ap1,cons,f1consv,ap1,acgpwhat,f1acgpwhatv,ap1,pn,f1pnum,ap2,kerp1,f1kerp1v,ap2,gennum,genv,ord)
  selstat1 <- str_c(sel,wadf,f1wadfv,ap1,adf,f1adfv,ap1,types,f1typesv,ap1,cons,f1consv,ap1,acgpwhat,f1acgpwhatv,ap1,pn,f1pnum,ap2,kerp1,f1kerp1v,ord)
  #print(selstat1)
  
  #rs <- dbSendQuery(con, "select Hits from beststatslong where (wADF in ('y')) and (ADF in ('n'))  and (ProblemNum = 37 and Kernel = 0 )")
  rs <- dbSendQuery(con, selstat1)
  d1 <- fetch(rs)
  #dbHasCompleted(rs)
  #d1
  #print(d1)
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
  
  # clean up
  dbDisconnect(con)

  printf("p %s %s \n", f1pnum, desc)

  return(d1)
}

groupsum <- function(d1,ver) {
  if(ver == "bofg") {
    o <- d1 %>% 
        group_by(ProblemNum,Kernel,wADF,ADF,Types,Constraints,acgpwhat,MaxTreeDepth,GenNum) %>% 
        summarise(num = n(), mean = mean(StdFitnessBestOfGenInd)) 
  }
  if(ver == "bofr") {
    o <- d1 %>% 
        group_by(ProblemNum,Kernel,wADF,ADF,Types,Constraints,acgpwhat,MaxTreeDepth,GenNum) %>% 
        summarise(num = n(), mean = mean(StdFitnessBestOfRunInd)) 
  }

  #print(o)
  print(o$mean)
  print(o$num)
  return(o) 
}


plot_sttlong <- function(f1pnum,f1ncol,ver,orignadf,origyadf,cgpnadf,cgpfyadf,acgpnadf,acgpfyadf,cgpfyadfgr,acgpfyadfgr) {

  if(f1pnum < 30)
  {
    if(orignadf == "y") {
      d1 <- get_sttlong(f1pnum   ,'0','y','n','n','n','n') 
    }
    if(origyadf == "y") {
      d2 <- get_sttlong(f1pnum   ,'0','y','y','n','n','n') 
    }
    if(cgpnadf == "y") {
      d3 <- get_sttlong(f1pnum   ,'1','n','n','n','n','n') 
    }
    if(cgpfyadf == "y") {
      d4 <- get_sttlong(f1pnum   ,'2','y','y','n','y','n') 
    }
    if(acgpnadf == "y") {
      d5 <- get_sttlong(f1pnum   ,'3','n','n','n','y','2') 
    }
    if(acgpfyadf == "y") {
      d6 <- get_sttlong(f1pnum   ,'4','y','y','n','y','2') 
    }
    if(cgpfyadfgr == "y") {
      d7 <- get_sttlong(f1pnum+1 ,'2','y','y','n','y','n') 
    }
    if(acgpfyadfgr == "y") {
      d8 <- get_sttlong(f1pnum+1 ,'4','y','y','n','y','2') 
    }

  } else if(f1pnum > 29 && f1pnum < 100) {
    if(orignadf == "y") {
      d1 <- get_sttlong(f1pnum   ,'0','y','n','n','n','n') 
    }
    if(origyadf == "y") {
      d2 <- get_sttlong(f1pnum   ,'0','y','y','n','n','n') 
    }
    if(cgpnadf == "y") {
      d3 <- get_sttlong(f1pnum   ,'1','n','n','n','n','n') 
    }
    if(cgpfyadf == "y") {
      d4 <- get_sttlong(f1pnum   ,'2','y','y','n','n','n') 
    }
    if(acgpnadf == "y") {
      d5 <- get_sttlong(f1pnum   ,'3','n','n','n','n','2') 
    }
    if(acgpfyadf == "y") {
      d6 <- get_sttlong(f1pnum   ,'4','y','y','n','n','2') 
    }
    if(cgpfyadfgr == "y") {
      d7 <- get_sttlong(f1pnum+1 ,'2','y','y','n','n','n') 
    }
    if(acgpfyadfgr == "y") {
      d8 <- get_sttlong(f1pnum+1 ,'4','y','y','n','n','2') 
    }

  } else if(f1pnum > 100) {
    if(orignadf == "y") {
      d1 <- get_sttlong(f1pnum   ,'0','y','n','n','n','n') 
    }
    if(origyadf == "y") {
      d2 <- get_sttlong(f1pnum   ,'0','y','y','n','n','n') 
    }
    if(cgpnadf == "y") {
      d3 <- get_sttlong(f1pnum   ,'1','n','n','y','y','n') 
    }
    if(cgpfyadf == "y") {
      d4 <- get_sttlong(f1pnum   ,'2','y','y','y','y','n') 
    }
    if(acgpnadf == "y") {
      d5 <- get_sttlong(f1pnum   ,'3','n','n','n','n','2') 
    }
    if(acgpfyadf == "y") {
      d6 <- get_sttlong(f1pnum   ,'4','y','y','y','y','2') 
    }
    if(cgpfyadfgr == "y") {
      d7 <- get_sttlong(f1pnum+1 ,'2','y','y','y','y','n') 
    }
    if(acgpfyadfgr == "y") {
      d8 <- get_sttlong(f1pnum+1 ,'4','y','y','y','y','2') 
    }

  } else {
    return("")
  }

  x <- c()
  val <- c()
  FrameWork <- c()
  if(orignadf == "y") {
    o <- groupsum(d1,ver)
    x <- c(x,o$GenNum)
    FrameWork <- c(FrameWork,rep("orig nadf",f1ncol))
    val <- c(val,o$mean)
  }
  if(origyadf == "y") {
    o <- groupsum(d2,ver)
    x <- c(x,o$GenNum)
    FrameWork <- c(FrameWork,rep("orig yadf",f1ncol))
    val <- c(val,o$mean)
  }
  if(cgpnadf == "y") {
    o <- groupsum(d3,ver)
    x <- c(x,o$GenNum)
    FrameWork <- c(FrameWork,rep("cgp2p1 nadf",f1ncol))
    val <- c(val,o$mean)
  }
  if(cgpfyadf == "y") {
    o <- groupsum(d4,ver)
    x <- c(x,o$GenNum)
    FrameWork <- c(FrameWork,rep("cgpf2p1 yadf",f1ncol))
    val <- c(val,o$mean)
  }
  if(acgpnadf == "y") {
    o <- groupsum(d5,ver)
    x <- c(x,o$GenNum)
    FrameWork <- c(FrameWork,rep("acgp1p1p12 nadf",f1ncol))
    val <- c(val,o$mean)
  }
  if(acgpfyadf == "y") {
    o <- groupsum(d6,ver)
    x <- c(x,o$GenNum)
    FrameWork <- c(FrameWork,rep("acgpf2p1 yadf",f1ncol))
    val <- c(val,o$mean)
  }
  if(cgpfyadfgr == "y") {
    o <- groupsum(d7,ver)
    x <- c(x,o$GenNum)
    FrameWork <- c(FrameWork,rep("cgpf2p1 yadf gr",f1ncol))
    val <- c(val,o$mean)
  }
  if(acgpfyadfgr == "y") {
    o <- groupsum(d8,ver)
    x <- c(x,o$GenNum)
    FrameWork <- c(FrameWork,rep("acgpf2p1 yadf gr",f1ncol))
    val <- c(val,o$mean)
  }

  df <- data.frame(x, FrameWork, val)

  fn <- str_c(sprintf("%s_%s",f1pnum,ver))
  fn <- str_c(fn, "_md17.pdf")

  fnt <- str_c("p", sprintf("%s_%s",f1pnum,ver))
  fnt <- str_c(fnt, "_md17.tex")

  tikz(file = fnt, pointsize = 8, width = 5.5, height = 3.5)

  title <- str_c("Problem: ")
  title <- str_c(title, problem_desc(f1pnum))
  if (f1pnum > 10 && f1pnum < 30 ) {
    title <- str_c(title," ",get_params_infodef(f1pnum,"LawnWidth"),"x",get_params_infodef(f1pnum,"LawnHeight"),"\n") 
  } else if (f1pnum > 29 && f1pnum < 100) {
    title <- str_c(title," ","Flowers ", get_params_infodef(f1pnum,"NFlowers"),"\n") 
  } else {
    title <- str_c(title, "\n")
  }
  title <- str_c(title,"Best of Run Individuals " ,"\n")
  if (inlist(f1pnum,genrmp) == "TRUE"){
    title <- str_c(title," ", "Use Generation Ramp ", " Max Generations ", get_params_infodef(f1pnum, "MaxGen"), "\n") 
  } else {
    title <- str_c(title," ", "Max Depth ", get_params_infodef(f1pnum, "MaxTreeDepth"),  " Max Generations ", get_params_infodef(f1pnum, "MaxGen"), "\n") 
  }
  if (inlist(f1pnum,nmpblm) == "TRUE"){
    title <- str_c(title," ","No Mutation ","\n") 
  }
  #get rid of title and do it in latex
  title <- ""

  if(ver == "bofr") {
    ytext <- "Mean Standard Fitness Best of Run Individuals"
  }
  if(ver == "bofg") {
    ytext <- "Mean Standard Fitness Best of Gen Individuals"
  }

  #plot <- ggplot(df, aes(x=x, y=val, group=FrameWork, color=FrameWork, linetype = FrameWork)) + geom_line() +
  plot <- ggplot(df, aes(x=x, y=val, group=FrameWork, color=FrameWork, linetype = FrameWork)) + 
  #plot <- ggplot(df, aes(x=x, y=val, group=FrameWork, linetype = FrameWork)) + 
	  geom_line() + 
	  geom_point(aes(shape=FrameWork), size = 2) +
          labs(title=title, x="Generation Number", y=ytext)  + 
	  ylim(0,1) +
  #        theme_bw() +
          theme(plot.title = element_text(hjust = 0.5),text=element_text(family="cmr10", size=11))
  #ggsave(plot, file=fn) #save pdf
  print(plot) # save tex?

  dev.off()

 # x <- c(o1$GenNum, o2$GenNum) 
 # print(str(x))
 # FrameWork <- c(rep("orig_nadf",52), rep("orig_yadf",52))
 # print(str(FrameWork))
 # val <- c(o1$mean, o2$mean)
 # print(str(val))

 # df <- data.frame(x, FrameWork, val)


}
## start of main program
#      1            2        3          4          5           6          7             8
#  "orignadf", "origyadf","cgpnadf","cgpfyadf","acgpnadf","acgpfyadf","cgpfyadfgr","acgpfyadfgr"

#                             1   2   3   4   5   6   7   8
#plot_sttlong( 23, 53,"bofg",'y','y','n','n','y','y','n','y')
#plot_sttlong( 15, 53,"bofg",'y','y','n','n','y','y','n','y')
#plot_sttlong( 30, 53,"bofg",'y','y','n','n','y','y','n','y')
#plot_sttlong( 36, 53,"bofg",'y','y','n','n','y','y','n','y')
#plot_sttlong( 40,105,"bofg",'y','y','n','n','y','y','n','y')
#plot_sttlong( 46,105,"bofg",'y','y','n','n','y','y','n','y')
#plot_sttlong( 50, 53,"bofg",'y','y','n','n','y','y','n','y')
#plot_sttlong( 56, 53,"bofg",'y','y','n','n','y','y','n','y')
#plot_sttlong( 60,157,"bofg",'y','y','n','n','y','y','n','y')
#plot_sttlong( 70,209,"bofg",'y','y','n','n','y','y','n','y')
#plot_sttlong( 96,105,"bofg",'y','y','n','n','y','y','n','y')
#plot_sttlong( 86, 53,"bofg",'y','y','n','n','y','y','n','y')
#plot_sttlong(103, 53,"bofg",'y','y','n','n','y','y','n','y')

#                            1   2   3   4   5   6   7   8
#plot_sttlong( 23, 53,"bofr",'y','y','n','n','y','y','n','y')
#plot_sttlong( 15, 53,"bofr",'y','y','n','n','y','y','n','y')
#plot_sttlong( 30, 53,"bofr",'y','y','n','n','y','y','n','y')
#plot_sttlong( 36, 53,"bofr",'y','y','n','n','y','y','n','y')
#plot_sttlong( 40,105,"bofr",'y','y','n','n','y','y','n','y')
#plot_sttlong( 46,105,"bofr",'y','y','n','n','y','y','n','y')
#plot_sttlong( 50, 53,"bofr",'y','y','n','n','y','y','n','y')
#plot_sttlong( 56, 53,"bofr",'y','y','n','n','y','y','n','y')
#plot_sttlong( 60,157,"bofr",'y','y','n','n','y','y','n','y')
#plot_sttlong( 70,209,"bofr",'y','y','n','n','y','y','n','y')
#plot_sttlong( 96,105,"bofr",'y','y','n','n','y','y','n','y')
#plot_sttlong( 86, 53,"bofr",'y','y','n','n','y','y','n','y')
#plot_sttlong(103, 53,"bofr",'y','y','n','n','y','y','n','y')

#all no cgpf
#                            1   2   3   4   5   6   7   8
#plot_sttlong( 23, 53,"bofr",'y','y','y','n','y','y','n','y')
#plot_sttlong( 15, 53,"bofr",'y','y','y','n','y','y','n','y')
#plot_sttlong( 30, 53,"bofr",'y','y','y','n','y','y','n','y')
#plot_sttlong( 36, 53,"bofr",'y','y','y','n','y','y','n','y')
#plot_sttlong( 40,105,"bofr",'y','y','y','n','y','y','n','y')
#plot_sttlong( 46,105,"bofr",'y','y','y','n','y','y','n','y')
#plot_sttlong( 50, 53,"bofr",'y','y','y','n','y','y','n','y')
#plot_sttlong( 56, 53,"bofr",'y','y','y','n','y','y','n','y')
#plot_sttlong( 58,105,"bofr",'y','y','y','n','y','y','n','y')
#plot_sttlong( 60,157,"bofr",'y','y','y','n','y','y','n','y')
#plot_sttlong( 66,157,"bofr",'y','y','y','n','y','y','n','y')
#plot_sttlong( 70,209,"bofr",'y','y','y','n','y','y','n','y')
plot_sttlong( 76,209,"bofr",'y','y','y','n','y','y','n','y')
#plot_sttlong( 86, 53,"bofr",'y','y','y','n','y','y','n','y')
#plot_sttlong( 96,105,"bofr",'y','y','y','n','y','y','n','y')
#plot_sttlong(103, 53,"bofr",'y','y','y','n','y','y','n','y')
#plot_sttlong(105, 53,"bofr",'y','y','y','n','y','y','n','y')

#plot_sttlong(30,53,"cgponly",'n','n','n','y','n','n','y','n')
cmd <- str_c("/home/ggerules/lilgp1.03/app/reports/cpybofr.bash")
system(cmd)

quit()

