#!/bin/sh
echo 'CICE-ic.sh'

####################################
# look for restarts if provided
ICDIR=${ICDIR:-${INPUTDATA_ROOT_BMIC}/${SYEAR}${SMONTH}${SDAY}${SHOUR}/cpc}
ice_ic=${ice_ic:-$( find -L ${ICDIR} -name "*${RESTART_DTG}.cice_model.res.nc" )}
rm -f ice.restart_file

####################################
# if not using the default optoin
if [[ ${ice_ic} != 'default' ]]; then
    if [[ ! -f ${ice_ic} ]]; then
        ice_ic=$( find -L ${ICDIR} -name "*iced.${RESTART_DTG_ALT}.nc" )
        if [[ ! -f ${ice_ic} ]]; then
            echo "  FATAL: ${ice_ic} file not found"
            exit 1
        fi
    fi
fi
rm -f cice_model.res.nc
ln -sf ${ice_ic} cice_model.res.nc
cat <<EOF > ice.restart_file
cice_model.res.nc
EOF
