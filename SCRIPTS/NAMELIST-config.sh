#!/bin/bash
set -u
[[ ${DEBUG} == T ]] && set -x
declare -rx PS4='+ $(basename ${BASH_SOURCE[0]:-${FUNCNAME[0]:-"Unknown"}})[${LINENO}]'

source ${PATHRT}/atparse.bash
source ${PATHRT}/rt_utils.sh

source ${SCRIPT_DIR}/FV3-namelist.sh
source ${SCRIPT_DIR}/MOM6-namelist.sh
source ${SCRIPT_DIR}/CICE-namelist.sh
source ${SCRIPT_DIR}/CMEPS-namelist.sh
[[ ${APP} == *A* ]] && source ${SCRIPT_DIR}/GOCART-namelist.sh 
[[ ${APP} == *W* ]] && source ${SCRIPT_DIR}/WW3-namelist.sh 

############
# create job card
source ${SCRIPT_DIR}/JOB-config.sh

