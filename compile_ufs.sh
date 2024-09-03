#!/bin/sh
set -u
# Defaults to Compile the SFS configuration, but could be changed
# examine the UFS/tests/rt.conf for COMPILE options for specific configurations
export RUN=SFS
TOPDIR=${PWD}

export SCRIPT_DIR=${TOPDIR}/SCRIPTS
source ${TOPDIR}/SCRIPTS/RUN-config.sh 
####################################
# get submodules
cd ${TOPDIR}/UFS
[[ ! -d ${TOPDIR}/UFS/CICE-interface/CICE/cicecore ]] && git submodule update --init --recursive

####################################
# build model
source ${TOPDIR}/UFS/tests/detect_machine.sh
module_file=ufs_${MACHINE_ID}.${RT_COMPILER}
module purge
[[ ${module_file} == *wcoss* ]] && module reset
module use modulefiles
module load ${module_file}

####################################
# get compile options for rt.conf
line=$( grep ${compile_search} ${TOPDIR}/UFS/tests/rt.conf | grep COMPILE | head -n 1 )
MAKE_OPT=$(cut -d '|' -f4  <<< "${line}")
MAKE_OPT=$(sed -e 's/^ *//' -e 's/ *$//' <<< "${MAKE_OPT}")
# APP
OPT="APP="
APP=${APP:-$( echo ${MAKE_OPT#*${OPT}} | cut -d ' ' -f1 )}
# RUN FV3 with 32 BIT or 64 BIT
OPT="32BIT=" 
if [[ ${MAKE_OPT} == *${OPT}* ]]; then
    BIT32=${BIT32:-$( echo ${MAKE_OPT#*${OPT}} | cut -d ' ' -f1 )}
else
    BIT32=${BIT32:-"OFF"}
fi
# ATM Hydrostatic mode turned on or off
OPT="DHYDRO=" 
if [[ ${MAKE_OPT} == *${OPT}* ]]; then
    HYDRO=${HYDRO:-$( echo ${MAKE_OPT#*${OPT}} | cut -d ' ' -f1 )}
else
    HYDRO=${HYDRO:-"OFF"}
fi
# CCPP suites options to compile 
OPT="DCCPP_SUITES="
CCPP_SUITES=${CCPP_SUITES:-$( echo ${MAKE_OPT#*${OPT}} | cut -d ' ' -f1 )}
# WAVE unstructured grid (PDLIB=ON) or structured grid (PDLIB=OFF)
OPT="PDLIB=" 
if [[ ${MAKE_OPT} == *${OPT}* ]]; then 
    PDLIB=${PDLIB:-$( echo ${MAKE_OPT#*${OPT}} | cut -d ' ' -f1 )}
else
    PDLIB=${PDLIB:-"OFF"}
fi

####################################
# compile
export CMAKE_FLAGS="-DAPP=${APP} -D32BIT=${BIT32} -DCCPP_SUITES=${CCPP_SUITES} -DHYDRO=${HYDRO} -DPDLIB=${PDLIB}"
echo "${RUN}: ${CMAKE_FLAGS}"
#[[ -d build ]] && rm -r build/
bash -x ./build.sh
mkdir -p ${TOPDIR}/bin
cp build/ufs_model ${TOPDIR}/bin/ufs_${RUN}
ls -ltr ${TOPDIR}/bin/*
echo "${RUN}: ${CMAKE_FLAGS}"

