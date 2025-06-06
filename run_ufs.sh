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
#export RUN=SFS && export DTG=1994050100 && export APP=S2S
#export ATM_RES=C192 && export OCN_RES=025 && export WAV_RES=glo_025 
# Default GEFS is using replay ICs at an +3 OFFSET at C384mx025
export RUN=GEFS && export DTG=2018010800
#export TOP_ICDIR=${NPB_WORKDIR}/ICs/REPLAY && export MOM6_INTERP_ICS=F && export TEST_NAME=REPLAY
#export TOP_ICDIR=${NPB_WORKDIR}/ICs/CPC && export MOM6_INTERP_ICS=T && export TEST_NAME=CPC && export NSST='2,1,0,0,0'

export JOB_QUEUE=normal # batch or debug on hera, normal or windfall on gaea
export DEBUG_SCRIPTS=${1:-F}
export RUNDIR_UNIQUE=F

#export ATM_INPES=8
#export ATM_JNPES=12
#export ATM_THRD=2
#export ATM_WPG=24
#export OCN_NMPI=220
#export ICE_NMPI=96
#export WAV_NMPI=100

############
# model updates
export FORECAST_LENGTH=6 && export WALLCLOCK=10 # in minutes
#export FORECAST_LENGTH=$(( 31 * 24 * 12 )) && export WALLCLOCK=$(( 18 * 60 )) # in minutes
export ENS_SETTINGS=T
export DA_INCREMENTS=F
export ENS_RESTART=F
export USE_ATM_PERTURB_FILES=T 
export USE_OCN_PERTURB_FILES=T 

############
# Submit Forecast
TOPDIR=${PWD}
export HOMEufs=${TOPDIR}/UFS
export SCRIPT_DIR=${TOPDIR}/SCRIPTS
${SCRIPT_DIR}/UFS-submit.sh 


