#!/bin/sh
RUN=GEFS
APP=S2S
dir1=${NPB_WORKDIR}/RUNS/UFS/run_${RUN}-${APP}_12HOUR
dir2=${NPB_WORKDIR}/RUNS/UFS/run_${RUN}-${APP}_LAST9HOUR
files='sfcf012.nc atmf012.nc'
for f in ${files}; do
    echo ${f}
    diff ${dir1}/${f} ${dir2}/${f}
    echo ""
    echo ""
done
