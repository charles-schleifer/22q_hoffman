#!/bin/sh

# 8/18/21
# initial commands for preprocessing xxx ENIGMA data, plus examples for later commands


#######################################################################
### organize and prepare data
#######################################################################

## set up study folder
# https://bitbucket.org/oriadev/qunex/wiki/UsageDocs/PreparingStudy.md
cd /u/project/cbearden/data/Enigma/
/u/project/cbearden/data/scripts/tools/qunex_bin/hoffman_submit_qunex.sh \
--qunex_command="create_study" \
--qunex_options="--studyfolder=/u/project/cbearden/data/Enigma/qunex_studyfolder" \
--scheduler_options="-l h_data=4G,h_rt=2:00:00" \
--array="no" 

# make directory to organize extra log files from hoffman_submit_qunex.sh
# run hoffman_submit_qunex.sh from this directory to keep logs organized 
mkdir /u/project/cbearden/data/Enigma/qunex_studyfolder/processing/logs/manual

## organize raw dicoms for Rome subjects
#cd /u/project/cbearden/data/raw/Enigma/Rome/subjects
#for i in $(ls); do echo $i; cp -r $i /u/project/cbearden/data/Enigma/qunex_studyfolder/sessions/inbox/MR/;done

## import DICOMs 
# https://bitbucket.org/oriadev/qunex/wiki/UsageDocs/OnboardingDICOMData.md
cd /u/project/cbearden/data/Enigma/qunex_studyfolder/processing/logs/manual
/u/project/cbearden/data/scripts/tools/qunex_bin/hoffman_submit_qunex.sh \
--qunex_command="import_dicom" \
--qunex_options="--sessionsfolder=/u/project/cbearden/data/Enigma/qunex_studyfolder/sessions --gzip=yes --check=any" \
--scheduler_options="-l h_data=16G,h_rt=24:00:00" \
--array="no" 




#######################################################################
### EXAMPLE COMMANDS (need to modify paths, session lists, and options)
#######################################################################

## get list of unique runs to aid in manual setup of hcp mapping file
seshdir=/u/project/cbearden/data/Enigma/qunex_studyfolder/sessions/
sessions="C01 C02 C03 C04 C06 C07 C08 C09 C10 C11 C12 C13 C14 C15 C17 C18 C19 C20 C21 C22 C23 C24 C25 C26 C27 D01 D02 D03 D04 D05 D06 D07 D08 D09 D10 D11 D12 D13 D14 D15 D16 D17 D18 D19 D20 D21 D22 D23 D24 D25 D26 P01 P02 P03 P04 P05 P06 P07 P08 P09 P10 P11 P12 P13 P14 P15 P16 P17 P18 P19 P20 P21 P22 P23 P24 P25 P26 P27 P28 P29 P30 P31 P32 P33 P34 P35 P36 P37 P38 C05"
#rm ${seshdir}/specs/all_runs.txt
for i in ${sessions}; do cat ${seshdir}/${i}/session.txt | grep '^[0-9]' >> ${seshdir}/specs/all_runs_$(whoami).txt; done
cut ${seshdir}/specs/all_runs_$(whoami).txt -d : -f 2 | sort | uniq > ${seshdir}/specs/unique_runs_$(whoami).txt


## Need to manually set up mapping file now
# https://bitbucket.org/oriadev/qunex/wiki/UsageDocs/PreparingMappingFile.md

## HCP mapping
# https://bitbucket.org/oriadev/qunex/wiki/UsageDocs/PreparingDataHCP.md
cd /u/project/cbearden/data/xxxPrisma/qunex_studyfolder/processing/logs/manual/
/u/project/cbearden/data/scripts/tools/qunex_bin/hoffman_submit_qunex.sh \
--qunex_command="create_session_info" \
--qunex_options="--overwrite=no --sourcefile=session.txt --targetfile=session_hcp.txt --pipelines=hcp --mapping=/u/project/cbearden/data/xxxPrisma/qunex_studyfolder/sessions/specs/xxxPrisma_HCP_mapping.txt --sessionsfolder=/u/project/cbearden/data/xxxPrisma/qunex_studyfolder/sessions/" \
--scheduler_options="-l h_data=4G,h_rt=5:00:00" \
--array="no" 

## Setup HCP
# https://bitbucket.org/oriadev/qunex/wiki/UsageDocs/PreparingDataHCP.md#markdown-header-mapping-the-files-into-the-hcp-file-structure
cd /u/project/cbearden/data/xxxPrisma/qunex_studyfolder/processing/logs/manual/
/u/project/cbearden/data/scripts/tools/qunex_bin/hoffman_submit_qunex.sh \
--qunex_command="setup_hcp" \
--qunex_options="--sessionsfolder=/u/project/cbearden/data/xxxPrisma/qunex_studyfolder/sessions --sourcefile=session_hcp.txt" \
--scheduler_options="-l h_data=4G,h_rt=24:00:00" \
--array="yes" \
--sessions="Q_0001_02222018 Q_0005_11072017"

## Need to manually set up parameter file now
# https://bitbucket.org/oriadev/qunex/wiki/UsageDocs/GeneratingBatchFiles.md

## create batch file
# Note: need to run as --array=no and specify sessions as a comma separated list in --qunex_options in order to create a single batch file with all sessions listed
cd /u/project/cbearden/data/xxxPrisma/qunex_studyfolder/processing/logs/manual/
/u/project/cbearden/data/scripts/tools/qunex_bin/hoffman_submit_qunex.sh \
--qunex_command="create_batch" \
--qunex_options=" --overwrite=yes --sessionsfolder=/u/project/cbearden/data/xxxPrisma/qunex_studyfolder/sessions --sourcefiles=session_hcp.txt --targetfile=/u/project/cbearden/data/xxxPrisma/qunex_studyfolder/processing/xxxPrisma_batch.txt --paramfile=/u/project/cbearden/data/xxxPrisma/qunex_studyfolder/sessions/specs/xxxPrisma_params.txt --sessions=Q_0001_02222018,Q_0005_11072017,Q_0017_10022017,Q_0019_03022020,Q_0030_05082018,Q_0036_08082017,Q_0036_08312018,Q_0036_09302019,Q_0037_08152017,Q_0038_08192019,Q_0041_10092017,Q_0051_02032017,Q_0105_03112020,Q_0105_12032018,Q_0114_12052017,Q_0138_01082018,Q_0141_06122018,Q_0141_08052019,Q_0147_12112017,Q_0147_12112018,Q_0196_01082020,Q_0213_05012017,Q_0214_05012017,Q_0217_01242017,Q_0217_02192020,Q_0234_05302017,Q_0235_05252017,Q_0238_02202018,Q_0240_09192017,Q_0240_11162018,Q_0246_10092018,Q_0246_10102017,Q_0246_10142016,Q_0250_10242017,Q_0260_06192017,Q_0260_06242019,Q_0260_06252018,Q_0263_02252019,Q_0263_02262018,Q_0263_11072016,Q_0271_10182016,Q_0277_11302017,Q_0277_12132016,Q_0278_11292017,Q_0278_12052019,Q_0278_12132016,Q_0279_11302017,Q_0279_12052019,Q_0279_12132016,Q_0285_03212017,Q_0285_06062018,Q_0286_03212017,Q_0287_03212017,Q_0287_06062018,Q_0288_06062018,Q_0289_03212017,Q_0289_06062018,Q_0291_11042016,Q_0291_11302018,Q_0304_12202016,Q_0310_01252018,Q_0310_02132017,Q_0310_04292019,Q_0313_05072019,Q_0319_03192018,Q_0319_03282017,Q_0321_03192018,Q_0321_03272017,Q_0324_04182018,Q_0324_05032017,Q_0326_10202017,Q_0326_12062018,Q_0327_10192017,Q_0327_12072018,Q_0331_06102019,Q_0331_06212018,Q_0331_06272017,Q_0333_04142017,Q_0334_12012016,Q_0336_01102017,Q_0337_04022018,Q_0338_02162017,Q_0339_03292018,Q_0345_04122017,Q_0345_08152018,Q_0345_09112019,Q_0346_04102017,Q_0346_04102018,Q_0348_04212017,Q_0348_08152018,Q_0350_04192017,Q_0350_09142018,Q_0353_04182018,Q_0353_05022017,Q_0355_05312018,Q_0355_06052019,Q_0356_05312018,Q_0356_06052019,Q_0356_06062017,Q_0361_08212017,Q_0361_10212019,Q_0361_11202018,Q_0369_04182018,Q_0369_06182019,Q_0371_07312019,Q_0371_08042020,Q_0374_05152019,Q_0374_05252018,Q_0377_07242018,Q_0381_08072018,Q_0381_09102019,Q_0382_08282018,Q_0383_08282018,Q_0387_08242018,Q_0387_12032019,Q_0390_09042018,Q_0390_09302019,Q_0391_09252018,Q_0395_11062018,Q_0395_11062018_18,Q_0395_11062018_2,Q_0397_10172019,Q_0402_01112019,Q_0404_03112019,Q_0404_03162020,Q_0407_06122019,Q_0408_05172019,Q_0411_05202019,Q_0414_07172019,Q_0415_07292019,Q_0416_07292019,Q_0419_08132019,Q_0422_11262019,Q_0425_11052019,Q_0426_11262019,Q_0429_01092020,Q_0432_02142020,Q_0433_02262020,Q_0443_06282021,Q_0446_06152021" \
--scheduler_options="-l h_data=4G,h_rt=4:00:00" \
--array="no" 


### --- HCP steps
# https://bitbucket.org/oriadev/qunex/wiki/UsageDocs/HCPPreprocessing.md

## PreFreeSurfer
# https://bitbucket.org/oriadev/qunex/wiki/UsageDocs/HCPPreFreeSurfer.md
cd /u/project/cbearden/data/xxxPrisma/qunex_studyfolder/processing/logs/manual/
/u/project/cbearden/data/scripts/tools/qunex_bin/hoffman_submit_qunex.sh \
--qunex_command="hcp_pre_freesurfer" \
--qunex_options="--sessions=/u/project/cbearden/data/xxxPrisma/qunex_studyfolder/processing/xxxPrisma_batch.txt --sessionsfolder=/u/project/cbearden/data/xxxPrisma/qunex_studyfolder/sessions --parsessions=1 --overwrite=no" \
--scheduler_options="-l h_data=16G,h_rt=24:00:00" \
--array="yes" \
--sessions="Q_0001_02222018 Q_0005_11072017"

## FreeSurfer
# https://bitbucket.org/oriadev/qunex/wiki/UsageDocs/HCPFreeSurfer.md
cd /u/project/cbearden/data/xxxPrisma/qunex_studyfolder/processing/logs/manual/
/u/project/cbearden/data/scripts/tools/qunex_bin/hoffman_submit_qunex.sh \
--qunex_command="hcp_freesurfer" \
--qunex_options="--sessions=/u/project/cbearden/data/xxxPrisma/qunex_studyfolder/processing/xxxPrisma_batch.txt --sessionsfolder=/u/project/cbearden/data/xxxPrisma/qunex_studyfolder/sessions --parsessions=1 --overwrite=no" \
--scheduler_options="-l h_data=16G,h_rt=48:00:00,highp" \
--array="yes" \
--sessions="Q_0001_02222018 Q_0005_11072017"

## PostFreeSurfer
# https://bitbucket.org/oriadev/qunex/wiki/UsageDocs/HCPPostFreeSurfer.md
cd /u/project/cbearden/data/xxxPrisma/qunex_studyfolder/processing/logs/manual/
/u/project/cbearden/data/scripts/tools/qunex_bin/hoffman_submit_qunex.sh \
--qunex_command="hcp_post_freesurfer" \
--qunex_options="--sessions=/u/project/cbearden/data/xxxPrisma/qunex_studyfolder/processing/xxxPrisma_batch.txt --sessionsfolder=/u/project/cbearden/data/xxxPrisma/qunex_studyfolder/sessions --parsessions=1 --overwrite=no" \
--scheduler_options="-l h_data=16G,h_rt=24:00:00" \
--array="yes" \
--sessions="Q_0001_02222018 Q_0005_11072017"

## FMRI VOLUME
# https://bitbucket.org/oriadev/qunex/wiki/UsageDocs/HCPfMRIVolume.md
cd /u/project/cbearden/data/xxxPrisma/qunex_studyfolder/processing/logs/manual/
/u/project/cbearden/data/scripts/tools/qunex_bin/hoffman_submit_qunex.sh \
--qunex_command="hcp_fmri_volume" \
--qunex_options="--sessions=/u/project/cbearden/data/xxxPrisma/qunex_studyfolder/processing/xxxPrisma_batch.txt --sessionsfolder=/u/project/cbearden/data/xxxPrisma/qunex_studyfolder/sessions --parsessions=1 --overwrite=no" \
--scheduler_options="-l h_data=16G,h_rt=48:00:00,highp" \
--array="yes" \
--sessions="Q_0001_02222018 Q_0005_11072017"

## FMRI SURFACE
# https://bitbucket.org/oriadev/qunex/wiki/UsageDocs/HCPfMRISurface.md
cd /u/project/cbearden/data/xxxPrisma/qunex_studyfolder/processing/logs/manual/
/u/project/cbearden/data/scripts/tools/qunex_bin/hoffman_submit_qunex.sh \
--qunex_command="hcp_fmri_surface" \
--qunex_options="--sessions=/u/project/cbearden/data/xxxPrisma/qunex_studyfolder/processing/xxxPrisma_batch.txt --sessionsfolder=/u/project/cbearden/data/xxxPrisma/qunex_studyfolder/sessions --parsessions=1 --overwrite=no" \
--scheduler_options="-l h_data=16G,h_rt=48:00:00,highp" \
--array="yes" \
--sessions="Q_0001_02222018 Q_0005_11072017"


### --- QC
# https://bitbucket.org/oriadev/qunex/wiki/UsageDocs/MultiModalQC.md

## T1w QC
cd /u/project/cbearden/data/xxxPrisma/qunex_studyfolder/processing/logs/manual
/u/project/cbearden/data/scripts/tools/qunex_bin/hoffman_submit_qunex.sh \
--qunex_command="run_qc" \
--qunex_options="--modality=T1w --overwrite=no --sessionsfolder=/u/project/cbearden/data/xxxPrisma/qunex_studyfolder/sessions" \
--scheduler_options="-l h_data=16G,h_rt=24:00:00" \
--array="yes" \
--sessions="Q_0001_02222018 Q_0005_11072017"

## BOLD QC
cd /u/project/cbearden/data/xxxPrisma/qunex_studyfolder/processing/logs/manual
/u/project/cbearden/data/scripts/tools/qunex_bin/hoffman_submit_qunex.sh \
--qunex_command="run_qc" \
--qunex_options="--modality=BOLD --bolddata=1,2,3,4 --boldprefix=BOLD --boldsuffix=Atlas --overwrite=no --skipframes=5 --sessionsfolder=/u/project/cbearden/data/xxxPrisma/qunex_studyfolder/sessions" \
--scheduler_options="-l h_data=16G,h_rt=24:00:00" \
--array="yes" \
--sessions="Q_0001_02222018 Q_0005_11072017"


### --- BOLD post-processing
# https://bitbucket.org/oriadev/qunex/wiki/UsageDocs/BOLDPreprocessing.md
# https://bitbucket.org/oriadev/qunex/wiki/UsageDocs/MovementScrubbing.md

## map hcp data
cd /u/project/cbearden/data/xxx/qunex_studyfolder/processing/logs/manual
/u/project/cbearden/data/scripts/tools/qunex_bin/hoffman_submit_qunex.sh \
--qunex_command="map_hcp_data" \
--qunex_options="--bolds=resting --sessions=/u/project/cbearden/data/xxx/qunex_studyfolder/processing/xxx_trio_batch.txt --sessionsfolder=/u/project/cbearden/data/xxx/qunex_studyfolder/sessions --overwrite=no" \
--scheduler_options="-l h_data=16G,h_rt=24:00:00" \
--array="yes" \
--sessions="Q_0001_09242012 Q_0001_10152010"

## brain masks
cd /u/project/cbearden/data/xxx/qunex_studyfolder/processing/logs/manual
/u/project/cbearden/data/scripts/tools/qunex_bin/hoffman_submit_qunex.sh \
--qunex_command="create_bold_brain_masks" \
--qunex_options="--sessions=/u/project/cbearden/data/xxx/qunex_studyfolder/processing/xxx_trio_batch.txt --sessionsfolder=/u/project/cbearden/data/xxx/qunex_studyfolder/sessions --overwrite=no" \
--scheduler_options="-l h_data=16G,h_rt=24:00:00" \
--array="yes" \
--sessions="Q_0001_09242012 Q_0001_10152010"

## bold stats
cd /u/project/cbearden/data/xxx/qunex_studyfolder/processing/logs/manual
/u/project/cbearden/data/scripts/tools/qunex_bin/hoffman_submit_qunex.sh \
--qunex_command="compute_bold_stats" \
--qunex_options="--bolds=resting --sessions=/u/project/cbearden/data/xxx/qunex_studyfolder/processing/xxx_trio_batch.txt --sessionsfolder=/u/project/cbearden/data/xxx/qunex_studyfolder/sessions --overwrite=no" \
--scheduler_options="-l h_data=16G,h_rt=24:00:00" \
--array="yes" \
--sessions="Q_0001_09242012 Q_0001_10152010"
   
## create stats report
cd /u/project/cbearden/data/xxx/qunex_studyfolder/processing/logs/manual
/u/project/cbearden/data/scripts/tools/qunex_bin/hoffman_submit_qunex.sh \
--qunex_command="create_stats_report" \
--qunex_options="--bolds=resting --sessions=/u/project/cbearden/data/xxx/qunex_studyfolder/processing/xxx_trio_batch.txt --sessionsfolder=/u/project/cbearden/data/xxx/qunex_studyfolder/sessions --overwrite=no" \
--scheduler_options="-l h_data=16G,h_rt=24:00:00" \
--array="no" 

## extract nuisance signal
cd /u/project/cbearden/data/xxx/qunex_studyfolder/processing/logs/manual
/u/project/cbearden/data/scripts/tools/qunex_bin/hoffman_submit_qunex.sh \
--qunex_command="extract_nuisance_signal" \
--qunex_options="--bolds=resting --sessions=/u/project/cbearden/data/xxx/qunex_studyfolder/processing/xxx_trio_batch.txt --sessionsfolder=/u/project/cbearden/data/xxx/qunex_studyfolder/sessions --overwrite=no" \
--scheduler_options="-l h_data=16G,h_rt=24:00:00" \
--array="yes" \
--sessions="Q_0001_09242012 Q_0001_10152010"

## preprocess bold CIFTI no GSR
# Note: failed with 16G but seems ok running with 20G
cd /u/project/cbearden/data/xxx/qunex_studyfolder/processing/logs/manual
/u/project/cbearden/data/scripts/tools/qunex_bin/hoffman_submit_qunex.sh \
--qunex_command="preprocess_bold" \
--qunex_options="--bolds=resting --bold_actions=s,h,r,c,l --bold_nuisance=m,V,WM,1d --image_target=dtseries --sessions=/u/project/cbearden/data/xxx/qunex_studyfolder/processing/xxx_trio_batch.txt --sessionsfolder=/u/project/cbearden/data/xxx/qunex_studyfolder/sessions --overwrite=no" \
--scheduler_options="-l h_data=20G,h_rt=24:00:00" \
--array="yes" \
--sessions="Q_0001_09242012 Q_0001_10152010"

## preprocess bold CIFTI GSR
cd /u/project/cbearden/data/xxx/qunex_studyfolder/processing/logs/manual
/u/project/cbearden/data/scripts/tools/qunex_bin/hoffman_submit_qunex.sh \
--qunex_command="preprocess_bold" \
--qunex_options="--bolds=resting --bold_actions=s,h,r,c,l --bold_nuisance=m,V,WM,WB,1d --image_target=dtseries --sessions=/u/project/cbearden/data/xxx/qunex_studyfolder/processing/xxx_trio_batch.txt --sessionsfolder=/u/project/cbearden/data/xxx/qunex_studyfolder/sessions --overwrite=no" \
--scheduler_options="-l h_data=20G,h_rt=24:00:00" \
--array="yes" \
--sessions="Q_0001_09242012 Q_0001_10152010"


