#!/bin/sh
gdbtui --args ./gp -p random_seed=1 -p acgp.what=2 -p max_depth=15 -p output.basename=./tmp/reg_rs1 -f input.file

