#!/bin/bash

sum=$(ls -l *.stt | wc -l)
paste -d" " *.stt | nawk -v s="$sum" '{
    for(i=0;i<=s-1;i++)
    {
        temp3 = temp3 + i 
        temp4 = temp4 + i 
    }
    printf("%d %d %4.5f %4.5f\n", $1, $2, $3, $4)
    temp1=0
    temp2=0
    temp3=0
    temp4=0
}'
