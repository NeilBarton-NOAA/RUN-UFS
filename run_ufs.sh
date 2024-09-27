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

export APP=S2S #WA
export RUN=GEFS
export DTG=2021032506
export ENS_SETTINGS=T
export ENS_RESTART=T
export USE_ATM_PERTURB_FILES=F 
export USE_OCN_PERTURB_FILES=F 

FIRST_RUN=F
if [[ ${FIRST_RUN} == T ]]; then
    export TEST_NAME=${RUN}-${APP}_12HOUR
    export ICDIR=${NPB_WORKDIR}/ICs/${DTG} 
    export OFFSET_START_HOUR=0
    export DA_INCREMENTS=T
else
    export TEST_NAME=${RUN}-${APP}_LAST6HOUR  
    export ICDIR=${NPB_WORKDIR}/RUNS/UFS/run_${RUN}-${APP}_12HOUR/RESTART 
    export OFFSET_START_HOUR=6 

fi

export FORECAST_LENGTH=12 #$(( 31 * 24 * 4 )) # in hours
export WALLCLOCK=15 #$(( 3 * 60 )) # in minutes
export JOB_QUEUE=debug #batch # batch or debug on hera
export DEBUG=F
export RUNDIR_UNIQUE=F

############
# Submit Forecast
TOPDIR=${PWD}
export HOMEufs=${TOPDIR}/UFS
export SCRIPT_DIR=${TOPDIR}/SCRIPTS
${SCRIPT_DIR}/UFS-submit.sh 


