#!/bin/bash
sed -i 's/leftcount > 5000/leftcount > 2600/g' info.def
sed -i 's/movecount > 5000/movecount > 2600/g' info.def
cat info.def | grep leftcount
cat info.def | grep movecount
