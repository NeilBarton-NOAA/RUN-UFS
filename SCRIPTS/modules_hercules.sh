#!/bin/sh
set -u
set +x
#module purge
module use -a /home/nbarton/TOOLS/modulefiles
module load conda
#module load nco
set -x
