#!/bin/sh
########################################################################
# Run UFS model outside of workflow and slightly following RT testing, but with more flexibility
# https://ufs-weather-model.readthedocs.io/en/ufs-v2.0.0/
# C96 (~100 km), C192 (~50 km), C384 (25 km), C768 (~13 km), C1152 (~9km)
# Default SFS configuration
####################################
# Set Top options
#export DTG=2021050100
export DTG=2018082000
export RUN=GEFS
export FORECAST_LENGTH=6 #$(( 31 * 4 * 24 )) # in hours
export WALLCLOCK=30 # in minutes
export JOB_QUEUE=debug # batch or debug on hera
export ENS_SETTINGS=F
export DEBUG=F
        
############
# Submit Forecast
TOPDIR=${PWD}
export HOMEufs=${TOPDIR}/UFS
export SCRIPT_DIR=${TOPDIR}/SCRIPTS
${SCRIPT_DIR}/UFS-submit.sh 


