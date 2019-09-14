#!/bin/bash
cat ./out.txt | awk -F"1" '{print NF-1}'
