#!/bin/sh
echo 'GOCART-namelists.sh'
GOCART_NO3=${GOCART_NO3:-T}

####################################
# parse namelist
atparse < ${PATHRT}/parm/gocart/AERO_HISTORY.rc.IN > AERO_HISTORY.rc

####################################
# from g-w
# Path to the input data tree
machine=$( echo ${MACHINE_ID} | tr '[:lower:]' '[:upper:]' )
case ${machine} in
  "HERA")
    AERO_INPUTS_DIR="/scratch1/NCEPDEV/global/glopara/data/gocart_emissions"
    ;;
  "ORION" | "HERCULES")
    AERO_INPUTS_DIR="/work2/noaa/global/wkolczyn/noscrub/global-workflow/gocart_emissions"
    ;;
  "S4")
    AERO_INPUTS_DIR="/data/prod/glopara/gocart_emissions"
    ;;
  "WCOSS2")
    AERO_INPUTS_DIR="/lfs/h2/emc/global/noscrub/emc.global/data/gocart_emissions"
    ;;
  "GAEA")
    AERO_INPUTS_DIR="/gpfs/f5/epic/proj-shared/global/glopara/data/gocart_emissions"
    ;;
  "JET")
    AERO_INPUTS_DIR="/lfs4/HFIP/hfv3gfs/glopara/data/gocart_emissions"
    ;;
  *)
    echo "FATAL ERROR: Machine ${machine} unsupported for aerosols"
    exit 2
    ;;
esac
rm -f ExtData
ln -sf ${AERO_INPUTS_DIR} ExtData

####################################
# namelist files
files=$(ls ${PATHRT}/parm/gocart/*.rc) 
for f in ${files}; do
    cp ${f} .
done

####################################
# chanages to use g-w data
sed -i "s:dust:Dust:g" AERO_ExtData.rc
sed -i "s:QFED:nexus/QFED:g" AERO_ExtData.rc
sed -i "s:ExtData/CEDS:ExtData/nexus/CEDS:g" AERO_ExtData.rc
sed -i "s:ExtData/MEGAN_OFFLINE_BVOC:ExtData/nexus/MEGAN_OFFLINE_BVOC:g" AERO_ExtData.rc

