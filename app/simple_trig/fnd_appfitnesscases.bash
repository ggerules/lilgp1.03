#!/bin/bash
find . -name "appdef.h" -exec grep -nH APP_FITNESS_CASES "{}" \; | grep trig | sort -r
