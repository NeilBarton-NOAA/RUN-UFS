#!/bin/sh
# Defaults for each model/case
export RT_COMPILER=intel
export RUN=${RUN:-SFS}

case ${RUN} in
    "SFS")
        export compile_search=s2swa_32bit_pdlib_sfs
        export PDLIB="OFF"
        export WAV_RES=${WAV_RES:-glo_100}
        export RT_TEST=cpld_control_sfs
        ;;
    "GEFS")
        export compile_search=s2swa_32bit_pdlib
        export PDLIB="OFF"
        ;;
    *)
        echo "  FATAL: ${ATMRES} not found yet supported"
        exit 1
        ;;
esac

