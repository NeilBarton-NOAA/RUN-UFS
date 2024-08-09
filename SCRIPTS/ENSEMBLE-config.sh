#!/bin/sh
# Stochastic physics parameters for perturbed forecasts
# ATMOS Options
export DO_SPPT=.true.
#export DO_SKEB=.true.
export DO_SKEB=.false.
echo "SKEB will be false in PR/Bug fix!!!!"
export DO_SHUM=.false.
export DO_CA=.true.
export PERT_MP=.false.
export PERT_RADTEND=.false.
export PERT_CLDS=.true.
# OCN Options
export DO_OCN_SPPT="True"
export PERT_EPBL="True"
#export DO_OCN_SPPT="False"
#export PERT_EPBL="False"

############
# Resolution Based Options
case "${ATMRES}" in
"C384") 
    export SKEB="0.8,-999,-999,-999,-999"
    export SPPT="0.56,0.28,0.14,0.056,0.028"
    ;;
"C96")
    export SKEB="0.03,-999,-999,-999,-999"
    export SPPT="0.28,0.14,0.056,0.028,0.014"
    ;;
*)
    echo "  FATAL: ${ATMRES} not found yet supported"
    exit 1
    ;;
esac

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
    echo "  RES not defined: ${OCNRES}"
    exit 1
    ;;
esac

############
# If replay ICs are used
if [[ "${REPLAY_ICS}" == "T" ]]; then
    export READ_INCREMENT=".true."
    export RES_LATLON_DYNAMICS="atminc.nc"
    export ODA_INCUPD="True"
    export ODA_TEMPINC_VAR='t_pert'
    export ODA_SALTINC_VAR='s_pert'
    export ODA_THK_VAR='h_anl'
    export ODA_INCUPD_UV="True"
    export ODA_UINC_VAR='u_pert'
    export ODA_VINC_VAR='v_pert'
    export ODA_INCUPD_NHOURS=0.0
else
    export ODA_INCUPD="False"
fi

########################
# Defaults
imem=${MEM:-0}
export base_seed=$(( DTG*10000 + imem*100))
export TAU="2.16E4,2.592E5,2.592E6,7.776E6,3.1536E7"
export LSCALE="500.E3,1000.E3,2000.E3,2000.E3,2000.E3"

########################
# Write Namelist

WRITE_STOCHY_NAMELIST() {
ln_start=$( grep -n '&nam_stochy' input.nml | cut -d: -f1) && ln_end=$(( ln_start + 1 ))
sed -i ${ln_start},${ln_end}d input.nml

cat >> input.nml << EOF

&nam_stochy
EOF
if [[ ${DO_SKEB} = ".true." ]]; then
cat >> input.nml << EOF
  skeb = ${SKEB}
  iseed_skeb = $(( base_seed + 1 ))
  skeb_tau = ${TAU}
  skeb_lscale = ${LSCALE}
  skebnorm = 1
  skeb_npass = 30
  skeb_vdof = 5
EOF
fi

if [[ ${DO_SHUM} = ".true" ]]; then
cat >> input.nml << EOF
  shum = 0.005
  iseed_shum = $(( base_seed + 2))
  shum_tau = 21600.
  shum_lscale = 500000.
EOF
fi

if [[ ${DO_SPPT} = ".true." ]]; then
cat >> input.nml << EOF
  sppt = ${SPPT}
  iseed_sppt = $((base_seed + 3)),$((base_seed + 4)),$((base_seed + 5)),$((base_seed + 6)),$((base_seed + 7))
  sppt_tau = ${TAU}
  sppt_lscale = ${LSCALE}
  sppt_logit = .true.
  sppt_sfclimit = .true.
  use_zmtnblck = .true.
  pbl_taper = 0,0,0,0.125,0.25,0.5,0.75
EOF
fi

if [[ "${DO_OCN_SPPT}" == "True" ]]; then
cat >> input.nml <<EOF
  OCNSPPT=${OCNSPPT}
  OCNSPPT_LSCALE=${LSCALE}
  OCNSPPT_TAU=${TAU}
  ISEED_OCNSPPT=$((base_seed + 8)),$((base_seed + 9)),$((base_seed + 10)),$((base_seed + 11)),$((base_seed + 12))
EOF
fi

if [[ "${PERT_EPBL}" == "True" ]]; then
cat >> input.nml <<EOF
  EPBL=${EPBL}
  EPBL_LSCALE=${LSCALE}
  EPBL_TAU=${TAU}
  ISEED_EPBL=$((base_seed + 13)),$((base_seed + 14)),$((base_seed + 15)),$((base_seed + 16)),$((base_seed + 17))
EOF
fi
cat >> input.nml << EOF
/
EOF
}
