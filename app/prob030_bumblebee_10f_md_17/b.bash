#!/bin/bash
#echo "making app.c files"
autogen -T app.tpl -o c --writable -b app info.def  
autogen -T cpyapp.tpl -o bashc --writable -b cpyapp info.def  
chmod 700 ./cpyapp.bashc
./cpyapp.bashc
rm -fR cpyapp.bashc
rm -fR app.c

autogen -T app.tpl -o adf --writable -b app info.def  
autogen -T cpyapp.tpl -o bashadf --writable -b cpyapp info.def  
chmod 700 ./cpyapp.bashadf
./cpyapp.bashadf
rm -fR cpyapp.bashadf
rm -fR app.adf


