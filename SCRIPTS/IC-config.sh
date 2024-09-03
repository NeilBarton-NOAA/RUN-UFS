#!/bin/bash
set -u
[[ ${DEBUG} == T ]] && set -x
declare -rx PS4='+ $(basename ${BASH_SOURCE[0]:-${FUNCNAME[0]:-"Unknown"}})[${LINENO}]'
        
# Replay ICs with +3 start
OFFSET_START_HOUR=${OFFSET_START_HOUR:-0}
if (( ${OFFSET_START_HOUR} != 0 )); then
    export SHOUR=$( printf "%02d" $(( ${DTG:8:2} + ${OFFSET_START_HOUR} )) )
    export SECS=$( printf "%05d" $(( $SHOUR * 3600 )) )
fi
[[ ${ENS_SETTINGS} == T ]] && source ${SCRIPT_DIR}/ENSEMBLE-config.sh
# Call IC file 
source ${SCRIPT_DIR}/FV3-ic.sh
source ${SCRIPT_DIR}/MOM6-ic.sh
source ${SCRIPT_DIR}/CICE-ic.sh
source ${SCRIPT_DIR}/CMEPS-ic.sh
if [[ ${APP} == *W* ]]; then
    source ${SCRIPT_DIR}/WW3-ic.sh 
fi
