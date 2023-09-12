#!/bin/bash

FSLDIR=/u/project/cbearden/data/scripts/tools/fsl-6.0.4
PATH=${FSLDIR}/bin:${PATH}
export FSLDIR PATH
. ${FSLDIR}/etc/fslconf/fsl.sh

niidir=/u/project/cbearden/data/22q_T1w_all/sessions/

for seshpath in ${niidir}/Q_* ;do
	sesh=$(basename $seshpath)	
	for i in ${seshpath}/nifti/*nii.gz;do
		bn=$(basename $i)
		fn=${bn%%.*}
		echo "... generating png image for ${i}"
		slicer $i -a ${seshpath}/${sesh}_nii_${fn}.png
	done
done