#!/bin/bash
  frmwrk=1
  prblm=6
  wadf=n
  adf=n
  types=y
  constrained=y
  acgpwhat=n
  maxdepth=7
  savepop=1
  useercs=0
  exe=gp
  pop=4000
  maxgen=50
  
  echo "pop=$pop"
  echo "maxgen=$maxgen"
  echo "maxindruns=$numindruns"
  echo "run_begin: $prblm-$frmwrk-1-$wadf-$adf-$types-$constrained-$acgpwhat-$maxdepth"

 valgrind --tool=callgrind  ./$exe -p pop_size=$pop -p max_generations=$maxgen -p random_seed=1 -p app.use_ercs=$useercs -p app.save_pop=$savepop -p acgp.what=$acgpwhat -p max_depth=$maxdepth -p output.basename=tmp/$prblm-$frmwrk-1-$wadf-$adf-$types-$constrained-$acgpwhat-$maxdepth -f input.file 

