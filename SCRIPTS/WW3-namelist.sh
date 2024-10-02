#!/bin/bash
echo 'WW3-namelist.sh'

####################################
# times
RUN_BEG="${SYEAR}${SMONTH}${SDAY} $(printf "%02d" $(( ${DTG:8:2} )))0000"
OUT_BEG=${RUN_BEG}
RST_BEG=${RUN_BEG}
RST_2_BEG=${RUN_BEG}
DTG_END=$(date -u -d"${SYEAR}-${SMONTH}-${SDAY} ${DTG:8:2}:00:00 ${FORECAST_LENGTH} hours" +%Y%m%d%H)
RUN_END="${DTG_END:0:4}${DTG_END:4:2}${DTG_END:6:2} $(printf "%02d" $(( ${DTG_END:8:2}  )))0000"
OUT_END=${RUN_END}
RST_END=${RUN_END}
RST_2_END=${RUN_END}

####################################
# new modef file?
if [[ ! -f ${MESH_WAV} ]]; then
    echo "WARNING: grabbing wave grid from gw"
    f_moddef=${STMP}/UFS/FIXFILES/mod_def.${WAV_RES} 
    if [[ ! -f ${f_moddef} ]]; then
        ${SCRIPT_DIR}/WW3-inp2moddef.sh ${GW_FIXDIR}/wave/20240105/ww3_grid.inp.${WAV_RES} ${HOMEufs} $(dirname ${f_moddef}) ${MACHINE_ID}
    fi
    ln -sf ${f_moddef} mod_def.ww3
    ln -sf ${GW_FIXDIR}/wave/20240105/${MESH_WAV} .
fi

####################################
case "${WAV_RES}" in
    "glo_025")
    export WAV_tasks=${WAV_NMPI:-120}
    export WAV_THRD=${WAV_THRD:-2}
    ;;
esac

####################################
# IO options
RESTART_FREQ=${RESTART_FREQ:-$FHMAX}
DT_2_RST=$(( RESTART_FREQ * 3600 )) 
DTFLD=${WW3_DTFLD:-${DT_2_RST}}
DTPNT=${WW3_DTPNT:-${DT_2_RST}}

####################################
#parse namelist file
export INPUT_CURFLD='C F     Currents'
export INPUT_ICEFLD='C F     Ice concentrations'
MULTIGRID=${MULTIGRID:-'false'}
echo "  ww3_shel.nml.IN"
atparse < ${PATHRT}/parm/ww3_shel.inp.IN > ww3_shel.inp
#atparse < ${PATHRT}/parm/ww3_shel.nml.IN > ww3_shel.nml
cp ${PATHRT}/parm/ww3_points.list .

