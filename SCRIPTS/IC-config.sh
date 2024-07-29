#!/bin/bash
set -u
[[ ${DEBUG} == T ]] && set -x
declare -rx PS4='+ $(basename ${BASH_SOURCE[0]:-${FUNCNAME[0]:-"Unknown"}})[${LINENO}]'
# Call IC file 
source ${SCRIPT_DIR}/FV3-ic.sh
source ${SCRIPT_DIR}/MOM6-ic.sh
source ${SCRIPT_DIR}/CICE-ic.sh
source ${SCRIPT_DIR}/CMEPS-ic.sh
if [[ ${APP} == *W* ]]; then
    source ${SCRIPT_DIR}/WW3-ic.sh 
fi
