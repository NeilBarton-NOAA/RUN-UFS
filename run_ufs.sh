#!/bin/sh
set -u
########################################################################
# Run UFS model outside of workflow and slightly following RT testing, but with more flexibility
# https://ufs-weather-model.readthedocs.io/en/ufs-v2.0.0/
# C96 (~100 km), C192 (~50 km), C384 (25 km), C768 (~13 km), C1152 (~9km)
# Default SFS configuration
####################################
# Set Top options
export DEBUG_SCRIPTS=${1:-F}
export RUNDIR_UNIQUE=F
export RUN=SFS && export DTG=1991090100 && export ATM_RES=C192 && export SFS_ICS=T && export MOM6_INTERP_ICS=T

####################################
# MPI Options
#export ATM_INPES=8
#export ATM_JNPES=8
#export ATM_THRD=2
#export ATM_WPG=24
#export OCN_NMPI=400
#export ICE_NMPI=96
#export WAV_NMPI=240

############
# model updates
export FORECAST_LENGTH=300 && export WALLCLOCK=120 #minutes 
export FORECAST_LENGTH=3 && export WALLCLOCK=10 && export JOB_QUEUE=debug 
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


