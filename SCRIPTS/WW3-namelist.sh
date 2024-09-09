#!/bin/bash
echo 'WW3-namelist.sh'

####################################
# times
RUN_BEG="${SYEAR}${SMONTH}${SDAY} $(printf "%02d" $(( SHOUR  )))0000"
RUN_END="2100${SMONTH}${SDAY} $(printf "%02d" $(( SHOUR  )))0000"
OUT_BEG=${RUN_BEG}
OUT_END=${RUN_END}
RST_BEG=${RUN_BEG}
RST_2_BEG=${RUN_BEG}
RST_END=${RUN_END}
RST_2_END=${RUN_END}

####################################
# new modef file?
if [[ ${WAV_RES} == glo_100 ]] || [[ ${WAV_RES} == glo_025 ]]; then
    f_moddef=${STMP}/UFS/FIXFILES/mod_def.${WAV_RES} 
    if [[ ! -f ${f_moddef} ]]; then
        ${SCRIPT_DIR}/WW3-inp2moddef.sh ${SCRIPT_DIR}/ww3_grid.inp.${WAV_RES} ${HOMEufs} $(dirname ${f_moddef}) ${MACHINE_ID}
    fi
    ln -sf ${f_moddef} mod_def.ww3
    ln -sf ${SCRIPT_DIR}/${MESH_WAV} .
fi

####################################
case "${WAV_RES}" in
    "glo_025")
    export WAV_tasks=${WAV_NMPI:-162}
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
#atparse < ${PATHRT}/parm/ww3_shel.inp.IN > ww3_shel.inp
atparse < ${PATHRT}/parm/ww3_shel.nml.IN > ww3_shel.nml
cp ${PATHRT}/parm/ww3_points.list .

