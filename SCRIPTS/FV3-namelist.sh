#!/bin/bash
####################################
# Appendix A
# https://www.gfdl.noaa.gov/wp-content/uploads/2020/02/FV3-Technical-Description.pdf
# experimental fix files for different resolutions
#   hera:/scratch2/NCEPDEV/stmp1/Sanath.Kumar/my_grids
####################################
set -u
echo 'FV3-namelist.sh'
mkdir -p INPUT RESTART

####################################
# namelist defaults
ATMRES=${ATM_RES:-$ATMRES}
ENS_SETTINGS=${ENS_SETTINGS:-T}
        
############
# resolution based options
K_SPLIT=2
N_SPLIT=5
case "${ATMRES}" in
    "C384") 
        DT_ATMOS=${ATM_DT:-300}
        ATM_INPES=${ATM_INPES:-12}
        ATM_JNPES=${ATM_INPES:-12}
        OUTPUT_FILE="'netcdf_parallel' 'netcdf_parallel'"
        MOM6_RESTART_SETTING='r'
        case "${MACHINE_ID}" in
        "hera")
            ATM_THRD=${ATM_THRD:-2}
            ;;
        "wcoss2")
            ATM_THRD=${ATM_THRD:-1}
            ;;
        esac
        ;;
    "C192")
        DT_ATMOS=${ATM_DT:-450}
        OUTPUT_FILE="'netcdf'"
        ;;
    "C96")
        DT_ATMOS=${ATM_DT:-900}
        ATM_INPES=${ATM_INPES:-4}
        ATM_JNPES=${ATM_JNPES:-4}
        ATM_THRD=${ATM_THRD:-1}
        K_SPLIT=1
        N_SPLIT=8
        OUTPUT_FILE="'netcdf'"
        ;;
    *)
        echo "  FATAL: ${ATMRES} not found yet supported"
        exit 1
        ;;
esac
DT_INNER=${DT_ATMOS}

####################################
# WARM_START
n_file=$( find -L -name "fv_core.res*.nc" | wc -l 2>/dev/null )
if (( n_file > 0 )); then
    # WARM START
    # change namelist options
    WARM_START=.true.
    MAKE_NH=.false.
    NA_INIT=0
    EXTERNAL_IC=.false.
    NGGPS_IC=.false.
    MOUNTAIN=.true.
    TILEDFIX=.true.
fi

####################################
# IO options
RESTART_N=${RESTART_FREQ:-${FHMAX}}
OUTPUT_N=${OUTPUT_FREQ:-${FHMAX}}
RESTART_INTERVAL="${RESTART_N} -1"
OUTPUT_FH="${OUTPUT_N} -1"

####################################
# NMPI options and thread options
INPES=${ATM_INPES:-$INPES}
JNPES=${ATM_JNPES:-$JNPES}
atm_omp_num_threads=${ATM_THRD:-${atm_omp_num_threads}}
WPG=${ATM_WPG:-0}
WRTTASK_PER_GROUP=$(( WPG * atm_omp_num_threads ))
[[ ${WPG} == 0 ]] && QUILTING='.false.' 

####################################
#  input.nml edits based on components running
[[ ${APP} != *W* ]] && CPLWAV=.false. && CPLWAV2ATM=.false.
[[ ${APP} == "A" ]] && IAER=2011

####################################
FHROT=${OFFSET_START_HOUR:-0}
####################################
if [[ ${MOM6_INTERP_ICS:-F} == T ]]; then
    export MOM6_RESTART_SETTING='n'
else
    export MOM6_RESTART_SETTING='r'
fi

################################################
# files with resolution 
FNALBC="'${ATMRES}.snowfree_albedo.tileX.nc'"
FNALBC2="'${ATMRES}.facsf.tileX.nc'"
FNVETC="'${ATMRES}.vegetation_type.tileX.nc'"
FNSOTC="'${ATMRES}.soil_type.tileX.nc'"
FNSOCC="'${ATMRES}.soil_color.tileX.nc'"
FNABSC="'${ATMRES}.maximum_snow_albedo.tileX.nc'"
FNTG3C="'${ATMRES}.substrate_temperature.tileX.nc'"
FNVEGC="'${ATMRES}.vegetation_greenness.tileX.nc'"
FNSLPC="'${ATMRES}.slope_type.tileX.nc'"
FNVMNC="'${ATMRES}.vegetation_greenness.tileX.nc'"
FNVMXC="'${ATMRES}.vegetation_greenness.tileX.nc'"

####################################
# parse and edit namelist files
# namelist options in run_test.sh
rt_f=${PATHRT}/run_test.sh
target_f=${SCRIPT_DIR}/FV3-options.sh
cat << EOF > ${target_f}
#!/bin/bash -u
# FV3 options defined in run_test.sh
EOF
ln_start=$(grep -n 'Magic to handle' ${rt_f} | head -n 1 | cut -d: -f1)
ln_end=$(( ln_start + 8 ))
ln_extra=$(( ln_end + 1 ))
sed -n "${ln_start},${ln_end}p;${ln_extra}q" ${rt_f} >> ${target_f}
chmod 755 ${target_f}
source ${target_f}

echo "  "${INPUT_NML}
echo "  "${MODEL_CONFIGURE}
echo "  "${FIELD_TABLE}
atparse < ${PATHRT}/parm/${INPUT_NML} > input.nml
atparse < ${PATHRT}/parm/${MODEL_CONFIGURE} > model_configure
cp "${PATHRT}/parm/noahmptable.tbl" .
cp ${PATHRT}/parm/field_table/${FIELD_TABLE} field_table 
if [[ ${QUILTING} == '.true.' ]]; then
    EXP_DIAG_TABLE=${EXP_DIAG_TABLE:-${PATHRT}/parm/diag_table/${DIAG_TABLE}}
    atparse < ${EXP_DIAG_TABLE} > diag_table
else
cat <<EOF > diag_table
${SYEAR}${SMONTH}${SDAY}.${SHOUR}Z.${ATMRES}.64bit.non-mono
${SYEAR} ${SMONTH} ${SDAY} ${SHOUR} 0 0
EOF
fi

if [[ ${RUN} == SFS ]]; then
echo "DAMPING UPDATES SHOULD BE REMOVED WHEN UPDATED IN MODEL"
# Hopefull these options are added to RT soon
sed -i "s:k_split = 2:k_split = ${K_SPLIT}:g" input.nml
sed -i "s:n_split = 5:n_split = ${N_SPLIT}:g" input.nml
sed -i "s:nudge_qv = .true.:nudge_qv = ${NUDGE_QV}:g" input.nml
sed -i "s:rf_cutoff = 10.:rf_cutoff = ${RF_CUTOFF}:g" input.nml
sed -i "s:fv_sg_adj = 450:fv_sg_adj = ${FV_SG_ADJ}:g" input.nml
sed -i "s:vtdm4 = 0.02:vtdm4 = ${VTDM4}:g" input.nml 
fi

# add stochastic options to input.nml
if [[ ${ENS_SETTINGS} == T ]]; then
    WRITE_STOCHY_NAMELIST
fi
