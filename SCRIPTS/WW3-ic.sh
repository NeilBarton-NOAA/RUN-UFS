#!/bin/bash
echo 'WW3-ic.sh'
####################################
rm -f ufs.cpld.ww3.r.*
rm -f restart.ww3

####################################
# look for restarts if provided
ICDIR=${ICDIR:-${INPUTDATA_ROOT_BMIC}/${SYEAR}${SMONTH}${SDAY}${SHOUR}/wav_p8c}
wav_ic=$( find -L ${ICDIR} -name "${RESTART_DTG}.restart.${WAV_RES}" )

if [[ ! -f ${wav_ic} ]]; then
    echo "  WARNING: wav IC with resolution suffix not found, looking for a restart without suffix"
    wav_ic=$( find -L ${ICDIR} -name "${RESTART_DTG}.restart.ww3" )
    if [[ ! -f ${wav_ic} ]]; then
        wav_ic=$( find -L ${ICDIR} -name "*restart*.ww3*" )
    fi
fi

if [[ ! -f ${wav_ic} ]]; then
    echo "  WAV IC not found, waves will cold start"
else
    #ln -sf ${wav_ic} ufs.cpld.ww3.r.${SYEAR}-${SMONTH}-${SDAY}-${SECS}
    ln -sf ${wav_ic} restart.ww3
fi
