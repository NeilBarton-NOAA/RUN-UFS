#!/bin/sh
# Defaults for each model/case
export RT_COMPILER=intel
export RUN=${RUN:-SFS}

case ${RUN} in
    "SFS")
        export compile_search=s2s_32bit_sfs
        export PDLIB="OFF"
        export RT_TEST=cpld_control_sfs
        export APP=${APP:-S2S}
        export ATM_RES=${ATM_RES:-C96}
        export WAV_RES=${WAV_RES:-glo_025}
        if [[ ${ATM_RES} == "C192" ]]; then
            export OCN_RES=${OCN_RES:-025}
            export ATM_INPES=${ATM_INPES:-8}
            export ATM_JNPES=${ATM_JNPES:-8}
            export ATM_WPG=${ATM_WPG:-60}
        else
            export OCN_RES=${OCN_RES:-100}
            export ATM_INPES=${ATM_INPES:-6}
            export ATM_JNPES=${ATM_JNPES:-8}
            export ATM_WPG=${ATM_WPG:-6}
        fi
        if [[ ${OCN_RES} == "025" ]]; then
            export OCN_NMPI=${OCN_NMPI:-220}
            export ICE_NMPI=${ICE_NMPI:-90}
            export MOM6_INTERP_ICS=${MOM6_INTERP_ICS:-F}
        else
            export MOM6_INTERP_ICS=${MOM6_INTERP_ICS:-T} 
        fi
        export OUTPUT_FREQ=24
        export CICE_FBOT_XFER_TYPE='mushy'          # default constant
        export CICE_TFREEZE_OPTION='linear_salt'    # default mushy
        export CICE_DT_MLT=0.5
        export CICE_RSNW_MLT=750.
        export CICE_R_ICE=2.5                       # default 0
        export CICE_R_PND=1.8                       # default 0
        export CICE_R_SNW=1.8
        export CICE_EMISSIVITY=0.98
        export CICE_TR_POND_TOPO='.true.'
        export CICE_RESTART_POND_TOPO='.true.'
        export CICE_TR_POND_LVL='.false.'
        export CICE_TR_SNOW='.true.'
        export CICE_HS0=0.001
        export CICE_HS1=0.005
        export CICE_DPSCALE=0.01
        export CICE_RFRACMIN=0.1
        export CICE_RFRACMAX=0.6
        export CICE_PNDASPECT=1.2
        export CICE_SNWREDIST='ITDrdg'
        export CICE_SNWGRAIN='.true.' 
        export CICE_CONDUCT='bubbly'
        export CICE_TSCALE_PND_DRAIN=0.5
        export MOM6_GUST_CONST=0.02
        export MOM6_HFREEZE=2.0
        export ALPHA_FD=35.0
        export DO_GWD_OPT_PSL='.false.'
        export ISEED_CA=1580109181
        ;;
    "GEFS")
        export compile_search=s2swa_32bit
        export PDLIB="OFF"
        export RT_TEST=cpld_control_gefs
        export APP=${APP:-S2SW}
        export ATM_RES=${ATM_RES:-C384}
        export OCN_RES=${OCN_RES:-025}
        export WAV_RES=${WAV_RES:-glo_025}
        export OFFSET_START_HOUR=${OFFSET_START_HOUR:-3}
        export ATM_WPG=${ATM_WPG:-48}
        export OUTPUT_FREQ=3
        export WW3_user_histname='false'
        ;;
    "GFS")
        export compile_search=s2swa_32bit_pdlib
        export RT_TEST=cpld_control_gfsv17
        export APP=${APP:-S2SW}
        export ATM_RES=${ATM_RES:-C1152}
        export OCN_RES=${OCN_RES:-025}
        #export WAV_RES=${WAV_RES:-glo_025}
        if [[ ${OCN_RES} == "025" ]]; then
            export OCN_NMPI=${OCN_NMPI:-220}
            export ICE_NMPI=${ICE_NMPI:-90}
        fi
        export OUTPUT_FREQ=24
        ;;
    *)
        echo "  FATAL: ${ATMRES} not found yet supported"
        exit 1
        ;;
esac
export RESTART_FREQ=${RESTART_FREQ:-${FORECAST_LENGTH:-24}}

