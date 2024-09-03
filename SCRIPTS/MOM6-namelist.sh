#!/bin/sh
echo 'MOM6-namelist.sh'
mkdir -p INPUT MOM6_OUTPUT

########################
# optoins
OCNRES=${OCN_RES:-$OCNRES}
MOM6_INPUT=MOM_input_${OCNRES}.IN
MOM_INPUT=${MOM_INPUT:-${PATHRT}/parm/${MOM6_INPUT}}

####################################
# options based on other active components
[[ ${APP} != *"W"* ]] && MOM6_USE_WAVES=false

case "${OCNRES}" in
    "100")
    OCN_tasks=${OCN_NMPI:-20}
    OCNTIM=3600
    NX_GLB=360
    NY_GLB=320
    DT_DYNAM_MOM6='3600'
    DT_THERM_MOM6='3600'
    FRUNOFF=""
    MOM6_CHLCLIM="seawifs_1998-2006_smoothed_2X.nc"
    MOM6_RIVER_RUNOFF='False'
    TOPOEDITS="ufs.topo_edits_011818.nc"
    MOM6_ALLOW_LANDMASK_CHANGES="True" 
    ;;
    "025")
    OCN_tasks=${OCN_NMPI:-130}
    OCNTIM=1800
    NX_GLB=1440
    NY_GLB=1080
    DT_DYNAM_MOM6='900'
    DT_THERM_MOM6='1800'
    FRUNOFF="runoff.daitren.clim.${NX_GLB}x${NY_GLB}.v20180328.nc"
    MOM6_CHLCLIM="seawifs-clim-1997-2010.${NX_GLB}x${NY_GLB}.v20180328.nc"
    MOM6_RIVER_RUNOFF='True'
    ;;
    *)
    echo "  RES not defined: ${OCNRES}"
    exit 1
    ;;
esac

if [[ ${MOM6_INTERP_ICS:-F} == T ]]; then
    export MOM6_WARMSTART_FILE="MOM.res.nc"
fi
####################################
# look for restarts if provided
n_files=$( find -L ${ICDIR} -name "*MOM.res*nc" 2>/dev/null | wc -l )
if (( ${n_files} == 0 )); then
    sed -i "s:input_filename = 'r':input_filename = 'n':g" input.nml
fi

###################################
# parse namelist file
echo "  "${MOM_INPUT}
atparse < ${MOM_INPUT} > INPUT/MOM_input

