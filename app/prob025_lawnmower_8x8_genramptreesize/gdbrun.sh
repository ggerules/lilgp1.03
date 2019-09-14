#!/bin/sh
gdbtui -x fgdbcmds.txt --args ./gp -p random_seed=30 -p max_generations=50 -p pop_size=1000 -p app.lawn_width=8 -p app.lawn_height=8 -p acgp.what=1 -p max_depth=17 -p app.use_ercs=0 -p app.save_pop=1 -p output.basename=./reg_rs1 -f input.file 
