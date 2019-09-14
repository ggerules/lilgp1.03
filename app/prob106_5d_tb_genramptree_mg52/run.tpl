[+ AutoGen5 template +][+ FOR objlst +][+IF (exist? "kname")+]
#!/bin/bash
#dirname=[+dirname+]

./cln.sh

b=`basename $PWD`
echo $b

mkdir -vp ../../mg52/

my_func() {
  frmwrk=[+frmwrk+]
  prblm=[+prblm+]
  wadf=[+(get "wadf")+]
  adf=[+(get "adf")+]
  types=[+(get "types")+]
  constrained=[+(get "cons")+]
  acgpwhat=[+(get "what")+]
  maxdepth=[+maxdepth+]
  savepop=[+savepop+]
  useercs=[+useercs+]
  exe=[+exe+]
  pop=[+pop+]
  maxgen=[+maxgen+]
  
  echo "pop=$pop"
  echo "maxgen=$maxgen"
  echo "maxindruns=$numindruns"
  echo "run_begin: $prblm-$frmwrk-$1-$wadf-$adf-$types-$constrained-$acgpwhat-$maxdepth"
[+IF (match-value? == "kname" "kernel.acgp1.1.2")+]
  ./$exe -p pop_size=$pop -p max_generations=$maxgen -p random_seed=$1 -p app.use_ercs=$useercs -p app.save_pop=$savepop -p acgp.what=$acgpwhat -p max_depth=$maxdepth -p output.basename=tmp/$prblm-$frmwrk-$1-$wadf-$adf-$types-$constrained-$acgpwhat-$maxdepth -f input.file < acgp1p1p2_cli_input.txt
[+ELSE+]
  ./$exe -p pop_size=$pop -p max_generations=$maxgen -p random_seed=$1 -p app.use_ercs=$useercs -p app.save_pop=$savepop -p acgp.what=$acgpwhat -p max_depth=$maxdepth -p output.basename=tmp/$prblm-$frmwrk-$1-$wadf-$adf-$types-$constrained-$acgpwhat-$maxdepth -f input.file 
[+ENDIF+]
  echo "run_end: $prblm-$frmwrk-$1-$wadf-$adf-$types-$constrained-$acgpwhat-$maxdepth"
  echo "compressing files:"
  xz -zv2 ./tmp/$prblm-$frmwrk-$1-$wadf-$adf-$types-$constrained-$acgpwhat-$maxdepth.pop 
  xz -zv2 ./tmp/$prblm-$frmwrk-$1-$wadf-$adf-$types-$constrained-$acgpwhat-$maxdepth.his
  mv -f ./tmp/$prblm-$frmwrk-$1-$wadf-$adf-$types-$constrained-$acgpwhat-$maxdepth.* ../../mg52/
}
export -f my_func
numindruns=[+numindruns+]
time seq 1 $numindruns | parallel --eta -j12 my_func {1}

-|[+ENDIF+][+ ENDFOR +]
