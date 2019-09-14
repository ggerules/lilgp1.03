#!/bin/bash
rm -fR ./acgp1p1p2_simple_trig_no_adf_qt.txt
cp -vR ./acgp1p1p2_simple_trig_no_adf_qt_no_cons.txt ./acgp1p1p2_simple_trig_no_adf_qt.txt
pop=500
echo "pop=$pop"
./r0 $pop
./r1 $pop
./r2 $pop
./r3 $pop
