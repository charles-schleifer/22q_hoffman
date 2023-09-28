#!/bin/sh

# C. Schleifer 11/03/22
# catch new subjects up with preprocessing

#####################################################################
### organize and prepare data
#####################################################################

## organize raw dicoms into inbox/MR
# automatically copies all scans not already in sessions folder or included list of excluded sessions
# note: if the paths to the raw data change substantially you will need to edit this script
logdir="/u/project/cbearden/data/22qPrisma/qunex_studyfolder/processing/logs/manual"
qsub -cwd -V -o ${logdir}/dicom_copy.o -e ${logdir}/dicom_copy.e -l h_data=8G,h_rt=24:00:00 /u/project/cbearden/data/22qPrisma/qunex_studyfolder/processing/scripts/prisma_copy_raw_dicoms_2023.sh

## import DICOMs 
/u/project/cbearden/data/scripts/tools/qunex_bin/hoffman_submit_qunex.sh \
--qunex_command="import_dicom" \
--qunex_options="--sessionsfolder=/u/project/cbearden/data/22qPrisma/qunex_studyfolder/sessions --gzip=yes --check=any" \
--scheduler_options="-l h_data=16G,h_rt=5:00:00" \
--logdir="/u/project/cbearden/data/22qPrisma/qunex_studyfolder/processing/logs/manual" \
--array="no" 

## HCP mapping
# note, using new mapping file that differentiates AP and PA
/u/project/cbearden/data/scripts/tools/qunex_bin/hoffman_submit_qunex.sh \
--qunex_command="create_session_info" \
--qunex_options="--overwrite=no --sourcefile=session.txt --targetfile=session_hcp.txt --pipelines=hcp --mapping=/u/project/cbearden/data/22qPrisma/qunex_studyfolder/sessions/specs/22qPrisma_HCP_mapping_AP_PA.txt --sessionsfolder=/u/project/cbearden/data/22qPrisma/qunex_studyfolder/sessions/" \
--scheduler_options="-l h_data=8G,h_rt=1:00:00" \
--logdir="/u/project/cbearden/data/22qPrisma/qunex_studyfolder/processing/logs/manual" \
--array="no" 

# run script to comment out second T1w and T2w (each session has two copies of each, with and without intensity normalization)
# same script fixes subject header in session_hcp.txt
# TO DO: paste in list of sessions separated by spaces
sessions=" "
bash /u/project/cbearden/data/22qPrisma/qunex_studyfolder/processing/scripts/edit_session_hcp.sh --sessions="${sessions}" --seshdir="/u/project/cbearden/data/22qPrisma/qunex_studyfolder/sessions/" 

## Setup HCP
# TO DO: paste in list of sessions (separated by spaces) for all following commands
/u/project/cbearden/data/scripts/tools/qunex_bin/hoffman_submit_qunex.sh \
--qunex_command="setup_hcp" \
--qunex_options="--sessionsfolder=/u/project/cbearden/data/22qPrisma/qunex_studyfolder/sessions --sourcefile=session_hcp.txt" \
--scheduler_options="-l h_data=16G,h_rt=1:00:00" \
--logdir="/u/project/cbearden/data/22qPrisma/qunex_studyfolder/processing/logs/manual" \
--array="yes" \
--sessions=" "

## create batch file
# TO DO: paste in list of sessions in qunex_options separated by commas
/u/project/cbearden/data/scripts/tools/qunex_bin/hoffman_submit_qunex.sh \
--qunex_command="create_batch" \
--qunex_options=" --overwrite=yes --sessionsfolder=/u/project/cbearden/data/22qPrisma/qunex_studyfolder/sessions --sourcefiles=session_hcp.txt --targetfile=/u/project/cbearden/data/22qPrisma/qunex_studyfolder/processing/22qPrisma_batch_new2023.txt --paramfile=/u/project/cbearden/data/22qPrisma/qunex_studyfolder/sessions/specs/22qPrisma_params.txt --sessions=" \
--scheduler_options="-l h_data=4G,h_rt=1:00:00" \
--logdir="/u/project/cbearden/data/22qPrisma/qunex_studyfolder/processing/logs/manual" \
--array="no" 


#####################################################################
### HCP steps
#####################################################################

# HCP preprocess subjects with T1w + T2w
## PreFreeSurfer
/u/project/cbearden/data/scripts/tools/qunex_bin/hoffman_submit_qunex.sh \
--qunex_command="hcp_pre_freesurfer" \
--qunex_options="--sessions=/u/project/cbearden/data/22qPrisma/qunex_studyfolder/processing/22qPrisma_batch_new2023.txt --sessionsfolder=/u/project/cbearden/data/22qPrisma/qunex_studyfolder/sessions --parsessions=1 --overwrite=no" \
--scheduler_options="-l h_data=16G,h_rt=24:00:00,arch=intel*" \
--logdir="/u/project/cbearden/data/22qPrisma/qunex_studyfolder/processing/logs/manual" \
--array="yes" \
--sessions=" "

## FreeSurfer
/u/project/cbearden/data/scripts/tools/qunex_bin/hoffman_submit_qunex.sh \
--qunex_command="hcp_freesurfer" \
--qunex_options="--sessions=/u/project/cbearden/data/22qPrisma/qunex_studyfolder/processing/22qPrisma_batch_new2023.txt --sessionsfolder=/u/project/cbearden/data/22qPrisma/qunex_studyfolder/sessions --parsessions=1 --overwrite=no" \
--scheduler_options="-l h_data=16G,h_rt=48:00:00,highp,arch=intel*" \
--logdir="/u/project/cbearden/data/22qPrisma/qunex_studyfolder/processing/logs/manual" \
--array="yes" \
--sessions=" "

## PostFreeSurfer
/u/project/cbearden/data/scripts/tools/qunex_bin/hoffman_submit_qunex.sh \
--qunex_command="hcp_post_freesurfer" \
--qunex_options="--sessions=/u/project/cbearden/data/22qPrisma/qunex_studyfolder/processing/22qPrisma_batch_new2023.txt --sessionsfolder=/u/project/cbearden/data/22qPrisma/qunex_studyfolder/sessions --parsessions=1 --overwrite=no" \
--scheduler_options="-l h_data=16G,h_rt=24:00:00,arch=intel*" \
--logdir="/u/project/cbearden/data/22qPrisma/qunex_studyfolder/processing/logs/manual" \
--array="yes" \
--sessions=" "

## FMRI VOLUME
/u/project/cbearden/data/scripts/tools/qunex_bin/hoffman_submit_qunex.sh \
--qunex_command="hcp_fmri_volume" \
--qunex_options="--sessions=/u/project/cbearden/data/22qPrisma/qunex_studyfolder/processing/22qPrisma_batch_new2023.txt --sessionsfolder=/u/project/cbearden/data/22qPrisma/qunex_studyfolder/sessions --parsessions=1 --overwrite=no" \
--scheduler_options="-l h_data=16G,h_rt=24:00:00,arch=intel*" \
--logdir="/u/project/cbearden/data/22qPrisma/qunex_studyfolder/processing/logs/manual" \
--array="yes" \
--sessions=" "

## FMRI SURFACE
/u/project/cbearden/data/scripts/tools/qunex_bin/hoffman_submit_qunex.sh \
--qunex_command="hcp_fmri_surface" \
--qunex_options="--sessions=/u/project/cbearden/data/22qPrisma/qunex_studyfolder/processing/22qPrisma_batch_new2023.txt --sessionsfolder=/u/project/cbearden/data/22qPrisma/qunex_studyfolder/sessions --parsessions=1 --overwrite=no" \
--scheduler_options="-l h_data=16G,h_rt=24:00:00,arch=intel*" \
--logdir="/u/project/cbearden/data/22qPrisma/qunex_studyfolder/processing/logs/manual" \
--array="yes" \
--sessions=" "


# TO DO: find sessions missing T2w

# make a batch file for these sessions
# TO DO: comma separated list of sessions in qunex_options
/u/project/cbearden/data/scripts/tools/qunex_bin/hoffman_submit_qunex.sh \
--qunex_command="create_batch" \
--qunex_options=" --overwrite=yes --sessionsfolder=/u/project/cbearden/data/22qPrisma/qunex_studyfolder/sessions --sourcefiles=session_hcp.txt --targetfile=/u/project/cbearden/data/22qPrisma/qunex_studyfolder/processing/22qPrisma_batch_no_t2_2023.txt --paramfile=/u/project/cbearden/data/22qPrisma/qunex_studyfolder/sessions/specs/22qPrisma_params_no_t2.txt --sessions=" \
--scheduler_options="-l h_data=4G,h_rt=4:00:00" \
--logdir="/u/project/cbearden/data/22qPrisma/qunex_studyfolder/processing/logs/manual" \
--array="no" 

## PreFreeSurfer
/u/project/cbearden/data/scripts/tools/qunex_bin/hoffman_submit_qunex.sh \
--qunex_command="hcp_pre_freesurfer" \
--qunex_options="--hcp_processing_mode=LegacyStyleData --sessions=/u/project/cbearden/data/22qPrisma/qunex_studyfolder/processing/22qPrisma_batch_no_t2_2023.txt --sessionsfolder=/u/project/cbearden/data/22qPrisma/qunex_studyfolder/sessions --parsessions=1 --overwrite=yes" \
--scheduler_options="-l h_data=16G,h_rt=24:00:00" \
--logdir="/u/project/cbearden/data/22qPrisma/qunex_studyfolder/processing/logs/manual" \
--array="yes" \
--sessions=" "

## FreeSurfer
# try with LegacyStyleData
/u/project/cbearden/data/scripts/tools/qunex_bin/hoffman_submit_qunex.sh \
--qunex_command="hcp_freesurfer" \
--qunex_options="--hcp_processing_mode=LegacyStyleData --sessions=/u/project/cbearden/data/22qPrisma/qunex_studyfolder/processing/22qPrisma_batch_no_t2_2023.txt --sessionsfolder=/u/project/cbearden/data/22qPrisma/qunex_studyfolder/sessions --parsessions=1 --overwrite=no" \
--scheduler_options="-l h_data=16G,h_rt=24:00:00,arch=intel*" \
--logdir="/u/project/cbearden/data/22qPrisma/qunex_studyfolder/processing/logs/manual" \
--array="yes" \
--sessions=" "

## PostFreeSurfer
# try with LegacyStyleData
/u/project/cbearden/data/scripts/tools/qunex_bin/hoffman_submit_qunex.sh \
--qunex_command="hcp_post_freesurfer" \
--qunex_options="--hcp_processing_mode=LegacyStyleData --sessions=/u/project/cbearden/data/22qPrisma/qunex_studyfolder/processing/22qPrisma_batch_no_t2_2023.txt --sessionsfolder=/u/project/cbearden/data/22qPrisma/qunex_studyfolder/sessions --parsessions=1 --overwrite=yes" \
--scheduler_options="-l h_data=16G,h_rt=24:00:00,arch=intel*" \
--logdir="/u/project/cbearden/data/22qPrisma/qunex_studyfolder/processing/logs/manual" \
--array="yes" \
--sessions=" "

## FMRI VOLUME
# try with HCPStyleData after running structurals as legacy
/u/project/cbearden/data/scripts/tools/qunex_bin/hoffman_submit_qunex.sh \
--qunex_command="hcp_fmri_volume" \
--qunex_options="--hcp_processing_mode=HCPStyleData --sessions=/u/project/cbearden/data/22qPrisma/qunex_studyfolder/processing/22qPrisma_batch_no_t2_2023.txt --sessionsfolder=/u/project/cbearden/data/22qPrisma/qunex_studyfolder/sessions --parsessions=1 --overwrite=yes" \
--scheduler_options="-l h_data=16G,h_rt=24:00:00,arch=intel*" \
--logdir="/u/project/cbearden/data/22qPrisma/qunex_studyfolder/processing/logs/manual" \
--array="yes" \
--sessions=" "

## FMRI SURFACE
# try with HCPStyleData after running structurals as legacy
/u/project/cbearden/data/scripts/tools/qunex_bin/hoffman_submit_qunex.sh \
--qunex_command="hcp_fmri_surface" \
--qunex_options="--hcp_processing_mode=HCPStyleData --sessions=/u/project/cbearden/data/22qPrisma/qunex_studyfolder/processing/22qPrisma_batch_no_t2_2023.txt --sessionsfolder=/u/project/cbearden/data/22qPrisma/qunex_studyfolder/sessions --parsessions=1 --overwrite=yes" \
--scheduler_options="-l h_data=16G,h_rt=24:00:00,arch=intel*" \
--logdir="/u/project/cbearden/data/22qPrisma/qunex_studyfolder/processing/logs/manual" \
--array="yes" \
--sessions=" "


#####################################################################
### display QC images one by one
#####################################################################
#n=25 sessions to QC (new scans, and re-processed T1w only and 0.7 TR scans)
#sessions="Q_0246_10142016 Q_0263_11072016 Q_0271_10182016 Q_0291_11042016 Q_0324_04182018 Q_0355_05312018 Q_0443_06282021 Q_0446_06152021 Q_0459_08192021 Q_0477_01052022 Q_0484_01042022 Q_0508_06232022 Q_0519_05312022 Q_0520_06012022 Q_0521_05202022 Q_0525_06072022 Q_0526_06242022 Q_0527_07112022 Q_0528_07202022 Q_0529_07202022 Q_0541_07182022 Q_0549_10182022 Q_0561_11032022 Q_0568_10252022"
cd /u/project/cbearden/data/22qPrisma/qunex_studyfolder/sessions
# structural
for i in $sessions; do echo ${i}; cat ${i}/session_hcp.txt; display /u/project/cbearden/data/22qPrisma/qunex_studyfolder/sessions/${i}/hcp/${i}/MNINonLinear/StructuralQC/snapshots/${i}.structuralQC.wb_scene1.png;done

# BOLD
for i in $sessions;do echo ${i};cat ${i}/session_hcp.txt; for k in /u/project/cbearden/data/22qPrisma/qunex_studyfolder/sessions/${i}/hcp/${i}/MNINonLinear/Results/*;do display ${k}/fMRIQC/snapshots/*fMRIQC.wb_scene1.png;display ${k}/fMRIQC/snapshots/*fMRIQC.wb_scene2.png;done; echo "---";done


#####################################################################
### BOLD post-processing
#####################################################################
# https://bitbucket.org/oriadev/qunex/wiki/UsageDocs/BOLDPreprocessing.md
# https://bitbucket.org/oriadev/qunex/wiki/UsageDocs/MovementScrubbing.md

## map hcp data
# T1w only
/u/project/cbearden/data/scripts/tools/qunex_bin/hoffman_submit_qunex.sh \
--qunex_command="map_hcp_data" \
--qunex_options="--overwrite=yes --bolds=restingAP,restingPA --sessions=/u/project/cbearden/data/22qPrisma/qunex_studyfolder/processing/22qPrisma_batch_no_t2_2023.txt --sessionsfolder=/u/project/cbearden/data/22qPrisma/qunex_studyfolder/sessions" \
--scheduler_options="-l h_data=20G,h_rt=1:00:00,arch=intel*" \
--logdir="/u/project/cbearden/data/22qPrisma/qunex_studyfolder/processing/logs/manual" \
--array="yes" \
--sessions=" "
# T1w+T2w 0.8TR
/u/project/cbearden/data/scripts/tools/qunex_bin/hoffman_submit_qunex.sh \
--qunex_command="map_hcp_data" \
--qunex_options="--overwrite=yes --bolds=restingAP,restingPA --sessions=/u/project/cbearden/data/22qPrisma/qunex_studyfolder/processing/22qPrisma_batch_new2023.txt --sessionsfolder=/u/project/cbearden/data/22qPrisma/qunex_studyfolder/sessions" \
--scheduler_options="-l h_data=20G,h_rt=1:00:00,arch=intel*" \
--logdir="/u/project/cbearden/data/22qPrisma/qunex_studyfolder/processing/logs/manual" \
--array="yes" \
--sessions=" "

## brain masks
# T1w only
/u/project/cbearden/data/scripts/tools/qunex_bin/hoffman_submit_qunex.sh \
--qunex_command="create_bold_brain_masks" \
--qunex_options="--overwrite=yes --bolds=restingAP,restingPA --sessions=/u/project/cbearden/data/22qPrisma/qunex_studyfolder/processing/22qPrisma_batch_no_t2_2023.txt --sessionsfolder=/u/project/cbearden/data/22qPrisma/qunex_studyfolder/sessions" \
--scheduler_options="-l h_data=20G,h_rt=1:00:00,arch=intel*" \
--logdir="/u/project/cbearden/data/22qPrisma/qunex_studyfolder/processing/logs/manual" \
--array="yes" \
--sessions=" "
# T1w+T2w 0.8TR
/u/project/cbearden/data/scripts/tools/qunex_bin/hoffman_submit_qunex.sh \
--qunex_command="create_bold_brain_masks" \
--qunex_options="--overwrite=yes --bolds=restingAP,restingPA --sessions=/u/project/cbearden/data/22qPrisma/qunex_studyfolder/processing/22qPrisma_batch_new2023.txt --sessionsfolder=/u/project/cbearden/data/22qPrisma/qunex_studyfolder/sessions" \
--scheduler_options="-l h_data=20G,h_rt=1:00:00,arch=intel*" \
--logdir="/u/project/cbearden/data/22qPrisma/qunex_studyfolder/processing/logs/manual" \
--array="yes" \
--sessions=" "

## bold stats
# T1w only
/u/project/cbearden/data/scripts/tools/qunex_bin/hoffman_submit_qunex.sh \
--qunex_command="compute_bold_stats" \
--qunex_options="--overwrite=yes --bolds=restingAP,restingPA --sessions=/u/project/cbearden/data/22qPrisma/qunex_studyfolder/processing/22qPrisma_batch_no_t2_2023.txt --sessionsfolder=/u/project/cbearden/data/22qPrisma/qunex_studyfolder/sessions" \
--scheduler_options="-l h_data=20G,h_rt=1:00:00,arch=intel*" \
--logdir="/u/project/cbearden/data/22qPrisma/qunex_studyfolder/processing/logs/manual" \
--array="yes" \
--sessions=" "
# T1w+T2w 0.8TR
/u/project/cbearden/data/scripts/tools/qunex_bin/hoffman_submit_qunex.sh \
--qunex_command="compute_bold_stats" \
--qunex_options="--overwrite=yes --bolds=restingAP,restingPA --sessions=/u/project/cbearden/data/22qPrisma/qunex_studyfolder/processing/22qPrisma_batch_new2023.txt --sessionsfolder=/u/project/cbearden/data/22qPrisma/qunex_studyfolder/sessions" \
--scheduler_options="-l h_data=20G,h_rt=1:00:00,arch=intel*" \
--logdir="/u/project/cbearden/data/22qPrisma/qunex_studyfolder/processing/logs/manual" \
--array="yes" \
--sessions=" "

## create stats report
# T1w only
/u/project/cbearden/data/scripts/tools/qunex_bin/hoffman_submit_qunex.sh \
--qunex_command="create_stats_report" \
--qunex_options="--overwrite=yes --bolds=restingAP,restingPA --sessions=/u/project/cbearden/data/22qPrisma/qunex_studyfolder/processing/22qPrisma_batch_no_t2_2023.txt --sessionsfolder=/u/project/cbearden/data/22qPrisma/qunex_studyfolder/sessions" \
--scheduler_options="-l h_data=20G,h_rt=1:00:00,arch=intel*" \
--logdir="/u/project/cbearden/data/22qPrisma/qunex_studyfolder/processing/logs/manual" \
--array="yes" \
--sessions=" "
# T1w+T2w 0.8TR
/u/project/cbearden/data/scripts/tools/qunex_bin/hoffman_submit_qunex.sh \
--qunex_command="create_stats_report" \
--qunex_options="--overwrite=yes --bolds=restingAP,restingPA --sessions=/u/project/cbearden/data/22qPrisma/qunex_studyfolder/processing/22qPrisma_batch_new2023.txt --sessionsfolder=/u/project/cbearden/data/22qPrisma/qunex_studyfolder/sessions" \
--scheduler_options="-l h_data=20G,h_rt=1:00:00,arch=intel*" \
--logdir="/u/project/cbearden/data/22qPrisma/qunex_studyfolder/processing/logs/manual" \
--array="yes" \
--sessions=" "

## extract nuisance signal
# T1w only
/u/project/cbearden/data/scripts/tools/qunex_bin/hoffman_submit_qunex.sh \
--qunex_command="extract_nuisance_signal" \
--qunex_options="--overwrite=yes --bolds=restingAP,restingPA --sessions=/u/project/cbearden/data/22qPrisma/qunex_studyfolder/processing/22qPrisma_batch_no_t2_2023.txt --sessionsfolder=/u/project/cbearden/data/22qPrisma/qunex_studyfolder/sessions" \
--scheduler_options="-l h_data=20G,h_rt=1:00:00,arch=intel*" \
--logdir="/u/project/cbearden/data/22qPrisma/qunex_studyfolder/processing/logs/manual" \
--array="yes" \
--sessions=" "
# T1w+T2w 0.8TR
/u/project/cbearden/data/scripts/tools/qunex_bin/hoffman_submit_qunex.sh \
--qunex_command="extract_nuisance_signal" \
--qunex_options="--overwrite=yes --bolds=restingAP,restingPA --sessions=/u/project/cbearden/data/22qPrisma/qunex_studyfolder/processing/22qPrisma_batch_new2023.txt --sessionsfolder=/u/project/cbearden/data/22qPrisma/qunex_studyfolder/sessions" \
--scheduler_options="-l h_data=20G,h_rt=1:00:00,arch=intel*" \
--logdir="/u/project/cbearden/data/22qPrisma/qunex_studyfolder/processing/logs/manual" \
--array="yes" \
--sessions=" "

## preprocess bold CIFTI no GSR
# T1w only
/u/project/cbearden/data/scripts/tools/qunex_bin/hoffman_submit_qunex.sh \
--qunex_command="preprocess_bold" \
--qunex_options="--overwrite=no --bolds=restingAP,restingPA --bold_actions=s,h,r,c,l --bold_nuisance=m,V,WM,1d --image_target=dtseries --sessions=/u/project/cbearden/data/22qPrisma/qunex_studyfolder/processing/22qPrisma_batch_no_t2_2023.txt --sessionsfolder=/u/project/cbearden/data/22qPrisma/qunex_studyfolder/sessions" \
--scheduler_options="-l h_data=20G,h_rt=4:00:00,arch=intel*" \
--logdir="/u/project/cbearden/data/22qPrisma/qunex_studyfolder/processing/logs/manual" \
--array="yes" \
--sessions=" "
# T1w+T2w 0.8TR
/u/project/cbearden/data/scripts/tools/qunex_bin/hoffman_submit_qunex.sh \
--qunex_command="preprocess_bold" \
--qunex_options="--overwrite=no --bolds=restingAP,restingPA --bold_actions=s,h,r,c,l --bold_nuisance=m,V,WM,1d --image_target=dtseries --sessions=/u/project/cbearden/data/22qPrisma/qunex_studyfolder/processing/22qPrisma_batch_new2023.txt --sessionsfolder=/u/project/cbearden/data/22qPrisma/qunex_studyfolder/sessions" \
--scheduler_options="-l h_data=20G,h_rt=4:00:00,arch=intel*" \
--logdir="/u/project/cbearden/data/22qPrisma/qunex_studyfolder/processing/logs/manual" \
--array="yes" \
--sessions=" "

## preprocess bold CIFTI GSR
# T1w only
/u/project/cbearden/data/scripts/tools/qunex_bin/hoffman_submit_qunex.sh \
--qunex_command="preprocess_bold" \
--qunex_options="--overwrite=yes --bolds=restingAP,restingPA --bold_actions=s,h,r,c,l --bold_nuisance=m,V,WM,WB,1d --image_target=dtseries --sessions=/u/project/cbearden/data/22qPrisma/qunex_studyfolder/processing/22qPrisma_batch_no_t2_2023.txt --sessionsfolder=/u/project/cbearden/data/22qPrisma/qunex_studyfolder/sessions" \
--scheduler_options="-l h_data=20G,h_rt=4:00:00,arch=intel*" \
--logdir="/u/project/cbearden/data/22qPrisma/qunex_studyfolder/processing/logs/manual" \
--array="yes" \
--sessions=" "
# T1w+T2w 0.8TR
/u/project/cbearden/data/scripts/tools/qunex_bin/hoffman_submit_qunex.sh \
--qunex_command="preprocess_bold" \
--qunex_options="--overwrite=yes --bolds=restingAP,restingPA --bold_actions=s,h,r,c,l --bold_nuisance=m,V,WM,WB,1d --image_target=dtseries --sessions=/u/project/cbearden/data/22qPrisma/qunex_studyfolder/processing/22qPrisma_batch_new2023.txt --sessionsfolder=/u/project/cbearden/data/22qPrisma/qunex_studyfolder/sessions" \
--scheduler_options="-l h_data=20G,h_rt=4:00:00,arch=intel*" \
--logdir="/u/project/cbearden/data/22qPrisma/qunex_studyfolder/processing/logs/manual" \
--array="yes" \
--sessions=" "

## check motion stats for new scans (print last line of boldn.scrub)
#sessions="Q_0246_10142016 Q_0263_11072016 Q_0271_10182016 Q_0291_11042016 Q_0355_05312018 Q_0443_06282021 Q_0446_06152021 Q_0459_08192021 Q_0324_04182018 Q_0484_01042022 Q_0520_06012022 Q_0519_05312022 Q_0521_05202022 Q_0525_06072022 Q_0526_06242022 Q_0527_07112022 Q_0528_07202022 Q_0529_07202022 Q_0561_11032022 Q_0568_10252022"
cd /u/project/cbearden/data/22qPrisma/qunex_studyfolder/sessions
for i in $sessions; do echo $i; for s in $i/images/functional/movement/bold*.scrub; do echo $s;tail -1 $s;read; done ; echo "---";done 
# check number of frames (based on bold scrub file)
for i in $sessions; do echo $i; for s in $i/images/functional/movement/bold*.scrub; do echo $s;cat $s | tail -3 | head -1 | cut -d " " -f 1 ;read; done ; echo "---";done 

#####################################################################
### seed-based BOLD functional connectivity
#####################################################################
# https://bitbucket.org/oriadev/qunex/wiki/UsageDocs/BOLDFunctionalConnectivity.md

# TO DO: haven't updated paths and batch files below

# subcortical seeds -- bandpass, GSR, reading boldn for bold rest from session_hcp.txt
# bold1
#sessions="Q_0005_11072017 Q_0017_10022017 Q_0019_03022020 Q_0036_08082017 Q_0036_08312018 Q_0036_09302019 Q_0037_08152017 Q_0041_10092017 Q_0051_02032017 Q_0105_03112020 Q_0105_12032018 Q_0114_12052017 Q_0141_06122018 Q_0141_08052019 Q_0147_12112017 Q_0147_12112018 Q_0196_01082020 Q_0213_05012017 Q_0214_05012017 Q_0217_01242017 Q_0217_02192020 Q_0235_05252017 Q_0238_02202018 Q_0240_09192017 Q_0240_11162018 Q_0246_10092018 Q_0246_10102017 Q_0246_10142016 Q_0260_06192017 Q_0260_06242019 Q_0260_06252018 Q_0263_02252019 Q_0263_02262018 Q_0263_11072016 Q_0271_10182016 Q_0277_12132016 Q_0278_11292017 Q_0278_12052019 Q_0278_12132016 Q_0279_11302017 Q_0279_12052019 Q_0279_12132016 Q_0285_03212017 Q_0285_06062018 Q_0286_03212017 Q_0287_06062018 Q_0288_06062018 Q_0289_03212017 Q_0289_06062018 Q_0291_11042016 Q_0291_11302018 Q_0304_12202016 Q_0310_01252018 Q_0310_02132017 Q_0310_04292019 Q_0319_03192018 Q_0319_03282017 Q_0321_03192018 Q_0321_03272017 Q_0324_04182018 Q_0326_10202017 Q_0326_12062018 Q_0327_10192017 Q_0327_12072018 Q_0331_06102019 Q_0331_06212018 Q_0331_06272017 Q_0333_04142017 Q_0334_12012016 Q_0336_01102017 Q_0345_04122017 Q_0345_08152018 Q_0345_09112019 Q_0346_04102017 Q_0346_04102018 Q_0348_04212017 Q_0348_08152018 Q_0350_04192017 Q_0350_09142018 Q_0353_04182018 Q_0353_05022017 Q_0355_05312018 Q_0356_05312018 Q_0361_10212019 Q_0361_11202018 Q_0369_04182018 Q_0369_06182019 Q_0371_08042020 Q_0374_05252018 Q_0381_08072018 Q_0381_09102019 Q_0382_08282018 Q_0383_08282018 Q_0387_08242018 Q_0387_12032019 Q_0390_09042018 Q_0390_09302019 Q_0391_09252018 Q_0395_11062018 Q_0397_10172019 Q_0402_01112019 Q_0404_03112019 Q_0407_06122019 Q_0408_05172019 Q_0414_07172019 Q_0415_07292019 Q_0416_07292019 Q_0425_11052019 Q_0429_01092020 Q_0432_02142020 Q_0433_02262020 Q_0443_06282021 Q_0446_06152021 Q_0459_08192021 Q_0461_09112021"
sdir=/u/project/cbearden/data/22qPrisma/qunex_studyfolder/sessions/
for sesh in $sessions; do 
# get boldn as the second field of session_hcp.txt line with "resting" skipping lines that don't start with [0-9] e.g. commented out
infile=bold1_Atlas_s_hpss_res-mVWMWB1d_lpss.dtseries.nii
echo ${sesh} ${infile}
/u/project/cbearden/data/scripts/tools/qunex_bin/hoffman_submit_qunex.sh \
--qunex_command="fc_compute_wrapper" \
--qunex_options="--sessionsfolder=${sdir} \
--calculation=seed \
--runtype=individual \
--inputfiles=${infile} \
--inputpath=/images/functional/ \
--overwrite=yes \
--extractdata=no \
--roinfo=/u/project/cbearden/data/22q/qunex_studyfolder/analysis/fcMRI/roi/seeds_cifti_10142021.names \
--outname=resting1_fc_seed_s_hpss_res-mVWMWB1d_lpss \
--ignore=udvarsme \
--method=mean \
--mask=5" \
--scheduler_options="-l h_data=20G,h_rt=2:00:00,arch=intel*" \
--array="yes" \
--logdir="/u/project/cbearden/data/22q/qunex_studyfolder/processing/logs/manual" \
--sessions=${sesh}
done

# bold2
#sessions="Q_0005_11072017 Q_0017_10022017 Q_0019_03022020 Q_0036_08082017 Q_0036_08312018 Q_0036_09302019 Q_0037_08152017 Q_0041_10092017 Q_0051_02032017 Q_0105_03112020 Q_0105_12032018 Q_0114_12052017 Q_0141_06122018 Q_0141_08052019 Q_0147_12112017 Q_0147_12112018 Q_0196_01082020 Q_0213_05012017 Q_0214_05012017 Q_0217_01242017 Q_0217_02192020 Q_0235_05252017 Q_0238_02202018 Q_0240_09192017 Q_0240_11162018 Q_0246_10092018 Q_0246_10102017 Q_0246_10142016 Q_0260_06192017 Q_0260_06242019 Q_0260_06252018 Q_0263_02252019 Q_0263_02262018 Q_0263_11072016 Q_0271_10182016 Q_0277_12132016 Q_0278_11292017 Q_0278_12052019 Q_0278_12132016 Q_0279_11302017 Q_0279_12052019 Q_0279_12132016 Q_0285_03212017 Q_0285_06062018 Q_0286_03212017 Q_0287_06062018 Q_0288_06062018 Q_0289_03212017 Q_0289_06062018 Q_0291_11042016 Q_0291_11302018 Q_0304_12202016 Q_0310_01252018 Q_0310_02132017 Q_0310_04292019 Q_0319_03192018 Q_0319_03282017 Q_0321_03192018 Q_0321_03272017 Q_0324_04182018 Q_0326_10202017 Q_0326_12062018 Q_0327_10192017 Q_0327_12072018 Q_0331_06102019 Q_0331_06212018 Q_0331_06272017 Q_0333_04142017 Q_0334_12012016 Q_0336_01102017 Q_0345_04122017 Q_0345_08152018 Q_0345_09112019 Q_0346_04102017 Q_0346_04102018 Q_0348_04212017 Q_0348_08152018 Q_0350_04192017 Q_0350_09142018 Q_0353_04182018 Q_0353_05022017 Q_0355_05312018 Q_0356_05312018 Q_0361_10212019 Q_0361_11202018 Q_0369_04182018 Q_0369_06182019 Q_0371_08042020 Q_0374_05252018 Q_0381_08072018 Q_0381_09102019 Q_0382_08282018 Q_0383_08282018 Q_0387_08242018 Q_0387_12032019 Q_0390_09042018 Q_0390_09302019 Q_0391_09252018 Q_0395_11062018 Q_0397_10172019 Q_0402_01112019 Q_0404_03112019 Q_0407_06122019 Q_0408_05172019 Q_0414_07172019 Q_0415_07292019 Q_0416_07292019 Q_0425_11052019 Q_0429_01092020 Q_0432_02142020 Q_0433_02262020 Q_0443_06282021 Q_0446_06152021 Q_0459_08192021 Q_0461_09112021"
sdir=/u/project/cbearden/data/22qPrisma/qunex_studyfolder/sessions/
for sesh in $sessions; do 
# get boldn as the second field of session_hcp.txt line with "resting" skipping lines that don't start with [0-9] e.g. commented out
boldn=$(cat ${sdir}/${sesh}/session_hcp.txt  | grep "resting" | grep ^[0-9] | cut -d ":" -f 2 | xargs)
infile=bold2_Atlas_s_hpss_res-mVWMWB1d_lpss.dtseries.nii
echo ${sesh} ${infile}
/u/project/cbearden/data/scripts/tools/qunex_bin/hoffman_submit_qunex.sh \
--qunex_command="fc_compute_wrapper" \
--qunex_options="--sessionsfolder=${sdir} \
--calculation=seed \
--runtype=individual \
--inputfiles=${infile} \
--inputpath=/images/functional/ \
--overwrite=yes \
--extractdata=no \
--roinfo=/u/project/cbearden/data/22q/qunex_studyfolder/analysis/fcMRI/roi/seeds_cifti_10142021.names \
--outname=resting2_fc_seed_s_hpss_res-mVWMWB1d_lpss \
--ignore=udvarsme \
--method=mean \
--mask=5" \
--scheduler_options="-l h_data=20G,h_rt=2:00:00,arch=intel*" \
--array="yes" \
--logdir="/u/project/cbearden/data/22q/qunex_studyfolder/processing/logs/manual" \
--sessions=${sesh}
done

#####################################################################
## Global Brain Connectivity (GBC)
#####################################################################

# Global Signal Topography (GBC in non-residualized data)
#sessions="Q_0005_11072017 Q_0017_10022017 Q_0019_03022020 Q_0036_08082017 Q_0036_08312018 Q_0036_09302019 Q_0037_08152017 Q_0041_10092017 Q_0051_02032017 Q_0105_03112020 Q_0105_12032018 Q_0114_12052017 Q_0141_06122018 Q_0141_08052019 Q_0147_12112017 Q_0147_12112018 Q_0196_01082020 Q_0213_05012017 Q_0217_01242017 Q_0217_02192020 Q_0235_05252017 Q_0238_02202018 Q_0240_09192017 Q_0240_11162018 Q_0246_10092018 Q_0246_10102017 Q_0246_10142016 Q_0260_06192017 Q_0260_06242019 Q_0260_06252018 Q_0263_02252019 Q_0263_02262018 Q_0263_11072016 Q_0271_10182016 Q_0277_12132016 Q_0278_11292017 Q_0279_11302017 Q_0279_12052019 Q_0279_12132016 Q_0285_03212017 Q_0285_06062018 Q_0286_03212017 Q_0287_06062018 Q_0289_03212017 Q_0289_06062018 Q_0291_11042016 Q_0291_11302018 Q_0304_12202016 Q_0310_01252018 Q_0310_02132017 Q_0310_04292019 Q_0319_03192018 Q_0319_03282017 Q_0321_03192018 Q_0321_03272017 Q_0324_04182018 Q_0326_10202017 Q_0326_12062018 Q_0327_10192017 Q_0327_12072018 Q_0331_06102019 Q_0331_06212018 Q_0331_06272017 Q_0333_04142017 Q_0334_12012016 Q_0336_01102017 Q_0345_04122017 Q_0345_08152018 Q_0345_09112019 Q_0346_04102017 Q_0346_04102018 Q_0348_04212017 Q_0348_08152018 Q_0350_04192017 Q_0350_09142018 Q_0353_04182018 Q_0353_05022017 Q_0355_05312018 Q_0356_05312018 Q_0361_10212019 Q_0361_11202018 Q_0369_04182018 Q_0369_06182019 Q_0371_08042020 Q_0374_05252018 Q_0381_08072018 Q_0381_09102019 Q_0382_08282018 Q_0383_08282018 Q_0387_08242018 Q_0387_12032019 Q_0390_09042018 Q_0390_09302019 Q_0391_09252018 Q_0395_11062018 Q_0397_10172019 Q_0402_01112019 Q_0404_03112019 Q_0407_06122019 Q_0408_05172019 Q_0414_07172019 Q_0415_07292019 Q_0416_07292019 Q_0425_11052019 Q_0429_01092020 Q_0432_02142020 Q_0433_02262020 Q_0443_06282021 Q_0446_06152021 Q_0459_08192021 Q_0461_09112021 Q_0484_01042022 Q_0519_05312022 Q_0520_06012022 Q_0521_05202022 Q_0525_06072022 Q_0526_06242022 Q_0527_07112022 Q_0528_07202022 Q_0529_07202022 Q_0561_11032022 Q_0568_10252022"
sdir=/u/project/cbearden/data/22qPrisma/qunex_studyfolder/sessions/
for sesh in $sessions; do 
# get boldn as the second field of session_hcp.txt line with "restingAP" skipping lines that don't start with [0-9] e.g. commented out
boldn=$(cat ${sdir}/${sesh}/session_hcp.txt  | grep "bold[0-9]:restingAP" | grep ^[0-9] | cut -d ":" -f 2 | xargs)
infile=${boldn}_Atlas_s_hpss.dtseries.nii
echo ${sesh} ${infile}
/u/project/cbearden/data/scripts/tools/qunex_bin/hoffman_submit_qunex.sh \
--qunex_command="fc_compute_wrapper" \
--qunex_options="--sessionsfolder=/u/project/cbearden/data/22qPrisma/qunex_studyfolder/sessions/ \
--calculation=gbc \
--command=mFz:0 \
--runtype=individual \
--inputfiles=${infile} \
--inputpath=/images/functional/ \
--overwrite=no \
--extractdata=no \
--outname=restingAP_fc_gbc_s_hpss \
--ignore=udvarsme \
--method=mean \
--mask=5" \
--scheduler_options="-l h_data=20G,h_rt=10:00:00,arch=intel*" \
--array="yes" \
--logdir="/u/project/cbearden/data/22qPrisma/qunex_studyfolder/processing/logs/manual" \
--sessions=${sesh}
done

# GSR, nuisance, bandpass
#sessions="Q_0005_11072017 Q_0017_10022017 Q_0019_03022020 Q_0036_08082017 Q_0036_08312018 Q_0036_09302019 Q_0037_08152017 Q_0041_10092017 Q_0051_02032017 Q_0105_03112020 Q_0105_12032018 Q_0114_12052017 Q_0141_06122018 Q_0141_08052019 Q_0147_12112017 Q_0147_12112018 Q_0196_01082020 Q_0213_05012017 Q_0217_01242017 Q_0217_02192020 Q_0235_05252017 Q_0238_02202018 Q_0240_09192017 Q_0240_11162018 Q_0246_10092018 Q_0246_10102017 Q_0246_10142016 Q_0260_06192017 Q_0260_06242019 Q_0260_06252018 Q_0263_02252019 Q_0263_02262018 Q_0263_11072016 Q_0271_10182016 Q_0277_12132016 Q_0278_11292017 Q_0279_11302017 Q_0279_12052019 Q_0279_12132016 Q_0285_03212017 Q_0285_06062018 Q_0286_03212017 Q_0287_06062018 Q_0289_03212017 Q_0289_06062018 Q_0291_11042016 Q_0291_11302018 Q_0304_12202016 Q_0310_01252018 Q_0310_02132017 Q_0310_04292019 Q_0319_03192018 Q_0319_03282017 Q_0321_03192018 Q_0321_03272017 Q_0324_04182018 Q_0326_10202017 Q_0326_12062018 Q_0327_10192017 Q_0327_12072018 Q_0331_06102019 Q_0331_06212018 Q_0331_06272017 Q_0333_04142017 Q_0334_12012016 Q_0336_01102017 Q_0345_04122017 Q_0345_08152018 Q_0345_09112019 Q_0346_04102017 Q_0346_04102018 Q_0348_04212017 Q_0348_08152018 Q_0350_04192017 Q_0350_09142018 Q_0353_04182018 Q_0353_05022017 Q_0355_05312018 Q_0356_05312018 Q_0361_10212019 Q_0361_11202018 Q_0369_04182018 Q_0369_06182019 Q_0371_08042020 Q_0374_05252018 Q_0381_08072018 Q_0381_09102019 Q_0382_08282018 Q_0383_08282018 Q_0387_08242018 Q_0387_12032019 Q_0390_09042018 Q_0391_09252018 Q_0395_11062018 Q_0397_10172019 Q_0402_01112019 Q_0404_03112019 Q_0407_06122019 Q_0408_05172019 Q_0414_07172019 Q_0415_07292019 Q_0416_07292019 Q_0425_11052019 Q_0429_01092020 Q_0432_02142020 Q_0433_02262020 Q_0443_06282021 Q_0446_06152021 Q_0459_08192021 Q_0461_09112021 Q_0484_01042022 Q_0519_05312022 Q_0520_06012022 Q_0521_05202022 Q_0525_06072022 Q_0526_06242022 Q_0527_07112022 Q_0528_07202022 Q_0529_07202022 Q_0561_11032022 Q_0568_10252022"
sdir=/u/project/cbearden/data/22qPrisma/qunex_studyfolder/sessions/
for sesh in $sessions; do 
# get boldn as the second field of session_hcp.txt line with "restingAP" skipping lines that don't start with [0-9] e.g. commented out
boldn=$(cat ${sdir}/${sesh}/session_hcp.txt  | grep "bold[0-9]:restingAP" | grep ^[0-9] | cut -d ":" -f 2 | xargs)
infile=${boldn}_Atlas_s_hpss_res-mVWMWB1d_lpss.dtseries.nii
echo ${sesh} ${infile}
/u/project/cbearden/data/scripts/tools/qunex_bin/hoffman_submit_qunex.sh \
--qunex_command="fc_compute_wrapper" \
--qunex_options="--sessionsfolder=/u/project/cbearden/data/22qPrisma/qunex_studyfolder/sessions/ \
--calculation=gbc \
--command=mFz:0 \
--runtype=individual \
--inputfiles=${infile} \
--inputpath=/images/functional/ \
--overwrite=no \
--extractdata=no \
--outname=restingAP_fc_gbc_s_hpss_res-mVWMWB1d_lpss \
--ignore=udvarsme \
--method=mean \
--mask=5" \
--scheduler_options="-l h_data=62G,h_rt=10:00:00,arch=intel*" \
--array="yes" \
--logdir="/u/project/cbearden/data/22qPrisma/qunex_studyfolder/processing/logs/manual" \
--sessions=${sesh}
done

# GSR, nuisance, highpass
#sessions="Q_0005_11072017 Q_0017_10022017 Q_0019_03022020 Q_0036_08082017 Q_0036_08312018 Q_0036_09302019 Q_0037_08152017 Q_0041_10092017 Q_0051_02032017 Q_0105_03112020 Q_0105_12032018 Q_0114_12052017 Q_0141_06122018 Q_0141_08052019 Q_0147_12112017 Q_0147_12112018 Q_0196_01082020 Q_0213_05012017 Q_0217_01242017 Q_0217_02192020 Q_0235_05252017 Q_0238_02202018 Q_0240_09192017 Q_0240_11162018 Q_0246_10092018 Q_0246_10102017 Q_0246_10142016 Q_0260_06192017 Q_0260_06242019 Q_0260_06252018 Q_0263_02252019 Q_0263_02262018 Q_0263_11072016 Q_0271_10182016 Q_0277_12132016 Q_0278_11292017 Q_0279_11302017 Q_0279_12052019 Q_0279_12132016 Q_0285_03212017 Q_0285_06062018 Q_0286_03212017 Q_0287_06062018 Q_0289_03212017 Q_0289_06062018 Q_0291_11042016 Q_0291_11302018 Q_0304_12202016 Q_0310_01252018 Q_0310_02132017 Q_0310_04292019 Q_0319_03192018 Q_0319_03282017 Q_0321_03192018 Q_0321_03272017 Q_0324_04182018 Q_0326_10202017 Q_0326_12062018 Q_0327_10192017 Q_0327_12072018 Q_0331_06102019 Q_0331_06212018 Q_0331_06272017 Q_0333_04142017 Q_0334_12012016 Q_0336_01102017 Q_0345_04122017 Q_0345_08152018 Q_0345_09112019 Q_0346_04102017 Q_0346_04102018 Q_0348_04212017 Q_0348_08152018 Q_0350_04192017 Q_0350_09142018 Q_0353_04182018 Q_0353_05022017 Q_0355_05312018 Q_0356_05312018 Q_0361_10212019 Q_0361_11202018 Q_0369_04182018 Q_0369_06182019 Q_0371_08042020 Q_0374_05252018 Q_0381_08072018 Q_0381_09102019 Q_0382_08282018 Q_0383_08282018 Q_0387_08242018 Q_0387_12032019 Q_0390_09042018 Q_0391_09252018 Q_0395_11062018 Q_0397_10172019 Q_0402_01112019 Q_0404_03112019 Q_0407_06122019 Q_0408_05172019 Q_0414_07172019 Q_0415_07292019 Q_0416_07292019 Q_0425_11052019 Q_0429_01092020 Q_0432_02142020 Q_0433_02262020 Q_0443_06282021 Q_0446_06152021 Q_0459_08192021 Q_0461_09112021 Q_0484_01042022 Q_0519_05312022 Q_0520_06012022 Q_0521_05202022 Q_0525_06072022 Q_0526_06242022 Q_0527_07112022 Q_0528_07202022 Q_0529_07202022 Q_0561_11032022 Q_0568_10252022"
sdir=/u/project/cbearden/data/22qPrisma/qunex_studyfolder/sessions/
for sesh in $sessions; do 
# get boldn as the second field of session_hcp.txt line with "restingAP" skipping lines that don't start with [0-9] e.g. commented out
boldn=$(cat ${sdir}/${sesh}/session_hcp.txt  | grep "bold[0-9]:restingAP" | grep ^[0-9] | cut -d ":" -f 2 | xargs)
infile=${boldn}_Atlas_s_hpss_res-mVWMWB1d.dtseries.nii
echo ${sesh} ${infile}
/u/project/cbearden/data/scripts/tools/qunex_bin/hoffman_submit_qunex.sh \
--qunex_command="fc_compute_wrapper" \
--qunex_options="--sessionsfolder=/u/project/cbearden/data/22qPrisma/qunex_studyfolder/sessions/ \
--calculation=gbc \
--command=mFz:0 \
--runtype=individual \
--inputfiles=${infile} \
--inputpath=/images/functional/ \
--overwrite=no \
--extractdata=no \
--outname=restingAP_fc_gbc_s_hpss_res-mVWMWB1d \
--ignore=udvarsme \
--method=mean \
--mask=5" \
--scheduler_options="-l h_data=62G,h_rt=10:00:00,arch=intel*" \
--array="yes" \
--logdir="/u/project/cbearden/data/22qPrisma/qunex_studyfolder/processing/logs/manual" \
--sessions=${sesh}
done
