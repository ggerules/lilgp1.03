#!/bin/bash
#create data
./run_simple_trig_orig.bash
./run_simple_trig_cgp2p1.bash
./run_simple_trig_acgp1p1p2.bash

#make long data file
cd ./data
./mkHitsLong.bash
cd ..

#run stats
./stats_v1_simple_trig.bash


