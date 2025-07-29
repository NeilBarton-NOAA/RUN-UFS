#!/bin/bash
set -u
[[ ${DEBUG_SCRIPTS} == T ]] && set -x
declare -rx PS4='+ $(basename ${BASH_SOURCE[0]:-${FUNCNAME[0]:-"Unknown"}})[${LINENO}]'
# source defaults
source ${PATHRT}/atparse.bash
source ${PATHRT}/rt_utils.sh
source ${SCRIPT_DIR}/RUN-config.sh
OFFSET_START_HOUR=${OFFSET_START_HOUR:-0} # Replay ICs with +3 start
STG=${DTG}
if (( ${OFFSET_START_HOUR} != 0 )); then
    STG=$(date -u -d"${SYEAR}-${SMONTH}-${SDAY} ${DTG:8:2}:00:00 ${OFFSET_START_HOUR} hours" +%Y%m%d%H)
fi
START_SECS=$( printf "%05d" $(( 10#${STG:8:2} * 3600 )) )
# source namelists
source ${SCRIPT_DIR}/FV3-namelist.sh
if [[ ${APP} != ATM ]]; then
    source ${SCRIPT_DIR}/MOM6-namelist.sh
    source ${SCRIPT_DIR}/CICE-namelist.sh
    [[ ${APP} == *A* ]] && source ${SCRIPT_DIR}/GOCART-namelist.sh 
    [[ ${APP} == *W* ]] && source ${SCRIPT_DIR}/WW3-namelist.sh 
fi
source ${SCRIPT_DIR}/CMEPS-namelist.sh

############
# create job card
source ${SCRIPT_DIR}/JOB-config.sh

