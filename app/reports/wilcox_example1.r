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


#RSQLite::rsqliteVersion()
# 
drv <- dbDriver("SQLite")
con <- dbConnect(drv, dbname = "/home/ggerules/lilgp1.03/app/reports/data.db")
#dbListTables(con)

rs <- dbSendQuery(con, "select Hits from beststatslong where (wADF in ('y')) and (ADF in ('n'))  and (ProblemNum = 37 and Kernel = 0 )")
d1 <- fetch(rs)
dbHasCompleted(rs)
#d1
#d1$Hits
dbClearResult(rs)
#dim(d1)
#str(d1)
#class(d1)
#names(d1)


#rs <- dbSendQuery(con, "select Hits from beststatslong where (wADF in ('y')) and (ADF in ('y'))  and (ProblemNum = 37 and Kernel = 4 )")
rs <- dbSendQuery(con, "select Hits from beststatslong where ((wADF in ('y')) and (ADF in ('y')) and (Types in ('n')) and (Constraints in ('n')))  and (ProblemNum = 37 and Kernel = 4 and acgpwhat = 3)")
d2 <- fetch(rs)
dbHasCompleted(rs)
#d2
#d2$Hits
dbClearResult(rs)
#dim(d2)
#str(d2)
#class(d2)
#names(d2)

my_data <- data.frame( 
                group = rep(c("orig_nadf", "acgpf2p1_yadf"), each = 50),
                hits = c(d1$Hits,  d2$Hits)
                )
print(my_data)

#group_by(my_data, group) %>%
#  summarise(
#    count = n(),
#    median = median(hits, na.rm = TRUE),
#    IQR = IQR(hits, na.rm = TRUE)
#  )

#res <- wilcox.test(hits ~ group, data = my_data, exact = FALSE)
#res
# Print the p-value only
#res$p.value

#The p-value of the test is 0.02712, which is less than the significance level alpha = 0.05. We can conclude that men’s median weight is significantly different from women’s median weight with a p-value = 0.02712.

#if you want to test whether the median orig hits is less than the median women’s weight, type this:
#res <- wilcox.test(hits ~ group, data = my_data, exact = FALSE, alternative = "less")
#res$p.value

#Or, if you want to test whether the median orig hits is greater than the median women’s weight, type this
res <- wilcox.test(hits ~ group, data = my_data, exact = FALSE, alternative = "greater")
res$p.value


   # clean up
dbDisconnect(con)

quit()
