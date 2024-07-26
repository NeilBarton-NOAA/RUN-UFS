#!/bin/sh
echo 'MOM6-namelist.sh'
mkdir -p INPUT MOM6_OUTPUT

####################################
# options based on other active components
[[ ${APP} != *"W"* ]] && MOM6_USE_WAVES=false

case "${OCNRES}" in
    "100")
    OCN_NMPI=${OCN_NMPI:-20}
    TS_FILE="${INPUTDATA_ROOT}/MOM6_IC/100/2011100100/MOM6_IC_TS_2011100100.nc"
    ;;
    "025")
    OCN_NMPI=${OCN_NMPI:-130}
    TS_FILE="${INPUTDATA_ROOT}/MOM6_IC/MOM6_IC_TS_2021032206.nc"
    ;;
    *)
    echo "  RES not defined: ${OCNRES}"
    exit 1
    ;;
esac

####################################
# look for restarts if provided
n_files=$( find -L ${ICDIR} -name "*MOM.res*nc" 2>/dev/null | wc -l )
if (( ${n_files} == 0 )); then
    sed -i "s:input_filename = 'r':input_filename = 'n':g" input.nml
fi

###################################
# namelist settings
if [[ ${ENS_SETTINGS} == T ]]; then
    DO_OCN_SPPT=true
    PERT_EPBL=true
fi

###################################
# parse namelist file
MOM_INPUT=${MOM_INPUT:-${PATHRT}/parm/${MOM6_INPUT}}
atparse < ${MOM_INPUT} > INPUT/MOM_input

