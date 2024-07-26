#!/bin/sh
echo 'GOCART-namelists.sh'
GOCART_NO3=${GOCART_NO3:-T}

####################################
# parse namelist
atparse < ${PATHRT}/parm/gocart/AERO_HISTORY.rc.IN > AERO_HISTORY.rc

####################################
# namelist files
files=$(ls ${PATHRT}/parm/gocart/*.rc) 
for f in ${files}; do
    cp ${f} .
done

