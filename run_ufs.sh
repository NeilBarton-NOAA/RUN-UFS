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
#export RUN=SFS && export DTG=2024123100 && export APP=S2S

#export RUN=SFS && export DTG=2024081500
#export TOP_ICDIR=${NPB_WORKDIR}/ICs/GFS_TEST && export MOM6_INTERP_ICS=F && export TEST_NAME=GFS_TEST
#export ATM_RES=C192 && export OCN_RES=025  && export APP=S2S

#export RUN=GEFS && export DTG=2025042206
#export TOP_ICDIR=${NPB_WORKDIR}/ICs/GFS_TEST && export MOM6_INTERP_ICS=F && export TEST_NAME=GFS_IAU_TEST
#export ATM_RES=C384 && export OCN_RES=025  && export APP=S2S && OFFSET_START_HOUR=3 
#export DA_INCREMENTS=T

#export RUN=GEFS && export DTG=2025042206
#export TOP_ICDIR=${NPB_WORKDIR}/ICs/GFS_TEST && export MOM6_INTERP_ICS=F && export TEST_NAME=GFS_TEST
#export ATM_RES=C384 && export OCN_RES=025  && export APP=S2S && OFFSET_START_HOUR=3 
#export DA_INCREMENTS=F

#export RUN=GEFS && export DTG=2024081500
#export TOP_ICDIR=${NPB_WORKDIR}/ICs/GFS_TEST && export MOM6_INTERP_ICS=F && export TEST_NAME=GFS_TEST
#export ATM_RES=C384 && export OCN_RES=025  && export APP=S2S && OFFSET_START_HOUR=3 

#export RUN=SFS && export DTG=2018010400
#export TOP_ICDIR=${NPB_WORKDIR}/ICs/REPLAY && export MOM6_INTERP_ICS=F && export RESTART_FREQ=3 && export TEST_NAME=WAV_IC
#export ATM_RES=C192 && export OCN_RES=025 && export WAV_RES=glo_025 && export OFFSET_START_HOUR=3 && export APP=S2SW
#export WAVIC_NC=F

#export RUN=GEFS && export DTG=2018010500
#export TOP_ICDIR=${NPB_WORKDIR}/ICs/HR4 && export OFFSET_START_HOUR=0 && export TEST_NAME=WAV_TEST
#export ICDIR=${NPB_WORKDIR}/RUNS/UFS/run_GEFS-S2SW-C384mx025_WAV_IC

export RUN=SFS && export DTG=2018010500 && export APP=S2SW
export ATM_RES=C192 && export OCN_RES=025 && export WAV_RES=glo_025 
export TOP_ICDIR=${NPB_WORKDIR}/ICs/REPLAY && export MOM6_INTERP_ICS=F && export TEST_NAME=WAV_TEST
export WAVIC_NC=T

#export TOP_ICDIR=${NPB_WORKDIR}/ICs/CPC && export MOM6_INTERP_ICS=T && export TEST_NAME=CPC && export NSST='2,1,0,0,0'
#export TOP_ICDIR=${NPB_WORKDIR}/ICs/CPC && export MOM6_INTERP_ICS=T && export TEST_NAME=TEST_LAYOUT && export NSST='2,1,0,0,0'
#export TOP_ICDIR=${NPB_WORKDIR}/ICs/REPLAY && export MOM6_INTERP_ICS=F && export TEST_NAME=REPLAY
#export PPN=144

export JOB_QUEUE=normal # batch or debug on hera, normal or windfall on gaea
export DEBUG_SCRIPTS=${1:-F}
export RUNDIR_UNIQUE=F

#export ATM_INPES=4
#export ATM_JNPES=6
#export ATM_THRD=4
#export ATM_WPG=24
#export OCN_NMPI=120
#export ICE_NMPI=48
#export WAV_NMPI=240

############
# model updates
#export FORECAST_LENGTH=24 && export WALLCLOCK=30 # in minutes
export FORECAST_LENGTH=15 && export WALLCLOCK=10 # in minutes
#export FORECAST_LENGTH=$(( 150 * 24 )) && export WALLCLOCK=600 # in minutes
#export FORECAST_LENGTH=$(( 31 * 24 * 8 )) && export WALLCLOCK=$(( 18 * 60 )) # in minutes
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


