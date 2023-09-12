#!/bin/bash

# script to find resting BOLD in session_hcp.txt, copy nifti to a new number, and record in session_hcp_despike.txt

sdir="/u/project/cbearden/data/22q/qunex_studyfolder/sessions"
for p in ${sdir}/Q_*; do
	#i=$(basename $p)
	boldn=$(cat ${p}/session_hcp_despike.txt | grep "^[0-9]" | grep "bold[0-9]" | grep "restingDespike" | cut -d " " -f 1 | xargs)
	#echo "/u/project/CCN/apps/abin/rh7/21.0.15/3dDespike -NEW -prefix 200${boldn}.nii.gz ${p}/nii/${boldn}.nii.gz" > ${p}/nii/despike.sh
	#qsub -cwd -V -o ${p}/nii/despike.$(date +%s).o -e ${p}/nii/despike.$(date +%s).e -l h_data=16G,h_rt=24:00:00,arch=intel*  ${p}/nii/despike.sh 
	/u/project/CCN/apps/abin/rh7/21.0.15/3dDespike -NEW -prefix ${p}/nii/200${boldn}.nii.gz ${p}/nii/${boldn}.nii.gz
done



