
#!/bin/bash
#dirname=orig_ywadf_nadf_ntypes_ncons_nwhatn

./cln.sh

b=`basename $PWD`
echo $b

rm -fR ../data/$b
mkdir -vp ../data/$b/tmp

my_func() {
  frmwrk=0
  prblm=0
  wadf=y
  adf=n
  types=n
  constrained=n
  acgpwhat=n
  maxdepth=4
  savepop=1
  useercs=0
  exe=gp
  pop=4000
  maxgen=50
  
  echo "pop=$pop"
  echo "maxgen=$maxgen"
  echo "maxindruns=$numindruns"

  ./$exe -p pop_size=$pop -p max_generations=$maxgen -p random_seed=$1 -p app.use_ercs=$useercs -p app.save_pop=$savepop -p acgp.what=$acgpwhat -p max_depth=$maxdepth -p output.basename=tmp/$frmwrk-$prblm-$1-$wadf-$adf-$types-$constrained-$acgpwhat-$maxdepth -f input.file 

}
export -f my_func
numindruns=30
#time seq 1 $numindruns | parallel --eta -j0 my_func {1}
#time seq 1 $numindruns 
i=`seq 1 30`
#echo $i
for x in $i;
do 
  my_func $x
done;

cd ./tmp/
find *.bst -exec grep -H hits "{}" \; | sort | uniq > ./hits.txt
sed -i 's/hits://g' ./hits.txt
sed -i 's/\.bst//g' ./hits.txt
sed -i 's/:/,/g'    ./hits.txt
sed -i 's/-/,/g'    ./hits.txt
cd ..

#rsync --progress -avth ./tmp/ ../data/$b/tmp/
 
