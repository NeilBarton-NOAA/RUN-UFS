#!/bin/bash
set -u
set -x
################################################################################################
# https://github.com/ufs-community/ufs-weather-model/wiki/Running-regression-test-using-rt.sh
################################################################################################
#REPO=ufs-community && HASH=develop && CODE_DIR=${PWD}/RUN-UFS/UFS 
REPO=ufs-community && HASH=develop && CODE_DIR=${NS_WORKDIR}/CODE/ufs_${HASH////\_}_${REPO}
#REPO=NeilBarton-NOAA && HASH=SFSBeta2 && CODE_DIR=${NS_WORKDIR}/CODE/ufs_${HASH////\_}_${REPO}

CHECKOUT_ONLY=F
TOPDIR=${PWD}
if [[ ! -d ${CODE_DIR} ]]; then
    cd $( dirname ${CODE_DIR} )
    git clone git@github.com:${REPO}/ufs-weather-model.git $( basename ${CODE_DIR} )
    cd ${CODE_DIR}
    git checkout ${HASH}
    git submodule update --init --recursive
fi
[[ "${CHECKOUT_ONLY:-F}" == "T" ]] && echo "Just Checking Out the Model" && exit 0
########################
# Run Case
#nohup ${CODE_DIR}/tests/rt.sh -a ${COMPUTE_ACCOUNT} -l ${TOPDIR}/rt.sfs.conf -e > ${TOPDIR}/rt_output.txt 2>&1 &
nohup ${CODE_DIR}/tests/rt.sh -a ${COMPUTE_ACCOUNT} -e > ${TOPDIR}/rt_output.txt 2>&1 &

tail -f ${TOPDIR}/rt_output.txt
