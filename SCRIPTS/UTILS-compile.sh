#!/bin/sh
set -u
source $PWD/MACHINE-config.sh
TOPDIR=$NPB_WORKDIR/CODE
machine=$(uname -n)
REPO=NeilBarton-NOAA 
REPO=NOAA-EMC
code=UFS_UTILS_${REPO}
########################
# check out code
mkdir -p ${TOPDIR}
cd ${TOPDIR}
if [[ ! -d ${code} ]]; then
    git clone --recursive https://github.com/${REPO}/UFS_UTILS.git ${code}
fi

########################
# build model
cd ${TOPDIR}/${code}
sh build_all.sh
cd fix
sh link_fixdirs.sh emc hera 
echo 'DONE'

