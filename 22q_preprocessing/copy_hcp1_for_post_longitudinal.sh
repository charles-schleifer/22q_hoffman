#!/bin/bash

# script to copy to target directory only the hcp directory materials expected after hcp1
# to be used for integrating fs longitudinal pipeline into hcp1-3

# get session id passed as argument
sesh=$1

# target directory
tgdir="/u/project/cbearden/data/22q/qunex_studyfolder/post_long_sessions/${sesh}/hcp/${sesh}"
mkdir -p ${tgdir}

# copy over unprocessed data
cp -rv /u/project/cbearden/data/22q/qunex_studyfolder/sessions/${sesh}/hcp/${sesh}/unprocessed ${tgdir}

mkdir -p ${tgdir}/T1w/
cp -v /u/project/cbearden/data/22q/qunex_studyfolder/sessions/${sesh}/hcp/${sesh}/T1w/T1w.nii.gz                       ${tgdir}/T1w/
cp -v /u/project/cbearden/data/22q/qunex_studyfolder/sessions/${sesh}/hcp/${sesh}/T1w/T1w_acpc.nii.gz                  ${tgdir}/T1w/
cp -v /u/project/cbearden/data/22q/qunex_studyfolder/sessions/${sesh}/hcp/${sesh}/T1w/T1w_acpc_brain_mask.nii.gz       ${tgdir}/T1w/
cp -v /u/project/cbearden/data/22q/qunex_studyfolder/sessions/${sesh}/hcp/${sesh}/T1w/T1w_acpc_brain.nii.gz            ${tgdir}/T1w/
cp -v /u/project/cbearden/data/22q/qunex_studyfolder/sessions/${sesh}/hcp/${sesh}/T1w/T1w_acpc_dc.nii.gz               ${tgdir}/T1w/
cp -v /u/project/cbearden/data/22q/qunex_studyfolder/sessions/${sesh}/hcp/${sesh}/T1w/T1w_acpc_dc_brain.nii.gz         ${tgdir}/T1w/
cp -v /u/project/cbearden/data/22q/qunex_studyfolder/sessions/${sesh}/hcp/${sesh}/T1w/T1w_acpc_dc_restore.nii.gz       ${tgdir}/T1w/
cp -v /u/project/cbearden/data/22q/qunex_studyfolder/sessions/${sesh}/hcp/${sesh}/T1w/T1w_acpc_dc_restore_brain.nii.gz ${tgdir}/T1w/
cp -v /u/project/cbearden/data/22q/qunex_studyfolder/sessions/${sesh}/hcp/${sesh}/T1w/BiasField_acpc_dc.nii.gz         ${tgdir}/T1w/
cp -v /u/project/cbearden/data/22q/qunex_studyfolder/sessions/${sesh}/hcp/${sesh}/T1w/T1w1_gdc.nii.gz                  ${tgdir}/T1w/

mkdir -p ${tgdir}/T1w/xfms
cp -v /u/project/cbearden/data/22q/qunex_studyfolder/sessions/${sesh}/hcp/${sesh}/T1w/xfms/acpc.mat                 ${tgdir}/T1w/xfms
cp -v /u/project/cbearden/data/22q/qunex_studyfolder/sessions/${sesh}/hcp/${sesh}/T1w/xfms/T1w_dc.nii.gz            ${tgdir}/T1w/xfms
cp -v /u/project/cbearden/data/22q/qunex_studyfolder/sessions/${sesh}/hcp/${sesh}/T1w/xfms/OrigT1w2T1w_PreFS.nii.gz ${tgdir}/T1w/xfms

mkdir -p ${tgdir}/T1w/ACPCAlignment
cp -v /u/project/cbearden/data/22q/qunex_studyfolder/sessions/${sesh}/hcp/${sesh}/T1w/ACPCAlignment/log.txt           ${tgdir}/T1w/ACPCAlignment
cp -v /u/project/cbearden/data/22q/qunex_studyfolder/sessions/${sesh}/hcp/${sesh}/T1w/ACPCAlignment/roi2full.mat      ${tgdir}/T1w/ACPCAlignment
cp -v /u/project/cbearden/data/22q/qunex_studyfolder/sessions/${sesh}/hcp/${sesh}/T1w/ACPCAlignment/robustroi.nii.gz  ${tgdir}/T1w/ACPCAlignment
cp -v /u/project/cbearden/data/22q/qunex_studyfolder/sessions/${sesh}/hcp/${sesh}/T1w/ACPCAlignment/full2roi.mat      ${tgdir}/T1w/ACPCAlignment
cp -v /u/project/cbearden/data/22q/qunex_studyfolder/sessions/${sesh}/hcp/${sesh}/T1w/ACPCAlignment/roi2std.mat       ${tgdir}/T1w/ACPCAlignment
cp -v /u/project/cbearden/data/22q/qunex_studyfolder/sessions/${sesh}/hcp/${sesh}/T1w/ACPCAlignment/acpc_final.nii.gz ${tgdir}/T1w/ACPCAlignment
cp -v /u/project/cbearden/data/22q/qunex_studyfolder/sessions/${sesh}/hcp/${sesh}/T1w/ACPCAlignment/full2std.mat      ${tgdir}/T1w/ACPCAlignment
cp -v /u/project/cbearden/data/22q/qunex_studyfolder/sessions/${sesh}/hcp/${sesh}/T1w/ACPCAlignment/qa.txt            ${tgdir}/T1w/ACPCAlignment

mkdir -p ${tgdir}/T1w/BrainExtraction_FNIRTbased
cp -v /u/project/cbearden/data/22q/qunex_studyfolder/sessions/${sesh}/hcp/${sesh}/T1w/BrainExtraction_FNIRTbased/log.txt                         ${tgdir}/T1w/BrainExtraction_FNIRTbased
cp -v /u/project/cbearden/data/22q/qunex_studyfolder/sessions/${sesh}/hcp/${sesh}/T1w/BrainExtraction_FNIRTbased/roughlin.mat                    ${tgdir}/T1w/BrainExtraction_FNIRTbased
cp -v /u/project/cbearden/data/22q/qunex_studyfolder/sessions/${sesh}/hcp/${sesh}/T1w/BrainExtraction_FNIRTbased/T1w_acpc_to_MNI_roughlin.nii.gz ${tgdir}/T1w/BrainExtraction_FNIRTbased
cp -v /u/project/cbearden/data/22q/qunex_studyfolder/sessions/${sesh}/hcp/${sesh}/T1w/BrainExtraction_FNIRTbased/NonlinearReg.txt                ${tgdir}/T1w/BrainExtraction_FNIRTbased
cp -v /u/project/cbearden/data/22q/qunex_studyfolder/sessions/${sesh}/hcp/${sesh}/T1w/BrainExtraction_FNIRTbased/NonlinearReg.nii.gz             ${tgdir}/T1w/BrainExtraction_FNIRTbased
cp -v /u/project/cbearden/data/22q/qunex_studyfolder/sessions/${sesh}/hcp/${sesh}/T1w/BrainExtraction_FNIRTbased/str2standard.nii.gz             ${tgdir}/T1w/BrainExtraction_FNIRTbased
cp -v /u/project/cbearden/data/22q/qunex_studyfolder/sessions/${sesh}/hcp/${sesh}/T1w/BrainExtraction_FNIRTbased/NonlinearRegJacobians.nii.gz    ${tgdir}/T1w/BrainExtraction_FNIRTbased
cp -v /u/project/cbearden/data/22q/qunex_studyfolder/sessions/${sesh}/hcp/${sesh}/T1w/BrainExtraction_FNIRTbased/IntensityModulatedT1.nii.gz     ${tgdir}/T1w/BrainExtraction_FNIRTbased
cp -v /u/project/cbearden/data/22q/qunex_studyfolder/sessions/${sesh}/hcp/${sesh}/T1w/BrainExtraction_FNIRTbased/NonlinearIntensities.nii.gz.txt ${tgdir}/T1w/BrainExtraction_FNIRTbased
cp -v /u/project/cbearden/data/22q/qunex_studyfolder/sessions/${sesh}/hcp/${sesh}/T1w/BrainExtraction_FNIRTbased/NonlinearIntensities.nii.gz     ${tgdir}/T1w/BrainExtraction_FNIRTbased
cp -v /u/project/cbearden/data/22q/qunex_studyfolder/sessions/${sesh}/hcp/${sesh}/T1w/BrainExtraction_FNIRTbased/T1w_acpc_to_MNI_nonlin.nii.gz   ${tgdir}/T1w/BrainExtraction_FNIRTbased
cp -v /u/project/cbearden/data/22q/qunex_studyfolder/sessions/${sesh}/hcp/${sesh}/T1w/BrainExtraction_FNIRTbased/standard2str.nii.gz             ${tgdir}/T1w/BrainExtraction_FNIRTbased
cp -v /u/project/cbearden/data/22q/qunex_studyfolder/sessions/${sesh}/hcp/${sesh}/T1w/BrainExtraction_FNIRTbased/qa.txt                          ${tgdir}/T1w/BrainExtraction_FNIRTbased

mkdir -p ${tgdir}/T1w/BiasFieldCorrection_T1wOnly.anat
cp -v /u/project/cbearden/data/22q/qunex_studyfolder/sessions/${sesh}/hcp/${sesh}/T1w/BiasFieldCorrection_T1wOnly.anat/log.txt                           ${tgdir}/T1w/BiasFieldCorrection_T1wOnly.anat
cp -v /u/project/cbearden/data/22q/qunex_studyfolder/sessions/${sesh}/hcp/${sesh}/T1w/BiasFieldCorrection_T1wOnly.anat/T1.nii.gz                         ${tgdir}/T1w/BiasFieldCorrection_T1wOnly.anat
cp -v /u/project/cbearden/data/22q/qunex_studyfolder/sessions/${sesh}/hcp/${sesh}/T1w/BiasFieldCorrection_T1wOnly.anat/lesionmask.nii.gz                 ${tgdir}/T1w/BiasFieldCorrection_T1wOnly.anat
cp -v /u/project/cbearden/data/22q/qunex_studyfolder/sessions/${sesh}/hcp/${sesh}/T1w/BiasFieldCorrection_T1wOnly.anat/lesionmaskinv.nii.gz              ${tgdir}/T1w/BiasFieldCorrection_T1wOnly.anat
cp -v /u/project/cbearden/data/22q/qunex_studyfolder/sessions/${sesh}/hcp/${sesh}/T1w/BiasFieldCorrection_T1wOnly.anat/T1_initfast2_brain.nii.gz         ${tgdir}/T1w/BiasFieldCorrection_T1wOnly.anat
cp -v /u/project/cbearden/data/22q/qunex_studyfolder/sessions/${sesh}/hcp/${sesh}/T1w/BiasFieldCorrection_T1wOnly.anat/T1_initfast2_brain_mask.nii.gz    ${tgdir}/T1w/BiasFieldCorrection_T1wOnly.anat
cp -v /u/project/cbearden/data/22q/qunex_studyfolder/sessions/${sesh}/hcp/${sesh}/T1w/BiasFieldCorrection_T1wOnly.anat/T1_initfast2_restore.nii.gz       ${tgdir}/T1w/BiasFieldCorrection_T1wOnly.anat
cp -v /u/project/cbearden/data/22q/qunex_studyfolder/sessions/${sesh}/hcp/${sesh}/T1w/BiasFieldCorrection_T1wOnly.anat/T1_initfast2_maskedrestore.nii.gz ${tgdir}/T1w/BiasFieldCorrection_T1wOnly.anat
cp -v /u/project/cbearden/data/22q/qunex_studyfolder/sessions/${sesh}/hcp/${sesh}/T1w/BiasFieldCorrection_T1wOnly.anat/T1_fast_seg.nii.gz                ${tgdir}/T1w/BiasFieldCorrection_T1wOnly.anat
cp -v /u/project/cbearden/data/22q/qunex_studyfolder/sessions/${sesh}/hcp/${sesh}/T1w/BiasFieldCorrection_T1wOnly.anat/T1_fast_restore.nii.gz            ${tgdir}/T1w/BiasFieldCorrection_T1wOnly.anat
cp -v /u/project/cbearden/data/22q/qunex_studyfolder/sessions/${sesh}/hcp/${sesh}/T1w/BiasFieldCorrection_T1wOnly.anat/T1_fast_bias.nii.gz               ${tgdir}/T1w/BiasFieldCorrection_T1wOnly.anat
cp -v /u/project/cbearden/data/22q/qunex_studyfolder/sessions/${sesh}/hcp/${sesh}/T1w/BiasFieldCorrection_T1wOnly.anat/T1_fast_totbias.nii.gz            ${tgdir}/T1w/BiasFieldCorrection_T1wOnly.anat
cp -v /u/project/cbearden/data/22q/qunex_studyfolder/sessions/${sesh}/hcp/${sesh}/T1w/BiasFieldCorrection_T1wOnly.anat/T1_initfast2_brain_mask2.nii.gz   ${tgdir}/T1w/BiasFieldCorrection_T1wOnly.anat
cp -v /u/project/cbearden/data/22q/qunex_studyfolder/sessions/${sesh}/hcp/${sesh}/T1w/BiasFieldCorrection_T1wOnly.anat/T1_fast_bias_init.nii.gz          ${tgdir}/T1w/BiasFieldCorrection_T1wOnly.anat
cp -v /u/project/cbearden/data/22q/qunex_studyfolder/sessions/${sesh}/hcp/${sesh}/T1w/BiasFieldCorrection_T1wOnly.anat/T1_fast_bias_vol2.nii.gz          ${tgdir}/T1w/BiasFieldCorrection_T1wOnly.anat
cp -v /u/project/cbearden/data/22q/qunex_studyfolder/sessions/${sesh}/hcp/${sesh}/T1w/BiasFieldCorrection_T1wOnly.anat/T1_fast_bias_vol32.nii.gz         ${tgdir}/T1w/BiasFieldCorrection_T1wOnly.anat
cp -v /u/project/cbearden/data/22q/qunex_studyfolder/sessions/${sesh}/hcp/${sesh}/T1w/BiasFieldCorrection_T1wOnly.anat/T1_fast_bias_idxmask.nii.gz       ${tgdir}/T1w/BiasFieldCorrection_T1wOnly.anat
cp -v /u/project/cbearden/data/22q/qunex_studyfolder/sessions/${sesh}/hcp/${sesh}/T1w/BiasFieldCorrection_T1wOnly.anat/T1_biascorr.nii.gz                ${tgdir}/T1w/BiasFieldCorrection_T1wOnly.anat
cp -v /u/project/cbearden/data/22q/qunex_studyfolder/sessions/${sesh}/hcp/${sesh}/T1w/BiasFieldCorrection_T1wOnly.anat/T1_biascorr_brain.nii.gz          ${tgdir}/T1w/BiasFieldCorrection_T1wOnly.anat
cp -v /u/project/cbearden/data/22q/qunex_studyfolder/sessions/${sesh}/hcp/${sesh}/T1w/BiasFieldCorrection_T1wOnly.anat/T1_biascorr_brain_mask.nii.gz     ${tgdir}/T1w/BiasFieldCorrection_T1wOnly.anat
cp -v /u/project/cbearden/data/22q/qunex_studyfolder/sessions/${sesh}/hcp/${sesh}/T1w/BiasFieldCorrection_T1wOnly.anat/qa.txt                            ${tgdir}/T1w/BiasFieldCorrection_T1wOnly.anat

mkdir -p ${tgdir}/T1w/T2w
mkdir -p ${tgdir}/T1w/T2w/xfms
mkdir -p ${tgdir}/T1w/T2w/T2wToT1wReg
cp -v /u/project/cbearden/data/22q/qunex_studyfolder/sessions/${sesh}/hcp/${sesh}/T2w/T2wToT1wReg/T1w_acpc_brain.nii.gz ${tgdir}/T1w/T2w/T2wToT1wReg

mkdir -p ${tgdir}/MNINonLinear
cp -v /u/project/cbearden/data/22q/qunex_studyfolder/sessions/${sesh}/hcp/${sesh}/MNINonLinear/T1w.nii.gz               ${tgdir}/MNINonLinear
cp -v /u/project/cbearden/data/22q/qunex_studyfolder/sessions/${sesh}/hcp/${sesh}/MNINonLinear/T1w_restore.nii.gz       ${tgdir}/MNINonLinear
cp -v /u/project/cbearden/data/22q/qunex_studyfolder/sessions/${sesh}/hcp/${sesh}/MNINonLinear/T1w_restore_brain.nii.gz ${tgdir}/MNINonLinear

mkdir -p ${tgdir}/MNINonLinear/xfms
cp -v /u/project/cbearden/data/22q/qunex_studyfolder/sessions/${sesh}/hcp/${sesh}/MNINonLinear/xfms/log.txt                                       ${tgdir}/MNINonLinear/xfms
cp -v /u/project/cbearden/data/22q/qunex_studyfolder/sessions/${sesh}/hcp/${sesh}/MNINonLinear/xfms/acpc2MNILinear.mat                            ${tgdir}/MNINonLinear/xfms
cp -v /u/project/cbearden/data/22q/qunex_studyfolder/sessions/${sesh}/hcp/${sesh}/MNINonLinear/xfms/T1w_acpc_dc_restore_brain_to_MNILinear.nii.gz ${tgdir}/MNINonLinear/xfms
cp -v /u/project/cbearden/data/22q/qunex_studyfolder/sessions/${sesh}/hcp/${sesh}/MNINonLinear/xfms/NonlinearReg.txt                              ${tgdir}/MNINonLinear/xfms
cp -v /u/project/cbearden/data/22q/qunex_studyfolder/sessions/${sesh}/hcp/${sesh}/MNINonLinear/xfms/NonlinearReg.nii.gz                           ${tgdir}/MNINonLinear/xfms
cp -v /u/project/cbearden/data/22q/qunex_studyfolder/sessions/${sesh}/hcp/${sesh}/MNINonLinear/xfms/acpc_dc2standard.nii.gz                       ${tgdir}/MNINonLinear/xfms
cp -v /u/project/cbearden/data/22q/qunex_studyfolder/sessions/${sesh}/hcp/${sesh}/MNINonLinear/xfms/NonlinearRegJacobians.nii.gz                  ${tgdir}/MNINonLinear/xfms
cp -v /u/project/cbearden/data/22q/qunex_studyfolder/sessions/${sesh}/hcp/${sesh}/MNINonLinear/xfms/IntensityModulatedT1.nii.gz                   ${tgdir}/MNINonLinear/xfms
cp -v /u/project/cbearden/data/22q/qunex_studyfolder/sessions/${sesh}/hcp/${sesh}/MNINonLinear/xfms/NonlinearIntensities.nii.gz.txt               ${tgdir}/MNINonLinear/xfms
cp -v /u/project/cbearden/data/22q/qunex_studyfolder/sessions/${sesh}/hcp/${sesh}/MNINonLinear/xfms/NonlinearIntensities.nii.gz                   ${tgdir}/MNINonLinear/xfms
cp -v /u/project/cbearden/data/22q/qunex_studyfolder/sessions/${sesh}/hcp/${sesh}/MNINonLinear/xfms/2mmReg.nii.gz                                 ${tgdir}/MNINonLinear/xfms
cp -v /u/project/cbearden/data/22q/qunex_studyfolder/sessions/${sesh}/hcp/${sesh}/MNINonLinear/xfms/standard2acpc_dc.nii.gz                       ${tgdir}/MNINonLinear/xfms
cp -v /u/project/cbearden/data/22q/qunex_studyfolder/sessions/${sesh}/hcp/${sesh}/MNINonLinear/xfms/qa.txt                                        ${tgdir}/MNINonLinear/xfms

echo "${sesh}: COMPLETE"
