#!/bin/sh
set -u
########################################################################
# Run UFS model outside of workflow and slightly following RT testing, but with more flexibility
# https://ufs-weather-model.readthedocs.io/en/ufs-v2.0.0/
# C96 (~100 km), C192 (~50 km), C384 (25 km), C768 (~13 km), C1152 (~9km)
# Default SFS configuration
####################################
# Set Top options
#export DTG=1994050100 && export RUN=SFS

export APP=S2SWA
export RUN=GEFS
#export DTG=2021032506
export DTG=2018041900
export ENS_SETTINGS=T

FIRST_RUN=T
if [[ ${FIRST_RUN} == T ]]; then
    export TEST_NAME=${RUN}-${APP}_12HOUR
    #export ICDIR=${NPB_WORKDIR}/ICs/${DTG} 
    export ICDIR=${NPB_WORKDIR}/ICs/REPLAY_ICs/C384mx025/${DTG}/mem001
    export OFFSET_START_HOUR=3
    export DA_INCREMENTS=F
    export ENS_RESTART=F
    export USE_ATM_PERTURB_FILES=T 
    export USE_OCN_PERTURB_FILES=T 
else
    export OFFSET_START_HOUR=6
    export TEST_NAME=${RUN}-${APP}_LAST${OFFSET_START_HOUR}HOUR  
    export ICDIR=${NPB_WORKDIR}/RUNS/UFS/run_${RUN}-${APP}_12HOUR #/RESTART 
    export ENS_RESTART=T
    export DA_INCREMENTS=F
    export USE_ATM_PERTURB_FILES=F 
    export USE_OCN_PERTURB_FILES=F
fi

export FORECAST_LENGTH=12 #$(( 31 * 24 * 4 )) # in hours
export WALLCLOCK=20 #$(( 3 * 60 )) # in minutes
export JOB_QUEUE=debug #batch # batch or debug on hera
export DEBUG=F
export RUNDIR_UNIQUE=F

############
# Submit Forecast
TOPDIR=${PWD}
export HOMEufs=${TOPDIR}/UFS
export SCRIPT_DIR=${TOPDIR}/SCRIPTS
${SCRIPT_DIR}/UFS-submit.sh 


