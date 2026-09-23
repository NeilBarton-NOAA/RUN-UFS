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
    "ursa")
        STMP=/scratch4/NCEPDEV/stmp/${USER}/RUNS
        GW_FIXDIR=/scratch3/NCEPDEV/global/role.glopara/fix
        RUNUFS_ICDIR=/scratch4/NCEPDEV/stmp/Neil.Barton/ICs/RUN_UFS
        SFS_ICDIR=/scratch4/NCEPDEV/global/Yangxing.Zheng/ICs
    ;;
    "orion")
        STMP=/work/noaa/marine/${USER}/RUNS
        GW_FIXDIR=/work/noaa/global/glopara/fix/
        TOP_ICDIR=/work/noaa/marine/nbarton/ICs/RUN_UFS
        SFS_ICDIR=/work/noaa/marine/Yangxing.Zheng/ICs
    ;;
    "hercules")
        STMP=/work/noaa/marine/${USER}/RUNS
        GW_FIXDIR=/work/noaa/global/glopara/fix/
        TOP_ICDIR=/work/noaa/marine/nbarton/ICs/RUN_UFS
        SFS_ICDIR=/work/noaa/marine/Yangxing.Zheng/ICs
    ;;
    "gaeac6")
        STMP=/gpfs/f6/sfs-emc/scratch/${USER}/RUNS
        GW_FIXDIR=/gpfs/f6/drsa-precip3/world-shared/role.glopara/fix/
        TOP_ICDIR=/gpfs/f6/sfs-emc/scratch/${USER}/ICs/RUN_UFS
        SFS_ICDIR=/gpfs/f6/sfs-emc/proj-shared/Yangxing.Zheng/SFS/ICs
    ;;
    "wcoss2")
        STMP=${STMP}/${USER}/RUNS
        GW_FIXDIR=/lfs/h2/emc/global/noscrub/emc.global/FIX/fix
        TOP_ICDIR=/lfs/h2/emc/couple/noscrub/neil.barton/ICs/RUN_UFS
        SFS_ICDIR=/lfs/h2/emc/couple/noscrub/neil.barton/ICs
    ;;
    *)
    echo "WARNING: MACHINE not set up"
    exit 1
    ;;
esac

SFS_ICDIR=${SFS_ICDIR}/CPC_landice

export MACHINE_ID SCHEDULER STMP PARTITION QUEUE GW_FIXDIR

