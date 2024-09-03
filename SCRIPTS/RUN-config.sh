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
        export WAV_RES=${WAV_RES:-glo_100}
        export ATM_INPES=${ATM_INPES:-6}
        export ATM_JNPES=${ATM_JNPES:-8}
        export ATM_WPG=6
        export MOM_INPUT=${SCRIPT_DIR}/MOM_input_coldstart_100.IN
        export OFFSET_START_HOUR=${OFFSET_START_HOUR:-3}
        ;;
    "GEFS")
        export compile_search=s2swa_32bit_pdlib
        export PDLIB="OFF"
        export RT_TEST=cpld_control_gfsv17
        export APP=${APP:-S2SWA}
        export ATM_RES=${ATM_RES:-C384}
        export OCN_RES=${OCN_RES:-025}
        export WAV_RES=${WAV_RES:-glo_025}
        export OFFSET_START_HOUR=${OFFSET_START_HOUR:-3}
        ;;
    *)
        echo "  FATAL: ${ATMRES} not found yet supported"
        exit 1
        ;;
esac

