library(DBI)
library(RSQLite)
library(dplyr)
library(crayon)

printf <- function(...) cat(sprintf(...))
prnf <- function(...) cat(sprintf("%f ", ...))
prnd <- function(...) cat(sprintf("%d ", ...))
prln <- function(...) cat(sprintf("\n"))

blue_printf   <- function(...) cat(blue(...))
white_printf <- function(...) cat(white(sprintf(...)))
silver_printf <- function(...) cat(silver(sprintf(...)))

#CREATE TABLE beststatslong(
#  "RowNum" INTEGER,
#  "ProblemNum" INTEGER,
#  "Kernel" INTEGER,
#  "IndRunNum" INTEGER,
#  "wADF" TEXT,
#  "ADF" TEXT,
#  "Types" TEXT,
#  "Constraints" TEXT,
#  "acgpwhat" INTEGER,
#  "MaxTreeDepth" INTEGER,
#  "Hits" INTEGER
#);

#RSQLite::rsqliteVersion()
# 
drv <- dbDriver("SQLite")
con <- dbConnect(drv, dbname = "/home/ggerules/lilgp1.03/app/reports/data.db")
#RowNum,ProblemNum,Kernel,IndRunNum,wADF,ADF,Types,Constraints,acgpwhat,MaxTreeDepth,Hits
#rs <- dbSendQuery(con, "select Hits from beststatslong where (wADF in ('y')) and (ADF in ('n'))  and (ProblemNum = 37 and Kernel = 0 )")
rs <- dbSendQuery(con, "select * from beststatslong where wADF in ('y') and ADF in ('y') and Types in ('n') and Constraints in ('n') and acgpwhat in ('n') and ProblemNum = 37 and Kernel = 0")
d1 <- fetch(rs)
#dbHasCompleted(rs)
d1
dbClearResult(rs)
#dbListTables(con)

   # clean up
dbDisconnect(con)
