#!/bin/bash
#rsync -avt ./mg50/ ggerules202:./mg50/
#rsync -avt ./mg52/ ggerules202:./mg52/
#rsync -avt ./mg104/ ggerules202:./mg104/
#rsync -avt ./mg156/ ggerules203:./mg156/
#rsync -avt ./mg208/ ggerules203:./mg208/
#rsync -avt ./mg500/ ggerules203:./mg500/
#rsync -avt ./dissertation/ ggerules201:./dissertation/
#rsync -avt ./reports/ ggerules201:./reports/

my_func() {
 #$PWD/parallel/main $1 $2
 /usr/bin/rsync -auvt $1 $2
}
export -f my_func
#parallel my_func ::: 1 2 3 4
#time parallel --eta -j 8  --colsep ' ' my_func $1 $2 :::: $PWD/parallel/rfile
/usr/bin/time -v parallel --eta -j 4  --colsep ' ' my_func $1 $2 :::: $PWD/backuplist.txt
