#!/bin/bash
# this is used to see if max hits is using an ADF
# this script is renamed adf in ~/bin/
echo $PWD
for x in `find *.bst -exec grep -l "hits: $1" "{}" \;`;
do 
  echo $x
  cat $PWD/$x | grep $2
done
