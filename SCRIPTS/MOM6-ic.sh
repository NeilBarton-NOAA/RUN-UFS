#!/bin/sh
echo 'MOM6-ic.sh'
rm -f INPUT/*MOM.res*nc 
n_files=$( find -L ${ICDIR} -name "*${RESTART_DTG}*MOM.res*nc" 2>/dev/null | wc -l )
MOM6_RESTART_SETTING='r'
if (( ${n_files} == 0 )); then
    echo '   WARNING: no ocn ICs found in:' ${ICDIR}
    echo '            will use TS file'
    MOM6_RESTART_SETTING='n'
fi
ocn_ics=$( find -L ${ICDIR} -name "*${RESTART_DTG}*MOM.res*nc" 2>/dev/null )
if (( n_files == 1 )); then
    f=$(basename ${ocn_ics}) && f=${f##*000.}
    ln -sf ${ocn_ics} INPUT/${f}
else
    for ocn_ic in ${ocn_ics}; do
        f=$(basename ${ocn_ic}) && f=${f##*000.}
        ln -sf ${ocn_ic} INPUT/${f}
    done
fi
# DA increment file
if [[ "${DA_INCREMENTS:-F}" == "T" ]]; then
    file=$( find -L ${ICDIR} -name "*mom6_increment.nc" )
    if (( ${#file} == 0 )); then
        echo "FATAL: *mom6_increment.nc not found"
        exit 1
    fi
    ln -s ${file} INPUT/mom6_increment.nc
fi

# OCN Perturbation Files
if [[ ${USE_OCN_PERTURB_FILES:-F} == T ]]; then
    file=$( find -L ${ICDIR} -name "*mom6_perturbation*.nc" | grep ${DTG:0:8} )
    if (( ${#file} == 0 )); then
        echo "FATAL: *mom6_perturbation*.nc not found"
        exit 1
    fi
    ln -s ${file} INPUT/mom6_increment.nc
fi

