#!/bin/bash

# script to find resting BOLD in session_hcp.txt, copy nifti to a new number, and record in session_hcp_despike.txt

sdir="/u/project/cbearden/data/22q/qunex_studyfolder/sessions"
for p in ${sdir}/Q_*; do
	#i=$(basename $p)
	boldn=$(cat ${p}/session_hcp.txt | grep "^[0-9]" | grep "bold[0-9]" | grep "resting" | cut -d " " -f 1 | xargs)
	cp -v ${p}/nii/${boldn}.nii.gz ${p}/nii/100${boldn}.nii.gz 
	cp -v ${p}/session_hcp.txt ${p}/session_hcp_despike.txt 
	echo "100${boldn} : bold100:restingDespike" >> ${p}/session_hcp_despike.txt 
done