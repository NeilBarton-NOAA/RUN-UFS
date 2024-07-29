#!/bin/bash
echo 'WW3-ic.sh'
####################################
# look for restarts if provided
ICDIR=${ICDIR:-${INPUTDATA_ROOT_BMIC}/${SYEAR}${SMONTH}${SDAY}${SHOUR}/wav_p8c}
wav_ic=$( find -L ${ICDIR} -name "${SYEAR}${SMONTH}${SDAY}.${SHOUR}0000.restart.${WAV_RES}" )

if [[ ! -f ${wav_ic} ]]; then
    echo "  WARNING: wav IC with RES not found, looking for a restart without RES defined"
    wav_ic=$( find -L ${ICDIR} -name "${SYEAR}${SMONTH}${SDAY}.${SHOUR}0000.restart*" )
    if [[ ! -f ${wav_ic} ]]; then
        wav_ic=$( find -L ${ICDIR} -name "*restart*.ww3*" )
    fi
fi

if [[ ! -f ${wav_ic} ]]; then
    echo "  WAV IC not found, waves will cold start"
else
    ln -sf ${wav_ic} ufs.cpld.ww3.r.${SYEAR}-${SMONTH}-${SDAY}-${SECS}
    ln -sf ${wav_ic} restart.ww3
fi
