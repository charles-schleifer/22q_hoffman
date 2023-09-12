#!/bin/sh

# C. Schleifer 12/08/21
# Script to batch preprocess Rome 22q data using qunex container
# Script should not be run directly. Execute functions one by one


#####################################################################
### organize and prepare data
#####################################################################

## 1. set up study folder
/u/project/cbearden/data/scripts/tools/qunex_bin/hoffman_submit_qunex.sh \
--qunex_command="create_study" \
--qunex_options="--studyfolder=/u/project/cbearden/data/Enigma/Rome/qunex_studyfolder" \
--scheduler_options="-l h_data=8G,h_rt=2:00:00" \
--logdir="/u/project/cbearden/data/Enigma/Rome/" \
--array="no" 
mkdir /u/project/cbearden/data/Enigma/Rome/qunex_studyfolder/processing/logs/manual

# 2. organize dicoms into inbox
bash /u/project/cbearden/data/Enigma/Rome/qunex_studyfolder/processing/scripts/Rome_organize_raw.sh

## 3. import DICOMs 
/u/project/cbearden/data/scripts/tools/qunex_bin/hoffman_submit_qunex.sh \
--qunex_command="import_dicom" \
--qunex_options="--sessionsfolder=/u/project/cbearden/data/Enigma/Rome/qunex_studyfolder/sessions --gzip=yes --check=any" \
--scheduler_options="-l h_data=16G,h_rt=24:00:00" \
--logdir="/u/project/cbearden/data/Enigma/Rome/qunex_studyfolder/processing/logs/manual" \
--array="no" 

## 4. set up HCP mapping file
# get list of unique runs to use when manually setting up mapping file
seshdir=/u/project/cbearden/data/Enigma/Rome/qunex_studyfolder/sessions/
rm ${seshdir}/specs/all_runs.txt
for i in ${seshdir}/X*; do cat ${i}/session.txt | grep '^[0-9]' >> ${seshdir}/specs/all_runs.txt; done
cut ${seshdir}/specs/all_runs.txt -d : -f 2 | sort | uniq > ${seshdir}/specs/unique_runs.txt

# 5. only run names are "BOLD - RESTING" "MPRAGE_SAG_BWM" so mapping file is easy
echo "MPRAGE => T1w" > /u/project/cbearden/data/Enigma/Rome/qunex_studyfolder/sessions/specs/Rome_HCP_mapping.txt
echo "T1_3D_MPRAGE => T1w" > /u/project/cbearden/data/Enigma/Rome/qunex_studyfolder/sessions/specs/Rome_HCP_mapping.txt
echo "BOLD_TRA_REST => bold:resting" >> /u/project/cbearden/data/Enigma/Rome/qunex_studyfolder/sessions/specs/Rome_HCP_mapping.txt

## 6. HCP mapping
/u/project/cbearden/data/scripts/tools/qunex_bin/hoffman_submit_qunex.sh \
--qunex_command="create_session_info" \
--qunex_options="--overwrite=yes --sourcefile=session.txt --targetfile=session_hcp.txt --pipelines=hcp --mapping=/u/project/cbearden/data/Enigma/Rome/qunex_studyfolder/sessions/specs/Rome_HCP_mapping.txt --sessionsfolder=/u/project/cbearden/data/Enigma/Rome/qunex_studyfolder/sessions" \
--scheduler_options="-l h_data=8G,h_rt=4:00:00" \
--logdir="/u/project/cbearden/data/Enigma/Rome/qunex_studyfolder/processing/logs/manual" \
--array="no" 

# 7. get list of sessions with a BOLD run
for i in /u/project/cbearden/data/Enigma/Rome/qunex_studyfolder/sessions/C* D* P*; do if [ 0 -ne $(cat $i/session_hcp.txt | grep -c "BOLD") ];then echo $(basename $i);fi;done
#sessions="C01 C02 C03 C04 C05 C06 C07 C08 C09 C10 C11 C12 C13 C14 C15 C17 C18 C19 C20 C21 C22 C23 C24 C25 C26 C27 D01 D02 D03 D04 D05 D06 D07 D08 D09 D10 D11 D12 D13 D14 D15 D16 D17 D18 D20 D21 D22 D23 D24 D25 D26 P01 P02 P03 P04 P05 P06 P07 P08 P09 P10 P11 P13 P14 P15 P16 P17 P18 P19 P20 P21 P22 P23 P24 P25 P26 P27 P28 P29 P30 P31 P32 P33 P35 P36 P37 P38"

## 8. Setup HCP
/u/project/cbearden/data/scripts/tools/qunex_bin/hoffman_submit_qunex.sh \
--qunex_command="setup_hcp" \
--qunex_options="--sessionsfolder=/u/project/cbearden/data/Enigma/Rome/qunex_studyfolder/sessions --sourcefile=session_hcp.txt" \
--scheduler_options="-l h_data=8G,h_rt=4:00:00" \
--logdir="/u/project/cbearden/data/Enigma/Rome/qunex_studyfolder/processing/logs/manual" \
--array="yes" \
--sessions="C01 C02 C03 C04 C05 C06 C07 C08 C09 C10 C11 C12 C13 C14 C15 C17 C18 C19 C20 C21 C22 C23 C24 C25 C26 C27 D01 D02 D03 D04 D05 D06 D07 D08 D09 D10 D11 D12 D13 D14 D15 D16 D17 D18 D20 D21 D22 D23 D24 D25 D26 P01 P02 P03 P04 P05 P06 P07 P08 P09 P10 P11 P13 P14 P15 P16 P17 P18 P19 P20 P21 P22 P23 P24 P25 P26 P27 P28 P29 P30 P31 P32 P33 P35 P36 P37 P38"

## 9. create batch file
# first copy over param file from 22qTrio 
cp /u/project/cbearden/data/22q/qunex_studyfolder/sessions/specs/22q_trio_params.txt /u/project/cbearden/data/Enigma/Rome/qunex_studyfolder/sessions/specs/Rome_params.txt
# IMPORTANT: need to manually edit Rome params to match acquisition.
# BOLD TR=3
# TO-DO: check if interleaved acquisition _hcp_bold_slicetimerparams : --odd
# currently setting params to skip slice time correction _hcp_bold_doslicetime   : NONE
/u/project/cbearden/data/scripts/tools/qunex_bin/hoffman_submit_qunex.sh \
--qunex_command="create_batch" \
--qunex_options=" --overwrite=yes --sessionsfolder=/u/project/cbearden/data/Enigma/Rome/qunex_studyfolder/sessions --sourcefiles=session_hcp.txt --targetfile=/u/project/cbearden/data/Enigma/Rome/qunex_studyfolder/processing/Rome_batch.txt --paramfile=/u/project/cbearden/data/Enigma/Rome/qunex_studyfolder/sessions/specs/Rome_params.txt --sessions=C01,C02,C03,C04,C05,C06,C07,C08,C09,C10,C11,C12,C13,C14,C15,C17,C18,C19,C20,C21,C22,C23,C24,C25,C26,C27,D01,D02,D03,D04,D05,D06,D07,D08,D09,D10,D11,D12,D13,D14,D15,D16,D17,D18,D20,D21,D22,D23,D24,D25,D26,P01,P02,P03,P04,P05,P06,P07,P08,P09,P10,P11,P13,P14,P15,P16,P17,P18,P19,P20,P21,P22,P23,P24,P25,P26,P27,P28,P29,P30,P31,P32,P33,P35,P36,P37,P38" \
--scheduler_options="-l h_data=4G,h_rt=4:00:00" \
--logdir="/u/project/cbearden/data/Enigma/Rome/qunex_studyfolder/processing/logs/manual" \
--array="no" 

#####################################################################
### HCP steps
#####################################################################

## 10. PreFreeSurfer
/u/project/cbearden/data/scripts/tools/qunex_bin/hoffman_submit_qunex.sh \
--qunex_command="hcp_pre_freesurfer" \
--qunex_options="--sessions=/u/project/cbearden/data/Enigma/Rome/qunex_studyfolder/processing/Rome_batch.txt --sessionsfolder=/u/project/cbearden/data/Enigma/Rome/qunex_studyfolder/sessions --parsessions=1 --overwrite=no" \
--scheduler_options="-l h_data=16G,h_rt=24:00:00,arch=intel*" \
--logdir="/u/project/cbearden/data/Enigma/Rome/qunex_studyfolder/processing/logs/manual" \
--array="yes" \
--sessions="C01 C02 C03 C04 C05 C06 C07 C08 C09 C10 C11 C12 C13 C14 C15 C17 C18 C19 C20 C21 C22 C23 C24 C25 C26 C27 D01 D02 D03 D04 D05 D06 D07 D08 D09 D10 D11 D12 D13 D14 D15 D16 D17 D18 D20 D21 D22 D23 D24 D25 D26 P01 P02 P03 P04 P05 P06 P07 P08 P09 P10 P11 P13 P14 P15 P16 P17 P18 P19 P20 P21 P22 P23 P24 P25 P26 P27 P28 P29 P30 P31 P32 P33 P35 P36 P37 P38"
# some worked but many failed eg. /u/project/cbearden/data/Enigma/Rome/qunex_studyfolder/processing/logs/comlogs/error_hcp_pre_freesurfer_P23_2022-01-31_21.45.1643694326.log

## 11. FreeSurfer
/u/project/cbearden/data/scripts/tools/qunex_bin/hoffman_submit_qunex.sh \
--qunex_command="hcp_freesurfer" \
--qunex_options="--sessions=/u/project/cbearden/data/Enigma/Rome/qunex_studyfolder/processing/Rome_batch.txt --sessionsfolder=/u/project/cbearden/data/Enigma/Rome/qunex_studyfolder/sessions --parsessions=1 --overwrite=no" \
--scheduler_options="-l h_data=20G,h_rt=48:00:00,arch=intel*,highp" \
--logdir="/u/project/cbearden/data/Enigma/Rome/qunex_studyfolder/processing/logs/manual" \
--array="yes" \
--sessions="C01 C02 C03 C04 C05 C06 C07 C08 C09 C10 C11 C12 C13 C14 C15 C17 C18 C19 C20 C21 C22 C23 C24 C25 C26 C27 D01 D02 D03 D04 D05 D06 D07 D08 D09 D10 D11 D12 D13 D14 D15 D16 D17 D18 D20 D21 D22 D23 D24 D25 D26 P01 P02 P03 P04 P05 P06 P07 P08 P09 P10 P11 P13 P14 P15 P16 P17 P18 P19 P20 P21 P22 P23 P24 P25 P26 P27 P28 P29 P30 P31 P32 P33 P35 P36 P37 P38"

## 12. PostFreeSurfer
/u/project/cbearden/data/scripts/tools/qunex_bin/hoffman_submit_qunex.sh \
--qunex_command="hcp_post_freesurfer" \
--qunex_options="--sessions=/u/project/cbearden/data/Enigma/Rome/qunex_studyfolder/processing/Rome_batch.txt --sessionsfolder=/u/project/cbearden/data/Enigma/Rome/qunex_studyfolder/sessions --parsessions=1 --overwrite=no" \
--scheduler_options="-l h_data=20G,h_rt=24:00:00,arch=intel*" \
--logdir="/u/project/cbearden/data/Enigma/Rome/qunex_studyfolder/processing/logs/manual" \
--array="yes" \
--sessions="C01 C02 C03 C04 C05 C06 C07 C08 C09 C10 C11 C12 C13 C14 C15 C17 C18 C19 C20 C21 C22 C23 C24 C25 C26 C27 D01 D02 D03 D04 D05 D06 D07 D08 D09 D10 D11 D12 D13 D14 D15 D16 D17 D18 D20 D21 D22 D23 D24 D25 D26 P01 P02 P03 P04 P05 P06 P07 P08 P09 P10 P11 P13 P14 P15 P16 P17 P18 P19 P20 P21 P22 P23 P24 P25 P26 P27 P28 P29 P30 P31 P32 P33 P35 P36 P37 P38"

## 13. FMRI VOLUME
/u/project/cbearden/data/scripts/tools/qunex_bin/hoffman_submit_qunex.sh \
--qunex_command="hcp_fmri_volume" \
--qunex_options="--sessions=/u/project/cbearden/data/Enigma/Rome/qunex_studyfolder/processing/Rome_batch.txt --sessionsfolder=/u/project/cbearden/data/Enigma/Rome/qunex_studyfolder/sessions --parsessions=1 --overwrite=no" \
--scheduler_options="-l h_data=16G,h_rt=24:00:00,arch=intel*" \
--logdir="/u/project/cbearden/data/Enigma/Rome/qunex_studyfolder/processing/logs/manual" \
--array="yes" \
--sessions="C01 C02 C03 C04 C05 C06 C07 C08 C09 C10 C11 C12 C13 C14 C15 C17 C18 C19 C20 C21 C22 C23 C24 C25 C26 C27 D01 D02 D03 D04 D05 D06 D07 D08 D09 D10 D11 D12 D13 D14 D15 D16 D17 D18 D20 D21 D22 D23 D24 D25 D26 P01 P02 P03 P04 P05 P06 P07 P08 P09 P10 P11 P13 P14 P15 P16 P17 P18 P19 P20 P21 P22 P23 P24 P25 P26 P27 P28 P29 P30 P31 P32 P33 P35 P36 P37 P38"

## 14. FMRI SURFACE
/u/project/cbearden/data/scripts/tools/qunex_bin/hoffman_submit_qunex.sh \
--qunex_command="hcp_fmri_surface" \
--qunex_options="--sessions=/u/project/cbearden/data/Enigma/Rome/qunex_studyfolder/processing/Rome_batch.txt --sessionsfolder=/u/project/cbearden/data/Enigma/Rome/qunex_studyfolder/sessions --parsessions=1 --overwrite=no" \
--scheduler_options="-l h_data=16G,h_rt=24:00:00,arch=intel*" \
--logdir="/u/project/cbearden/data/Enigma/Rome/qunex_studyfolder/processing/logs/manual" \
--array="yes" \
--sessions="C01 C02 C03 C04 C05 C06 C07 C08 C09 C10 C11 C12 C13 C14 C15 C17 C18 C19 C20 C21 C22 C23 C24 C25 C26 C27 D01 D02 D03 D04 D05 D06 D07 D08 D09 D10 D11 D12 D13 D14 D15 D16 D17 D18 D20 D21 D22 D23 D24 D25 D26 P01 P02 P03 P04 P05 P06 P07 P08 P09 P10 P11 P13 P14 P15 P16 P17 P18 P19 P20 P21 P22 P23 P24 P25 P26 P27 P28 P29 P30 P31 P32 P33 P35 P36 P37 P38"

#####################################################################
### BOLD post-processing
#####################################################################
# https://bitbucket.org/oriadev/qunex/wiki/UsageDocs/BOLDPreprocessing.md
# https://bitbucket.org/oriadev/qunex/wiki/UsageDocs/MovementScrubbing.md

## map hcp data
/u/project/cbearden/data/scripts/tools/qunex_bin/hoffman_submit_qunex.sh \
--qunex_command="map_hcp_data" \
--qunex_options=" --overwrite=yes --bolds=resting --sessions=/u/project/cbearden/data/Enigma/Rome/qunex_studyfolder/processing/Rome_batch.txt --sessionsfolder=/u/project/cbearden/data/Enigma/Rome/qunex_studyfolder/sessions" \
--scheduler_options="-l h_data=20G,h_rt=4:00:00,arch=intel*" \
--array="yes" \
--logdir="/u/project/cbearden/data/Enigma/Rome/qunex_studyfolder/processing/logs/manual" \
--sessions="C01 C02 C03 C04 C05 C06 C07 C08 C09 C10 C11 C12 C13 C14 C15 C17 C18 C19 C20 C21 C22 C23 C24 C25 C26 C27 D01 D02 D03 D04 D05 D06 D07 D08 D09 D10 D11 D12 D13 D14 D15 D16 D17 D18 D20 D21 D22 D23 D24 D25 D26 P01 P02 P03 P04 P05 P06 P07 P08 P09 P10 P11 P13 P14 P15 P16 P17 P18 P19 P20 P21 P22 P23 P24 P25 P26 P27 P28 P29 P30 P31 P32 P33 P35 P36 P37 P38"

## brain masks
/u/project/cbearden/data/scripts/tools/qunex_bin/hoffman_submit_qunex.sh \
--qunex_command="create_bold_brain_masks" \
--qunex_options="--overwrite=yes --sessions=/u/project/cbearden/data/Enigma/Rome/qunex_studyfolder/processing/Rome_batch.txt --sessionsfolder=/u/project/cbearden/data/Enigma/Rome/qunex_studyfolder/sessions" \
--scheduler_options="-l h_data=20G,h_rt=4:00:00,arch=intel*" \
--array="yes" \
--logdir="/u/project/cbearden/data/Enigma/Rome/qunex_studyfolder/processing/logs/manual" \
--sessions="C01 C02 C03 C04 C05 C06 C07 C08 C09 C10 C11 C12 C13 C14 C15 C17 C18 C19 C20 C21 C22 C23 C24 C25 C26 C27 D01 D02 D03 D04 D05 D06 D07 D08 D09 D10 D11 D12 D13 D14 D15 D16 D17 D18 D20 D21 D22 D23 D24 D25 D26 P01 P02 P03 P04 P05 P06 P07 P08 P09 P10 P11 P13 P14 P15 P16 P17 P18 P19 P20 P21 P22 P23 P24 P25 P26 P27 P28 P29 P30 P31 P32 P33 P35 P36 P37 P38"

## bold stats
/u/project/cbearden/data/scripts/tools/qunex_bin/hoffman_submit_qunex.sh \
--qunex_command="compute_bold_stats" \
--qunex_options="--overwrite=yes --bolds=resting --sessions=/u/project/cbearden/data/Enigma/Rome/qunex_studyfolder/processing/Rome_batch.txt --sessionsfolder=/u/project/cbearden/data/Enigma/Rome/qunex_studyfolder/sessions" \
--scheduler_options="-l h_data=20G,h_rt=4:00:00,arch=intel*" \
--array="yes" \
--logdir="/u/project/cbearden/data/Enigma/Rome/qunex_studyfolder/processing/logs/manual" \
--sessions="C01 C02 C03 C04 C05 C06 C07 C08 C09 C10 C11 C12 C13 C14 C15 C17 C18 C19 C20 C21 C22 C23 C24 C25 C26 C27 D01 D02 D03 D04 D05 D06 D07 D08 D09 D10 D11 D12 D13 D14 D15 D16 D17 D18 D20 D21 D22 D23 D24 D25 D26 P01 P02 P03 P04 P05 P06 P07 P08 P09 P10 P11 P13 P14 P15 P16 P17 P18 P19 P20 P21 P22 P23 P24 P25 P26 P27 P28 P29 P30 P31 P32 P33 P35 P36 P37 P38"
   
## create stats report
/u/project/cbearden/data/scripts/tools/qunex_bin/hoffman_submit_qunex.sh \
--qunex_command="create_stats_report" \
--qunex_options="--overwrite=yes --bolds=resting --sessions=/u/project/cbearden/data/Enigma/Rome/qunex_studyfolder/processing/Rome_batch.txt --sessionsfolder=/u/project/cbearden/data/Enigma/Rome/qunex_studyfolder/sessions" \
--scheduler_options="-l h_data=20G,h_rt=4:00:00,arch=intel*" \
--array="yes" \
--logdir="/u/project/cbearden/data/Enigma/Rome/qunex_studyfolder/processing/logs/manual" \
--sessions="C01 C02 C03 C04 C05 C06 C07 C08 C09 C10 C11 C12 C13 C14 C15 C17 C18 C19 C20 C21 C22 C23 C24 C25 C26 C27 D01 D02 D03 D04 D05 D06 D07 D08 D09 D10 D11 D12 D13 D14 D15 D16 D17 D18 D20 D21 D22 D23 D24 D25 D26 P01 P02 P03 P04 P05 P06 P07 P08 P09 P10 P11 P13 P14 P15 P16 P17 P18 P19 P20 P21 P22 P23 P24 P25 P26 P27 P28 P29 P30 P31 P32 P33 P35 P36 P37 P38"

## extract nuisance signal
/u/project/cbearden/data/scripts/tools/qunex_bin/hoffman_submit_qunex.sh \
--qunex_command="extract_nuisance_signal" \
--qunex_options="--overwrite=yes --bolds=resting --sessions=/u/project/cbearden/data/Enigma/Rome/qunex_studyfolder/processing/Rome_batch.txt --sessionsfolder=/u/project/cbearden/data/Enigma/Rome/qunex_studyfolder/sessions" \
--scheduler_options="-l h_data=20G,h_rt=4:00:00,arch=intel*" \
--array="yes" \
--logdir="/u/project/cbearden/data/Enigma/Rome/qunex_studyfolder/processing/logs/manual" \
--sessions="C01 C02 C03 C04 C05 C06 C07 C08 C09 C10 C11 C12 C13 C14 C15 C17 C18 C19 C20 C21 C22 C23 C24 C25 C26 C27 D01 D02 D03 D04 D05 D06 D07 D08 D09 D10 D11 D12 D13 D14 D15 D16 D17 D18 D20 D21 D22 D23 D24 D25 D26 P01 P02 P03 P04 P05 P06 P07 P08 P09 P10 P11 P13 P14 P15 P16 P17 P18 P19 P20 P21 P22 P23 P24 P25 P26 P27 P28 P29 P30 P31 P32 P33 P35 P36 P37 P38"


## preprocess bold CIFTI no GSR
/u/project/cbearden/data/scripts/tools/qunex_bin/hoffman_submit_qunex.sh \
--qunex_command="preprocess_bold" \
--qunex_options="--overwrite=yes --bolds=resting --bold_actions=s,h,r,c,l --bold_nuisance=m,V,WM,1d --image_target=dtseries --sessions=/u/project/cbearden/data/Enigma/Rome/qunex_studyfolder/processing/Rome_batch.txt --sessionsfolder=/u/project/cbearden/data/Enigma/Rome/qunex_studyfolder/sessions" \
--scheduler_options="-l h_data=20G,h_rt=4:00:00,arch=intel*" \
--array="yes" \
--logdir="/u/project/cbearden/data/Enigma/Rome/qunex_studyfolder/processing/logs/manual" \
--sessions="C01 C02 C03 C04 C05 C06 C07 C08 C09 C10 C11 C12 C13 C14 C15 C17 C18 C19 C20 C21 C22 C23 C24 C25 C26 C27 D01 D02 D03 D04 D05 D06 D07 D08 D09 D10 D11 D12 D13 D14 D15 D16 D17 D18 D20 D21 D22 D23 D24 D25 D26 P01 P02 P03 P04 P05 P06 P07 P08 P09 P10 P11 P13 P14 P15 P16 P17 P18 P19 P20 P21 P22 P23 P24 P25 P26 P27 P28 P29 P30 P31 P32 P33 P35 P36 P37 P38"

## preprocess bold CIFTI GSR
/u/project/cbearden/data/scripts/tools/qunex_bin/hoffman_submit_qunex.sh \
--qunex_command="preprocess_bold" \
--qunex_options="--overwrite=yes --bolds=resting --bold_actions=s,h,r,c,l --bold_nuisance=m,V,WM,WB,1d --image_target=dtseries --sessions=/u/project/cbearden/data/Enigma/Rome/qunex_studyfolder/processing/Rome_batch.txt --sessionsfolder=/u/project/cbearden/data/Enigma/Rome/qunex_studyfolder/sessions" \
--scheduler_options="-l h_data=20G,h_rt=4:00:00,arch=intel*" \
--array="yes" \
--logdir="/u/project/cbearden/data/Enigma/Rome/qunex_studyfolder/processing/logs/manual" \
--sessions="C01 C02 C03 C04 C05 C06 C07 C08 C09 C10 C11 C12 C13 C14 C15 C17 C18 C19 C20 C21 C22 C23 C24 C25 C26 C27 D01 D02 D03 D04 D05 D06 D07 D08 D09 D10 D11 D12 D13 D14 D15 D16 D17 D18 D20 D21 D22 D23 D24 D25 D26 P01 P02 P03 P04 P05 P06 P07 P08 P09 P10 P11 P13 P14 P15 P16 P17 P18 P19 P20 P21 P22 P23 P24 P25 P26 P27 P28 P29 P30 P31 P32 P33 P35 P36 P37 P38"

#####################################################################
### Catch up sessions that didn't finish
#####################################################################

msessions="C01 C02 C03 C04 C05 C06 C07 C08 C09 C10 C11 C12 C13 C14 C15 C17 C18 C19 C20 C21 C22 C23 C24 C25 C26 C27 D01 D02 D03 D04 D05 D06 D07 D08 D09 D10 D11 D12 D13 D14 D15 D16 D17 D18 D20 D21 D22 D23 D24 D25 D26 P01 P02 P03 P04 P05 P06 P07 P08 P09 P10 P11 P13 P14 P15 P16 P17 P18 P19 P20 P21 P22 P23 P24 P25 P26 P27 P28 P29 P30 P31 P32 P33 P35 P36 P37 P38"
for i in $sessions; do if [[ -f ${i}/images/functional/bold1_Atlas_s_hpss_res-mVWMWB1d_lpss.dtseries.nii  ]] || [[ -f ${i}/images/functional/bold2_Atlas_s_hpss_res-mVWMWB1d_lpss.dtseries.nii  ]]; then echo ${i} has processed BOLD; else echo ${i} MISSING; fi; done
#for i in $sessions; do if [[ ! -f ${i}/images/functional/bold1_Atlas_s_hpss_res-mVWMWB1d_lpss.dtseries.nii  ]]; then echo ${i} missing processed BOLD; fi; done

# missing processed BOLD 3/15/22
sessions="D08 D24 D26 P13"
# D08 -- no bold rest, has "act_BOLD_1_" need to figure out what that is
# D24 -- no bold rest, has "bas_BOLD_1_" need to figure out what that is
# D26 -- no T1w scan seemingly
# P13 has two bold rest and a t1w, need to try rerunning

# D19, P12, P34 do not have BOLD

## 10. PreFreeSurfer
/u/project/cbearden/data/scripts/tools/qunex_bin/hoffman_submit_qunex.sh \
--qunex_command="hcp_pre_freesurfer" \
--qunex_options="--sessions=/u/project/cbearden/data/Enigma/Rome/qunex_studyfolder/processing/Rome_batch.txt --sessionsfolder=/u/project/cbearden/data/Enigma/Rome/qunex_studyfolder/sessions --parsessions=1 --overwrite=no" \
--scheduler_options="-l h_data=16G,h_rt=24:00:00,arch=intel*" \
--logdir="/u/project/cbearden/data/Enigma/Rome/qunex_studyfolder/processing/logs/manual" \
--array="yes" \
--sessions="P13"
## 11. FreeSurfer
/u/project/cbearden/data/scripts/tools/qunex_bin/hoffman_submit_qunex.sh \
--qunex_command="hcp_freesurfer" \
--qunex_options="--sessions=/u/project/cbearden/data/Enigma/Rome/qunex_studyfolder/processing/Rome_batch.txt --sessionsfolder=/u/project/cbearden/data/Enigma/Rome/qunex_studyfolder/sessions --parsessions=1 --overwrite=no" \
--scheduler_options="-l h_data=20G,h_rt=48:00:00,arch=intel*,highp" \
--logdir="/u/project/cbearden/data/Enigma/Rome/qunex_studyfolder/processing/logs/manual" \
--array="yes" \
--sessions="P13"
## 12. PostFreeSurfer
/u/project/cbearden/data/scripts/tools/qunex_bin/hoffman_submit_qunex.sh \
--qunex_command="hcp_post_freesurfer" \
--qunex_options="--sessions=/u/project/cbearden/data/Enigma/Rome/qunex_studyfolder/processing/Rome_batch.txt --sessionsfolder=/u/project/cbearden/data/Enigma/Rome/qunex_studyfolder/sessions --parsessions=1 --overwrite=no" \
--scheduler_options="-l h_data=20G,h_rt=24:00:00,arch=intel*" \
--logdir="/u/project/cbearden/data/Enigma/Rome/qunex_studyfolder/processing/logs/manual" \
--array="yes" \
--sessions="P13"
## 13. FMRI VOLUME
# was failing on P13 bold1, commented out in Rome_batch.txt to get to bold2
/u/project/cbearden/data/scripts/tools/qunex_bin/hoffman_submit_qunex.sh \
--qunex_command="hcp_fmri_volume" \
--qunex_options="--sessions=/u/project/cbearden/data/Enigma/Rome/qunex_studyfolder/processing/Rome_batch.txt --sessionsfolder=/u/project/cbearden/data/Enigma/Rome/qunex_studyfolder/sessions --parsessions=1 --overwrite=no" \
--scheduler_options="-l h_data=16G,h_rt=24:00:00,arch=intel*" \
--logdir="/u/project/cbearden/data/Enigma/Rome/qunex_studyfolder/processing/logs/manual" \
--array="yes" \
--sessions="P13"
## 14. FMRI SURFACE
/u/project/cbearden/data/scripts/tools/qunex_bin/hoffman_submit_qunex.sh \
--qunex_command="hcp_fmri_surface" \
--qunex_options="--sessions=/u/project/cbearden/data/Enigma/Rome/qunex_studyfolder/processing/Rome_batch.txt --sessionsfolder=/u/project/cbearden/data/Enigma/Rome/qunex_studyfolder/sessions --parsessions=1 --overwrite=no" \
--scheduler_options="-l h_data=16G,h_rt=24:00:00,arch=intel*" \
--logdir="/u/project/cbearden/data/Enigma/Rome/qunex_studyfolder/processing/logs/manual" \
--array="yes" \
--sessions="P13"
## map hcp data
/u/project/cbearden/data/scripts/tools/qunex_bin/hoffman_submit_qunex.sh \
--qunex_command="map_hcp_data" \
--qunex_options=" --overwrite=yes --bolds=resting --sessions=/u/project/cbearden/data/Enigma/Rome/qunex_studyfolder/processing/Rome_batch.txt --sessionsfolder=/u/project/cbearden/data/Enigma/Rome/qunex_studyfolder/sessions" \
--scheduler_options="-l h_data=20G,h_rt=4:00:00,arch=intel*" \
--array="yes" \
--logdir="/u/project/cbearden/data/Enigma/Rome/qunex_studyfolder/processing/logs/manual" \
--sessions="P13"
## brain masks
/u/project/cbearden/data/scripts/tools/qunex_bin/hoffman_submit_qunex.sh \
--qunex_command="create_bold_brain_masks" \
--qunex_options="--overwrite=yes --sessions=/u/project/cbearden/data/Enigma/Rome/qunex_studyfolder/processing/Rome_batch.txt --sessionsfolder=/u/project/cbearden/data/Enigma/Rome/qunex_studyfolder/sessions" \
--scheduler_options="-l h_data=20G,h_rt=4:00:00,arch=intel*" \
--array="yes" \
--logdir="/u/project/cbearden/data/Enigma/Rome/qunex_studyfolder/processing/logs/manual" \
--sessions="P13"
## bold stats
/u/project/cbearden/data/scripts/tools/qunex_bin/hoffman_submit_qunex.sh \
--qunex_command="compute_bold_stats" \
--qunex_options="--overwrite=yes --bolds=resting --sessions=/u/project/cbearden/data/Enigma/Rome/qunex_studyfolder/processing/Rome_batch.txt --sessionsfolder=/u/project/cbearden/data/Enigma/Rome/qunex_studyfolder/sessions" \
--scheduler_options="-l h_data=20G,h_rt=4:00:00,arch=intel*" \
--array="yes" \
--logdir="/u/project/cbearden/data/Enigma/Rome/qunex_studyfolder/processing/logs/manual" \
--sessions="P13"
## create stats report
/u/project/cbearden/data/scripts/tools/qunex_bin/hoffman_submit_qunex.sh \
--qunex_command="create_stats_report" \
--qunex_options="--overwrite=yes --bolds=resting --sessions=/u/project/cbearden/data/Enigma/Rome/qunex_studyfolder/processing/Rome_batch.txt --sessionsfolder=/u/project/cbearden/data/Enigma/Rome/qunex_studyfolder/sessions" \
--scheduler_options="-l h_data=20G,h_rt=4:00:00,arch=intel*" \
--array="yes" \
--logdir="/u/project/cbearden/data/Enigma/Rome/qunex_studyfolder/processing/logs/manual" \
--sessions="P13"
## extract nuisance signal
/u/project/cbearden/data/scripts/tools/qunex_bin/hoffman_submit_qunex.sh \
--qunex_command="extract_nuisance_signal" \
--qunex_options="--overwrite=yes --bolds=resting --sessions=/u/project/cbearden/data/Enigma/Rome/qunex_studyfolder/processing/Rome_batch.txt --sessionsfolder=/u/project/cbearden/data/Enigma/Rome/qunex_studyfolder/sessions" \
--scheduler_options="-l h_data=20G,h_rt=4:00:00,arch=intel*" \
--array="yes" \
--logdir="/u/project/cbearden/data/Enigma/Rome/qunex_studyfolder/processing/logs/manual" \
--sessions="P13"
## preprocess bold CIFTI no GSR
/u/project/cbearden/data/scripts/tools/qunex_bin/hoffman_submit_qunex.sh \
--qunex_command="preprocess_bold" \
--qunex_options="--overwrite=yes --bolds=resting --bold_actions=s,h,r,c,l --bold_nuisance=m,V,WM,1d --image_target=dtseries --sessions=/u/project/cbearden/data/Enigma/Rome/qunex_studyfolder/processing/Rome_batch.txt --sessionsfolder=/u/project/cbearden/data/Enigma/Rome/qunex_studyfolder/sessions" \
--scheduler_options="-l h_data=20G,h_rt=4:00:00,arch=intel*" \
--array="yes" \
--logdir="/u/project/cbearden/data/Enigma/Rome/qunex_studyfolder/processing/logs/manual" \
--sessions="P13"
## preprocess bold CIFTI GSR
/u/project/cbearden/data/scripts/tools/qunex_bin/hoffman_submit_qunex.sh \
--qunex_command="preprocess_bold" \
--qunex_options="--overwrite=yes --bolds=resting --bold_actions=s,h,r,c,l --bold_nuisance=m,V,WM,WB,1d --image_target=dtseries --sessions=/u/project/cbearden/data/Enigma/Rome/qunex_studyfolder/processing/Rome_batch.txt --sessionsfolder=/u/project/cbearden/data/Enigma/Rome/qunex_studyfolder/sessions" \
--scheduler_options="-l h_data=20G,h_rt=4:00:00,arch=intel*" \
--array="yes" \
--logdir="/u/project/cbearden/data/Enigma/Rome/qunex_studyfolder/processing/logs/manual" \
--sessions="P13"

# final check for check GSR and noGSR for everything in sessions dir
cd /u/project/cbearden/data/Enigma/Rome/qunex_studyfolder/sessions
sessions=*[0-9]
echo GSR
for i in $sessions; do if [[ -f ${i}/images/functional/bold1_Atlas_s_hpss_res-mVWMWB1d_lpss.dtseries.nii  ]] || [[ -f ${i}/images/functional/bold2_Atlas_s_hpss_res-mVWMWB1d_lpss.dtseries.nii  ]]; then echo ${i} has processed BOLD; else echo ${i} MISSING; fi; done
echo noGSR
for i in $sessions; do if [[ -f ${i}/images/functional/bold1_Atlas_s_hpss_res-mVWM1d_lpss.dtseries.nii  ]] || [[ -f ${i}/images/functional/bold2_Atlas_s_hpss_res-mVWM1d_lpss.dtseries.nii  ]]; then echo ${i} has processed BOLD; else echo ${i} MISSING; fi; done

#####################################################################
### re-check T1w QC
#####################################################################
sessions="C01 C02 C03 C04 C05 C06 C07 C08 C09 C10 C11 C12 C13 C14 C15 C17 C18 C19 C20 C21 C22 C23 C24 C25 C26 C27 D01 D02 D03 D04 D05 D06 D07 D08 D09 D10 D11 D12 D13 D14 D15 D16 D17 D18 D20 D21 D22 D23 D24 D25 P01 P02 P03 P04 P05 P06 P07 P08 P09 P10 P11 P13 P14 P15 P16 P17 P18 P19 P20 P21 P22 P23 P24 P25 P26 P27 P28 P29 P30 P31 P32 P33 P35 P36 P37 P38 "

# check T1w QC image for each session, while manually recording results in 22q_BOLD_Longitudinal_multisite_QC_cs.xlsx
# fail any session with obvious bad T1 (motion, intense banding, signal dropout in brain), pass all others
# note if failing for a neuroanatomical variation
for sesh in $sessions; do echo ${sesh}; display /u/project/cbearden/data/Enigma/Rome/qunex_studyfolder/sessions/${sesh}/hcp/${sesh}/MNINonLinear/StructuralQC/snapshots/${sesh}.structuralQC.wb_scene1.png;done


#####################################################################
### Seed-based BOLD functional connectivity
#####################################################################
# https://bitbucket.org/oriadev/qunex/wiki/UsageDocs/BOLDFunctionalConnectivity.md

# subcortical seeds -- bandpass, GSR, reading boldn for bold rest from session_hcp.txt
# n=79
sessions="C01 C02 C03 C04 C05 C06 C07 C08 C09 C10 C11 C12 C13 C14 C15 C17 C18 C19 C20 C21 C22 C23 C24 C25 C26 C27 D01 D02 D03 D04 D05 D06 D07 D09 D10 D11 D12 D14 D15 D16 D17 D18 D20 D21 D22 D23 P02 P04 P05 P06 P07 P08 P09 P11 P13 P14 P15 P16 P17 P18 P19 P20 P21 P22 P23 P24 P25 P26 P27 P28 P29 P30 P31 P32 P33 P35 P36 P37 P38"
sdir=/u/project/cbearden/data/Enigma/Rome/qunex_studyfolder/sessions/
for sesh in $sessions; do 
# get boldn as the second field of session_hcp.txt line with "resting" skipping lines that don't start with [0-9] e.g. commented out
boldn=$(cat ${sdir}/${sesh}/session_hcp.txt  | grep "resting" | grep ^[0-9] | cut -d ":" -f 2 | xargs)
infile=${boldn}_Atlas_s_hpss_res-mVWMWB1d_lpss.dtseries.nii
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
--outname=resting_fc_seed_s_hpss_res-mVWMWB1d_lpss \
--ignore=udvarsme \
--method=mean \
--mask=5" \
--scheduler_options="-l h_data=20G,h_rt=2:00:00,arch=intel*" \
--array="yes" \
--logdir="/u/project/cbearden/data/Enigma/Rome/qunex_studyfolder/processing/logs/manual" \
--sessions=${sesh}
done


# subcortical seeds -- bandpass, no GSR, reading boldn for bold rest from session_hcp.txt
# n=79
sessions="C01 C02 C03 C04 C05 C06 C07 C08 C09 C10 C11 C12 C13 C14 C15 C17 C18 C19 C20 C21 C22 C23 C24 C25 C26 C27 D01 D02 D03 D04 D05 D06 D07 D09 D10 D11 D12 D14 D15 D16 D17 D18 D20 D21 D22 D23 P02 P04 P05 P06 P07 P08 P09 P11 P13 P14 P15 P16 P17 P18 P19 P20 P21 P22 P23 P24 P25 P26 P27 P28 P29 P30 P31 P32 P33 P35 P36 P37 P38"
sdir=/u/project/cbearden/data/Enigma/Rome/qunex_studyfolder/sessions/
for sesh in $sessions; do 
# get boldn as the second field of session_hcp.txt line with "resting" skipping lines that don't start with [0-9] e.g. commented out
boldn=$(cat ${sdir}/${sesh}/session_hcp.txt  | grep "resting" | grep ^[0-9] | cut -d ":" -f 2 | xargs)
infile=${boldn}_Atlas_s_hpss_res-mVWM1d_lpss.dtseries.nii
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
--outname=resting_fc_seed_s_hpss_res-mVWM1d_lpss \
--ignore=udvarsme \
--method=mean \
--mask=5" \
--scheduler_options="-l h_data=20G,h_rt=2:00:00,arch=intel*" \
--array="yes" \
--logdir="/u/project/cbearden/data/Enigma/Rome/qunex_studyfolder/processing/logs/manual" \
--sessions=${sesh}
done


#####################################################################
### Global BOLD functional connectivity
#####################################################################

## Global Brain Connectivity
# GSR, bandpass
sessions="C01 C02 C03 C04 C05 C06 C07 C08 C09 C10 C11 C12 C13 C14 C15 C17 C18 C19 C20 C21 C22 C23 C24 C25 C26 C27 D01 D02 D03 D04 D05 D06 D07 D09 D10 D11 D12 D14 D15 D16 D17 D18 D20 D21 D22 D23 P02 P04 P05 P06 P07 P08 P09 P11 P13 P14 P15 P16 P17 P18 P19 P20 P21 P22 P23 P24 P25 P26 P27 P28 P29 P30 P31 P32 P33 P35 P36 P37 P38"
sdir=/u/project/cbearden/data/Enigma/Rome/qunex_studyfolder/sessions/
for sesh in $sessions; do 
# get boldn as the second field of session_hcp.txt line with "resting" skipping lines that don't start with [0-9] e.g. commented out
boldn=$(cat ${sdir}/${sesh}/session_hcp.txt  | grep "resting" | grep ^[0-9] | cut -d ":" -f 2 | xargs)
infile=${boldn}_Atlas_s_hpss_res-mVWMWB1d_lpss.dtseries.nii
echo ${sesh} ${infile}
/u/project/cbearden/data/scripts/tools/qunex_bin/hoffman_submit_qunex.sh \
--qunex_command="fc_compute_wrapper" \
--qunex_options="--sessionsfolder=/u/project/cbearden/data/22q/qunex_studyfolder/sessions/ \
--calculation=gbc \
--command=mFz:0 \
--runtype=individual \
--inputfiles=${infile} \
--inputpath=/images/functional/ \
--overwrite=no \
--extractdata=no \
--outname=resting_fc_gbc_s_hpss_res-mVWMWB1d_lpss \
--ignore=udvarsme \
--method=mean \
--mask=5" \
--scheduler_options="-l h_data=20G,h_rt=10:00:00,arch=intel*" \
--array="yes" \
--logdir="/u/project/cbearden/data/Enigma/Rome/qunex_studyfolder/processing/logs/manual" \
--sessions=${sesh}
done


## Global Brain Connectivity
# no GSR, bandpass
sessions="C01 C02 C03 C04 C05 C06 C07 C08 C09 C10 C11 C12 C13 C14 C15 C17 C18 C19 C20 C21 C22 C23 C24 C25 C26 C27 D01 D02 D03 D04 D05 D06 D07 D09 D10 D11 D12 D14 D15 D16 D17 D18 D20 D21 D22 D23 P02 P04 P05 P06 P07 P08 P09 P11 P13 P14 P15 P16 P17 P18 P19 P20 P21 P22 P23 P24 P25 P26 P27 P28 P29 P30 P31 P32 P33 P35 P36 P37 P38"
sdir=/u/project/cbearden/data/Enigma/Rome/qunex_studyfolder/sessions/
for sesh in $sessions; do 
# get boldn as the second field of session_hcp.txt line with "resting" skipping lines that don't start with [0-9] e.g. commented out
boldn=$(cat ${sdir}/${sesh}/session_hcp.txt  | grep "resting" | grep ^[0-9] | cut -d ":" -f 2 | xargs)
infile=${boldn}_Atlas_s_hpss_res-mVWM1d_lpss.dtseries.nii
echo ${sesh} ${infile}
/u/project/cbearden/data/scripts/tools/qunex_bin/hoffman_submit_qunex.sh \
--qunex_command="fc_compute_wrapper" \
--qunex_options="--sessionsfolder=/u/project/cbearden/data/22q/qunex_studyfolder/sessions/ \
--calculation=gbc \
--command=mFz:0 \
--runtype=individual \
--inputfiles=${infile} \
--inputpath=/images/functional/ \
--overwrite=no \
--extractdata=no \
--outname=resting_fc_gbc_s_hpss_res-mVWM1d_lpss \
--ignore=udvarsme \
--method=mean \
--mask=5" \
--scheduler_options="-l h_data=20G,h_rt=10:00:00,arch=intel*" \
--array="yes" \
--logdir="/u/project/cbearden/data/Enigma/Rome/qunex_studyfolder/processing/logs/manual" \
--sessions=${sesh}
done

