#!/bin/bash

sum=$(ls -l *.stt | wc -l)
paste -d" " *.stt | nawk -v s="$sum" '{
    for(i=0;i<=s-1;i++)
    {
        t3 = 3+(i*5)
        temp3 = temp3 + $t3
        t4 = 4+(i*5)
        temp4 = temp4 + $t4
    }
    print $1" "temp3/s" "temp4/s" "
    temp1=0
    temp2=0
    temp3=0
    temp4=0
}'
