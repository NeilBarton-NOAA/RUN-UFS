#!/bin/bash
set -u
################################################
# create MACHINE-id.sh script
################################################
# machine specific items
target_f=$( dirname ${0} )/MACHINE-id.sh
HOMEufs=${1}
export PATHRT=${HOMEufs}/tests

source ${PATHRT}/detect_machine.sh
rt_f=${PATHRT}/rt.sh
export MACHINE_ID
cat << EOF > ${target_f}
#!/bin/bash -u
# machine specific items grab from the rt.sh file
export MACHINE_ID=${MACHINE_ID}
if [[ ${MACHINE_ID} == wcoss2 ]]; then
    export ACCNR=${ACCNR:-GFS-DEV}
elif [[ ${MACHINE_ID} == gaeac6 ]]; then
    export ACCNR=${ACCNR:-ira-sti}
else
    export ACCNR=${ACCNR:-marine-cpu}
fi
EOF
ln_start=$(grep -n 'case ${MACHINE_ID}' ${rt_f} | head -n 1 | cut -d: -f1)
ln_end=$(grep -n 'esac' ${rt_f} | head -n 2 | tail -n 1 | cut -d: -f1)
ln_extra=$(( ln_end + 1 ))
sed -n "${ln_start},${ln_end}p;${ln_extra}q" ${rt_f} >> ${target_f}
grep INPUTDATA ${rt_f} | grep -v ENTITY >> ${target_f}
chmod 755 ${target_f}
sed -i "s/cp fv3_conf/#cp fv3_conf/g" ${target_f}
source ${target_f}
echo $MACHINE_ID
case "${MACHINE_ID}" in
    "hera")
        STMP=/scratch2/NCEPDEV/stmp3/${USER}/RUNS
        TOP_ICDIR=${TOP_ICDIR:-/scratch2/NCEPDEV/stmp1/Neil.Barton/ICs/RUN_UFS}
        GW_FIXDIR=/scratch1/NCEPDEV/global/glopara/fix
    ;;
    "orion")
        STMP=/work/noaa/marine/${USER}/RUNS
        TOP_ICDIR=/work/noaa/marine/nbarton/ICs/RUN_UFS
        GW_FIXDIR=/work/noaa/global/glopara/fix/
    ;;
    "hercules")
        STMP=/work/noaa/marine/${USER}/RUNS
        TOP_ICDIR=/work/noaa/marine/nbarton/ICs/RUN_UFS
        GW_FIXDIR=/work/noaa/global/glopara/fix/
    ;;
    "gaeac6")
        STMP=/gpfs/f6/sfs-emc/scratch/${USER}/RUNS
        TOP_ICDIR=${TOP_ICDIR:-/gpfs/f6/sfs-emc/scratch/${USER}/ICs/RUN_UFS}
        GW_FIXDIR=/gpfs/f6/drsa-precip3/world-shared/role.glopara/fix/
    ;;
    "wcoss2")
        STMP=${STMP}/${USER}/RUNS
        TOP_ICDIR=${TOP_ICDIR:-/lfs/h2/emc/couple/noscrub/neil.barton/ICs/RUN_UFS}
        GW_FIXDIR=/lfs/h2/emc/global/noscrub/emc.global/FIX/fix
    ;;
    *)
    echo "WARNING: MACHINE not set up"
    exit 1
    ;;
esac
export MACHINE_ID SCHEDULER STMP PARTITION QUEUE GW_FIXDIR

