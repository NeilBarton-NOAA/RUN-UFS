#!/bin/bash
set -u
################################################################################################
# https://github.com/ufs-community/ufs-weather-model/wiki/Running-regression-test-using-rt.sh
################################################################################################
#REPO=ufs-community && HASH=develop && CODE_DIR=${PWD}/RUN-UFS/UFS 
REPO=NeilBarton-NOAA && HASH=GUST_CONST && CODE_DIR=${NPB_WORKDIR}/CODE/ufs_${HASH////\_}_${REPO}

if [[ ! -d ${CODE_DIR} ]]; then
    cd $( dirname ${CODE_DIR} )
    git clone git@github.com:${REPO}/ufs-weather-model.git $( basename ${CODE_DIR} )
    cd ${CODE_DIR}
    git checkout ${HASH}
    git submodule update --init --recursive
fi

########################
# Run Case
nohup ${CODE_DIR}/tests/rt.sh -a ${COMPUTE_ACCOUNT} -e > rt_output.txt 2>&1 &
