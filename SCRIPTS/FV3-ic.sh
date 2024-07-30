#!/bin/bash
####################################
set -u
echo 'FV3-ic.sh'
ICDIR=${ICDIR}
####################################
# first remove possible restart data
rm -f INPUT/*sfc_data*nc INPUT/*gfs_data*.nc INPUT/gfs_ctrl.nc
rm -f INPUT/*ca_data*nc INPUT/*fv_core.res*nc INPUT/*fv_srf_wnd.res*nc INPUT/*fv_tracer*nc INPUT/*phy_data*nc 

n_files=$( find -L ${ICDIR} -name "*sfc_data*nc" 2>/dev/null | wc -l )
if (( ${n_files} == 0 )); then
    echo '  FATAL: no atm ICs found in:' ${ICDIR}
    exit 1
fi
n_files=$( find -L ${ICDIR} -name "*gfs_data*.nc" 2>/dev/null | wc -l)
if (( ${n_files} == ${NTILES} )); then
    echo "  FV3 Cold Start"
    WARM_START=.false.
    PREFIXS="gfs_data sfc_data"
    for t in $(seq ${NTILES}); do
        for v in ${PREFIXS}; do
            f=$( find -L ${ICDIR} -name "${v}.tile${t}.nc" )
            ln -sf ${f} INPUT/
        done
    done
    f=$( find -L ${ICDIR} -name "gfs_ctrl.nc" )
    ln -sf ${f} INPUT/
else #ATM WARMSTART
    echo "  FV3 Warm Start"
    WARM_START=.false.
    warm_files='*ca_data*nc \
                *fv_core.res*nc \
                *fv_srf_wnd.res*nc \
                *fv_tracer*nc \
                *phy_data*nc \
                *sfc_data*nc'
    for warm_file in ${warm_files}; do
        files=$( find -L ${ICDIR} -name "${warm_file}" )
        for atm_ic in ${files}; do
            f=$( basename ${atm_ic} )
            if [[ ${f:11:4} == '0000' ]]; then
                f=${f:16}
            fi
            ln -sf ${atm_ic} INPUT/${f}
        done
    done
    # make coupler.res file
    cat >> INPUT/coupler.res << EOF
    cat >> INPUT/coupler.res << EOF
 3        (Calendar: no_calendar=0, thirty_day_months=1, julian=2, gregorian=3, noleap=4)
 ${SYEAR}  ${SMONTH}  ${SDAY}  ${SHOUR}     0     0        Model start time:   year, month, day, hour, minute, second
 ${SYEAR}  ${SMONTH}  ${SDAY}  ${SHOUR}     0     0        Current model time: year, month, day, hour, minute, second
EOF
fi #cold start/warm start

