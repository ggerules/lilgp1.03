#!/bin/bash
#find . -name "*.sh" -type f -exec sed -i 's/numindruns=100/numindruns=50/g' "{}" \; 
find . -name "*.sh" -type f -exec sed -i 's/app.save_pop=0/app.save_pop=0/g' "{}" \; 
find . -name "*.sh" -type f -exec grep -nH "app.save_pop=" "{}" \; | sort -r

