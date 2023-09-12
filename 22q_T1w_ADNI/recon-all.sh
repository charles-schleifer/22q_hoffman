#!/bin/sh

#=========================================================================================
# C. Schleifer, 4/15/2021
# Script to run recon-all on NAPLS2 T1w images
# Requires raw T1w scans organized by $subject_$session/nifti/$scanname.nii as output by organize_sessions.sh
# USAGE: <qrsh array command> recon-all.sh <t1dir> <sdir> <listfile>
#        <t1dir> is the directory containing raw t1s
#        <sdir> is output directory
#        <listfile> is space delimited txt file listing all IDs to process. This version skips listfile and uses all files in t1dir
#        this script should be executed by submit_recon-all_array.sh, not run directly
#=========================================================================================

export FREESURFER_HOME=/u/project/CCN/apps/freesurfer/rh7/7.3.2/
source $FREESURFER_HOME/SetUpFreeSurfer.sh


# get raw t1 dir, study dir, and text file listing subjects from command line args
t1dir=$1
sdir=$2
#listfile=$3

# read array of subjects
seshArray=($(ls $t1dir))

# chose session based on $SGE_TASK_ID
i=$(($SGE_TASK_ID - 1))
seshID=${seshArray[$i]}

#nscans=$(ls ${t1dir}/${seshID}/nifti | wc -l)

# run recon-all if not completed
log=$(tail -1 ${sdir}/${seshID}/scripts/recon-all-status.log)
if [[ ${log} == *"finished without error"* ]]; then
	echo $log
else
	if [[ ! -z "${seshID}" ]]; then
		rm -r ${sdir}/${seshID}
	fi
	scan1=${t1dir}/${seshID}/nifti/*.nii*
	recon-all -sd ${sdir} -subject ${seshID} -i ${scan1} -all	
fi








