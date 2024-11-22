#!/bin/bash
set -u
export DEBUG_SCRIPTS=${DEBUG_SCRIPTS:-F}
CYLC_RUN=${CYLC_RUN:-F}
MEM=${MEM:-0} && MEM=$( printf "%03d" ${MEM} )
[[ ${DEBUG_SCRIPTS} == T ]] && set -x
declare -rx PS4='+ $(basename ${BASH_SOURCE[0]:-${FUNCNAME[0]:-"Unknown"}})[${LINENO}]'

################################################
# submit UFS weather model largely folling RTs, but with more flexability 
#   default is to run the S2SWA using the RT defaults
#   TODOS:
#       - link needed data instead of running ./fv3_run
#       - not sure if field table in FV3-config.sh is needed
################################################
# machine specific items
export PATHRT=${HOMEufs}/tests
# machine specific directories
source ${SCRIPT_DIR}/MACHINE-config.sh ${HOMEufs}

# defaults
source ${SCRIPT_DIR}/RUN-config.sh

# variables
source ${PATHRT}/default_vars.sh
source ${PATHRT}/tests/${RT_TEST}

############
# edits to defaults if needed
# forecast length
FORECAST_LENGTH=${FORECAST_LENGTH:-6}
FHMAX=${FORECAST_LENGTH}
# start date
DTG=${DTG:-${SYEAR}${SMONTH}${SDAY}${SHOUR}00}
export SYEAR=${DTG:0:4}
export SMONTH=${DTG:4:2}
export SDAY=${DTG:6:2}
export SHOUR=${DTG:8:2}
export SECS=$( printf "%05d" $(( 10#${SHOUR} * 3600 )) )

############
# change in resolution
export ATMRES=${ATM_RES:-$ATMRES}
export OCNRES=${OCN_RES:-$OCNRES}
res=$( echo ${ATMRES} | cut -c2- )
export IMO=$(( ${res} * 4 ))
export JMO=$(( ${res} * 2 ))
export NPX=$(( ${res} + 1 ))
export NPY=$(( ${res} + 1 ))
export NPZ=${ATM_LEVELS:-127}
export NPZP=$(( NPZ + 1 ))
WW3_DOMAIN=${WAV_RES:-$WW3_DOMAIN}
export MESH_WAV=mesh.${WW3_DOMAIN}.nc
[[ ${APP} == *A* ]] && export CPLCHM=.true.
############
# Run Directory
if [[ ${CYLC_RUN} == T ]]; then
    if (( MEM > 0 )); then
        export ENS_SETTINGS=T
    else
        export ENS_SETTINGS=F
    fi
    export TEST_NAME=${TEST_NAME:-CYLC_${RUN}-${APP}}
    RUNDIR=${STMP}/${TEST_NAME}/${DTG}/mem${MEM}
else
    export TEST_NAME=${TEST_NAME:-${RUN}-${APP}}
    RUNDIR=${STMP}/UFS/run_${TEST_NAME}
    [[ ${RUNDIR_UNIQUE:-T} == T ]] &&  RUNDIR=${RUNDIR}_$$
    [[ -d ${RUNDIR} ]] && rm -r ${RUNDIR}/*
    [[ ${ENS_SETTINGS:-F} == T ]] && MEM=001
fi
mkdir -p ${RUNDIR} && mkdir -p ${RUNDIR}/INPUT && cd ${RUNDIR}
echo "RUNDIR is at ${RUNDIR}"

# Top variables for CONFIG scripts

export ICDIR=${ICDIR:-${TOP_ICDIR}/${ATM_RES}mx${OCN_RES}/*/*/mem${MEM}}
[[ ${CYLC_RUN} == T ]] && echo 'RUNNING IN CYCL ' && return

############
# Get Fix Files
${SCRIPT_DIR}/FIXFILES-config.sh ${APP}
if (( ${?} > 0 )); then
    echo "FAILED @ ${SCRIPT_DIR}/FIXFILES-config.sh ${APP}"
    exit 1
fi

############
# IC files
${SCRIPT_DIR}/IC-config.sh ${APP}
if (( ${?} > 0 )); then
    echo "FAILED @ ${SCRIPT_DIR}/IC-config.sh ${APP}"
    exit 1
fi

############
# Write Namelist Files
${SCRIPT_DIR}/NAMELIST-config.sh ${APP}
if (( ${?} > 0 )); then
    echo "FAILED @ ${SCRIPT_DIR}/NAMELIST-config.sh ${APP}"
    exit 1
fi

############
# execute model
echo 'RUNDIR: ' ${PWD}
case ${SCHEDULER} in
    "pbs")
        SUBMIT=qsub;;
    "slurm")
        SUBMIT=sbatch;;
esac

if [[ ${DEBUG_SCRIPTS} == F ]]; then
    ${SUBMIT} job_card
fi
