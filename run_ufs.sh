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
# Default GEFS is using replay ICs at an +3 OFFSET at C384mx025
export RUN=SFS && export DTG=1994050100 && export APP=S2S
#export RUN=SFS && export DTG=1994050100 && export APP=S2S && export ATM_RES=C192
export DEBUG_SCRIPTS=${1:-F}
export RUNDIR_UNIQUE=T
#export JOB_QUEUE=normal # batch or debug on hera, normal or windfall on gaea

############
# MPI Options
export ATM_INPES=3
export ATM_JNPES=6
#export ATM_THRD=4
#export ATM_WPG=24
export OCN_NMPI=150
export ICE_NMPI=36
#export WAV_NMPI=240

############
# model updates
export FORECAST_LENGTH=120 && export WALLCLOCK=90 #minutes
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


