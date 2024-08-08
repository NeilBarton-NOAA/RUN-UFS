#!/bin/bash
set -u
echo 'CMEPS-namelist.sh'
lc_APP=$( echo ${APP} | tr '[:upper:]' '[:lower:]' )
UFS_CONFIGURE=ufs.configure.${lc_APP}_esmf.IN
PET_LOGS=${PETLOGS:-F}

########################
# coupling time steps
coupling_interval_fast_sec=${DT_ATMOS}
coupling_interval_slow_sec=${DT_THERM_MOM6}

########################
# mpi tasks
ATM_compute_tasks=$(( INPES * JNPES * NTILES ))
MED_tasks=${MED_NMPI:-${ATM_compute_tasks}}
if (( ${MED_tasks} > ${ATM_compute_tasks} )); then
    MED_tasks=${ATM_compute_tasks}
fi
med_omp_num_threads=${atm_omp_num_threads}
chm_omp_num_threads=${atm_omp_num_threads}
TEST_ID=UFS && RTVERBOSE=F
compute_petbounds_and_tasks

########################
# options based on resolutions
MESH_OCN=mesh.mx${OCNRES}.nc
MESH_ICE=mesh.mx${OCNRES}.nc
case "${OCNRES}" in
    "500") eps_imesh="4.0e-1";;
    "100") eps_imesh="2.5e-1";;
    *) eps_imesh="1.0e-1";;
esac
#ATMTILESIZE=${ATMRES:1}

########################
# write namelists files
echo "  "${UFS_CONFIGURE}
atparse < ${PATHRT}/parm/${UFS_CONFIGURE} > ufs.configure
cp ${PATHRT}/parm/fd_ufs.yaml fd_ufs.yaml

# post edits
[[ ${PET_LOGS} == F ]] && sed -i "s:ESMF_LOGKIND_MULTI:ESMF_LOGKIND_MULTI_ON_ERROR:g" ufs.configure
