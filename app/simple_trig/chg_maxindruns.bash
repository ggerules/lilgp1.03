#!/bin/bash
#find . -name "*.sh" -type f -exec sed -i 's/numindruns=100/numindruns=50/g' "{}" \; 
find . -name "*.sh" -type f -exec sed -i 's/numindruns=50/numindruns=100/g' "{}" \; 
find . -name "*.sh" -type f -exec grep -nH "numindruns=" "{}" \; | sort -r

