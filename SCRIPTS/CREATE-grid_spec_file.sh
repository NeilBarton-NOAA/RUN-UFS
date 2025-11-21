#!/bin/sh
set -u

FRE_NC_DIR=/scratch1/NCEPDEV/climate/Jiande.Wang/MOM6-FRE-NCtools/FRE-NCtools
MAKE_COUPLER_MOSAIC=${FRE_NC_DIR}/tools/make_coupler_mosaic/make_coupler_mosaic

RT_DIR=/scratch1/NCEPDEV/nems/emc.nemspara/RT/NEMSfv3gfs/input-data-20220414
ATM_MOSAIC=${RT_DIR}/FV3_input_data192/INPUT_L127/C192_mosaic.nc
OCN_MOSAIC=${RT_DIR}/MOM6_FIX/025/ocean_mosaic.nc 
OCN_TOPOG=${RT_DIR}/MOM6_FIX/025/topog.nc
${MAKE_COUPLER_MOSAIC} \
    --atmos_mosaic ${ATM_MOSAIC} \
    --ocean_mosaic ${OCN_MOSAIC} \
    --mosaic_name mosaic \
    --ocean_topog ${OCN_TOPOG} \
    --mosaic_name grid_spec 

