#!/bin/bash
#dirname=orig_ywadf_yadf_ntypes_ncons_nwhatn

./cln.sh

b=`basename $PWD`
echo $b

#mkdir -vp ../../mg52/

my_func() {
  frmwrk=0
  prblm=lm
  wadf=y
  adf=y
  types=n
  constrained=n
  acgpwhat=n
  maxdepth=17
  savepop=0
  useercs=0
  exe=gp
  pop=1000
  maxgen=52
  lw=10
  lh=10
  
  echo "pop=$pop"
  echo "maxgen=$maxgen"
  echo "maxindruns=$numindruns"
  echo "run_begin: $prblm-$frmwrk-$1-$wadf-$adf-$types-$constrained-$acgpwhat-$maxdepth"

  ./$exe -p pop_size=$pop -p app.use_adfs=yes -p max_generations=$maxgen -p random_seed=$1 -p app.lawn_width=$lw -p app.lawn_height=$lh -p app.use_ercs=$useercs -p app.save_pop=$savepop -p acgp.what=$acgpwhat -p max_depth=$maxdepth -p output.basename=tmp/$prblm-$frmwrk-$1-$wadf-$adf-$types-$constrained-$acgpwhat-$maxdepth -f input.file 

  echo "run_end: $prblm-$frmwrk-$1-$wadf-$adf-$types-$constrained-$acgpwhat-$maxdepth"
  echo "compressing files:"
  xz -zv2 ./tmp/$prblm-$frmwrk-$1-$wadf-$adf-$types-$constrained-$acgpwhat-$maxdepth.pop 
  xz -zv2 ./tmp/$prblm-$frmwrk-$1-$wadf-$adf-$types-$constrained-$acgpwhat-$maxdepth.his
#  mv -f ./tmp/$prblm-$frmwrk-$1-$wadf-$adf-$types-$constrained-$acgpwhat-$maxdepth.* ../../mg52/
}
export -f my_func
numindruns=50
time seq 1 $numindruns | parallel --eta -j8 my_func {1}

 
