#!/bin/bash
set -u
################################################################################################
# https://github.com/ufs-community/ufs-weather-model/wiki/Running-regression-test-using-rt.sh
################################################################################################
RUN=SFS # GFS, GEFS
CODE_DIR=${PWD}/RUN-UFS/UFS 
#REPO=ufs-community && HASH=develop && CODE_DIR=${CODE_DIR}/ufs_${HASH////\_}_${REPO}
export RUNDIR_ROOT=${NPB_WORKDIR}/RUNS/RTs
RT_COMPILER=intel

########################
# Get Case Test
[[ ${RUN} == SFS ]]  && RT_COMPILE=s2swa_32bit_pdlib_sfs && RT_RUN=cpld_control_sfs 
[[ ${RUN} == GEFS ]] && RT_COMPILE=s2swa_32bit           && RT_RUN=cpld_control_gefs
[[ ${RUN} == GFS ]]  && RT_COMPILE=s2swa_32bit_pdlib     && RT_RUN=cpld_control_gfsv17

CASE=${PWD}/RUN_CASE
grep ${RT_COMPILE} ${CODE_DIR}/tests/rt.conf | grep COMPILE | head -n 1 >& ${CASE}
grep ${RT_RUN} ${CODE_DIR}/tests/rt.conf     | grep RUN     | head -n 1 >> ${CASE}

########################
# Maybe need to load modules
#source ${CODE_DIR}/tests/detect_machine.sh
#module_file=ufs_${MACHINE_ID}.${RT_COMPILER}
#cd ${CODE_DIR} && module purge && module use modulefiles && module load ${module_file}

########################
# Run Case
SUFFIX=$( basename ${CASE} )_$( date +%Y%m%d%h_%M-%S )
echo "RUNS at ${RUNDIR_ROOT}"
nohup ${CODE_DIR}/tests/rt.sh -a ${COMPUTE_ACCOUNT} -ekl ${CASE} >rt_output_${SUFFIX}.txt 2>&1 &
#rm ${CASE}
