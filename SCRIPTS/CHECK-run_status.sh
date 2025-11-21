#!/bin/sh
set -eu
########################
# remove Regression Testings
########################

TOPDIR=${NPB_WORKDIR}/RUNS/UFS
delete=F
clean=F

show_help(){
echo "This script check the directories that have RT runs and either"
echo "  list them "
echo "  delete them or "
echo "  cleans/removes the large files"
echo "OPTIONS:"
echo "  -l  : controls top directory to search for runs (default ${TOPDIR})"
echo "  -d  : deletes the directories in which the runs did not complete (default False)"
echo "  -c  : cleans/deletes large files rom the directories (default False)"
echo ""
echo "No options lists the directories that did not finish the forecast run"
}
while getopts "d:rch" flag; do
    case "${flag}" in
        d)  TOPDIR=${OPTARG};;
        r)  delete=T;;
        c)  clean=T;;
        h)  show_help; exit 0;;
        *)  show_help; exit 0;;
    esac
done

ds=$(ls -d $TOPDIR/*/)
print=T
for d in $ds; do
  if [[ $clean == T ]]; then
    [[ $print == T ]] && echo 'Removing Large Files:'; print=F
    echo $d
    rm ${d}/*nc 2>/dev/null
    rm ${d}/RESTART/*nc 2>/dev/null
    rm ${d}/INPUT/*nc 2>/dev/null
    rm ${d}/history/*nc 2>/dev/null
  elif [[ ! -f $d/ESMF_Profile.summary ]]; then
    if [[ $delete == T ]]; then 
        [[ $print == T ]] && echo 'Removing:'
        echo $d
        rm -r $d
    else
        [[ $print == T ]] && echo 'Did Not Finish:'
        echo $d
    fi
    print=F 
  fi
done

[[ $print == T ]] && echo 'No Unfinished Runs Found at '$TOPDIR
