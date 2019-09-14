#!/bin/bash
rm -fR ./tables/*
./run_reports_bofrs.r
./run_reports_bofrs_shapiro_testofnorm.r
./run_reports_evaltime.r
./run_reports_runparams0.r
#./run_reports_runparams1.r
./run_reports_wallclocktime.r
./run_reports_wilcox_stats.r
./run_reports_hyp.r
./run_reports_gr_hyp.r
./run_reports_stt.r
rsync -avt  ./tables/ ../dissertation/tables/

