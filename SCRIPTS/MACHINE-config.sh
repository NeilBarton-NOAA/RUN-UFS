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

if [[ ${MACHINE_ID} == hercules ]]; then
    STMP=/work/noaa/marine/${USER}/RUNS
    TOP_ICDIR=/work/noaa/marine/nbarton/ICs/REPLAY_ICs
else
    STMP=${STMP%%${USER}*}/${USER}/RUNS
    TOP_ICDIR=${STMP}/ICs/REPLAY_ICs
fi
export MACHINE_ID SCHEDULER STMP PARTITION QUEUE

