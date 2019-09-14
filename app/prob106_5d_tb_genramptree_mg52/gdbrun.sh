#!/bin/sh
gdbtui -x fgdbcmds.txt --args ./gp -p random_seed=1 -p max_generations=2 -p pop_size=6 -p acgp.what=1 -p max_depth=4 -p app.use_ercs=0 -p app.save_pop=1 -p output.basename=./reg_rs1 -f input.file

