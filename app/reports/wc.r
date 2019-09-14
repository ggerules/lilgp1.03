#pblm <- c(15,16)
#pblm <- c(12,11,13,14,23,24,15,16,30,31,50,51,32,33,34,35,36,37,40,41,42,43,44,45,46,47,60,61,70,71,3,103,104,205,206,207,208,209,210)
#pblm <- c(12,11,13,14,23,24,15,16,30,31,50,51,32,33,34,35,36,37,40,41,42,43,44,45,46,47,60,61,70,71,103,104)
#pblm <- c(12,11,13,14,23,15,17,30,50,32,34,36,40,42,44,46,60,70,103,205,207,209)
#pblm <- c(12,11,13,14,23,15,30,50,32,34,36,40,42,44,46,60,70,103,205,207,209)
#pblm <- c(12,11,13,14,23,15,17,30,50,32,34,36,40,42,44,46,60,70)
pblm <- c(12,11,13,14,23,15,30,50,32,34,36,40,42,44,46,60,70,103,104)

probset1 <- c(12,11,13,14)
#probset2 <- c(23,15,17,30,50,32,34,36,40,42,44,46,60,70,80,82,84,86,90,92,94,96,103,205,207,209)
#probset2 <- c(23,15,17,30,50,32,34,36,40,42,44,46,60,70,80,82,84,86,90,92,94,96)
probset2 <- c(23,15,30,50,32,34,36,40,42,44,46,60,70,80,82,84,86,90,92,94,96,103)

#genrmp <- c(16,18,24,31,33,35,37,41,43,45,47,51,61,71,81,83,85,87,91,93,95,97,25,26,27,28,206,208,210)
#genrmp <- c(16,18,24,31,33,35,37,41,43,45,47,51,61,71,81,83,85,87,91,93,95,97,25,26,27,28)
genrmp <- c(16,24,31,33,35,37,41,43,45,47,51,61,71,81,83,85,87,91,93,95,97,25,26,27,28,104)


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



