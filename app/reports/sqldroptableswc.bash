#!/usr/bin/env Rscript

library(argparser, quietly=TRUE)
library(DBI)
library(RSQLite)
library(dplyr, quietly=TRUE, warn.conflicts = FALSE)
library(crayon)
library(stringr)


drv <- dbDriver("SQLite")
con <- dbConnect(drv, dbname = "/home/ggerules/lilgp1.03/app/reports/data.db")
dbListTables(con)


dt1 <- str_c("drop table ")
dt1 <- str_c(dt1,"wallclocktimes")
rs <- dbSendQuery(con, dt1)
dbClearResult(rs)

dbListTables(con)

  #printf("%s\n", selstat1)


  #d1 <- fetch(rs)
  #dbHasCompleted(rs)
  #d1
  #d1$Hits
  #dim(d1)
  #str(d1)
  #class(d1)
  #names(d1)


# clean up
dbDisconnect(con)
quit()
