#!/bin/bash
#find . -name "appdef.h" -exec sed -i 's/\/\/#define APP_FITNESS_CASES 23//g' "{}" \;
#find . -name "appdef.h" -exec sed -i 's/\/\/#define APP_FITNESS_CASES 55//g' "{}" \;
find . -name "appdef.h" -exec sed -i 's/#define APP_FITNESS_CASES 21/#define APP_FITNESS_CASES 20/g' "{}" \;
find . -name "appdef.h" -exec grep -nH APP_FITNESS_CASES "{}" \; | grep trig | sort -r
