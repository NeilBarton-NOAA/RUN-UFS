#!/bin/bash
set -u
echo 'JOB-config.sh'
UFS_EXEC=${UFS_EXEC:-${HOMEufs}/../bin/ufs_${RUN}}
JBNME=${TEST_NAME:-UFS}
WLCLK=${WALLCLOCK:-$WLCLK_dflt}
EXTRA_NODE=${EXTRA_NODE:-F}
WLCLK=${WLCLK%.*}
QUEUE=${JOB_QUEUE:-$QUEUE}
# Total Nodes
TPN=$(( TPN / THRD ))
if (( TASKS < TPN )); then
  TPN=${TASKS}
fi
NODES=$(( TASKS / TPN ))
if (( NODES * TPN < TASKS )); then
  NODES=$(( NODES + 1 ))
fi
TASKS=$(( NODES * TPN ))
if [[ ${EXTRA_NODE} == T ]]; then
  NODES=$(( NODES + 1 ))
fi

# copy needed items
module_file=ufs_${MACHINE_ID}.${RT_COMPILER}
mkdir -p modulefiles
cp ${PATHRT}/module-setup.sh .
cp ${HOMEufs}/modulefiles/${module_file}.lua modulefiles/modules.fv3.lua
cp ${HOMEufs}/modulefiles/ufs_common* modulefiles
cp ${UFS_EXEC} fv3.exe

# rm files if needed
[[ -f err ]] && rm err
[[ -f out ]] && rm out

# Create job_card
echo "  "fv3_${SCHEDULER}.IN_${MACHINE_ID} 
atparse < ${PATHRT}/fv3_conf/fv3_${SCHEDULER}.IN_${MACHINE_ID} > job_card
# add module purge options
ln=$(grep -wn "set +x" job_card | cut -d: -f1) && ln=$(( ln + 1 ))
sed -i "${ln} i export I_MPI_SHM_HEAP_VSIZE=16384" job_card && ln=$(( ln + 1 ))
sed -i "${ln} i module purge" job_card && ln=$(( ln + 1 ))
if [[ ${MACHINE_ID} == wcoss2* ]]; then #WCOSS2
    sed -i "${ln} i module reset" job_card
fi

