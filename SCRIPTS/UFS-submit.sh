#!/bin/bash
set -u
DEBUG=${DEBUG:-F}
[[ ${DEBUG} == T ]] && set -x
declare -rx PS4='+ $(basename ${BASH_SOURCE[0]:-${FUNCNAME[0]:-"Unknown"}})[${LINENO}]'

################################################
# submit UFS weather model largely folling RTs, but with more flexability 
#   default is to run the S2SWA using the RT defaults
#   TODOS:
#       - link needed data instead of running ./fv3_run
#       - not sure if field table in FV3-config.sh is needed
################################################
# defaults
source ${SCRIPT_DIR}/RUN-config.sh
# tools
export PATHRT=${HOMEufs}/tests
# machine specific directories
source ${PATHRT}/detect_machine.sh
rm ${SCRIPT_DIR}/MACHINE-config.sh
if [[ ! -f ${SCRIPT_DIR}/MACHINE-config.sh ]]; then
    rt_f=${PATHRT}/rt.sh
    target_f=${SCRIPT_DIR}/MACHINE-config.sh
cat << EOF > ${target_f}
#!/bin/bash -u
# machine specific items grab from the rt.sh file
if [[ ${MACHINE_ID} == wcoss2 ]]; then
    export ACCNR=${ACCNR:-GFS-DEV}
else
    export ACCNR=${ACCNR:-marine-cpu}
fi
EOF
    ln_start=$(grep -n 'case ${MACHINE_ID}' ${rt_f} | head -n 1 | cut -d: -f1)
    ln_end=$(grep -n 'esac' ${rt_f} | head -n 2 | tail -n 1 | cut -d: -f1)
    ln_extra=$(( ln_end + 1 ))
    sed -n "${ln_start},${ln_end}p;${ln_extra}q" ${rt_f} >> ${target_f}
    grep INPUTDATA ${rt_f} | grep -v ENTITY >> ${target_f}
    chmod 755 ${target_f}
fi
source ${target_f}
export MACHINE_ID SCHEDULER STMP

# variables
source ${PATHRT}/default_vars.sh
source ${PATHRT}/tests/${RT_TEST}

############
# edits to defaults if needed
# forecast length
FL=${FORECAST_LENGTH:-1}
FHMAX=$( echo "${FL} * 24" | bc )
FHMAX=${FHMAX%.*}
# start date
DTG=${DTG:-${SYEAR}${SMONTH}${SDAY}${SHOUR}00}
export SYEAR=${DTG:0:4}
export SMONTH=${DTG:4:2}
export SDAY=${DTG:6:2}
export SHOUR=${DTG:8:2}
export SECS=$( printf "%05d" $(( $SHOUR * 3600 )) )
REPLAY_ICS=${REPLAY_ICS:-F}
if [[ ${REPLAY_ICS} == T ]]; then
    export SHOUR=$( printf "%02d" $(( ${DTG:8:2} + 3 )) )
    export SECS=$( printf "%05d" $(( $SHOUR * 3600 )) )
fi

############
# Run Directory
RUNDIR=${STMP}/${USER}/UFS/run_$$
RUNDIR=${STMP}/${USER}/UFS/run_${RUN}-${APP}
[[ -d ${RUNDIR} ]] && rm -r ${RUNDIR}/*
mkdir -p ${RUNDIR} && mkdir -p ${RUNDIR}/INPUT && cd ${RUNDIR}
echo "RUNDIR is at ${RUNDIR}"

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

[[ ${DEBUG} == F ]] && ${SUBMIT} job_card
