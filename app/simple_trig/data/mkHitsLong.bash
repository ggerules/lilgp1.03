#!/bin/bash
find . -name "hits.txt" -exec cat "{}" \; > hitslong_b.csv
nl -s, hitslong_b.csv > hitslong_c.csv
cat header_hits_long.txt > hitslong.csv
cat hitslong_c.csv >> hitslong.csv
rm -fR hitslong_b.csv
rm -fR hitslong_c.csv
Rscript file_v1.r
