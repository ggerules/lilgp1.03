#!/bin/bash
for x in `ls -b group*.r`;
do
 echo $x
 sed -i 's/prob003_tb/prob006_st_new/g' $x
 sed -i 's/Two Box /Simple Trig /g' $x
done;
