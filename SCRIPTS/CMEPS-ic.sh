#!/bin/bash
set -u
echo 'CMEPS-ic.sh'
########################
# ICs
ICDIR=${ICDIR}
if [[ ${WARM_START} == '.true.' ]]; then
    med_ic=${med_ic:-$( find ${ICDIR} -name "*ufs.cpld.cpl.r*.nc")}
    if [[ ! -f ${med_ic} ]]; then
        echo "  FATAL: ${med_ic} file not found"
        exit 1
    fi
    ln -sf ${med_ic} ufs.cpld.cpl.r.nc
    rm -f rpointer.cpl && touch rpointer.cpl
    echo "ufs.cpld.cpl.r.nc" >> "rpointer.cpl"
    RUNTYPE=continue
fi

