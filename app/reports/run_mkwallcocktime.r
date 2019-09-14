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


pblm <- c(12,11,13,14,23,24,15,16,30,50,40,60,70,31,51,41,61,71,32,42,33,43,34,44,35,45,36,46,37,47,3,103,104,205,206,207,208,209,210)
#genrmp <- c(16,24,31,33,35,37,41,43,45,47,51,61,71)

fl0 <- "./wallclocktimes.csv"
unlink(fl0)


fp <- system("find .. -name \"time.txt\" | grep prob | grep -v qt | sort", intern = TRUE)

for (f in fp) {
  ll <- readLines(f)
  #print(f)

  pn <- strtoi(str_sub(f, 8, 10), base = 10)

  wct <- ""

  for (row in ll) {
    #print(row)
    #print(typeof(row))

    if (str_length(row) < 2) {
      next
    }

    #print(row)

    if (str_detect(row,"wall clock")){
      s0 <- str_split(row, " |\\(|\\)")
      #print(s0)
      wct <- sapply(s0, "[", 12)
      #print(wct)
      if (str_detect(wct, "\\.")) {
        tmp <- "0:"
        wct <- str_c(tmp, wct)
      } else {
        wct <- str_c(wct, ".0")
      }
    }
  }

  printf("p%d %s \n", pn, wct)

  df <- data.frame( 
          pn, wct 
       )
  #print(df)

  write.table(df, file=fl0, append=TRUE, sep = ",", quote = FALSE, row.names = FALSE, col.names = FALSE)

}

quit()
