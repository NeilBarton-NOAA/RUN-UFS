#!/bin/sh
########################################################################
# Run UFS model outside of workflow and slightly following RT testing, but with more flexibility
# https://ufs-weather-model.readthedocs.io/en/ufs-v2.0.0/
# C96 (~100 km), C192 (~50 km), C384 (25 km), C768 (~13 km), C1152 (~9km)
# Default SFS configuration
####################################
# Set Top options
#export DTG=2018082000
#export RUN=GEFS
export DTG=1994050100
#export DTG=2021050100
export RUN=SFS
export ENS_SETTINGS=F
export FORECAST_LENGTH=240 #$(( 31 * 24 * 4 )) # in hours
export WALLCLOCK=30 #$(( 3 * 60 )) # in minutes
export JOB_QUEUE=debug # batch or debug on hera
export DEBUG=F

#export ATM_INPES=8 
#export ATM_JNPES=8 
        
############
# Submit Forecast
TOPDIR=${PWD}
export HOMEufs=${TOPDIR}/UFS
export SCRIPT_DIR=${TOPDIR}/SCRIPTS
${SCRIPT_DIR}/UFS-submit.sh 


