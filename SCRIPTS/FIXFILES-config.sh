#!/bin/bash
set -u
[[ ${DEBUG} == T ]] && set -x
declare -rx PS4='+ $(basename ${BASH_SOURCE[0]:-${FUNCNAME[0]:-"Unknown"}})[${LINENO}]'
echo "FIXFILES-config.sh"
source ${PATHRT}/atparse.bash
target_f=${SCRIPT_DIR}/FIXFILES-link.sh

cat << EOF > ${target_f}
#!/bin/bash -u
# fixfiles for run. Link instead of copying because that takes forever
EOF
# grab stuff in run_test.sh
rt_f=${PATHRT}/run_test.sh
ln_start=$(grep -n '${FV3} == true ' ${rt_f} | head -n 1 | cut -d: -f1)
ln_end=$(( ln_start + 9 ))
ln_extra=$(( ln_end + 1 ))
sed -n "${ln_start},${ln_end}p;${ln_extra}q" ${rt_f} >> ${target_f}
# parse FV3_RUN file
atparse < ${PATHRT}/fv3_conf/${FV3_RUN} >> ${target_f}
# replace cp with ln -sf
sed -i "s:cp :ln -sf :g" ${target_f}
sed -i "s:mkdir INPUT RESTART:mkdir -p INPUT RESTART:g" ${target_f}
#
export RT_SUFFIX=DUMMY
chmod 755 ${target_f}
source ${target_f}
