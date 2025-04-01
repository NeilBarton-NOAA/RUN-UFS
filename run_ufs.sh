#!/bin/sh
set -u
########################################################################
# Run UFS model outside of workflow and slightly following RT testing, but with more flexibility
# https://ufs-weather-model.readthedocs.io/en/ufs-v2.0.0/
# C96 (~100 km), C192 (~50 km), C384 (25 km), C768 (~13 km), C1152 (~9km)
# Default SFS configuration
####################################
# Set Top options
# Default SFS is using replay ICs with interpolated MOM6 ICs at C96mx100 
export RUN=SFS && export DTG=1994050100 && export APP=S2S
# Default GEFS is using replay ICs at an +3 OFFSET at C384mx025
#export RUN=GEFS && export DTG=2018010800 && export APP=S2SW

export JOB_QUEUE=windfall # batch or debug on hera, windfall on gaea
export DEBUG_SCRIPTS=${1:-F}
export RUNDIR_UNIQUE=F

############
# model updates
export FORECAST_LENGTH=6 #$(( 31 * 24 * 4 )) # in hours
export WALLCLOCK=5 #$(( 3 * 60 )) # in minutes
export ENS_SETTINGS=F
export DA_INCREMENTS=F
export ENS_RESTART=F
export USE_ATM_PERTURB_FILES=F 
export USE_OCN_PERTURB_FILES=F 

############
# Submit Forecast
TOPDIR=${PWD}
export HOMEufs=${TOPDIR}/UFS
export SCRIPT_DIR=${TOPDIR}/SCRIPTS
${SCRIPT_DIR}/UFS-submit.sh 


