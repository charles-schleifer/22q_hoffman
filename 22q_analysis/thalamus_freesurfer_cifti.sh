#!/bin/bash
# C. Schleifer  7, 2023
# Run thal/hipp/amy segmentation and convert thalamic ROI to CIFTI format

# set up freesurfer and FSL
export FREESURFER_HOME=/u/project/CCN/apps/freesurfer/rh7/7.3.2/
export SUBJECTS_DIR=$FREESURFER_HOME/subjects
source $FREESURFER_HOME/SetUpFreeSurfer.sh
FSLDIR=/u/project/cbearden/data/scripts/tools/fsl-6.0.4; PATH=${FSLDIR}/bin:${PATH}; export FSLDIR PATH;. ${FSLDIR}/etc/fslconf/fsl.sh

# list dirs to process
study_dirs="/u/project/cbearden/data/22q/qunex_studyfolder/sessions/ /u/project/cbearden/data/22qPrisma/qunex_studyfolder/sessions/"

# wb_command path
wb_command="/u/project/cbearden/data/scripts/tools/workbench/bin_rh_linux64/wb_command"

# cifti template to use
template="/u/project/cbearden/data/22q/qunex_studyfolder/analysis/fcMRI/roi/ColeAnticevicNetPartition-master/data/CortexSubcortex_ColeAnticevic_NetPartition_wSubcorGSR_netassignments_LR.dscalar.nii"

for study_dir in $study_dirs; do
	
	# get list of sessions to process
	seshpaths=$(ls -d $study_dir/Q_*)
	
	for path in $seshpaths; do
		echo $path
		
		# set up paths
		sesh=$(basename $path)
		hcp_dir=${study_dir}/${sesh}/hcp/${sesh}/
		subject_dir=${hcp_dir}/T1w/	
		mni_dir=${hcp_dir}/MNINonLinear/
		fsmri_dir=${subject_dir}/${sesh}/mri
		cifti_out=${subject_dir}/${sesh}/mri/ThalamicNuclei_Atlas_2mm.dscalar.nii
		echo "starting ${sesh}"
	

		# cross sectional freesurfer subregions
		echo "...segmenting thalamus"
		segment_subregions thalamus hippo-amygdala --cross $sesh --sd $subject_dir
		echo "...segmenting hippocampus and amygdala"
		segment_subregions hippo-amygdala --cross $sesh --sd $subject_dir
		
		# convert to nii
		echo "...converting thalamus to NIFTI"
		mri_convert -rt nearest -rl ${subject_dir}/T1w_acpc_dc_restore.nii.gz ${fsmri_dir}/ThalamicNuclei.mgz ${fsmri_dir}/ThalamicNuclei.nii.gz

		# warp to cifti space
		# https://groups.google.com/a/humanconnectome.org/g/hcp-users/c/4T9yVabLH94
		echo "...warping to native space T1w"
		applywarp --rel --interp=nn -i ${fsmri_dir}/ThalamicNuclei.nii.gz -r ${mni_dir}/T1w_restore.nii.gz -w ${mni_dir}/xfms/acpc_dc2standard.nii.gz -o ${fsmri_dir}/ThalamicNuclei_native.nii.gz
		echo "...warping to 2mm mesh"
		applywarp --interp=nn -i ${fsmri_dir}/ThalamicNuclei_native.nii.gz -r ${mni_dir}/ROIs/Atlas_ROIs.2.nii.gz -o ${fsmri_dir}/ThalamicNuclei_Atlas_2mm.nii.gz

		# convert to CIFTI
		echo "...creating ${cifti_out}"
		${wb_command} -cifti-create-dense-from-template $template $cifti_out -volume-all ${fsmri_dir}/ThalamicNuclei_Atlas_2mm.nii.gz
		echo "done"
		
	done
done

#logdir="/u/project/cbearden/data/22q/qunex_studyfolder/processing/logs/manual/"
#qsub -cwd -V -o ${logdir}/22q_thal_fs_cifti.$(date +%s).o -e ${logdir}/22q_thal_fs_cifti.$(date +%s).e -l h_data=32G,highp,h_rt=48:00:00,arch=intel*  /u/project/cbearden/data/22q/qunex_studyfolder/analysis/scripts/thalamus_freesurfer_cifti.sh