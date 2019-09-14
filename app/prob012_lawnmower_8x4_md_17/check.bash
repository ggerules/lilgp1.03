#!/bin/bash
echo "making checkhits files"
autogen -T checkhits.tpl -o lsh --writable -b checkhits info.def  
autogen -T cpycheckhits.tpl -o sh --writable -b cpycheckhits info.def  
chmod 700 ./cpycheckhits.sh
./cpycheckhits.sh
rm -fR ./cpycheckhits.sh
rm -fR ./checkhits.sh

echo "making adfused files"
autogen -T adfused.tpl -o lsh --writable -b adfused info.def  
autogen -T cpyadfused.tpl -o sh --writable -b cpyadfused info.def  
chmod 700 ./cpyadfused.sh
./cpyadfused.sh
rm -fR ./cpyadfused.sh
rm -fR ./adfused.sh

echo "making runcheckhits script" 
autogen -T runcheckhits.tpl --writable -b runcheckhits info.def
chmod 700 runcheckhits.bash


