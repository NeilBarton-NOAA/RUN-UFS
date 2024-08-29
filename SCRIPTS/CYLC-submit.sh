#!/bin/bash
set -u

JOB_CARD=${RUNDIR}/job_card
cp ${JOB_CARD} ${JOB_CARD}_orig
echo ${JOB_CARD}
sed -i "/SBATCH/d" ${JOB_CARD}

chmod 755 ${JOB_CARD}
cd $( dirname ${JOB_CARD} )
./job_card
