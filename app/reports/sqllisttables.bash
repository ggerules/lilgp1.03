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

# clean up
dbDisconnect(con)
quit()
