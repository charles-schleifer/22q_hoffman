#!/bin/sh

# C. Schleifer, 10/11/2021
# Script to submit job array for NAPLS2 T1w recon-all.sh
# Rerunning subjects with CCN install of freesurfer 5.3.0
# Requires raw T1w scans organized by $subject_$session/nifti/$scanname.nii.gz as output by organize_sessions.sh

# set up freesurfer
export FREESURFER_HOME=/u/project/CCN/apps/freesurfer/rh7/7.3.2/
source $FREESURFER_HOME/SetUpFreeSurfer.sh

# path to raw t1 data
t1dir=/u/project/cbearden/data/22q_T1w_all/sessions/
# path for freesurfer output
sdir=/u/project/cbearden/data/22q_T1w_all/sessions_recon-all/
mkdir -p $sdir/logs

# get array with all sessions in t1dir
seshArray=($(ls $t1dir))

# get indices for array
length=${#seshArray[@]}

# queue options
QUEUE="-l h_data=5G,h_rt=24:00:00"

echo -e "Using UGE to submit array of n=${length} recon-all jobs"
job=recon-all_array.$(date +"%s")
queuing_command="qsub -cwd -V -N ${job} -o ${sdir}/logs/ -e ${sdir}/logs/ -t 1-${length}:1 ${QUEUE}"
echo "queue command: ${queuing_command}"
$queuing_command /u/project/cbearden/data/22q_T1w_all/scripts/recon-all.sh $t1dir $sdir 
