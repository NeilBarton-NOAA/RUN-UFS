#!/bin/sh
echo 'CICE-namelist.sh'
mkdir -p history

OCNRES=${OCN_RES:-$OCNRES}
####################################
# Resolution based options
case "${OCNRES}" in
    "100")
    ICE_tasks=${ICE_NMPI:-10}
    NY_GLB=320
    CICE_DECOMP="slenderX1"
    ;;
    "025")
    ICE_tasks=${ICE_NMPI:-76}
    NX_GLB=1440
    NY_GLB=1080
    CICE_DECOMP="slenderX2"
    ;;
    *)
    echo "  RES not defined: ${OCNRES}"
    exit 1
    ;;
esac

############
# IC 
CICE_RESTART=${CICE_RESTART:-'.true.'}
CICERUNTYPE=${CICERUNTYPE:-'initial'}
USE_RESTART_TIME=${CICE_USE_RESTART_TIME:-.true.}

####################################
# IO options
CICE_OUTPUT=${CICE_OUTPUT:-F}
RESTART_FREQ=${RESTART_FREQ:-$FHMAX}
DUMPFREQ_N=$(( RESTART_FREQ / 24 ))
CICE_HIST_AVG='.false.'

####################################
# grid files
CICE_GRID=grid_cice_NEMS_mx${OCNRES}.nc
CICE_MASK=kmtu_cice_NEMS_mx${OCNRES}.nc

####################################
# determine block size from ICE_tasks and grid
DT_CICE=${DT_ATMOS:-$DT_CICE}
NPROC_ICE=${ICE_tasks} && CICE_NPROC=${ICE_tasks}
ice_omp_num_threads=${ICE_THRD:-${ice_omp_num_threads}}
cice_processor_shape=${CICE_DECOMP:-'slenderX2'}
shape=${cice_processor_shape#${cice_processor_shape%?}}
NPX=$(( ICE_tasks / shape )) #number of processors in x direction
NPY=$(( ICE_tasks / NPX ))   #number of processors in y direction
if (( $(( NX_GLB % NPX )) == 0 )); then
    CICE_BLCKX=$(( NX_GLB / NPX ))
else
    CICE_BLCKX=$(( (NX_GLB / NPX) + 1 ))
fi
if (( $(( NY_GLB % NPY )) == 0 )); then
    CICE_BLCKY=$(( NY_GLB / NPY ))
else
    CICE_BLCKY=$(( (NY_GLB / NPY) + 1 ))
fi

####################################
# parse namelist file
[[ -f ${PATHRT}/parm/ice_in.IN ]] && parse_file=ice_in.IN
atparse < ${PATHRT}/parm/${parse_file} > ice_in
if [[ ${CICE_OUTPUT} == F ]]; then
    sed -i "s:histfreq       = 'm','d','h','x','x':histfreq       = 'x','x','x','x','x':g"  ice_in
    sed -i "s:histfreq_n     =  0 , 0 , 6 , 1 , 1:histfreq_n     =  0 , 0 , 0 , 0 , 0:g" ice_in
else
    sed -i "s:histfreq       = 'm','d','h','x','x':histfreq       = 'm','d','h','1','x':g"  ice_in
    sed -i "s:histfreq_n     =  0 , 0 , 6 , 1 , 1:histfreq_n     =  0 , 0 , 3 , 1 , 0:g" ice_in

fi
if [[ ${CICE_RESTART} == '.false.' ]]; then
    sed -i "s:restart        = .true.:restart        = .false.:g" ice_in
fi
