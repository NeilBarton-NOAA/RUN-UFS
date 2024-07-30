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

####################################
# RT test are set up to run nitrates, we are not
sed -i "/'NIEXTTAU'      , 'NI'       , 'AOD_NI',/d" AERO_HISTORY.rc
sed -i "/'inst_ni'/d" AERO_HISTORY.rc
sed -i "/'inst_ni_bin'/d" AERO_HISTORY.rc
sed -i "/NH3,NI                  nh3/d" CAP.rc
sed -i "/NH4a,NI                 nh4a/d" CAP.rc
sed -i "/NO3an1,NI               no3an1/d" CAP.rc
sed -i "/NO3an2,NI               no3an2/d" CAP.rc
sed -i "/NO3an3,NI               no3an3/d" CAP.rc
sed -i "s/alpha: 0.039/alpha: 0.04/g" DU2G_instance_DU.rc
sed -i "s/gamma: 0.8/gamma: 1.0/g" DU2G_instance_DU.rc
sed -i "s/ACTIVE_INSTANCES_NI:  NI  # NI.data/ACTIVE_INSTANCES_NI:/g" GOCART2G_GridComp.rc
cp ${SCRIPT_DIR}/field_table_thompson_noaero_tke_GOCART_NONITRATES field_table 
