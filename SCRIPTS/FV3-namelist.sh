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
export HIDE_AIAU=' '
export HIDE_LIAU=' '
# optoins
OUTPUT_HISTORY='.true.'
DOGP_CLDOPTICS_LUT=.false.
DOGP_LWSCAT=.false.
DOGP_SGS_CNV=.true.
IDEFLATE=1
MAX_OUTPUT_FIELDS=300
DOMAINS_STACK_SIZE=16000000
TAU=4.0
RF_CUTOFF=100.
FV_SG_ADJ=900
FHZERO=6
DO_GSL_DRAG_SS=.false.
DO_GWD_OPT_PSL=.true.
IOPT_DIAG=2
QUANTIZE_NSD=5
DNATS=0

############
# resolution based options
IDEFLATE=0
ICHUNK2D=$(( ${ATMRES:1} * 4 ))
JCHUNK2D=$(( ${ATMRES:1} * 2 ))
ICHUNK3D=$(( ${ATMRES:1} * 4 ))
JCHUNK3D=$(( ${ATMRES:1} * 2 ))
KCHUNK3D=1
QUANTIZE_NSD=0
XR_CNVCLD=.true.
LRADAR=.true.
case "${ATMRES}" in
    "C384") 
        DT_ATMOS=${ATM_DT:-300}
        ATM_INPES=${ATM_INPES:-16}
        ATM_JNPES=${ATM_JNPES:-12}
        CDMBWD="20.0,2.5,1.0,1.0"  # settings for GSL drag suite
        KNOB_UGWP_TAUAMP=0.8e-3      # setting for UGWPv1 non-stationary GWD
        N_SPLIT=4
        OUTPUT_FILE="'netcdf_parallel' 'netcdf'"
        MOM6_RESTART_SETTING='r'
        ATM_THRD=${ATM_THRD:-1}
        case "${MACHINE_ID}" in
        "hera")
            ATM_THRD=4
            ;;
        esac
        ;;
    "C192")
        DT_ATMOS=${ATM_DT:-600}
        DT_INNER=300
        ATM_INPES=${ATM_INPES:-4}
        ATM_JNPES=${ATM_JNPES:-4}
        CDMBWD="10.0,3.5,1.0,1.0"  # settings for GSL drag suite
        OUTPUT_FILE="'netcdf' 'netcdf'"
        N_SPLIT=4
        KNOB_UGWP_TAUAMP=1.5e-3
        TAU=6
        FV_SG_ADJ=1800
        ;;
    "C96")
        DT_ATMOS=${ATM_DT:-900}
        ATM_INPES=${ATM_INPES:-4}
        ATM_JNPES=${ATM_JNPES:-4}
        ATM_THRD=${ATM_THRD:-1}
        CDMBWD="20.0,2.5,1.0,1.0"  # settings for GSL drag suite
        KNOB_UGWP_TAUAMP=3.0e-3
        K_SPLIT=1
        N_SPLIT=8
        OUTPUT_FILE="'netcdf'"
        ;;
    *)
        echo "  FATAL: ${ATMRES} not found yet supported"
        exit 1
        ;;
esac
DT_INNER=${DT_INNER:-$DT_ATMOS}
if  [[ ${HYDROSTATIC} == .true. ]]; then
    UPDATE_FULL_OMEGA=.false.
fi

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
    #CMEPS ufs.config
    RUNTYPE='continue' 
fi

# DA increment file
if [[ "${DA_INCREMENTS:-F}" == "T" ]]; then
    IAUFHRS=6
    IAU_DELTHRS=6
    READ_INCREMENT=".true."
    RES_LATLON_DYNAMICS="fv3_increment.nc"
    IAU_INC_FILES="fv3_increment.nc"
else
    IAUFHRS=0
    IAU_DELTHRS=0
    READ_INCREMENT=".false."
    RES_LATLON_DYNAMICS='""'
    IAU_INC_FILES='""'
fi

# Ensemble Run Settings
if [[ ${ENS_SETTINGS} == T ]]; then
    imem=${MEM:-1}
    base_seed=$(( DTG*10000 + imem*100))
    DO_SPPT=.true.
    DO_SKEB=.true.
    PERT_CLDS=.true.
    ISEED_SKEB=$(( base_seed + 1 ))
    ISEED_SPPT="$((base_seed + 3)),$((base_seed + 4)),$((base_seed + 5)),$((base_seed + 6)),$((base_seed + 7))"
    ISEED_OCNSPPT="$((base_seed + 8)),$((base_seed + 9)),$((base_seed + 10)),$((base_seed + 11)),$((base_seed + 12))"
    ISEED_EPBL="$((base_seed + 13)),$((base_seed + 14)),$((base_seed + 15)),$((base_seed + 16)),$((base_seed + 17))"
    case "${ATMRES}" in
    "C384") 
        SKEB="0.8,-999,-999,-999,-999"
        SPPT="0.56,0.28,0.14,0.056,0.028"
        ;;
    "C192")
        SKEB="0.8,-999,-999,-999,-999"
        SPPT="0.56,0.28,0.14,0.056,0.028"
        ;;
    "C96")
        SKEB="0.03,-999,-999,-999,-999"
        SPPT="0.28,0.14,0.056,0.028,0.014"
        ;;
    *)
        echo "  FATAL: ${ATMRES} not found yet supported"
        exit 1
        ;;
    esac
    if  [[ ${HYDROSTATIC} == .true. ]]; then
        DO_SKEB=.false.
        SKEB="-999."
    fi
    case "${OCNRES}" in
    "100")
        export OCNSPPT="0.4,0.2,0.1,0.04,0.02"
        export EPBL="0.4,0.2,0.1,0.04,0.02"
        ;;
    "025")
        export OCNSPPT="0.8,0.4,0.2,0.08,0.04"
        export EPBL="0.8,0.4,0.2,0.08,0.04"
        ;;
    *)
    esac
else
    DO_SPPT=.false.
    DO_SKEB=.false.
    PERT_CLDS=.false.
fi

############
if [[ ${USE_ATM_PERTURB_FILES} == T ]]; then
    export READ_INCREMENT=".true."
    export RES_LATLON_DYNAMICS="atminc.nc"
fi

############
if [[ ${ENS_RESTART:-F} == T ]]; then
    STOCHINI=".true."
else
    STOCHINI=".false."
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
if [[ ${WPG} == 0 ]]; then
    QUILTING='.false.' 
    QUILTING_RESTART='.false.'
    WRITE_DOPOST='.false.'
else
    QUILTING='.true.' 
    QUILTING_RESTART='.true.'
    WRITE_DOPOST='.true.'
fi

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

