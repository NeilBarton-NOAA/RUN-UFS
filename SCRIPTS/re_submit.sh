#!/bin/sh
dir=${1}
cd ${dir}

TO_REMOVE="
out
err
ice_diag.d
job_timestamp.txt
log.*
PET*
*mom6*
FV3ATM_OUTPUT/
RESTART/
CICE_OUTPUT/
CICE_RESTART/
MOM6_OUTPUT/
MOM6_RESTART/
"

for f in ${TO_REMOVE}; do
    if [[ "${f}" == *"/"* ]]; then
        files=$(find ${f} -type f -name "*")
    else
        files=$(find . -type f -name "${f}")
    fi
    for ff in ${files}; do
        rm ${ff}
    done
done
[[ -f ice.restart_file ]] && rm ice.restart_file
cat >> ice.restart_file << EOF
./cice_model.res.nc
EOF
sbatch job_card
