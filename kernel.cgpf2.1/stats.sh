#!/bin/bash
grep -H tr cgp_czj.h > out.txt
grep -H tr cgp_czj.c >> out.txt 
grep -H tr cgp2_czj.h >> out.txt
grep -H tr cgp2_czj.c >> out.txt
cat ./out.txt | wc -l
wc -l cgp_czj.h cgp_czj.c cgp2_czj.h cgp2_czj.c
