#!/bin/sh

logdir="/u/project/cbearden/data/22q/qunex_studyfolder/processing/logs/manual/"
qsub -cwd -V -o ${logdir}/22q_thal_fs_cifti.$(date +%s).o -e ${logdir}/22q_thal_fs_cifti.$(date +%s).e -l h_data=32G,highp,h_rt=48:00:00,arch=intel*  /u/project/cbearden/data/22q/qunex_studyfolder/analysis/scripts/thalamus_freesurfer_cifti.sh
