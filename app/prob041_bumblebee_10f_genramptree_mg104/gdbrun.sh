#!/bin/sh
gdbtui -x fgdbcmds.txt --args ./gp -p random_seed=30 -p max_generations=50 -p pop_size=4000 -p acgp.what=0 -p max_depth=4 -p app.use_ercs=0 -p app.save_pop=1 -p output.basename=./tmp/reg_rs1 -f input.file

