#!/bin/sh
echo 'CICE-namelist.sh'
mkdir -p history?

####################################
# Resolution based options
case "${OCNRES}" in
    "100")
    ICE_NMPI=${ICE_NMPI:-10}
    ;;
    "025")
    ICE_NMPI=${ICE_NMPI:-76}
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
USE_RESTART_TIME=${CICE_USE_RESTART_TIME:-.false.}

####################################
# IO options
CICE_OUTPUT=${CICE_OUTPUT:-F}
RESTART_FREQ=${RESTART_FREQ:-$FHMAX}
DUMPFREQ_N=$(( RESTART_FREQ / 24 ))
CICE_HIST_AVG='.false.'

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
    BLCKX=$(( NX_GLB / NPX ))
else
    BLCKX=$(( (NX_GLB / NPX) + 1 ))
fi
if (( $(( NY_GLB % NPY )) == 0 )); then
    BLCKY=$(( NY_GLB / NPY ))
else
    BLCKY=$(( (NY_GLB / NPY) + 1 ))
fi

####################################
# parse namelist file
[[ -f ${PATHRT}/parm/ice_in.IN ]] && parse_file=ice_in.IN
[[ -f ${PATHRT}/parm/ice_in_template ]] && parse_file=ice_in_template
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
