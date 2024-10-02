#!/bin/bash
set -u
[[ ${DEBUG} == T ]] && set -x
declare -rx PS4='+ $(basename ${BASH_SOURCE[0]:-${FUNCNAME[0]:-"Unknown"}})[${LINENO}]'

source ${SCRIPT_DIR}/RUN-config.sh
        
# Replay ICs with +3 start
OFFSET_START_HOUR=${OFFSET_START_HOUR:-0}
if (( ${OFFSET_START_HOUR} != 0 )); then
    STG=$(date -u -d"${SYEAR}-${SMONTH}-${SDAY} ${DTG:8:2}:00:00 ${OFFSET_START_HOUR} hours" +%Y%m%d%H)
    START_SECS=$( printf "%05d" $(( 10#${STG:8:2} * 3600 )) )
fi
RESTART_DTG=${STG:0:8}.${STG:8:2}0000
RESTART_DTG_ALT=${SYEAR}-${SMONTH}-${SDAY}-${START_SECS}
# Call IC file 
source ${SCRIPT_DIR}/FV3-ic.sh
source ${SCRIPT_DIR}/MOM6-ic.sh
source ${SCRIPT_DIR}/CICE-ic.sh
if [[ ${APP} == *W* ]]; then
    source ${SCRIPT_DIR}/WW3-ic.sh 
fi
source ${SCRIPT_DIR}/CMEPS-ic.sh

if [[ ${ENS_RESTART:-F} == T ]]; then
    ln -sf ${ICDIR}/${RESTART_DTG}.ocn_stoch.res.nc INPUT/ocn_stoch.res.nc
    ln -sf ${ICDIR}/${RESTART_DTG}.atm_stoch.res.nc INPUT/atm_stoch.res.nc
fi
