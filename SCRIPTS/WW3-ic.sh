#!/bin/bash
echo 'WW3-ic.sh'
####################################
rm -f ufs.cpld.ww3.r.*
rm -f restart.ww3
WAVIC_NC=${WAVIC_NC:-F}
SUFFIX=""
[[ ${WAVIC_NC} == T ]] && SUFFIX=".nc"

####################################
# look for restarts if provided
ICDIR=${ICDIR:-${INPUTDATA_ROOT_BMIC}/${SYEAR}${SMONTH}${SDAY}${SHOUR}/wav_p8c}
wav_ic=$( find -L ${ICDIR} -name "ufs.cpld.ww3.r.${SYEAR}-${SMONTH}-${SDAY}-${SECS}${SUFFIX}" )
if [[ ! -f ${wav_ic} ]]; then
    wav_ic=$( find -L ${ICDIR} -name "${RESTART_DTG}.restart.ww3${SUFFIX}" )
    if [[ ! -f ${wav_ic} ]]; then
        wav_ic=$( find -L ${ICDIR} -name "${RESTART_DTG}.restart.${WAV_RES}${SUFFIX}" )
    fi
    if [[ ! -f ${wav_ic} ]]; then
        wav_ic=$( find -L ${ICDIR} -name "*restart*.ww3*${SUFFIX}" )
    fi
fi

if [[ ! -f ${wav_ic} ]]; then
    echo "  WAV IC not found, waves will cold start"
else
    ln -sf ${wav_ic} ufs.cpld.ww3.r.${RESTART_DTG_ALT}${SUFFIX}
    #ln -sf ${wav_ic} restart.ww3
fi
