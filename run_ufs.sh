#!/bin/sh
########################################################################
# Run UFS model outside of workflow and slightly following RT testing, but with more flexibility
# https://ufs-weather-model.readthedocs.io/en/ufs-v2.0.0/
# C96 (~100 km), C192 (~50 km), C384 (25 km), C768 (~13 km), C1152 (~9km)
# Default SFS configuration
####################################
# Set Top options
#export DTG=1994050100 && export RUN=SFS
export DTG=2018041900 && export RUN=GEFS && export APP=S2SW
export ENS_SETTINGS=F
export FORECAST_LENGTH=6 #$(( 31 * 24 * 4 )) # in hours
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


