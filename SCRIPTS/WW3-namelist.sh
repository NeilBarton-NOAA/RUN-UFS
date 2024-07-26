#!/bin/bash
echo 'WW3-namelist.sh'

####################################
# new modef file?

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
atparse < ${PATHRT}/parm/ww3_shel.nml.IN > ww3_shel.nml
cp ${PATHRT}/parm/ww3_points.list .

