#!/bin/sh
# Defaults for each model/case
export RT_COMPILER=intel
export RUN=${RUN:-SFS}

case ${RUN} in
    "SFS")
        export compile_search=s2swa_32bit_pdlib_sfs
        export PDLIB="OFF"
        export RT_TEST=cpld_control_sfs
        export APP=${APP:-S2SWA}
        export WAV_RES=${WAV_RES:-glo_100}
        export MOM_INPUT=${SCRIPT_DIR}/MOM_input_coldstart_100.IN
        ;;
    "GEFS")
        export compile_search=s2swa_32bit_pdlib
        export PDLIB="OFF"
        export RT_TEST=cpld_control_gfsv17
        export APP=${APP:-S2SWA}
        export ATM_RES=${WAV_RES:-C384}
        export OCN_RES=${WAV_RES:-025}
        export WAV_RES=${WAV_RES:-glo_025}
        ;;
    *)
        echo "  FATAL: ${ATMRES} not found yet supported"
        exit 1
        ;;
esac

