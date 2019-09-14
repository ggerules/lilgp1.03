#!/usr/bin/env Rscript

library(argparser, quietly=TRUE)
library(DBI)
library(RSQLite)
library(dplyr, quietly=TRUE, warn.conflicts = FALSE)
library(crayon)
library(stringr)
library(ggplot2, quietly=TRUE, warn.conflicts = FALSE)

fun <- function(...) {
  #print(list(...))
  print(class(list(...)))
  c(list(...))
}

v <- fun(a="onadf", b="oyadf", c="cnadf")
print(v$a)
