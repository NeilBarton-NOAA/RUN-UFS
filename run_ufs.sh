#!/bin/sh
########################################################################
# Run UFS model outside of workflow and slightly following RT testing, but with more flexibility
# https://ufs-weather-model.readthedocs.io/en/ufs-v2.0.0/
# C96 (~100 km), C192 (~50 km), C384 (25 km), C768 (~13 km), C1152 (~9km)
# Default SFS configuration
####################################
# Set Top options
#export DTG=1994050100 && export RUN=SFS

export APP=S2S #WA
export RUN=SFS && export DTG=1994050100 && export ATM_RES=C192 && export OCN_RES=025 && export OFFSET_START_HOUR=0

#export RUN=SFS && export DTG=2021050100
#export RUN=GEFS && export DTG=2018041900 
#export RUN=GEFS && export DTG=2021032506 && export ICDIR=/work/noaa/marine/nbarton/ICs/${DTG} && export OFFSET_START_HOUR=0

#export TEST_NAME=${RUN}_${APP}_12HOUR
#export OFFSET_START_HOUR=0 

#export TEST_NAME=${RUN}_${APP}_LAST6HOUR  
#export ICDIR=/work/noaa/marine/nbarton/RUNS/UFS/run_${RUN}_${APP}_12HOUR/RESTART 
#export OFFSET_START_HOUR=6 
#export USE_ATM_PERTURB_FILES=F && export USE_OCN_PERTURB_FILES=F 
#export MOM6_INTERP_ICS=F
#export ENS_RESTART=T

export FORECAST_LENGTH=12 #$(( 31 * 24 * 4 )) # in hours
export ENS_SETTINGS=F
export WALLCLOCK=5 #$(( 3 * 60 )) # in minutes
export JOB_QUEUE=batch #batch # batch or debug on hera
export DEBUG=F
export RUNDIR_UNIQUE=F

############
# Submit Forecast
TOPDIR=${PWD}
export HOMEufs=${TOPDIR}/UFS
export SCRIPT_DIR=${TOPDIR}/SCRIPTS
${SCRIPT_DIR}/UFS-submit.sh 


