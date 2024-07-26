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
ENS_SETTINGS=${ENS_SETTINGS:-T}
        
############
# resolution based options
case "${ATMRES}" in
    "C384") 
        DT_ATMOS=${ATM_DT:-$DT_ATMOS}
        ATM_INPES=${ATM_INPES:-12}
        ATM_JNPES=${ATM_INPES:-12}
        OUTPUT_FILE="'netcdf_parallel' 'netcdf_parallel'"
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
        DT_ATMOS=${ATM_DT:-720}
        ATM_INPES=${ATM_INPES:-2}
        ATM_JNPES=${ATM_INPES:-2}
        ATM_THRD=${ATM_THRD:-1}
        OUTPUT_FILE="'netcdf'"
        ;;
    *)
        echo "  FATAL: ${ATMRES} not found yet supported"
        exit 1
        ;;
esac

####################################
# WARM_START
file=$( find -L ${ICDIR} -name "gfs_ctrl.nc" >/dev/null )
if [[ ! -f ${file} ]]; then
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
# vertical resolution options
NPZ=${ATM_LEVELS:-127}
NPZP=$(( NPZ + 1 ))

#res=$( echo ${ATMRES} | cut -c2- )
#IMO=$(( ${res} * 4 ))
#JMO=$(( ${res} * 2 ))
#NPX=$(( ${res} + 1 ))
#NPY=$(( ${res} + 1 ))
#FNALBC="'${ATMRES}.snowfree_albedo.tileX.nc'"
#FNALBC2="'${ATMRES}.facsf.tileX.nc'"
#FNVETC="'${ATMRES}.vegetation_type.tileX.nc'"
#FNSOTC="'${ATMRES}.soil_type.tileX.nc'"
#FNABSC="'${ATMRES}.maximum_snow_albedo.tileX.nc'"
#FNTG3C="'${ATMRES}.substrate_temperature.tileX.nc'"
#FNVEGC="'${ATMRES}.vegetation_greenness.tileX.nc'"
#FNSLPC="'${ATMRES}.slope_type.tileX.nc'"
#FNVMNC="'${ATMRES}.vegetation_greenness.tileX.nc'"
#FNVMXC="'${ATMRES}.vegetation_greenness.tileX.nc'"
#DT_INNER=${DT_ATMOS}

####################################
#  input.nml edits based on components running
#[[ ${APP} == *A* ]] && CPLCHM=.false. && FIELD_TABLE=field_table_thompson_noaero_tke_progsigma
[[ ${APP} != *W* ]] && CPLWAV=.false. && CPLWAV2ATM=.false.
[[ ${APP} != "A" ]] && IAER=2011

####################################
# namelist options
if [[ ${ENS_SETTINGS} == T ]]; then
    DO_SPPT=.true.
    DO_SHUM=.false.
    DO_SKEB=.true.
    PERT_MP=.false.
    PERT_RADTEND=.false.
    PERT_CLDS=.true.
fi

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

atparse < ${PATHRT}/parm/${INPUT_NML} > input.nml
atparse < ${PATHRT}/parm/${MODEL_CONFIGURE} > model_configure
cp "${PATHRT}/parm/noahmptable.tbl" .
cp ${PATHRT}/parm/field_table/${FIELD_TABLE} field_table 
if [[ ${QUILTING} == '.true.' ]]; then
    atparse < ${PATHRT}/parm/diag_table/${DIAG_TABLE} > diag_table
    sed -i "s:6,  "hours", 1,:${OUTPUT_FH},  "hours", 1,:g" diag_table
    sed -i "s:1,  "days", 1,:${OUTPUT_FH},  "hours", 1,:g" diag_table
else
cat <<EOF > diag_table
${SYEAR}${SMONTH}${SDAY}.${SHOUR}Z.${ATMRES}.64bit.non-mono
${SYEAR} ${SMONTH} ${SDAY} ${SHOUR} 0 0
EOF
fi

# add stochastic options to input.nml
if [[ ${ENS_SETTINGS} == T ]]; then
echo "IN ENS_SETTINGS find a better way to do this!"
ens_options="\\
  skeb = 0.8,-999,-999,-999,-999\n\
  iseed_skeb = 0\n\
  skeb_tau = 2.16E4,1.728E5,2.592E6,7.776E6,3.1536E7\n\
  skeb_lscale = 500.E3,1000.E3,2000.E3,2000.E3,2000.E3\n\
  skebnorm = 1\n\
  skeb_npass = 30\n\
  skeb_vdof = 5\n\
  sppt = 0.56,0.28,0.14,0.056,0.028\n\
  iseed_sppt = 20210929000103,20210929000104,20210929000105,20210929000106,20210929000107\n\
  sppt_tau = 2.16E4,2.592E5,2.592E6,7.776E6,3.1536E7\n\
  sppt_lscale = 500.E3,1000.E3,2000.E3,2000.E3,2000.E3\n\
  sppt_logit = .true.\n\
  sppt_sfclimit = .true.\n\
  use_zmtnblck = .true.\n\
  OCNSPPT=0.8,0.4,0.2,0.08,0.04\n\
  OCNSPPT_LSCALE=500.E3,1000.E3,2000.E3,2000.E3,2000.E3\n\
  OCNSPPT_TAU=2.16E4,2.592E5,2.592E6,7.776E6,3.1536E7\n\
  ISEED_OCNSPPT=20210929000108,20210929000109,20210929000110,20210929000111,20210929000112\n\
  EPBL=0.8,0.4,0.2,0.08,0.04\n\
  EPBL_LSCALE=500.E3,1000.E3,2000.E3,2000.E3,2000.E3\n\
  EPBL_TAU=2.16E4,2.592E5,2.592E6,7.776E6,3.1536E7\n\
  ISEED_EPBL=20210929000113,20210929000114,20210929000115,20210929000116,20210929000117
"
sed -i "/nam_stochy/a ${ens_options}" input.nml
fi

