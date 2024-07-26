#!/bin/sh
########################################################################
# Run UFS model outside of workflow and slightly following RT testing, but with more flexibility
# https://ufs-weather-model.readthedocs.io/en/ufs-v2.0.0/
# C96 (~100 km), C192 (~50 km), C384 (25 km), C768 (~13 km), C1152 (~9km)
# Default SFS configuration
####################################
# Set Top options
export DTG=2023012300
export RUN=SFS
export APP=S2SWA
export FORECAST_LENGTH=1 # in days
export WALLCLOCK=30 #$(( 2 * 60 )) # in minutes
export JOB_QUEUE=debug # batch or debug on hera
export ICDIR=${NPB_WORKDIR}/ICs/REPLAY_ICs/CI/${DTG}/mem000
export REPLAY_ICS=T
export ENS_SETTINGS=F
export DEBUG=F

############
# Submit Forecast
TOPDIR=${PWD}
export HOMEufs=${TOPDIR}/UFS
export SCRIPT_DIR=${TOPDIR}/SCRIPTS
${SCRIPT_DIR}/UFS-submit.sh 


