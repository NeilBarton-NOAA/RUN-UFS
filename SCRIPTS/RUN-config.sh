#!/bin/sh
# Defaults for each model/case
export RT_COMPILER=intel
export RUN=${RUN:-SFS}

case ${RUN} in
    "SFS")
        export compile_search=s2swa_32bit_pdlib_sfs
        export PDLIB="OFF"
        export RT_TEST=cpld_control_sfs
        export APP=${APP:-S2S}
        export ATM_RES=${ATM_RES:-C96}
        export OCN_RES=${OCN_RES:-100}
        export WAV_RES=${WAV_RES:-glo_025}
        if [[ ${ATM_RES} == "C192" ]]; then
            export ATM_INPES=${ATM_INPES:-8}
            export ATM_JNPES=${ATM_JNPES:-8}
            export ATM_WPG=${ATM_WPG:-60}
        else
            export ATM_INPES=${ATM_INPES:-6}
            export ATM_JNPES=${ATM_JNPES:-8}
            export ATM_WPG=${ATM_WPG:-6}
        fi
        if [[ ${OCN_RES} == "025" ]]; then
            export OCN_NMPI=${OCN_NMPI:-220}
            export ICE_NMPI=${ICE_NMPI:-90}
        fi
        export OUTPUT_FREQ=24
        export MOM6_INTERP_ICS=${MOM6_INTERP_ICS:-T} 
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

