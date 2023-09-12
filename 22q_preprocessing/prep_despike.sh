#!/bin/bash

# script to find resting BOLD in session_hcp.txt, copy nifti to a new number, and record in session_hcp_despike.txt

# sessions directory
sdir="/u/project/cbearden/data/22q/qunex_studyfolder/sessions"
for p in ${sdir}/Q_*; do
	# get resting BOLD nii number
	boldn=$(cat ${p}/session_hcp.txt | grep "^[0-9]" | grep "bold[0-9]" | grep "resting" | cut -d " " -f 1 | xargs)
	# make a new session file for despiked data
	cp -v ${p}/session_hcp.txt ${p}/session_hcp_despike.txt 
	echo "100${boldn} : bold100:restingDespike" >> ${p}/session_hcp_despike.txt 
	# write and submit script with despike command
	echo "/u/project/CCN/apps/abin/rh7/21.0.15/3dDespike -NEW -prefix ${p}/nii/100${boldn}.nii.gz ${p}/nii/${boldn}.nii.gz" > ${p}/nii/despike.sh
	qsub -cwd -V -o ${p}/nii/despike.log.o -e ${p}/nii/despike.log.e -l h_data=8G,h_rt=24:00:00,arch=intel*  ${p}/nii/despike.sh 
done