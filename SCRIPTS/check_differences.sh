#!/bin/sh
set -u
dir1=${1}
dir2=${2}
diff_file=diff_$( basename ${dir1})_$( basename ${dir2} ).out
[[ -f ${diff_file} ]] && rm ${diff_file}

FILES="
CICE_OUTPUT/iceh_ic.1996-04-18-00000.nc
fv3.exe
input.nml
model_configure
ufs.configure
ice_in
rpointer.cpl
INPUT/MOM_input
INPUT/MOM_override
INPUT/coupler.res
ufs.cpld.cpl.r.nc
cice_model.res.nc
INPUT/MOM.res.nc
INPUT/MOM.res_1.nc
INPUT/MOM.res_2.nc
INPUT/MOM.res_3.nc
INPUT/ocn_stoch.res.nc
INPUT/atm_stoch.res.nc
INPUT/fv_core.res.nc"
TILE_FILES="ca_data fv_core.res fv_srf_wnd.res fv_tracer.res phy_data sfc_data"
RESTART_FILES=""
for f in ${TILE_FILES}; do
for t in {1..6}; do
    RESTART_FILES="${RESTART_FILES} INPUT/${f}.tile${t}.nc"
done
done
FILES="${FILES} ${RESTART_FILES}"

################################################
################################################

for f in ${FILES}; do
   echo $f
   echo '   '${f} >> ${diff_file}
   diff ${dir1}/${f} ${dir2}/${f} >> ${diff_file}
   echo '   ' >> ${diff_file}
done
echo "checking directory differences"
diff -q -r ${dir1} ${dir2} >> ${diff_file}
FILES_TO_IGNORE="mom6 CICE_OUTPUT/iceh_24h FV3ATM_OUTPUT MOM6_OUTPUT RESTART"
for f in ${FILES_TO_IGNORE}; do
    grep -v ${f} ${diff_file} >& temp_diff
    mv temp_diff ${diff_file}
done
echo ${diff_file}
