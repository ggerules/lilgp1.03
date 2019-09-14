#!/bin/bash
#find . -maxdepth 1 -name "*bofr*.pdf" -exec cp -v "{}" ../dissertation/tables/ \;
find . -maxdepth 1 -name "*bofr*.tex" -exec cp -v "{}" ../dissertation/tables/ \;
