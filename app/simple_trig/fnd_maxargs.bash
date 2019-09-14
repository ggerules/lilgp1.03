#!/bin/bash
find . -name "*.h" -type f -exec grep -nH "#define MAXARGS" "{}" \; | sort -r

