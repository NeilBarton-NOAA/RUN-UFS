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
[[ ${APP} != *"W"* ]] && MOM6_USE_WAVES=False

case "${OCNRES}" in
    "100")
    OCN_tasks=${OCN_NMPI:-20}
    OCNTIM=3600
    NX_GLB=360
    NY_GLB=320
    DT_DYNAM_MOM6='1800'
    DT_THERM_MOM6='3600'
    FRUNOFF=""
    MOM6_CHLCLIM="seawifs_1998-2006_smoothed_2X.nc"
    MOM6_RIVER_RUNOFF='False'
    MOM6_TOPOEDITS="ufs.topo_edits_011818.nc"
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
    MOM6_ALLOW_LANDMASK_CHANGES="False" 
    MOM6_DIAG_COORD_DEF_Z_FILE=interpolate_zgrid_40L.nc
    ;;
    *)
    echo "  RES not defined: ${OCNRES}"
    exit 1
    ;;
esac
if [[ ${MOM6_INTERP_ICS:-F} == T ]]; then
   MOM6_WARMSTART_FILE="MOM.res.nc"
   MOM6_INIT_FROM_Z='False'
   MOM6_INIT_UV='file'
else
   MOM6_INIT_FROM_Z='.True.'
   MOM6_WARMSTART_FILE="none"
   MOM6_INIT_UV="zero"
fi
# DA increment file
if [[ "${DA_INCREMENTS:-F}" == "T" ]]; then
    ODA_INCUPD="True"
    ODA_TEMPINC_VAR='t_pert'
    ODA_SALTINC_VAR='s_pert'
    ODA_THK_VAR='h_anl'
    ODA_INCUPD_UV="True"
    ODA_UINC_VAR='u_pert'
    ODA_VINC_VAR='v_pert'
    ODA_INCUPD_NHOURS=0.0
else
    ODA_INCUPD="False"
    ODA_TEMPINC_VAR='Temp'
    ODA_SALTINC_VAR='Salt'
    ODA_THK_VAR='h'
    ODA_INCUPD_UV="False"
    ODA_UINC_VAR='u'
    ODA_VINC_VAR='v'
    ODA_INCUPD_NHOURS=3.0
fi

if [[ ${ENS_SETTINGS} == T ]]; then
    export DO_OCN_SPPT="True"
    export PERT_EPBL="True"
else
    export DO_OCN_SPPT="False"
    export PERT_EPBL="False"
fi

if [[ ${USE_OCN_PERTURB_FILES} == T ]]; then
    export ODA_INCUPD="True"
    export ODA_TEMPINC_VAR='t_pert'
    export ODA_SALTINC_VAR='s_pert'
    export ODA_THK_VAR='h_anl'
    export ODA_INCUPD_UV="True"
    export ODA_UINC_VAR='u_pert'
    export ODA_VINC_VAR='v_pert'
    export ODA_INCUPD_NHOURS=0.0
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

