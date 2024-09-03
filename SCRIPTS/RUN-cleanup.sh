#!/bin/sh
[[ ${DEBUG} == T ]] && set -x
declare -rx PS4='+ $(basename ${BASH_SOURCE[0]:-${FUNCNAME[0]:-"Unknown"}})[${LINENO}]'
# Organizes data and cleans run after cylc run

########################
# Moves Output
echo "Saving Output"
OUTPUTDIR=output && mkdir -p ${OUTPUTDIR}
#FV3 
mkdir -p ${OUTPUTDIR}/atmos
mv sfcf*.nc ${OUTPUTDIR}/atmos
mv atmf*.nc ${OUTPUTDIR}/atmos

#MOM6
mkdir -p ${OUTPUTDIR}/ocean
mv MOM6_OUTPUT/SST*.nc ${OUTPUTDIR}/ocean
mv MOM6_OUTPUT/ocn*.nc ${OUTPUTDIR}/ocean
mv MOM6_OUTPUT/ocean.stats* ${OUTPUTDIR}/ocean

#CICE6
mkdir -p ${OUTPUTDIR}/ice
mv ice_diag.d ${OUTPUTDIR}/ice
mv history/*nc ${OUTPUTDIR}/ice

if [[ ${APP} == *W* ]]; then
    echo "FATAL Wave output needs to be set up"
    exit 1
fi

########################
# Moves Namelist and log files
echo "Saving namelist files"
OUTPUTDIR=namelists && mkdir -p ${OUTPUTDIR}
files="
ESMF_Profile.summary 
mediator.log 
job_card 
fd_ufs.yaml 
ice_in 
ufs.configure 
diag_table
field_table
input.nml
model_configure
noahmptable.tbl
INPUT/MOM_input
INPUT/MOM_override
"
for f in ${files}; do
    mv ${f} ${OUTPUTDIR}/$(basename ${f})
done

########################
# remove rest of items
echo "Removing files/directories not needed for analysis"
find . | grep -v namelists | grep -v output | xargs rm -r 2>/dev/null

