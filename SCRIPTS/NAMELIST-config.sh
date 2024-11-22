#!/bin/bash
set -u
[[ ${DEBUG_SCRIPTS} == T ]] && set -x
declare -rx PS4='+ $(basename ${BASH_SOURCE[0]:-${FUNCNAME[0]:-"Unknown"}})[${LINENO}]'

source ${PATHRT}/atparse.bash
source ${PATHRT}/rt_utils.sh
source ${SCRIPT_DIR}/RUN-config.sh
# Replay ICs with +3 start
OFFSET_START_HOUR=${OFFSET_START_HOUR:-0}
#if (( ${OFFSET_START_HOUR} != 0 )); then
#    export SHOUR=$( printf "%02d" $(( ${DTG:8:2} + ${OFFSET_START_HOUR} )) )
#    export SECS=$( printf "%05d" $(( $SHOUR * 3600 )) )
#fi
#RESTART_DTG=${DTG:0:8}.${SHOUR}0000
#RESTART_DTG_ALT=${SYEAR}-${SMONTH}-${SDAY}-$(( ${SHOUR} * 3600 ))

[[ ${ENS_SETTINGS} == T ]] && source ${SCRIPT_DIR}/ENSEMBLE-config.sh
source ${SCRIPT_DIR}/FV3-namelist.sh
source ${SCRIPT_DIR}/MOM6-namelist.sh
source ${SCRIPT_DIR}/CICE-namelist.sh
[[ ${APP} == *A* ]] && source ${SCRIPT_DIR}/GOCART-namelist.sh 
[[ ${APP} == *W* ]] && source ${SCRIPT_DIR}/WW3-namelist.sh 
source ${SCRIPT_DIR}/CMEPS-namelist.sh

############
# create job card
source ${SCRIPT_DIR}/JOB-config.sh

