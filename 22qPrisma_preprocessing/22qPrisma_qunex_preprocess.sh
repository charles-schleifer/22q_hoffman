#!/bin/sh

# C. Schleifer 11/03/22
# catch new subjects up with preprocessing

#####################################################################
### organize and prepare data
#####################################################################

## set up study folder
/u/project/cbearden/data/scripts/tools/qunex_bin/hoffman_submit_qunex.sh \
--qunex_command="create_study" \
--qunex_options="--studyfolder=/u/project/cbearden/data/22qPrisma/qunex_studyfolder" \
--scheduler_options="-l h_data=16G,h_rt=24:00:00" \
--logdir="/u/project/cbearden/data/22qPrisma/qunex_studyfolder/processing/logs/manual" \
--array="no" 

## organize raw dicoms
qsub -cwd -V -l h_data=8G,h_rt=24:00:00 /u/project/cbearden/data/22qPrisma/qunex_studyfolder/processing/scripts/prisma_copy_raw_dicoms.sh

## import DICOMs 
/u/project/cbearden/data/scripts/tools/qunex_bin/hoffman_submit_qunex.sh \
--qunex_command="import_dicom" \
--qunex_options="--sessionsfolder=/u/project/cbearden/data/22qPrisma/qunex_studyfolder/sessions --gzip=yes --check=any" \
--scheduler_options="-l h_data=16G,h_rt=24:00:00" \
--logdir="/u/project/cbearden/data/22qPrisma/qunex_studyfolder/processing/logs/manual" \
--array="no" 

## set up HCP mapping file
seshdir=/u/project/cbearden/data/22qPrisma/qunex_studyfolder/sessions/
rm ${seshdir}/specs/all_runs.txt
for i in ${seshdir}/Q_0*; do cat ${i}/session.txt | grep '^[0-9]' >> ${seshdir}/specs/all_runs.txt; done
cut ${seshdir}/specs/all_runs.txt -d : -f 2 | sort | uniq > ${seshdir}/specs/unique_runs.txt

## HCP mapping
/u/project/cbearden/data/scripts/tools/qunex_bin/hoffman_submit_qunex.sh \
--qunex_command="create_session_info" \
--qunex_options="--overwrite=no --sourcefile=session.txt --targetfile=session_hcp.txt --pipelines=hcp --mapping=/u/project/cbearden/data/22qPrisma/qunex_studyfolder/sessions/specs/22qPrisma_HCP_mapping.txt --sessionsfolder=/u/project/cbearden/data/22qPrisma/qunex_studyfolder/sessions/" \
--scheduler_options="-l h_data=8G,h_rt=5:00:00" \
--logdir="/u/project/cbearden/data/22qPrisma/qunex_studyfolder/processing/logs/manual" \
--array="no" 

## Setup HCP
/u/project/cbearden/data/scripts/tools/qunex_bin/hoffman_submit_qunex.sh \
--qunex_command="setup_hcp" \
--qunex_options="--sessionsfolder=/u/project/cbearden/data/22qPrisma/qunex_studyfolder/sessions --sourcefile=session_hcp.txt" \
--scheduler_options="-l h_data=16G,h_rt=24:00:00" \
--logdir="/u/project/cbearden/data/22qPrisma/qunex_studyfolder/processing/logs/manual" \
--array="yes" \
--sessions="Q_0001_02222018 Q_0005_11072017 Q_0017_10022017 Q_0019_03022020 Q_0030_05082018 Q_0036_08082017 Q_0036_08312018 Q_0036_09302019 Q_0037_08152017 Q_0038_08192019 Q_0041_10092017 Q_0051_02032017 Q_0105_03112020 Q_0105_12032018 Q_0114_12052017 Q_0138_01082018 Q_0141_06122018 Q_0141_08052019 Q_0147_12112017 Q_0147_12112018 Q_0192_11192018 Q_0192_11202017 Q_0192_11252019 Q_0196_01082020 Q_0213_05012017 Q_0214_05012017 Q_0217_01242017 Q_0217_02192020 Q_0234_05302017 Q_0235_05252017 Q_0238_02202018 Q_0240_09192017 Q_0240_11162018 Q_0246_10092018 Q_0246_10102017 Q_0246_10142016 Q_0250_10232018 Q_0250_10242017 Q_0260_06192017 Q_0260_06242019 Q_0260_06252018 Q_0263_02252019 Q_0263_02262018 Q_0263_11072016 Q_0271_10182016 Q_0277_11302017 Q_0277_12132016 Q_0278_11292017 Q_0278_12052019 Q_0278_12132016 Q_0279_11302017 Q_0279_12052019 Q_0279_12132016 Q_0285_03212017 Q_0285_06062018 Q_0286_03212017 Q_0287_03212017 Q_0287_06062018 Q_0288_03212017 Q_0288_06062018 Q_0289_03212017 Q_0289_06062018 Q_0291_11042016 Q_0291_11302018 Q_0304_12202016 Q_0310_01252018 Q_0310_02132017 Q_0310_04292019 Q_0313_05072019 Q_0313_12132016 Q_0313_12142017 Q_0315_02162017 Q_0319_03192018 Q_0319_03282017 Q_0321_03192018 Q_0321_03272017 Q_0324_04182018 Q_0324_05032017 Q_0326_10202017 Q_0326_12062018 Q_0327_10192017 Q_0327_12072018 Q_0331_06102019 Q_0331_06212018 Q_0331_06272017 Q_0333_04142017 Q_0334_12012016 Q_0336_01102017 Q_0337_04022018 Q_0338_02162017 Q_0338_03292018 Q_0339_03292018 Q_0345_04122017 Q_0345_08152018 Q_0345_09112019 Q_0346_04102017 Q_0346_04102018 Q_0348_04212017 Q_0348_08152018 Q_0350_04192017 Q_0350_09142018 Q_0353_04182018 Q_0353_05022017 Q_0355_05312018 Q_0355_06052019 Q_0356_05312018 Q_0356_06052019 Q_0356_06062017 Q_0361_08212017 Q_0361_10212019 Q_0361_11202018 Q_0369_04182018 Q_0369_06182019 Q_0371_07312019 Q_0371_08042020 Q_0374_05152019 Q_0374_05252018 Q_0377_07242018 Q_0381_08072018 Q_0381_09102019 Q_0382_08282018 Q_0383_08282018 Q_0384_08282018 Q_0387_08242018 Q_0387_12032019 Q_0390_09042018 Q_0390_09302019 Q_0391_09252018 Q_0395_11062018 Q_0395_11062018_18 Q_0395_11062018_2 Q_0397_10172019 Q_0397_11082018 Q_0401_01112019 Q_0401_01112019_2 Q_0401_01112019_8 Q_0402_01112019 Q_0404_03112019 Q_0404_03162020 Q_0407_06122019 Q_0408_05172019 Q_0411_05202019 Q_0414_07172019 Q_0415_07292019 Q_0416_07292019 Q_0419_08132019 Q_0422_11262019 Q_0425_11052019 Q_0426_11262019 Q_0429_01092020 Q_0432_02142020 Q_0433_02262020 Q_0443_06282021 Q_0446_06152021"

## list of sessions with at least one T1w scan
--sessions="Q_0001_02222018 Q_0005_11072017 Q_0017_10022017 Q_0019_03022020 Q_0030_05082018 Q_0036_08082017 Q_0036_08312018 Q_0036_09302019 Q_0037_08152017 Q_0038_08192019 Q_0041_10092017 Q_0051_02032017 Q_0105_03112020 Q_0105_12032018 Q_0114_12052017 Q_0138_01082018 Q_0141_06122018 Q_0141_08052019 Q_0147_12112017 Q_0147_12112018 Q_0196_01082020 Q_0213_05012017 Q_0214_05012017 Q_0217_01242017 Q_0217_02192020 Q_0234_05302017 Q_0235_05252017 Q_0238_02202018 Q_0240_09192017 Q_0240_11162018 Q_0246_10092018 Q_0246_10102017 Q_0246_10142016 Q_0250_10242017 Q_0260_06192017 Q_0260_06242019 Q_0260_06252018 Q_0263_02252019 Q_0263_02262018 Q_0263_11072016 Q_0271_10182016 Q_0277_11302017 Q_0277_12132016 Q_0278_11292017 Q_0278_12052019 Q_0278_12132016 Q_0279_11302017 Q_0279_12052019 Q_0279_12132016 Q_0285_03212017 Q_0285_06062018 Q_0286_03212017 Q_0287_03212017 Q_0287_06062018 Q_0288_06062018 Q_0289_03212017 Q_0289_06062018 Q_0291_11042016 Q_0291_11302018 Q_0304_12202016 Q_0310_01252018 Q_0310_02132017 Q_0310_04292019 Q_0313_05072019 Q_0319_03192018 Q_0319_03282017 Q_0321_03192018 Q_0321_03272017 Q_0324_04182018 Q_0324_05032017 Q_0326_10202017 Q_0326_12062018 Q_0327_10192017 Q_0327_12072018 Q_0331_06102019 Q_0331_06212018 Q_0331_06272017 Q_0333_04142017 Q_0334_12012016 Q_0336_01102017 Q_0337_04022018 Q_0338_02162017 Q_0339_03292018 Q_0345_04122017 Q_0345_08152018 Q_0345_09112019 Q_0346_04102017 Q_0346_04102018 Q_0348_04212017 Q_0348_08152018 Q_0350_04192017 Q_0350_09142018 Q_0353_04182018 Q_0353_05022017 Q_0355_05312018 Q_0355_06052019 Q_0356_05312018 Q_0356_06052019 Q_0356_06062017 Q_0361_08212017 Q_0361_10212019 Q_0361_11202018 Q_0369_04182018 Q_0369_06182019 Q_0371_07312019 Q_0371_08042020 Q_0374_05152019 Q_0374_05252018 Q_0377_07242018 Q_0381_08072018 Q_0381_09102019 Q_0382_08282018 Q_0383_08282018 Q_0387_08242018 Q_0387_12032019 Q_0390_09042018 Q_0390_09302019 Q_0391_09252018 Q_0395_11062018 Q_0395_11062018_18 Q_0395_11062018_2 Q_0397_10172019 Q_0402_01112019 Q_0404_03112019 Q_0404_03162020 Q_0407_06122019 Q_0408_05172019 Q_0411_05202019 Q_0414_07172019 Q_0415_07292019 Q_0416_07292019 Q_0419_08132019 Q_0422_11262019 Q_0425_11052019 Q_0426_11262019 Q_0429_01092020 Q_0432_02142020 Q_0433_02262020 Q_0443_06282021 Q_0446_06152021"

## create batch file
/u/project/cbearden/data/scripts/tools/qunex_bin/hoffman_submit_qunex.sh \
--qunex_command="create_batch" \
--qunex_options=" --overwrite=yes --sessionsfolder=/u/project/cbearden/data/22qPrisma/qunex_studyfolder/sessions --sourcefiles=session_hcp.txt --targetfile=/u/project/cbearden/data/22qPrisma/qunex_studyfolder/processing/22qPrisma_batch.txt --paramfile=/u/project/cbearden/data/22qPrisma/qunex_studyfolder/sessions/specs/22qPrisma_params.txt --sessions=Q_0001_02222018,Q_0005_11072017,Q_0017_10022017,Q_0019_03022020,Q_0030_05082018,Q_0036_08082017,Q_0036_08312018,Q_0036_09302019,Q_0037_08152017,Q_0038_08192019,Q_0041_10092017,Q_0051_02032017,Q_0105_03112020,Q_0105_12032018,Q_0114_12052017,Q_0138_01082018,Q_0141_06122018,Q_0141_08052019,Q_0147_12112017,Q_0147_12112018,Q_0196_01082020,Q_0213_05012017,Q_0214_05012017,Q_0217_01242017,Q_0217_02192020,Q_0234_05302017,Q_0235_05252017,Q_0238_02202018,Q_0240_09192017,Q_0240_11162018,Q_0246_10092018,Q_0246_10102017,Q_0246_10142016,Q_0250_10242017,Q_0260_06192017,Q_0260_06242019,Q_0260_06252018,Q_0263_02252019,Q_0263_02262018,Q_0263_11072016,Q_0271_10182016,Q_0277_11302017,Q_0277_12132016,Q_0278_11292017,Q_0278_12052019,Q_0278_12132016,Q_0279_11302017,Q_0279_12052019,Q_0279_12132016,Q_0285_03212017,Q_0285_06062018,Q_0286_03212017,Q_0287_03212017,Q_0287_06062018,Q_0288_06062018,Q_0289_03212017,Q_0289_06062018,Q_0291_11042016,Q_0291_11302018,Q_0304_12202016,Q_0310_01252018,Q_0310_02132017,Q_0310_04292019,Q_0313_05072019,Q_0319_03192018,Q_0319_03282017,Q_0321_03192018,Q_0321_03272017,Q_0324_04182018,Q_0324_05032017,Q_0326_10202017,Q_0326_12062018,Q_0327_10192017,Q_0327_12072018,Q_0331_06102019,Q_0331_06212018,Q_0331_06272017,Q_0333_04142017,Q_0334_12012016,Q_0336_01102017,Q_0337_04022018,Q_0338_02162017,Q_0339_03292018,Q_0345_04122017,Q_0345_08152018,Q_0345_09112019,Q_0346_04102017,Q_0346_04102018,Q_0348_04212017,Q_0348_08152018,Q_0350_04192017,Q_0350_09142018,Q_0353_04182018,Q_0353_05022017,Q_0355_05312018,Q_0355_06052019,Q_0356_05312018,Q_0356_06052019,Q_0356_06062017,Q_0361_08212017,Q_0361_10212019,Q_0361_11202018,Q_0369_04182018,Q_0369_06182019,Q_0371_07312019,Q_0371_08042020,Q_0374_05152019,Q_0374_05252018,Q_0377_07242018,Q_0381_08072018,Q_0381_09102019,Q_0382_08282018,Q_0383_08282018,Q_0387_08242018,Q_0387_12032019,Q_0390_09042018,Q_0390_09302019,Q_0391_09252018,Q_0395_11062018,Q_0395_11062018_18,Q_0395_11062018_2,Q_0397_10172019,Q_0402_01112019,Q_0404_03112019,Q_0404_03162020,Q_0407_06122019,Q_0408_05172019,Q_0411_05202019,Q_0414_07172019,Q_0415_07292019,Q_0416_07292019,Q_0419_08132019,Q_0422_11262019,Q_0425_11052019,Q_0426_11262019,Q_0429_01092020,Q_0432_02142020,Q_0433_02262020,Q_0443_06282021,Q_0446_06152021" \
--scheduler_options="-l h_data=4G,h_rt=4:00:00" \
--logdir="/u/project/cbearden/data/22qPrisma/qunex_studyfolder/processing/logs/manual" \
--array="no" 


#####################################################################
### HCP steps
#####################################################################

## PreFreeSurfer
/u/project/cbearden/data/scripts/tools/qunex_bin/hoffman_submit_qunex.sh \
--qunex_command="hcp_pre_freesurfer" \
--qunex_options="--sessions=/u/project/cbearden/data/22qPrisma/qunex_studyfolder/processing/22qPrisma_batch.txt --sessionsfolder=/u/project/cbearden/data/22qPrisma/qunex_studyfolder/sessions --parsessions=1 --overwrite=no" \
--scheduler_options="-l h_data=16G,h_rt=24:00:00" \
--logdir="/u/project/cbearden/data/22qPrisma/qunex_studyfolder/processing/logs/manual" \
--array="yes" \
--sessions="Q_0001_02222018 Q_0005_11072017 Q_0017_10022017 Q_0019_03022020 Q_0030_05082018 Q_0036_08082017 Q_0036_08312018 Q_0036_09302019 Q_0037_08152017 Q_0038_08192019 Q_0041_10092017 Q_0051_02032017 Q_0105_03112020 Q_0105_12032018 Q_0114_12052017 Q_0138_01082018 Q_0141_06122018 Q_0141_08052019 Q_0147_12112017 Q_0147_12112018 Q_0196_01082020 Q_0213_05012017 Q_0214_05012017 Q_0217_01242017 Q_0217_02192020 Q_0234_05302017 Q_0235_05252017 Q_0238_02202018 Q_0240_09192017 Q_0240_11162018 Q_0246_10092018 Q_0246_10102017 Q_0246_10142016 Q_0250_10242017 Q_0260_06192017 Q_0260_06242019 Q_0260_06252018 Q_0263_02252019 Q_0263_02262018 Q_0263_11072016 Q_0271_10182016 Q_0277_11302017 Q_0277_12132016 Q_0278_11292017 Q_0278_12052019 Q_0278_12132016 Q_0279_11302017 Q_0279_12052019 Q_0279_12132016 Q_0285_03212017 Q_0285_06062018 Q_0286_03212017 Q_0287_03212017 Q_0287_06062018 Q_0288_06062018 Q_0289_03212017 Q_0289_06062018 Q_0291_11042016 Q_0291_11302018 Q_0304_12202016 Q_0310_01252018 Q_0310_02132017 Q_0310_04292019 Q_0313_05072019 Q_0319_03192018 Q_0319_03282017 Q_0321_03192018 Q_0321_03272017 Q_0324_04182018 Q_0324_05032017 Q_0326_10202017 Q_0326_12062018 Q_0327_10192017 Q_0327_12072018 Q_0331_06102019 Q_0331_06212018 Q_0331_06272017 Q_0333_04142017 Q_0334_12012016 Q_0336_01102017 Q_0337_04022018 Q_0338_02162017 Q_0339_03292018 Q_0345_04122017 Q_0345_08152018 Q_0345_09112019 Q_0346_04102017 Q_0346_04102018 Q_0348_04212017 Q_0348_08152018 Q_0350_04192017 Q_0350_09142018 Q_0353_04182018 Q_0353_05022017 Q_0355_05312018 Q_0355_06052019 Q_0356_05312018 Q_0356_06052019 Q_0356_06062017 Q_0361_08212017 Q_0361_10212019 Q_0361_11202018 Q_0369_04182018 Q_0369_06182019 Q_0371_07312019 Q_0371_08042020 Q_0374_05152019 Q_0374_05252018 Q_0377_07242018 Q_0381_08072018 Q_0381_09102019 Q_0382_08282018 Q_0383_08282018 Q_0387_08242018 Q_0387_12032019 Q_0390_09042018 Q_0390_09302019 Q_0391_09252018 Q_0395_11062018 Q_0395_11062018_18 Q_0395_11062018_2 Q_0397_10172019 Q_0402_01112019 Q_0404_03112019 Q_0404_03162020 Q_0407_06122019 Q_0408_05172019 Q_0411_05202019 Q_0414_07172019 Q_0415_07292019 Q_0416_07292019 Q_0419_08132019 Q_0422_11262019 Q_0425_11052019 Q_0426_11262019 Q_0429_01092020 Q_0432_02142020 Q_0433_02262020 Q_0443_06282021 Q_0446_06152021"

## FreeSurfer
/u/project/cbearden/data/scripts/tools/qunex_bin/hoffman_submit_qunex.sh \
--qunex_command="hcp_freesurfer" \
--qunex_options="--sessions=/u/project/cbearden/data/22qPrisma/qunex_studyfolder/processing/22qPrisma_batch.txt --sessionsfolder=/u/project/cbearden/data/22qPrisma/qunex_studyfolder/sessions --parsessions=1 --overwrite=no" \
--scheduler_options="-l h_data=16G,h_rt=48:00:00,highp" \
--logdir="/u/project/cbearden/data/22qPrisma/qunex_studyfolder/processing/logs/manual" \
--array="yes" \
--sessions="Q_0001_02222018 Q_0005_11072017 Q_0017_10022017 Q_0019_03022020 Q_0030_05082018 Q_0036_08082017 Q_0036_08312018 Q_0036_09302019 Q_0037_08152017 Q_0038_08192019 Q_0041_10092017 Q_0051_02032017 Q_0105_03112020 Q_0105_12032018 Q_0114_12052017 Q_0138_01082018 Q_0141_06122018 Q_0141_08052019 Q_0147_12112017 Q_0147_12112018 Q_0196_01082020 Q_0213_05012017 Q_0214_05012017 Q_0217_01242017 Q_0217_02192020 Q_0234_05302017 Q_0235_05252017 Q_0238_02202018 Q_0240_09192017 Q_0240_11162018 Q_0246_10092018 Q_0246_10102017 Q_0246_10142016 Q_0250_10242017 Q_0260_06192017 Q_0260_06242019 Q_0260_06252018 Q_0263_02252019 Q_0263_02262018 Q_0263_11072016 Q_0271_10182016 Q_0277_11302017 Q_0277_12132016 Q_0278_11292017 Q_0278_12052019 Q_0278_12132016 Q_0279_11302017 Q_0279_12052019 Q_0279_12132016 Q_0285_03212017 Q_0285_06062018 Q_0286_03212017 Q_0287_03212017 Q_0287_06062018 Q_0288_06062018 Q_0289_03212017 Q_0289_06062018 Q_0291_11042016 Q_0291_11302018 Q_0304_12202016 Q_0310_01252018 Q_0310_02132017 Q_0310_04292019 Q_0313_05072019 Q_0319_03192018 Q_0319_03282017 Q_0321_03192018 Q_0321_03272017 Q_0324_04182018 Q_0324_05032017 Q_0326_10202017 Q_0326_12062018 Q_0327_10192017 Q_0327_12072018 Q_0331_06102019 Q_0331_06212018 Q_0331_06272017 Q_0333_04142017 Q_0334_12012016 Q_0336_01102017 Q_0337_04022018 Q_0338_02162017 Q_0339_03292018 Q_0345_04122017 Q_0345_08152018 Q_0345_09112019 Q_0346_04102017 Q_0346_04102018 Q_0348_04212017 Q_0348_08152018 Q_0350_04192017 Q_0350_09142018 Q_0353_04182018 Q_0353_05022017 Q_0355_05312018 Q_0355_06052019 Q_0356_05312018 Q_0356_06052019 Q_0356_06062017 Q_0361_08212017 Q_0361_10212019 Q_0361_11202018 Q_0369_04182018 Q_0369_06182019 Q_0371_07312019 Q_0371_08042020 Q_0374_05152019 Q_0374_05252018 Q_0377_07242018 Q_0381_08072018 Q_0381_09102019 Q_0382_08282018 Q_0383_08282018 Q_0387_08242018 Q_0387_12032019 Q_0390_09042018 Q_0390_09302019 Q_0391_09252018 Q_0395_11062018 Q_0395_11062018_18 Q_0395_11062018_2 Q_0397_10172019 Q_0402_01112019 Q_0404_03112019 Q_0404_03162020 Q_0407_06122019 Q_0408_05172019 Q_0411_05202019 Q_0414_07172019 Q_0415_07292019 Q_0416_07292019 Q_0419_08132019 Q_0422_11262019 Q_0425_11052019 Q_0426_11262019 Q_0429_01092020 Q_0432_02142020 Q_0433_02262020 Q_0443_06282021 Q_0446_06152021"

## PostFreeSurfer
/u/project/cbearden/data/scripts/tools/qunex_bin/hoffman_submit_qunex.sh \
--qunex_command="hcp_post_freesurfer" \
--qunex_options="--sessions=/u/project/cbearden/data/22qPrisma/qunex_studyfolder/processing/22qPrisma_batch.txt --sessionsfolder=/u/project/cbearden/data/22qPrisma/qunex_studyfolder/sessions --parsessions=1 --overwrite=no" \
--scheduler_options="-l h_data=16G,h_rt=24:00:00" \
--logdir="/u/project/cbearden/data/22qPrisma/qunex_studyfolder/processing/logs/manual" \
--array="yes" \
--sessions="Q_0001_02222018 Q_0005_11072017 Q_0017_10022017 Q_0019_03022020 Q_0030_05082018 Q_0036_08082017 Q_0036_08312018 Q_0036_09302019 Q_0037_08152017 Q_0038_08192019 Q_0041_10092017 Q_0051_02032017 Q_0105_03112020 Q_0105_12032018 Q_0114_12052017 Q_0138_01082018 Q_0141_06122018 Q_0141_08052019 Q_0147_12112017 Q_0147_12112018 Q_0196_01082020 Q_0213_05012017 Q_0214_05012017 Q_0217_01242017 Q_0217_02192020 Q_0234_05302017 Q_0235_05252017 Q_0238_02202018 Q_0240_09192017 Q_0240_11162018 Q_0246_10092018 Q_0246_10102017 Q_0246_10142016 Q_0250_10242017 Q_0260_06192017 Q_0260_06242019 Q_0260_06252018 Q_0263_02252019 Q_0263_02262018 Q_0263_11072016 Q_0271_10182016 Q_0277_11302017 Q_0277_12132016 Q_0278_11292017 Q_0278_12052019 Q_0278_12132016 Q_0279_11302017 Q_0279_12052019 Q_0279_12132016 Q_0285_03212017 Q_0285_06062018 Q_0286_03212017 Q_0287_03212017 Q_0287_06062018 Q_0288_06062018 Q_0289_03212017 Q_0289_06062018 Q_0291_11042016 Q_0291_11302018 Q_0304_12202016 Q_0310_01252018 Q_0310_02132017 Q_0310_04292019 Q_0313_05072019 Q_0319_03192018 Q_0319_03282017 Q_0321_03192018 Q_0321_03272017 Q_0324_04182018 Q_0324_05032017 Q_0326_10202017 Q_0326_12062018 Q_0327_10192017 Q_0327_12072018 Q_0331_06102019 Q_0331_06212018 Q_0331_06272017 Q_0333_04142017 Q_0334_12012016 Q_0336_01102017 Q_0337_04022018 Q_0338_02162017 Q_0339_03292018 Q_0345_04122017 Q_0345_08152018 Q_0345_09112019 Q_0346_04102017 Q_0346_04102018 Q_0348_04212017 Q_0348_08152018 Q_0350_04192017 Q_0350_09142018 Q_0353_04182018 Q_0353_05022017 Q_0355_05312018 Q_0355_06052019 Q_0356_05312018 Q_0356_06052019 Q_0356_06062017 Q_0361_08212017 Q_0361_10212019 Q_0361_11202018 Q_0369_04182018 Q_0369_06182019 Q_0371_07312019 Q_0371_08042020 Q_0374_05152019 Q_0374_05252018 Q_0377_07242018 Q_0381_08072018 Q_0381_09102019 Q_0382_08282018 Q_0383_08282018 Q_0387_08242018 Q_0387_12032019 Q_0390_09042018 Q_0390_09302019 Q_0391_09252018 Q_0395_11062018 Q_0395_11062018_18 Q_0395_11062018_2 Q_0397_10172019 Q_0402_01112019 Q_0404_03112019 Q_0404_03162020 Q_0407_06122019 Q_0408_05172019 Q_0411_05202019 Q_0414_07172019 Q_0415_07292019 Q_0416_07292019 Q_0419_08132019 Q_0422_11262019 Q_0425_11052019 Q_0426_11262019 Q_0429_01092020 Q_0432_02142020 Q_0433_02262020 Q_0443_06282021 Q_0446_06152021"

## FMRI VOLUME
/u/project/cbearden/data/scripts/tools/qunex_bin/hoffman_submit_qunex.sh \
--qunex_command="hcp_fmri_volume" \
--qunex_options="--sessions=/u/project/cbearden/data/22qPrisma/qunex_studyfolder/processing/22qPrisma_batch.txt --sessionsfolder=/u/project/cbearden/data/22qPrisma/qunex_studyfolder/sessions --parsessions=1 --overwrite=no" \
--scheduler_options="-l h_data=16G,h_rt=24:00:00" \
--logdir="/u/project/cbearden/data/22qPrisma/qunex_studyfolder/processing/logs/manual" \
--array="yes" \
--sessions="Q_0001_02222018 Q_0005_11072017 Q_0017_10022017 Q_0019_03022020 Q_0030_05082018 Q_0036_08082017 Q_0036_08312018 Q_0036_09302019 Q_0037_08152017 Q_0038_08192019 Q_0041_10092017 Q_0051_02032017 Q_0105_03112020 Q_0105_12032018 Q_0114_12052017 Q_0138_01082018 Q_0141_06122018 Q_0141_08052019 Q_0147_12112017 Q_0147_12112018 Q_0196_01082020 Q_0213_05012017 Q_0214_05012017 Q_0217_01242017 Q_0217_02192020 Q_0234_05302017 Q_0235_05252017 Q_0238_02202018 Q_0240_09192017 Q_0240_11162018 Q_0246_10092018 Q_0246_10102017 Q_0246_10142016 Q_0250_10242017 Q_0260_06192017 Q_0260_06242019 Q_0260_06252018 Q_0263_02252019 Q_0263_02262018 Q_0263_11072016 Q_0271_10182016 Q_0277_11302017 Q_0277_12132016 Q_0278_11292017 Q_0278_12052019 Q_0278_12132016 Q_0279_11302017 Q_0279_12052019 Q_0279_12132016 Q_0285_03212017 Q_0285_06062018 Q_0286_03212017 Q_0287_03212017 Q_0287_06062018 Q_0288_06062018 Q_0289_03212017 Q_0289_06062018 Q_0291_11042016 Q_0291_11302018 Q_0304_12202016 Q_0310_01252018 Q_0310_02132017 Q_0310_04292019 Q_0313_05072019 Q_0319_03192018 Q_0319_03282017 Q_0321_03192018 Q_0321_03272017 Q_0324_04182018 Q_0324_05032017 Q_0326_10202017 Q_0326_12062018 Q_0327_10192017 Q_0327_12072018 Q_0331_06102019 Q_0331_06212018 Q_0331_06272017 Q_0333_04142017 Q_0334_12012016 Q_0336_01102017 Q_0337_04022018 Q_0338_02162017 Q_0339_03292018 Q_0345_04122017 Q_0345_08152018 Q_0345_09112019 Q_0346_04102017 Q_0346_04102018 Q_0348_04212017 Q_0348_08152018 Q_0350_04192017 Q_0350_09142018 Q_0353_04182018 Q_0353_05022017 Q_0355_05312018 Q_0355_06052019 Q_0356_05312018 Q_0356_06052019 Q_0356_06062017 Q_0361_08212017 Q_0361_10212019 Q_0361_11202018 Q_0369_04182018 Q_0369_06182019 Q_0371_07312019 Q_0371_08042020 Q_0374_05152019 Q_0374_05252018 Q_0377_07242018 Q_0381_08072018 Q_0381_09102019 Q_0382_08282018 Q_0383_08282018 Q_0387_08242018 Q_0387_12032019 Q_0390_09042018 Q_0390_09302019 Q_0391_09252018 Q_0395_11062018 Q_0395_11062018_18 Q_0395_11062018_2 Q_0397_10172019 Q_0402_01112019 Q_0404_03112019 Q_0404_03162020 Q_0407_06122019 Q_0408_05172019 Q_0411_05202019 Q_0414_07172019 Q_0415_07292019 Q_0416_07292019 Q_0419_08132019 Q_0422_11262019 Q_0425_11052019 Q_0426_11262019 Q_0429_01092020 Q_0432_02142020 Q_0433_02262020 Q_0443_06282021 Q_0446_06152021"

## FMRI SURFACE
/u/project/cbearden/data/scripts/tools/qunex_bin/hoffman_submit_qunex.sh \
--qunex_command="hcp_fmri_surface" \
--qunex_options="--sessions=/u/project/cbearden/data/22qPrisma/qunex_studyfolder/processing/22qPrisma_batch.txt --sessionsfolder=/u/project/cbearden/data/22qPrisma/qunex_studyfolder/sessions --parsessions=1 --overwrite=no" \
--scheduler_options="-l h_data=16G,h_rt=24:00:00" \
--logdir="/u/project/cbearden/data/22qPrisma/qunex_studyfolder/processing/logs/manual" \
--array="yes" \
--sessions="Q_0001_02222018 Q_0005_11072017 Q_0017_10022017 Q_0019_03022020 Q_0030_05082018 Q_0036_08082017 Q_0036_08312018 Q_0036_09302019 Q_0037_08152017 Q_0038_08192019 Q_0041_10092017 Q_0051_02032017 Q_0105_03112020 Q_0105_12032018 Q_0114_12052017 Q_0138_01082018 Q_0141_06122018 Q_0141_08052019 Q_0147_12112017 Q_0147_12112018 Q_0196_01082020 Q_0213_05012017 Q_0214_05012017 Q_0217_01242017 Q_0217_02192020 Q_0234_05302017 Q_0235_05252017 Q_0238_02202018 Q_0240_09192017 Q_0240_11162018 Q_0246_10092018 Q_0246_10102017 Q_0246_10142016 Q_0250_10242017 Q_0260_06192017 Q_0260_06242019 Q_0260_06252018 Q_0263_02252019 Q_0263_02262018 Q_0263_11072016 Q_0271_10182016 Q_0277_11302017 Q_0277_12132016 Q_0278_11292017 Q_0278_12052019 Q_0278_12132016 Q_0279_11302017 Q_0279_12052019 Q_0279_12132016 Q_0285_03212017 Q_0285_06062018 Q_0286_03212017 Q_0287_03212017 Q_0287_06062018 Q_0288_06062018 Q_0289_03212017 Q_0289_06062018 Q_0291_11042016 Q_0291_11302018 Q_0304_12202016 Q_0310_01252018 Q_0310_02132017 Q_0310_04292019 Q_0313_05072019 Q_0319_03192018 Q_0319_03282017 Q_0321_03192018 Q_0321_03272017 Q_0324_04182018 Q_0324_05032017 Q_0326_10202017 Q_0326_12062018 Q_0327_10192017 Q_0327_12072018 Q_0331_06102019 Q_0331_06212018 Q_0331_06272017 Q_0333_04142017 Q_0334_12012016 Q_0336_01102017 Q_0337_04022018 Q_0338_02162017 Q_0339_03292018 Q_0345_04122017 Q_0345_08152018 Q_0345_09112019 Q_0346_04102017 Q_0346_04102018 Q_0348_04212017 Q_0348_08152018 Q_0350_04192017 Q_0350_09142018 Q_0353_04182018 Q_0353_05022017 Q_0355_05312018 Q_0355_06052019 Q_0356_05312018 Q_0356_06052019 Q_0356_06062017 Q_0361_08212017 Q_0361_10212019 Q_0361_11202018 Q_0369_04182018 Q_0369_06182019 Q_0371_07312019 Q_0371_08042020 Q_0374_05152019 Q_0374_05252018 Q_0377_07242018 Q_0381_08072018 Q_0381_09102019 Q_0382_08282018 Q_0383_08282018 Q_0387_08242018 Q_0387_12032019 Q_0390_09042018 Q_0390_09302019 Q_0391_09252018 Q_0395_11062018 Q_0395_11062018_18 Q_0395_11062018_2 Q_0397_10172019 Q_0402_01112019 Q_0404_03112019 Q_0404_03162020 Q_0407_06122019 Q_0408_05172019 Q_0411_05202019 Q_0414_07172019 Q_0415_07292019 Q_0416_07292019 Q_0419_08132019 Q_0422_11262019 Q_0425_11052019 Q_0426_11262019 Q_0429_01092020 Q_0432_02142020 Q_0433_02262020 Q_0443_06282021 Q_0446_06152021"


#####################################################################
### dataset QC
#####################################################################

# check qunex_studyfolder against raw for missing data
/u/project/cbearden/data/22qPrisma/qunex_studyfolder/processing/scripts/check_qunex_against_raw_prisma.py 
# output  /u/project/cbearden/data/22qPrisma/qunex_studyfolder/sessions/specs/prisma_raw_qunex_runs_compare_100321_annotated.xlsx
# move sessions with no T1w to unused_sessions
sessions_remove="Q_0192_11192018 Q_0192_11202017 Q_0192_11252019 Q_0246_10142016 Q_0250_10232018 Q_0263_11072016 Q_0271_10182016 Q_0288_03212017 Q_0291_11042016 Q_0313_12132016 Q_0313_12142017 Q_0315_02162017 Q_0338_03292018 Q_0384_08282018 Q_0397_11082018 Q_0401_01112019 Q_0401_01112019_2 Q_0401_01112019_8"
mkdir /u/project/cbearden/data/22qPrisma/qunex_studyfolder/sessions/unused_sessions
for sesh in $sessions_remove; do mv -v /u/project/cbearden/data/22qPrisma/qunex_studyfolder/sessions/${sesh} /u/project/cbearden/data/22qPrisma/qunex_studyfolder/sessions/unused_sessions;done

# Q_0346_04102018 qunex missing rest PA
# Q_0459_08192021, Q_0461_09112021 in raw but not qunex
mv -v /u/project/cbearden/data/22qPrisma/qunex_studyfolder/sessions/Q_0346_04102018 /u/project/cbearden/data/22qPrisma/qunex_studyfolder/sessions/outdated
# sessions to copy from raw
sessions_copy="Q_0346_04102018 Q_0459_08192021 Q_0461_09112021"
sdir="/u/project/cbearden/data/22qPrisma/qunex_studyfolder/sessions/"
rdir="/u/project/cbearden/data/raw/22qPrisma"
inbox=${sdir}/inbox/MR
for sesh in $sessions_copy; do 
	mkdir -p ${inbox}/${sesh}/inbox/
	for run in $(ls ${rdir}/${sesh}/*/*/*/); do
		for i in $(ls ${rdir}/${sesh}/*/*/*/${run}); do
			cp -v ${rdir}/${sesh}/*/*/*/${run}/${i} ${inbox}/${sesh}/inbox/${run}_${i}
		done
	done
done

## import DICOM for new sessions
/u/project/cbearden/data/scripts/tools/qunex_bin/hoffman_submit_qunex.sh \
--qunex_command="import_dicom" \
--qunex_options="--sessionsfolder=/u/project/cbearden/data/22qPrisma/qunex_studyfolder/sessions --gzip=yes --check=any" \
--scheduler_options="-l h_data=4G,h_rt=24:00:00" \
--logdir="/u/project/cbearden/data/22qPrisma/qunex_studyfolder/processing/logs/manual" \
--array="no" 

# nifti still not generated for Q_0346_04102018 restPA
# 373 dicoms in raw, last one ends with *.filepart suggesting incomplete download from MRI server. Asked Leila

## count resting frames
sdir="/u/project/cbearden/data/22qPrisma/qunex_studyfolder/sessions"
ofile=${sdir}/specs/nframes_BOLD_resting_prisma.csv
echo "session,nframes_AP,nframes_PA" > $ofile
for i in ${sdir}/Q_*;do
	sesh=$(basename ${i})
	ap=$(cat ${sdir}/${sesh}/dicom/DICOM-Report.txt | grep "rfMRI_REST_AP "| xargs | cut -d " " -f 4)
	pa=$(cat ${sdir}/${sesh}/dicom/DICOM-Report.txt | grep "rfMRI_REST_PA "| xargs | cut -d " " -f 4)
	echo ${sesh},${ap},${pa} >> $ofile
done

# move subjects with no BOLD to unused
sessions_no_bold="Q_0001_02222018 Q_0038_08192019 Q_0234_05302017 Q_0250_10242017 Q_0277_11302017 Q_0287_03212017 Q_0313_05072019 Q_0324_05032017 Q_0337_04022018 Q_0338_02162017 Q_0339_03292018 Q_0355_06052019 Q_0356_06052019 Q_0356_06062017 Q_0361_08212017 Q_0371_07312019 Q_0374_05152019 Q_0377_07242018 Q_0404_03162020 Q_0411_05202019 Q_0422_11262019 Q_0426_11262019"
for sesh in $sessions_no_bold;do mv -v /u/project/cbearden/data/22qPrisma/qunex_studyfolder/sessions/${sesh} /u/project/cbearden/data/22qPrisma/qunex_studyfolder/sessions/unused_sessions/;done


## catch up Q_0346_04102018
# sessions to copy from raw
sessions_copy="Q_0346_04102018"
sdir="/u/project/cbearden/data/22qPrisma/qunex_studyfolder/sessions/"
rdir="/u/project/cbearden/data/raw/22qPrisma"
inbox=${sdir}/inbox/MR
for sesh in $sessions_copy; do 
	mkdir -p ${inbox}/${sesh}/inbox/
	for run in $(ls ${rdir}/${sesh}/*/*/*/); do
		for i in $(ls ${rdir}/${sesh}/*/*/*/${run}); do
			cp -v ${rdir}/${sesh}/*/*/*/${run}/${i} ${inbox}/${sesh}/inbox/${run}_${i}
		done
	done
done

# remove filepart and move existing data to outdated
rm -f /u/project/cbearden/data/22qPrisma/qunex_studyfolder/sessions/inbox/MR/Q_0346_04102018/inbox/rfMRI_REST_PA_21_000373.dcm.filepart
mv /u/project/cbearden/data/22qPrisma/qunex_studyfolder/sessions/Q_0346_04102018 /u/project/cbearden/data/22qPrisma/qunex_studyfolder/sessions/outdated/Q_0346_04102018_v2

## import DICOM for new sessions
/u/project/cbearden/data/scripts/tools/qunex_bin/hoffman_submit_qunex.sh \
--qunex_command="import_dicom" \
--qunex_options="--sessionsfolder=/u/project/cbearden/data/22qPrisma/qunex_studyfolder/sessions --gzip=yes --check=any" \
--scheduler_options="-l h_data=4G,h_rt=4:00:00" \
--logdir="/u/project/cbearden/data/22qPrisma/qunex_studyfolder/processing/logs/manual" \
--array="no" 

# sessions need hcp
--sessions="Q_0346_04102018 Q_0459_08192021 Q_0461_09112021"

## HCP mapping
/u/project/cbearden/data/scripts/tools/qunex_bin/hoffman_submit_qunex.sh \
--qunex_command="create_session_info" \
--qunex_options="--overwrite=no --sourcefile=session.txt --targetfile=session_hcp.txt --pipelines=hcp --mapping=/u/project/cbearden/data/22qPrisma/qunex_studyfolder/sessions/specs/22qPrisma_HCP_mapping.txt --sessionsfolder=/u/project/cbearden/data/22qPrisma/qunex_studyfolder/sessions/" \
--scheduler_options="-l h_data=8G,h_rt=5:00:00" \
--logdir="/u/project/cbearden/data/22qPrisma/qunex_studyfolder/processing/logs/manual" \
--array="no" 

## fix session_hcp subject id
/u/project/cbearden/data/22qPrisma/qunex_studyfolder/processing/scripts/edit_session_hcp_subject_id.sh

## Setup HCP
/u/project/cbearden/data/scripts/tools/qunex_bin/hoffman_submit_qunex.sh \
--qunex_command="setup_hcp" \
--qunex_options="--sessionsfolder=/u/project/cbearden/data/22qPrisma/qunex_studyfolder/sessions --sourcefile=session_hcp.txt" \
--scheduler_options="-l h_data=16G,h_rt=24:00:00" \
--logdir="/u/project/cbearden/data/22qPrisma/qunex_studyfolder/processing/logs/manual" \
--array="yes" \
--sessions="Q_0346_04102018 Q_0459_08192021 Q_0461_09112021"


## create batch file for all n=114 usable
# --sessions="Q_0005_11072017 Q_0017_10022017 Q_0019_03022020 Q_0030_05082018 Q_0036_08082017 Q_0036_08312018 Q_0036_09302019 Q_0037_08152017 Q_0041_10092017 Q_0051_02032017 Q_0105_03112020 Q_0105_12032018 Q_0114_12052017 Q_0138_01082018 Q_0141_06122018 Q_0141_08052019 Q_0147_12112017 Q_0147_12112018 Q_0196_01082020 Q_0213_05012017 Q_0214_05012017 Q_0217_01242017 Q_0217_02192020 Q_0235_05252017 Q_0238_02202018 Q_0240_09192017 Q_0240_11162018 Q_0246_10092018 Q_0246_10102017 Q_0260_06192017 Q_0260_06242019 Q_0260_06252018 Q_0263_02252019 Q_0263_02262018 Q_0277_12132016 Q_0278_11292017 Q_0278_12052019 Q_0278_12132016 Q_0279_11302017 Q_0279_12052019 Q_0279_12132016 Q_0285_03212017 Q_0285_06062018 Q_0286_03212017 Q_0287_06062018 Q_0288_06062018 Q_0289_03212017 Q_0289_06062018 Q_0291_11302018 Q_0304_12202016 Q_0310_01252018 Q_0310_02132017 Q_0310_04292019 Q_0319_03192018 Q_0319_03282017 Q_0321_03192018 Q_0321_03272017 Q_0324_04182018 Q_0326_10202017 Q_0326_12062018 Q_0327_10192017 Q_0327_12072018 Q_0331_06102019 Q_0331_06212018 Q_0331_06272017 Q_0333_04142017 Q_0334_12012016 Q_0336_01102017 Q_0345_04122017 Q_0345_08152018 Q_0345_09112019 Q_0346_04102017 Q_0346_04102018 Q_0348_04212017 Q_0348_08152018 Q_0350_04192017 Q_0350_09142018 Q_0353_04182018 Q_0353_05022017 Q_0355_05312018 Q_0356_05312018 Q_0361_10212019 Q_0361_11202018 Q_0369_04182018 Q_0369_06182019 Q_0371_08042020 Q_0374_05252018 Q_0381_08072018 Q_0381_09102019 Q_0382_08282018 Q_0383_08282018 Q_0387_08242018 Q_0387_12032019 Q_0390_09042018 Q_0390_09302019 Q_0391_09252018 Q_0395_11062018 Q_0397_10172019 Q_0402_01112019 Q_0404_03112019 Q_0407_06122019 Q_0408_05172019 Q_0414_07172019 Q_0415_07292019 Q_0416_07292019 Q_0419_08132019 Q_0425_11052019 Q_0429_01092020 Q_0432_02142020 Q_0433_02262020 Q_0443_06282021 Q_0446_06152021 Q_0459_08192021 Q_0461_09112021"
/u/project/cbearden/data/scripts/tools/qunex_bin/hoffman_submit_qunex.sh \
--qunex_command="create_batch" \
--qunex_options=" --overwrite=yes --sessionsfolder=/u/project/cbearden/data/22qPrisma/qunex_studyfolder/sessions --sourcefiles=session_hcp.txt --targetfile=/u/project/cbearden/data/22qPrisma/qunex_studyfolder/processing/22qPrisma_batch_cleaned_n114.txt --paramfile=/u/project/cbearden/data/22qPrisma/qunex_studyfolder/sessions/specs/22qPrisma_params.txt --sessions=Q_0005_11072017,Q_0017_10022017,Q_0019_03022020,Q_0030_05082018,Q_0036_08082017,Q_0036_08312018,Q_0036_09302019,Q_0037_08152017,Q_0041_10092017,Q_0051_02032017,Q_0105_03112020,Q_0105_12032018,Q_0114_12052017,Q_0138_01082018,Q_0141_06122018,Q_0141_08052019,Q_0147_12112017,Q_0147_12112018,Q_0196_01082020,Q_0213_05012017,Q_0214_05012017,Q_0217_01242017,Q_0217_02192020,Q_0235_05252017,Q_0238_02202018,Q_0240_09192017,Q_0240_11162018,Q_0246_10092018,Q_0246_10102017,Q_0260_06192017,Q_0260_06242019,Q_0260_06252018,Q_0263_02252019,Q_0263_02262018,Q_0277_12132016,Q_0278_11292017,Q_0278_12052019,Q_0278_12132016,Q_0279_11302017,Q_0279_12052019,Q_0279_12132016,Q_0285_03212017,Q_0285_06062018,Q_0286_03212017,Q_0287_06062018,Q_0288_06062018,Q_0289_03212017,Q_0289_06062018,Q_0291_11302018,Q_0304_12202016,Q_0310_01252018,Q_0310_02132017,Q_0310_04292019,Q_0319_03192018,Q_0319_03282017,Q_0321_03192018,Q_0321_03272017,Q_0324_04182018,Q_0326_10202017,Q_0326_12062018,Q_0327_10192017,Q_0327_12072018,Q_0331_06102019,Q_0331_06212018,Q_0331_06272017,Q_0333_04142017,Q_0334_12012016,Q_0336_01102017,Q_0345_04122017,Q_0345_08152018,Q_0345_09112019,Q_0346_04102017,Q_0346_04102018,Q_0348_04212017,Q_0348_08152018,Q_0350_04192017,Q_0350_09142018,Q_0353_04182018,Q_0353_05022017,Q_0355_05312018,Q_0356_05312018,Q_0361_10212019,Q_0361_11202018,Q_0369_04182018,Q_0369_06182019,Q_0371_08042020,Q_0374_05252018,Q_0381_08072018,Q_0381_09102019,Q_0382_08282018,Q_0383_08282018,Q_0387_08242018,Q_0387_12032019,Q_0390_09042018,Q_0390_09302019,Q_0391_09252018,Q_0395_11062018,Q_0397_10172019,Q_0402_01112019,Q_0404_03112019,Q_0407_06122019,Q_0408_05172019,Q_0414_07172019,Q_0415_07292019,Q_0416_07292019,Q_0419_08132019,Q_0425_11052019,Q_0429_01092020,Q_0432_02142020,Q_0433_02262020,Q_0443_06282021,Q_0446_06152021,Q_0459_08192021,Q_0461_09112021" \
--scheduler_options="-l h_data=4G,h_rt=4:00:00" \
--logdir="/u/project/cbearden/data/22qPrisma/qunex_studyfolder/processing/logs/manual" \
--array="no" 

## PreFreeSurfer
/u/project/cbearden/data/scripts/tools/qunex_bin/hoffman_submit_qunex.sh \
--qunex_command="hcp_pre_freesurfer" \
--qunex_options="--sessions=/u/project/cbearden/data/22qPrisma/qunex_studyfolder/processing/22qPrisma_batch_cleaned_n114.txt --sessionsfolder=/u/project/cbearden/data/22qPrisma/qunex_studyfolder/sessions --parsessions=1 --overwrite=no" \
--scheduler_options="-l h_data=16G,h_rt=24:00:00" \
--logdir="/u/project/cbearden/data/22qPrisma/qunex_studyfolder/processing/logs/manual" \
--array="yes" \
--sessions="Q_0346_04102018 Q_0459_08192021 Q_0461_09112021"

## FreeSurfer
/u/project/cbearden/data/scripts/tools/qunex_bin/hoffman_submit_qunex.sh \
--qunex_command="hcp_freesurfer" \
--qunex_options="--sessions=/u/project/cbearden/data/22qPrisma/qunex_studyfolder/processing/22qPrisma_batch_cleaned_n114.txt --sessionsfolder=/u/project/cbearden/data/22qPrisma/qunex_studyfolder/sessions --parsessions=1 --overwrite=no" \
--scheduler_options="-l h_data=16G,h_rt=48:00:00,highp" \
--logdir="/u/project/cbearden/data/22qPrisma/qunex_studyfolder/processing/logs/manual" \
--array="yes" \
--sessions="Q_0346_04102018 Q_0459_08192021 Q_0461_09112021"

## PostFreeSurfer
/u/project/cbearden/data/scripts/tools/qunex_bin/hoffman_submit_qunex.sh \
--qunex_command="hcp_post_freesurfer" \
--qunex_options="--sessions=/u/project/cbearden/data/22qPrisma/qunex_studyfolder/processing/22qPrisma_batch_cleaned_n114.txt --sessionsfolder=/u/project/cbearden/data/22qPrisma/qunex_studyfolder/sessions --parsessions=1 --overwrite=no" \
--scheduler_options="-l h_data=16G,h_rt=24:00:00" \
--logdir="/u/project/cbearden/data/22qPrisma/qunex_studyfolder/processing/logs/manual" \
--array="yes" \
--sessions="Q_0346_04102018 Q_0459_08192021 Q_0461_09112021"

## FMRI VOLUME
/u/project/cbearden/data/scripts/tools/qunex_bin/hoffman_submit_qunex.sh \
--qunex_command="hcp_fmri_volume" \
--qunex_options="--sessions=/u/project/cbearden/data/22qPrisma/qunex_studyfolder/processing/22qPrisma_batch_cleaned_n114.txt --sessionsfolder=/u/project/cbearden/data/22qPrisma/qunex_studyfolder/sessions --parsessions=1 --overwrite=no" \
--scheduler_options="-l h_data=16G,h_rt=24:00:00" \
--logdir="/u/project/cbearden/data/22qPrisma/qunex_studyfolder/processing/logs/manual" \
--array="yes" \
--sessions="Q_0346_04102018 Q_0459_08192021 Q_0461_09112021"

## FMRI SURFACE
/u/project/cbearden/data/scripts/tools/qunex_bin/hoffman_submit_qunex.sh \
--qunex_command="hcp_fmri_surface" \
--qunex_options="--sessions=/u/project/cbearden/data/22qPrisma/qunex_studyfolder/processing/22qPrisma_batch_cleaned_n114.txt --sessionsfolder=/u/project/cbearden/data/22qPrisma/qunex_studyfolder/sessions --parsessions=1 --overwrite=no" \
--scheduler_options="-l h_data=16G,h_rt=24:00:00" \
--logdir="/u/project/cbearden/data/22qPrisma/qunex_studyfolder/processing/logs/manual" \
--array="yes" \
--sessions="Q_0346_04102018 Q_0459_08192021 Q_0461_09112021"


#####################################################################
### process sessions missing t2w
### use LegacyStyleData for hcp1-3 then try HCPStyleData
### NOTE: if this works, then after t2w QC may add more sessions with bad t2w but good t1w
#####################################################################

## find sessions with no t2w in session_hcp.txt
for i in /u/project/cbearden/data/22qPrisma/qunex_studyfolder/sessions/Q_*;do sesh=$(basename $i); nt2=$(cat $i/session_hcp.txt | grep -c "T2w"); if [[ $nt2 == 0 ]]; then echo $sesh;fi; done
# n=4 sessions with no t2w:
--sessions="Q_0355_05312018 Q_0443_06282021 Q_0446_06152021 Q_0459_08192021"

# make a param file with t2w settings set to none and _hcp_processing_mode kept out to specify in command line args
/u/project/cbearden/data/22qPrisma/qunex_studyfolder/sessions/specs/22qPrisma_params_no_t2.txt

# make a batch file for these 4 sessions
/u/project/cbearden/data/scripts/tools/qunex_bin/hoffman_submit_qunex.sh \
--qunex_command="create_batch" \
--qunex_options=" --overwrite=yes --sessionsfolder=/u/project/cbearden/data/22qPrisma/qunex_studyfolder/sessions --sourcefiles=session_hcp.txt --targetfile=/u/project/cbearden/data/22qPrisma/qunex_studyfolder/processing/22qPrisma_batch_no_t2_n4.txt --paramfile=/u/project/cbearden/data/22qPrisma/qunex_studyfolder/sessions/specs/22qPrisma_params_no_t2.txt --sessions=Q_0355_05312018,Q_0443_06282021,Q_0446_06152021,Q_0459_08192021" \
--scheduler_options="-l h_data=4G,h_rt=4:00:00" \
--logdir="/u/project/cbearden/data/22qPrisma/qunex_studyfolder/processing/logs/manual" \
--array="no" 

## PreFreeSurfer
/u/project/cbearden/data/scripts/tools/qunex_bin/hoffman_submit_qunex.sh \
--qunex_command="hcp_pre_freesurfer" \
--qunex_options="--hcp_processing_mode=LegacyStyleData --sessions=/u/project/cbearden/data/22qPrisma/qunex_studyfolder/processing/22qPrisma_batch_no_t2_n4.txt --sessionsfolder=/u/project/cbearden/data/22qPrisma/qunex_studyfolder/sessions --parsessions=1 --overwrite=no" \
--scheduler_options="-l h_data=16G,h_rt=24:00:00" \
--logdir="/u/project/cbearden/data/22qPrisma/qunex_studyfolder/processing/logs/manual" \
--array="yes" \
--sessions="Q_0355_05312018 Q_0443_06282021 Q_0446_06152021 Q_0459_08192021"

## FreeSurfer
# try with LegacyStyleData
/u/project/cbearden/data/scripts/tools/qunex_bin/hoffman_submit_qunex.sh \
--qunex_command="hcp_freesurfer" \
--qunex_options="--hcp_processing_mode=LegacyStyleData --sessions=/u/project/cbearden/data/22qPrisma/qunex_studyfolder/processing/22qPrisma_batch_no_t2_n4.txt --sessionsfolder=/u/project/cbearden/data/22qPrisma/qunex_studyfolder/sessions --parsessions=1 --overwrite=no" \
--scheduler_options="-l h_data=16G,h_rt=24:00:00" \
--logdir="/u/project/cbearden/data/22qPrisma/qunex_studyfolder/processing/logs/manual" \
--array="yes" \
--sessions="Q_0355_05312018 Q_0443_06282021 Q_0446_06152021 Q_0459_08192021"

## PostFreeSurfer
# try with LegacyStyleData
/u/project/cbearden/data/scripts/tools/qunex_bin/hoffman_submit_qunex.sh \
--qunex_command="hcp_post_freesurfer" \
--qunex_options="--hcp_processing_mode=LegacyStyleData --sessions=/u/project/cbearden/data/22qPrisma/qunex_studyfolder/processing/22qPrisma_batch_no_t2_n4.txt --sessionsfolder=/u/project/cbearden/data/22qPrisma/qunex_studyfolder/sessions --parsessions=1 --overwrite=no" \
--scheduler_options="-l h_data=16G,h_rt=24:00:00" \
--logdir="/u/project/cbearden/data/22qPrisma/qunex_studyfolder/processing/logs/manual" \
--array="yes" \
--sessions="Q_0355_05312018 Q_0443_06282021 Q_0446_06152021 Q_0459_08192021"

## FMRI VOLUME
# try with HCPStyleData after running structurals as legacy
/u/project/cbearden/data/scripts/tools/qunex_bin/hoffman_submit_qunex.sh \
--qunex_command="hcp_fmri_volume" \
--qunex_options="--hcp_processing_mode=HCPStyleData --sessions=/u/project/cbearden/data/22qPrisma/qunex_studyfolder/processing/22qPrisma_batch_no_t2_n4.txt --sessionsfolder=/u/project/cbearden/data/22qPrisma/qunex_studyfolder/sessions --parsessions=1 --overwrite=no" \
--scheduler_options="-l h_data=16G,h_rt=24:00:00" \
--logdir="/u/project/cbearden/data/22qPrisma/qunex_studyfolder/processing/logs/manual" \
--array="yes" \
--sessions="Q_0355_05312018 Q_0443_06282021 Q_0446_06152021 Q_0459_08192021"

## FMRI SURFACE
# try with HCPStyleData after running structurals as legacy
/u/project/cbearden/data/scripts/tools/qunex_bin/hoffman_submit_qunex.sh \
--qunex_command="hcp_fmri_surface" \
--qunex_options="--hcp_processing_mode=HCPStyleData --sessions=/u/project/cbearden/data/22qPrisma/qunex_studyfolder/processing/22qPrisma_batch_no_t2_n4.txt --sessionsfolder=/u/project/cbearden/data/22qPrisma/qunex_studyfolder/sessions --parsessions=1 --overwrite=no" \
--scheduler_options="-l h_data=16G,h_rt=24:00:00" \
--logdir="/u/project/cbearden/data/22qPrisma/qunex_studyfolder/processing/logs/manual" \
--array="yes" \
--sessions="Q_0355_05312018 Q_0443_06282021 Q_0446_06152021 Q_0459_08192021"

/u/project/cbearden/data/scripts/tools/qunex_bin/hoffman_submit_qunex.sh \
--qunex_command="hcp_fmri_surface" \
--qunex_options="--hcp_processing_mode=HCPStyleData --sessions=/u/project/cbearden/data/22qPrisma/qunex_studyfolder/processing/22qPrisma_batch_no_t2_n4.txt --sessionsfolder=/u/project/cbearden/data/22qPrisma/qunex_studyfolder/sessions --parsessions=1 --overwrite=no" \
--scheduler_options="-l h_data=16G,h_rt=24:00:00" \
--logdir="/u/project/cbearden/data/22qPrisma/qunex_studyfolder/processing/logs/manual" \
--array="yes" \
--sessions="Q_0459_08192021"


#####################################################################
### QC
#####################################################################

## T1w QC
cd /u/project/cbearden/data/22qPrisma/qunex_studyfolder/processing/logs/manual
/u/project/cbearden/data/scripts/tools/qunex_bin/hoffman_submit_qunex.sh \
--qunex_command="run_qc" \
--qunex_options="--modality=T1w --overwrite=yes --sessionsfolder=/u/project/cbearden/data/22qPrisma/qunex_studyfolder/sessions" \
--scheduler_options="-l h_data=16G,h_rt=24:00:00" \
--logdir="/u/project/cbearden/data/22qPrisma/qunex_studyfolder/processing/logs/manual" \
--array="yes" \
--sessions="Q_0001_02222018 Q_0005_11072017 Q_0017_10022017 Q_0019_03022020 Q_0030_05082018 Q_0036_08082017 Q_0036_08312018 Q_0036_09302019 Q_0037_08152017 Q_0038_08192019 Q_0041_10092017 Q_0051_02032017 Q_0105_03112020 Q_0105_12032018 Q_0114_12052017 Q_0138_01082018 Q_0141_06122018 Q_0141_08052019 Q_0147_12112017 Q_0147_12112018 Q_0196_01082020 Q_0213_05012017 Q_0214_05012017 Q_0217_01242017 Q_0217_02192020 Q_0234_05302017 Q_0235_05252017 Q_0238_02202018 Q_0240_09192017 Q_0240_11162018 Q_0246_10092018 Q_0246_10102017 Q_0246_10142016 Q_0250_10242017 Q_0260_06192017 Q_0260_06242019 Q_0260_06252018 Q_0263_02252019 Q_0263_02262018 Q_0263_11072016 Q_0271_10182016 Q_0277_11302017 Q_0277_12132016 Q_0278_11292017 Q_0278_12052019 Q_0278_12132016 Q_0279_11302017 Q_0279_12052019 Q_0279_12132016 Q_0285_03212017 Q_0285_06062018 Q_0286_03212017 Q_0287_03212017 Q_0287_06062018 Q_0288_06062018 Q_0289_03212017 Q_0289_06062018 Q_0291_11042016 Q_0291_11302018 Q_0304_12202016 Q_0310_01252018 Q_0310_02132017 Q_0310_04292019 Q_0313_05072019 Q_0319_03192018 Q_0319_03282017 Q_0321_03192018 Q_0321_03272017 Q_0324_04182018 Q_0324_05032017 Q_0326_10202017 Q_0326_12062018 Q_0327_10192017 Q_0327_12072018 Q_0331_06102019 Q_0331_06212018 Q_0331_06272017 Q_0333_04142017 Q_0334_12012016 Q_0336_01102017 Q_0337_04022018 Q_0338_02162017 Q_0339_03292018 Q_0345_04122017 Q_0345_08152018 Q_0345_09112019 Q_0346_04102017 Q_0346_04102018 Q_0348_04212017 Q_0348_08152018 Q_0350_04192017 Q_0350_09142018 Q_0353_04182018 Q_0353_05022017 Q_0355_05312018 Q_0355_06052019 Q_0356_05312018 Q_0356_06052019 Q_0356_06062017 Q_0361_08212017 Q_0361_10212019 Q_0361_11202018 Q_0369_04182018 Q_0369_06182019 Q_0371_07312019 Q_0371_08042020 Q_0374_05152019 Q_0374_05252018 Q_0377_07242018 Q_0381_08072018 Q_0381_09102019 Q_0382_08282018 Q_0383_08282018 Q_0387_08242018 Q_0387_12032019 Q_0390_09042018 Q_0390_09302019 Q_0391_09252018 Q_0395_11062018 Q_0395_11062018_18 Q_0395_11062018_2 Q_0397_10172019 Q_0402_01112019 Q_0404_03112019 Q_0404_03162020 Q_0407_06122019 Q_0408_05172019 Q_0411_05202019 Q_0414_07172019 Q_0415_07292019 Q_0416_07292019 Q_0419_08132019 Q_0422_11262019 Q_0425_11052019 Q_0426_11262019 Q_0429_01092020 Q_0432_02142020 Q_0433_02262020 Q_0443_06282021 Q_0446_06152021"

## T2w QC
cd /u/project/cbearden/data/22qPrisma/qunex_studyfolder/processing/logs/manual
/u/project/cbearden/data/scripts/tools/qunex_bin/hoffman_submit_qunex.sh \
--qunex_command="run_qc" \
--qunex_options="--modality=T2w --overwrite=yes --sessionsfolder=/u/project/cbearden/data/22qPrisma/qunex_studyfolder/sessions" \
--scheduler_options="-l h_data=16G,h_rt=24:00:00" \
--logdir="/u/project/cbearden/data/22qPrisma/qunex_studyfolder/processing/logs/manual" \
--array="yes" \
--sessions="Q_0001_02222018 Q_0005_11072017 Q_0017_10022017 Q_0019_03022020 Q_0030_05082018 Q_0036_08082017 Q_0036_08312018 Q_0036_09302019 Q_0037_08152017 Q_0038_08192019 Q_0041_10092017 Q_0051_02032017 Q_0105_03112020 Q_0105_12032018 Q_0114_12052017 Q_0138_01082018 Q_0141_06122018 Q_0141_08052019 Q_0147_12112017 Q_0147_12112018 Q_0196_01082020 Q_0213_05012017 Q_0214_05012017 Q_0217_01242017 Q_0217_02192020 Q_0234_05302017 Q_0235_05252017 Q_0238_02202018 Q_0240_09192017 Q_0240_11162018 Q_0246_10092018 Q_0246_10102017 Q_0246_10142016 Q_0250_10242017 Q_0260_06192017 Q_0260_06242019 Q_0260_06252018 Q_0263_02252019 Q_0263_02262018 Q_0263_11072016 Q_0271_10182016 Q_0277_11302017 Q_0277_12132016 Q_0278_11292017 Q_0278_12052019 Q_0278_12132016 Q_0279_11302017 Q_0279_12052019 Q_0279_12132016 Q_0285_03212017 Q_0285_06062018 Q_0286_03212017 Q_0287_03212017 Q_0287_06062018 Q_0288_06062018 Q_0289_03212017 Q_0289_06062018 Q_0291_11042016 Q_0291_11302018 Q_0304_12202016 Q_0310_01252018 Q_0310_02132017 Q_0310_04292019 Q_0313_05072019 Q_0319_03192018 Q_0319_03282017 Q_0321_03192018 Q_0321_03272017 Q_0324_04182018 Q_0324_05032017 Q_0326_10202017 Q_0326_12062018 Q_0327_10192017 Q_0327_12072018 Q_0331_06102019 Q_0331_06212018 Q_0331_06272017 Q_0333_04142017 Q_0334_12012016 Q_0336_01102017 Q_0337_04022018 Q_0338_02162017 Q_0339_03292018 Q_0345_04122017 Q_0345_08152018 Q_0345_09112019 Q_0346_04102017 Q_0346_04102018 Q_0348_04212017 Q_0348_08152018 Q_0350_04192017 Q_0350_09142018 Q_0353_04182018 Q_0353_05022017 Q_0355_05312018 Q_0355_06052019 Q_0356_05312018 Q_0356_06052019 Q_0356_06062017 Q_0361_08212017 Q_0361_10212019 Q_0361_11202018 Q_0369_04182018 Q_0369_06182019 Q_0371_07312019 Q_0371_08042020 Q_0374_05152019 Q_0374_05252018 Q_0377_07242018 Q_0381_08072018 Q_0381_09102019 Q_0382_08282018 Q_0383_08282018 Q_0387_08242018 Q_0387_12032019 Q_0390_09042018 Q_0390_09302019 Q_0391_09252018 Q_0395_11062018 Q_0395_11062018_18 Q_0395_11062018_2 Q_0397_10172019 Q_0402_01112019 Q_0404_03112019 Q_0404_03162020 Q_0407_06122019 Q_0408_05172019 Q_0411_05202019 Q_0414_07172019 Q_0415_07292019 Q_0416_07292019 Q_0419_08132019 Q_0422_11262019 Q_0425_11052019 Q_0426_11262019 Q_0429_01092020 Q_0432_02142020 Q_0433_02262020 Q_0443_06282021 Q_0446_06152021"

## BOLD QC
cd /u/project/cbearden/data/22qPrisma/qunex_studyfolder/processing/logs/manual
/u/project/cbearden/data/scripts/tools/qunex_bin/hoffman_submit_qunex.sh \
--qunex_command="run_qc" \
--qunex_options="--modality=BOLD --bolddata=1,2,3,4 --boldprefix=BOLD --boldsuffix=Atlas --overwrite=yes --skipframes=5 --sessionsfolder=/u/project/cbearden/data/22qPrisma/qunex_studyfolder/sessions" \
--scheduler_options="-l h_data=16G,h_rt=24:00:00" \
--logdir="/u/project/cbearden/data/22qPrisma/qunex_studyfolder/processing/logs/manual" \
--array="yes" \
--sessions="Q_0001_02222018 Q_0005_11072017 Q_0017_10022017 Q_0019_03022020 Q_0030_05082018 Q_0036_08082017 Q_0036_08312018 Q_0036_09302019 Q_0037_08152017 Q_0038_08192019 Q_0041_10092017 Q_0051_02032017 Q_0105_03112020 Q_0105_12032018 Q_0114_12052017 Q_0138_01082018 Q_0141_06122018 Q_0141_08052019 Q_0147_12112017 Q_0147_12112018 Q_0196_01082020 Q_0213_05012017 Q_0214_05012017 Q_0217_01242017 Q_0217_02192020 Q_0234_05302017 Q_0235_05252017 Q_0238_02202018 Q_0240_09192017 Q_0240_11162018 Q_0246_10092018 Q_0246_10102017 Q_0246_10142016 Q_0250_10242017 Q_0260_06192017 Q_0260_06242019 Q_0260_06252018 Q_0263_02252019 Q_0263_02262018 Q_0263_11072016 Q_0271_10182016 Q_0277_11302017 Q_0277_12132016 Q_0278_11292017 Q_0278_12052019 Q_0278_12132016 Q_0279_11302017 Q_0279_12052019 Q_0279_12132016 Q_0285_03212017 Q_0285_06062018 Q_0286_03212017 Q_0287_03212017 Q_0287_06062018 Q_0288_06062018 Q_0289_03212017 Q_0289_06062018 Q_0291_11042016 Q_0291_11302018 Q_0304_12202016 Q_0310_01252018 Q_0310_02132017 Q_0310_04292019 Q_0313_05072019 Q_0319_03192018 Q_0319_03282017 Q_0321_03192018 Q_0321_03272017 Q_0324_04182018 Q_0324_05032017 Q_0326_10202017 Q_0326_12062018 Q_0327_10192017 Q_0327_12072018 Q_0331_06102019 Q_0331_06212018 Q_0331_06272017 Q_0333_04142017 Q_0334_12012016 Q_0336_01102017 Q_0337_04022018 Q_0338_02162017 Q_0339_03292018 Q_0345_04122017 Q_0345_08152018 Q_0345_09112019 Q_0346_04102017 Q_0346_04102018 Q_0348_04212017 Q_0348_08152018 Q_0350_04192017 Q_0350_09142018 Q_0353_04182018 Q_0353_05022017 Q_0355_05312018 Q_0355_06052019 Q_0356_05312018 Q_0356_06052019 Q_0356_06062017 Q_0361_08212017 Q_0361_10212019 Q_0361_11202018 Q_0369_04182018 Q_0369_06182019 Q_0371_07312019 Q_0371_08042020 Q_0374_05152019 Q_0374_05252018 Q_0377_07242018 Q_0381_08072018 Q_0381_09102019 Q_0382_08282018 Q_0383_08282018 Q_0387_08242018 Q_0387_12032019 Q_0390_09042018 Q_0390_09302019 Q_0391_09252018 Q_0395_11062018 Q_0395_11062018_18 Q_0395_11062018_2 Q_0397_10172019 Q_0402_01112019 Q_0404_03112019 Q_0404_03162020 Q_0407_06122019 Q_0408_05172019 Q_0411_05202019 Q_0414_07172019 Q_0415_07292019 Q_0416_07292019 Q_0419_08132019 Q_0422_11262019 Q_0425_11052019 Q_0426_11262019 Q_0429_01092020 Q_0432_02142020 Q_0433_02262020 Q_0443_06282021 Q_0446_06152021"


#####################################################################
### BOLD post-processing
#####################################################################
# https://bitbucket.org/oriadev/qunex/wiki/UsageDocs/BOLDPreprocessing.md
# https://bitbucket.org/oriadev/qunex/wiki/UsageDocs/MovementScrubbing.md

## map hcp data
/u/project/cbearden/data/scripts/tools/qunex_bin/hoffman_submit_qunex.sh \
--qunex_command="map_hcp_data" \
--qunex_options="--overwrite=yes --bolds=resting --sessions=/u/project/cbearden/data/22qPrisma/qunex_studyfolder/processing/22qPrisma_batch_cleaned_n114.txt --sessionsfolder=/u/project/cbearden/data/22qPrisma/qunex_studyfolder/sessions" \
--scheduler_options="-l h_data=20G,h_rt=4:00:00,arch=intel*" \
--logdir="/u/project/cbearden/data/22qPrisma/qunex_studyfolder/processing/logs/manual" \
--array="yes" \
--sessions="Q_0005_11072017 Q_0017_10022017 Q_0019_03022020 Q_0030_05082018 Q_0036_08082017 Q_0036_08312018 Q_0036_09302019 Q_0037_08152017 Q_0041_10092017 Q_0051_02032017 Q_0105_03112020 Q_0105_12032018 Q_0114_12052017 Q_0138_01082018 Q_0141_06122018 Q_0141_08052019 Q_0147_12112017 Q_0147_12112018 Q_0196_01082020 Q_0213_05012017 Q_0214_05012017 Q_0217_01242017 Q_0217_02192020 Q_0235_05252017 Q_0238_02202018 Q_0240_09192017 Q_0240_11162018 Q_0246_10092018 Q_0246_10102017 Q_0260_06192017 Q_0260_06242019 Q_0260_06252018 Q_0263_02252019 Q_0263_02262018 Q_0277_12132016 Q_0278_11292017 Q_0278_12052019 Q_0278_12132016 Q_0279_11302017 Q_0279_12052019 Q_0279_12132016 Q_0285_03212017 Q_0285_06062018 Q_0286_03212017 Q_0287_06062018 Q_0288_06062018 Q_0289_03212017 Q_0289_06062018 Q_0291_11302018 Q_0304_12202016 Q_0310_01252018 Q_0310_02132017 Q_0310_04292019 Q_0319_03192018 Q_0319_03282017 Q_0321_03192018 Q_0321_03272017 Q_0324_04182018 Q_0326_10202017 Q_0326_12062018 Q_0327_10192017 Q_0327_12072018 Q_0331_06102019 Q_0331_06212018 Q_0331_06272017 Q_0333_04142017 Q_0334_12012016 Q_0336_01102017 Q_0345_04122017 Q_0345_08152018 Q_0345_09112019 Q_0346_04102017 Q_0346_04102018 Q_0348_04212017 Q_0348_08152018 Q_0350_04192017 Q_0350_09142018 Q_0353_04182018 Q_0353_05022017 Q_0355_05312018 Q_0356_05312018 Q_0361_10212019 Q_0361_11202018 Q_0369_04182018 Q_0369_06182019 Q_0371_08042020 Q_0374_05252018 Q_0381_08072018 Q_0381_09102019 Q_0382_08282018 Q_0383_08282018 Q_0387_08242018 Q_0387_12032019 Q_0390_09042018 Q_0390_09302019 Q_0391_09252018 Q_0395_11062018 Q_0397_10172019 Q_0402_01112019 Q_0404_03112019 Q_0407_06122019 Q_0408_05172019 Q_0414_07172019 Q_0415_07292019 Q_0416_07292019 Q_0419_08132019 Q_0425_11052019 Q_0429_01092020 Q_0432_02142020 Q_0433_02262020 Q_0443_06282021 Q_0446_06152021 Q_0459_08192021 Q_0461_09112021"

## brain masks
/u/project/cbearden/data/scripts/tools/qunex_bin/hoffman_submit_qunex.sh \
--qunex_command="create_bold_brain_masks" \
--qunex_options="--overwrite=yes --bolds=resting --sessions=/u/project/cbearden/data/22qPrisma/qunex_studyfolder/processing/22qPrisma_batch_cleaned_n114.txt --sessionsfolder=/u/project/cbearden/data/22qPrisma/qunex_studyfolder/sessions" \
--scheduler_options="-l h_data=20G,h_rt=4:00:00,arch=intel*" \
--logdir="/u/project/cbearden/data/22qPrisma/qunex_studyfolder/processing/logs/manual" \
--array="yes" \
--sessions="Q_0005_11072017 Q_0017_10022017 Q_0019_03022020 Q_0030_05082018 Q_0036_08082017 Q_0036_08312018 Q_0036_09302019 Q_0037_08152017 Q_0041_10092017 Q_0051_02032017 Q_0105_03112020 Q_0105_12032018 Q_0114_12052017 Q_0138_01082018 Q_0141_06122018 Q_0141_08052019 Q_0147_12112017 Q_0147_12112018 Q_0196_01082020 Q_0213_05012017 Q_0214_05012017 Q_0217_01242017 Q_0217_02192020 Q_0235_05252017 Q_0238_02202018 Q_0240_09192017 Q_0240_11162018 Q_0246_10092018 Q_0246_10102017 Q_0260_06192017 Q_0260_06242019 Q_0260_06252018 Q_0263_02252019 Q_0263_02262018 Q_0277_12132016 Q_0278_11292017 Q_0278_12052019 Q_0278_12132016 Q_0279_11302017 Q_0279_12052019 Q_0279_12132016 Q_0285_03212017 Q_0285_06062018 Q_0286_03212017 Q_0287_06062018 Q_0288_06062018 Q_0289_03212017 Q_0289_06062018 Q_0291_11302018 Q_0304_12202016 Q_0310_01252018 Q_0310_02132017 Q_0310_04292019 Q_0319_03192018 Q_0319_03282017 Q_0321_03192018 Q_0321_03272017 Q_0324_04182018 Q_0326_10202017 Q_0326_12062018 Q_0327_10192017 Q_0327_12072018 Q_0331_06102019 Q_0331_06212018 Q_0331_06272017 Q_0333_04142017 Q_0334_12012016 Q_0336_01102017 Q_0345_04122017 Q_0345_08152018 Q_0345_09112019 Q_0346_04102017 Q_0346_04102018 Q_0348_04212017 Q_0348_08152018 Q_0350_04192017 Q_0350_09142018 Q_0353_04182018 Q_0353_05022017 Q_0355_05312018 Q_0356_05312018 Q_0361_10212019 Q_0361_11202018 Q_0369_04182018 Q_0369_06182019 Q_0371_08042020 Q_0374_05252018 Q_0381_08072018 Q_0381_09102019 Q_0382_08282018 Q_0383_08282018 Q_0387_08242018 Q_0387_12032019 Q_0390_09042018 Q_0390_09302019 Q_0391_09252018 Q_0395_11062018 Q_0397_10172019 Q_0402_01112019 Q_0404_03112019 Q_0407_06122019 Q_0408_05172019 Q_0414_07172019 Q_0415_07292019 Q_0416_07292019 Q_0419_08132019 Q_0425_11052019 Q_0429_01092020 Q_0432_02142020 Q_0433_02262020 Q_0443_06282021 Q_0446_06152021 Q_0459_08192021 Q_0461_09112021"

## bold stats
/u/project/cbearden/data/scripts/tools/qunex_bin/hoffman_submit_qunex.sh \
--qunex_command="compute_bold_stats" \
--qunex_options="--overwrite=yes --bolds=resting --sessions=/u/project/cbearden/data/22qPrisma/qunex_studyfolder/processing/22qPrisma_batch_cleaned_n114.txt --sessionsfolder=/u/project/cbearden/data/22qPrisma/qunex_studyfolder/sessions" \
--scheduler_options="-l h_data=20G,h_rt=4:00:00,arch=intel*" \
--logdir="/u/project/cbearden/data/22qPrisma/qunex_studyfolder/processing/logs/manual" \
--array="yes" \
--sessions="Q_0005_11072017 Q_0017_10022017 Q_0019_03022020 Q_0030_05082018 Q_0036_08082017 Q_0036_08312018 Q_0036_09302019 Q_0037_08152017 Q_0041_10092017 Q_0051_02032017 Q_0105_03112020 Q_0105_12032018 Q_0114_12052017 Q_0138_01082018 Q_0141_06122018 Q_0141_08052019 Q_0147_12112017 Q_0147_12112018 Q_0196_01082020 Q_0213_05012017 Q_0214_05012017 Q_0217_01242017 Q_0217_02192020 Q_0235_05252017 Q_0238_02202018 Q_0240_09192017 Q_0240_11162018 Q_0246_10092018 Q_0246_10102017 Q_0260_06192017 Q_0260_06242019 Q_0260_06252018 Q_0263_02252019 Q_0263_02262018 Q_0277_12132016 Q_0278_11292017 Q_0278_12052019 Q_0278_12132016 Q_0279_11302017 Q_0279_12052019 Q_0279_12132016 Q_0285_03212017 Q_0285_06062018 Q_0286_03212017 Q_0287_06062018 Q_0288_06062018 Q_0289_03212017 Q_0289_06062018 Q_0291_11302018 Q_0304_12202016 Q_0310_01252018 Q_0310_02132017 Q_0310_04292019 Q_0319_03192018 Q_0319_03282017 Q_0321_03192018 Q_0321_03272017 Q_0324_04182018 Q_0326_10202017 Q_0326_12062018 Q_0327_10192017 Q_0327_12072018 Q_0331_06102019 Q_0331_06212018 Q_0331_06272017 Q_0333_04142017 Q_0334_12012016 Q_0336_01102017 Q_0345_04122017 Q_0345_08152018 Q_0345_09112019 Q_0346_04102017 Q_0346_04102018 Q_0348_04212017 Q_0348_08152018 Q_0350_04192017 Q_0350_09142018 Q_0353_04182018 Q_0353_05022017 Q_0355_05312018 Q_0356_05312018 Q_0361_10212019 Q_0361_11202018 Q_0369_04182018 Q_0369_06182019 Q_0371_08042020 Q_0374_05252018 Q_0381_08072018 Q_0381_09102019 Q_0382_08282018 Q_0383_08282018 Q_0387_08242018 Q_0387_12032019 Q_0390_09042018 Q_0390_09302019 Q_0391_09252018 Q_0395_11062018 Q_0397_10172019 Q_0402_01112019 Q_0404_03112019 Q_0407_06122019 Q_0408_05172019 Q_0414_07172019 Q_0415_07292019 Q_0416_07292019 Q_0419_08132019 Q_0425_11052019 Q_0429_01092020 Q_0432_02142020 Q_0433_02262020 Q_0443_06282021 Q_0446_06152021 Q_0459_08192021 Q_0461_09112021"

## create stats report
/u/project/cbearden/data/scripts/tools/qunex_bin/hoffman_submit_qunex.sh \
--qunex_command="create_stats_report" \
--qunex_options="--overwrite=yes --bolds=resting --sessions=/u/project/cbearden/data/22qPrisma/qunex_studyfolder/processing/22qPrisma_batch_cleaned_n114.txt --sessionsfolder=/u/project/cbearden/data/22qPrisma/qunex_studyfolder/sessions" \
--scheduler_options="-l h_data=20G,h_rt=4:00:00,arch=intel*" \
--logdir="/u/project/cbearden/data/22qPrisma/qunex_studyfolder/processing/logs/manual" \
--array="yes" \
--sessions="Q_0005_11072017 Q_0017_10022017 Q_0019_03022020 Q_0030_05082018 Q_0036_08082017 Q_0036_08312018 Q_0036_09302019 Q_0037_08152017 Q_0041_10092017 Q_0051_02032017 Q_0105_03112020 Q_0105_12032018 Q_0114_12052017 Q_0138_01082018 Q_0141_06122018 Q_0141_08052019 Q_0147_12112017 Q_0147_12112018 Q_0196_01082020 Q_0213_05012017 Q_0214_05012017 Q_0217_01242017 Q_0217_02192020 Q_0235_05252017 Q_0238_02202018 Q_0240_09192017 Q_0240_11162018 Q_0246_10092018 Q_0246_10102017 Q_0260_06192017 Q_0260_06242019 Q_0260_06252018 Q_0263_02252019 Q_0263_02262018 Q_0277_12132016 Q_0278_11292017 Q_0278_12052019 Q_0278_12132016 Q_0279_11302017 Q_0279_12052019 Q_0279_12132016 Q_0285_03212017 Q_0285_06062018 Q_0286_03212017 Q_0287_06062018 Q_0288_06062018 Q_0289_03212017 Q_0289_06062018 Q_0291_11302018 Q_0304_12202016 Q_0310_01252018 Q_0310_02132017 Q_0310_04292019 Q_0319_03192018 Q_0319_03282017 Q_0321_03192018 Q_0321_03272017 Q_0324_04182018 Q_0326_10202017 Q_0326_12062018 Q_0327_10192017 Q_0327_12072018 Q_0331_06102019 Q_0331_06212018 Q_0331_06272017 Q_0333_04142017 Q_0334_12012016 Q_0336_01102017 Q_0345_04122017 Q_0345_08152018 Q_0345_09112019 Q_0346_04102017 Q_0346_04102018 Q_0348_04212017 Q_0348_08152018 Q_0350_04192017 Q_0350_09142018 Q_0353_04182018 Q_0353_05022017 Q_0355_05312018 Q_0356_05312018 Q_0361_10212019 Q_0361_11202018 Q_0369_04182018 Q_0369_06182019 Q_0371_08042020 Q_0374_05252018 Q_0381_08072018 Q_0381_09102019 Q_0382_08282018 Q_0383_08282018 Q_0387_08242018 Q_0387_12032019 Q_0390_09042018 Q_0390_09302019 Q_0391_09252018 Q_0395_11062018 Q_0397_10172019 Q_0402_01112019 Q_0404_03112019 Q_0407_06122019 Q_0408_05172019 Q_0414_07172019 Q_0415_07292019 Q_0416_07292019 Q_0419_08132019 Q_0425_11052019 Q_0429_01092020 Q_0432_02142020 Q_0433_02262020 Q_0443_06282021 Q_0446_06152021 Q_0459_08192021 Q_0461_09112021"

## extract nuisance signal
/u/project/cbearden/data/scripts/tools/qunex_bin/hoffman_submit_qunex.sh \
--qunex_command="extract_nuisance_signal" \
--qunex_options="--overwrite=yes --bolds=resting --sessions=/u/project/cbearden/data/22qPrisma/qunex_studyfolder/processing/22qPrisma_batch_cleaned_n114.txt --sessionsfolder=/u/project/cbearden/data/22qPrisma/qunex_studyfolder/sessions" \
--scheduler_options="-l h_data=20G,h_rt=4:00:00,arch=intel*" \
--logdir="/u/project/cbearden/data/22qPrisma/qunex_studyfolder/processing/logs/manual" \
--array="yes" \
--sessions="Q_0005_11072017 Q_0017_10022017 Q_0019_03022020 Q_0030_05082018 Q_0036_08082017 Q_0036_08312018 Q_0036_09302019 Q_0037_08152017 Q_0041_10092017 Q_0051_02032017 Q_0105_03112020 Q_0105_12032018 Q_0114_12052017 Q_0138_01082018 Q_0141_06122018 Q_0141_08052019 Q_0147_12112017 Q_0147_12112018 Q_0196_01082020 Q_0213_05012017 Q_0214_05012017 Q_0217_01242017 Q_0217_02192020 Q_0235_05252017 Q_0238_02202018 Q_0240_09192017 Q_0240_11162018 Q_0246_10092018 Q_0246_10102017 Q_0260_06192017 Q_0260_06242019 Q_0260_06252018 Q_0263_02252019 Q_0263_02262018 Q_0277_12132016 Q_0278_11292017 Q_0278_12052019 Q_0278_12132016 Q_0279_11302017 Q_0279_12052019 Q_0279_12132016 Q_0285_03212017 Q_0285_06062018 Q_0286_03212017 Q_0287_06062018 Q_0288_06062018 Q_0289_03212017 Q_0289_06062018 Q_0291_11302018 Q_0304_12202016 Q_0310_01252018 Q_0310_02132017 Q_0310_04292019 Q_0319_03192018 Q_0319_03282017 Q_0321_03192018 Q_0321_03272017 Q_0324_04182018 Q_0326_10202017 Q_0326_12062018 Q_0327_10192017 Q_0327_12072018 Q_0331_06102019 Q_0331_06212018 Q_0331_06272017 Q_0333_04142017 Q_0334_12012016 Q_0336_01102017 Q_0345_04122017 Q_0345_08152018 Q_0345_09112019 Q_0346_04102017 Q_0346_04102018 Q_0348_04212017 Q_0348_08152018 Q_0350_04192017 Q_0350_09142018 Q_0353_04182018 Q_0353_05022017 Q_0355_05312018 Q_0356_05312018 Q_0361_10212019 Q_0361_11202018 Q_0369_04182018 Q_0369_06182019 Q_0371_08042020 Q_0374_05252018 Q_0381_08072018 Q_0381_09102019 Q_0382_08282018 Q_0383_08282018 Q_0387_08242018 Q_0387_12032019 Q_0390_09042018 Q_0390_09302019 Q_0391_09252018 Q_0395_11062018 Q_0397_10172019 Q_0402_01112019 Q_0404_03112019 Q_0407_06122019 Q_0408_05172019 Q_0414_07172019 Q_0415_07292019 Q_0416_07292019 Q_0419_08132019 Q_0425_11052019 Q_0429_01092020 Q_0432_02142020 Q_0433_02262020 Q_0443_06282021 Q_0446_06152021 Q_0459_08192021 Q_0461_09112021"

## preprocess bold CIFTI no GSR
/u/project/cbearden/data/scripts/tools/qunex_bin/hoffman_submit_qunex.sh \
--qunex_command="preprocess_bold" \
--qunex_options="--overwrite=yes --bolds=resting --bold_actions=s,h,r,c,l --bold_nuisance=m,V,WM,1d --image_target=dtseries --sessions=/u/project/cbearden/data/22qPrisma/qunex_studyfolder/processing/22qPrisma_batch_cleaned_n114.txt --sessionsfolder=/u/project/cbearden/data/22qPrisma/qunex_studyfolder/sessions" \
--scheduler_options="-l h_data=20G,h_rt=4:00:00,arch=intel*" \
--logdir="/u/project/cbearden/data/22qPrisma/qunex_studyfolder/processing/logs/manual" \
--array="yes" \
--sessions="Q_0005_11072017 Q_0017_10022017 Q_0019_03022020 Q_0030_05082018 Q_0036_08082017 Q_0036_08312018 Q_0036_09302019 Q_0037_08152017 Q_0041_10092017 Q_0051_02032017 Q_0105_03112020 Q_0105_12032018 Q_0114_12052017 Q_0138_01082018 Q_0141_06122018 Q_0141_08052019 Q_0147_12112017 Q_0147_12112018 Q_0196_01082020 Q_0213_05012017 Q_0214_05012017 Q_0217_01242017 Q_0217_02192020 Q_0235_05252017 Q_0238_02202018 Q_0240_09192017 Q_0240_11162018 Q_0246_10092018 Q_0246_10102017 Q_0260_06192017 Q_0260_06242019 Q_0260_06252018 Q_0263_02252019 Q_0263_02262018 Q_0277_12132016 Q_0278_11292017 Q_0278_12052019 Q_0278_12132016 Q_0279_11302017 Q_0279_12052019 Q_0279_12132016 Q_0285_03212017 Q_0285_06062018 Q_0286_03212017 Q_0287_06062018 Q_0288_06062018 Q_0289_03212017 Q_0289_06062018 Q_0291_11302018 Q_0304_12202016 Q_0310_01252018 Q_0310_02132017 Q_0310_04292019 Q_0319_03192018 Q_0319_03282017 Q_0321_03192018 Q_0321_03272017 Q_0324_04182018 Q_0326_10202017 Q_0326_12062018 Q_0327_10192017 Q_0327_12072018 Q_0331_06102019 Q_0331_06212018 Q_0331_06272017 Q_0333_04142017 Q_0334_12012016 Q_0336_01102017 Q_0345_04122017 Q_0345_08152018 Q_0345_09112019 Q_0346_04102017 Q_0346_04102018 Q_0348_04212017 Q_0348_08152018 Q_0350_04192017 Q_0350_09142018 Q_0353_04182018 Q_0353_05022017 Q_0355_05312018 Q_0356_05312018 Q_0361_10212019 Q_0361_11202018 Q_0369_04182018 Q_0369_06182019 Q_0371_08042020 Q_0374_05252018 Q_0381_08072018 Q_0381_09102019 Q_0382_08282018 Q_0383_08282018 Q_0387_08242018 Q_0387_12032019 Q_0390_09042018 Q_0390_09302019 Q_0391_09252018 Q_0395_11062018 Q_0397_10172019 Q_0402_01112019 Q_0404_03112019 Q_0407_06122019 Q_0408_05172019 Q_0414_07172019 Q_0415_07292019 Q_0416_07292019 Q_0419_08132019 Q_0425_11052019 Q_0429_01092020 Q_0432_02142020 Q_0433_02262020 Q_0443_06282021 Q_0446_06152021 Q_0459_08192021 Q_0461_09112021"

## preprocess bold CIFTI GSR
/u/project/cbearden/data/scripts/tools/qunex_bin/hoffman_submit_qunex.sh \
--qunex_command="preprocess_bold" \
--qunex_options="--overwrite=yes --bolds=resting --bold_actions=s,h,r,c,l --bold_nuisance=m,V,WM,WB,1d --image_target=dtseries  --sessions=/u/project/cbearden/data/22qPrisma/qunex_studyfolder/processing/22qPrisma_batch_cleaned_n114.txt --sessionsfolder=/u/project/cbearden/data/22qPrisma/qunex_studyfolder/sessions" \
--scheduler_options="-l h_data=20G,h_rt=4:00:00,arch=intel*" \
--logdir="/u/project/cbearden/data/22qPrisma/qunex_studyfolder/processing/logs/manual" \
--array="yes" \
--sessions="Q_0005_11072017 Q_0017_10022017 Q_0019_03022020 Q_0030_05082018 Q_0036_08082017 Q_0036_08312018 Q_0036_09302019 Q_0037_08152017 Q_0041_10092017 Q_0051_02032017 Q_0105_03112020 Q_0105_12032018 Q_0114_12052017 Q_0138_01082018 Q_0141_06122018 Q_0141_08052019 Q_0147_12112017 Q_0147_12112018 Q_0196_01082020 Q_0213_05012017 Q_0214_05012017 Q_0217_01242017 Q_0217_02192020 Q_0235_05252017 Q_0238_02202018 Q_0240_09192017 Q_0240_11162018 Q_0246_10092018 Q_0246_10102017 Q_0260_06192017 Q_0260_06242019 Q_0260_06252018 Q_0263_02252019 Q_0263_02262018 Q_0277_12132016 Q_0278_11292017 Q_0278_12052019 Q_0278_12132016 Q_0279_11302017 Q_0279_12052019 Q_0279_12132016 Q_0285_03212017 Q_0285_06062018 Q_0286_03212017 Q_0287_06062018 Q_0288_06062018 Q_0289_03212017 Q_0289_06062018 Q_0291_11302018 Q_0304_12202016 Q_0310_01252018 Q_0310_02132017 Q_0310_04292019 Q_0319_03192018 Q_0319_03282017 Q_0321_03192018 Q_0321_03272017 Q_0324_04182018 Q_0326_10202017 Q_0326_12062018 Q_0327_10192017 Q_0327_12072018 Q_0331_06102019 Q_0331_06212018 Q_0331_06272017 Q_0333_04142017 Q_0334_12012016 Q_0336_01102017 Q_0345_04122017 Q_0345_08152018 Q_0345_09112019 Q_0346_04102017 Q_0346_04102018 Q_0348_04212017 Q_0348_08152018 Q_0350_04192017 Q_0350_09142018 Q_0353_04182018 Q_0353_05022017 Q_0355_05312018 Q_0356_05312018 Q_0361_10212019 Q_0361_11202018 Q_0369_04182018 Q_0369_06182019 Q_0371_08042020 Q_0374_05252018 Q_0381_08072018 Q_0381_09102019 Q_0382_08282018 Q_0383_08282018 Q_0387_08242018 Q_0387_12032019 Q_0390_09042018 Q_0390_09302019 Q_0391_09252018 Q_0395_11062018 Q_0397_10172019 Q_0402_01112019 Q_0404_03112019 Q_0407_06122019 Q_0408_05172019 Q_0414_07172019 Q_0415_07292019 Q_0416_07292019 Q_0419_08132019 Q_0425_11052019 Q_0429_01092020 Q_0432_02142020 Q_0433_02262020 Q_0443_06282021 Q_0446_06152021 Q_0459_08192021 Q_0461_09112021"

# final check for check GSR and noGSR for everything in sessions dir
cd /u/project/cbearden/data/22qPrisma/qunex_studyfolder/sessions
sessions=Q_*
echo GSR
for i in $sessions; do if [[ -f ${i}/images/functional/bold1_Atlas_s_hpss_res-mVWMWB1d_lpss.dtseries.nii  ]] || [[ -f ${i}/images/functional/bold2_Atlas_s_hpss_res-mVWMWB1d_lpss.dtseries.nii  ]]|| [[ -f ${i}/images/functional/bold3_Atlas_s_hpss_res-mVWMWB1d_lpss.dtseries.nii  ]]|| [[ -f ${i}/images/functional/bold4_Atlas_s_hpss_res-mVWMWB1d_lpss.dtseries.nii  ]]; then echo ${i} has processed BOLD; else echo ${i} MISSING; fi; done
echo noGSR
for i in $sessions; do if [[ -f ${i}/images/functional/bold1_Atlas_s_hpss_res-mVWM1d_lpss.dtseries.nii  ]] || [[ -f ${i}/images/functional/bold2_Atlas_s_hpss_res-mVWM1d_lpss.dtseries.nii  ]]|| [[ -f ${i}/images/functional/bold3_Atlas_s_hpss_res-mVWM1d_lpss.dtseries.nii  ]]|| [[ -f ${i}/images/functional/bold4_Atlas_s_hpss_res-mVWM1d_lpss.dtseries.nii  ]]; then echo ${i} has processed BOLD; else echo ${i} MISSING; fi; done

#####################################################################
### re-check T1w QC
#####################################################################
sessions="Q_0005_11072017 Q_0017_10022017 Q_0019_03022020 Q_0030_05082018 Q_0036_08082017 Q_0036_08312018 Q_0036_09302019 Q_0037_08152017 Q_0041_10092017 Q_0051_02032017 Q_0105_03112020 Q_0105_12032018 Q_0114_12052017 Q_0138_01082018 Q_0141_06122018 Q_0141_08052019 Q_0147_12112017 Q_0147_12112018 Q_0196_01082020 Q_0213_05012017 Q_0214_05012017 Q_0217_01242017 Q_0217_02192020 Q_0235_05252017 Q_0238_02202018 Q_0240_09192017 Q_0240_11162018 Q_0246_10092018 Q_0246_10102017 Q_0260_06192017 Q_0260_06242019 Q_0260_06252018 Q_0263_02252019 Q_0263_02262018 Q_0277_12132016 Q_0278_11292017 Q_0278_12052019 Q_0278_12132016 Q_0279_11302017 Q_0279_12052019 Q_0279_12132016 Q_0285_03212017 Q_0285_06062018 Q_0286_03212017 Q_0287_06062018 Q_0288_06062018 Q_0289_03212017 Q_0289_06062018 Q_0291_11302018 Q_0304_12202016 Q_0310_01252018 Q_0310_02132017 Q_0310_04292019 Q_0319_03192018 Q_0319_03282017 Q_0321_03192018 Q_0321_03272017 Q_0324_04182018 Q_0326_10202017 Q_0326_12062018 Q_0327_10192017 Q_0327_12072018 Q_0331_06102019 Q_0331_06212018 Q_0331_06272017 Q_0333_04142017 Q_0334_12012016 Q_0336_01102017 Q_0345_04122017 Q_0345_08152018 Q_0345_09112019 Q_0346_04102017 Q_0346_04102018 Q_0348_04212017 Q_0348_08152018 Q_0350_04192017 Q_0350_09142018 Q_0353_04182018 Q_0353_05022017 Q_0355_05312018 Q_0356_05312018 Q_0361_10212019 Q_0361_11202018 Q_0369_04182018 Q_0369_06182019 Q_0371_08042020 Q_0374_05252018 Q_0381_08072018 Q_0381_09102019 Q_0382_08282018 Q_0383_08282018 Q_0387_08242018 Q_0387_12032019 Q_0390_09042018 Q_0390_09302019 Q_0391_09252018 Q_0395_11062018 Q_0397_10172019 Q_0402_01112019 Q_0404_03112019 Q_0407_06122019 Q_0408_05172019 Q_0414_07172019 Q_0415_07292019 Q_0416_07292019 Q_0419_08132019 Q_0425_11052019 Q_0429_01092020 Q_0432_02142020 Q_0433_02262020 Q_0443_06282021 Q_0446_06152021 Q_0459_08192021 Q_0461_09112021"
# check T1w QC image for each session, while manually recording results in 22q_BOLD_Longitudinal_multisite_QC_cs.xlsx
# fail any session with obvious bad T1 (motion, intense banding, signal dropout in brain), pass all others
# note if failing for a neuroanatomical variation
for sesh in $sessions; do echo ${sesh}; display /u/project/cbearden/data/22qPrisma/qunex_studyfolder/sessions/${sesh}/hcp/${sesh}/MNINonLinear/StructuralQC/snapshots/${sesh}.structuralQC.wb_scene1.png;done


#####################################################################
### fix handfull of subjects
#####################################################################
# n=4 subjects with BOLD rest labeled as BOLD bic
sessions="Q_0246_10142016 Q_0263_11072016 Q_0271_10182016 Q_0291_11042016"
# fist edit hcp mapping file to map rfMRI_REST_AP_BIC_v2  => bold:resting: phenc(AP) 
# can't just run map hcp for those four though, need to change session_hcp.txt manually
for i in $sessions; do mv /u/project/cbearden/data/22qPrisma/qunex_studyfolder/sessions/unused_sessions/${i} /u/project/cbearden/data/22qPrisma/qunex_studyfolder/sessions/${i};done
for i in $sessions; do sed -i 's/bic/resting/g' /u/project/cbearden/data/22qPrisma/qunex_studyfolder/sessions/${i}/session_hcp.txt;done

# n=2 sessions need to re-run without T2
sessions="Q_0278_12132016 Q_0324_04182018"
# move hcp directory to hcp_outdated
for i in $sessions; do mv /u/project/cbearden/data/22qPrisma/qunex_studyfolder/sessions/${i}/hcp /u/project/cbearden/data/22qPrisma/qunex_studyfolder/sessions/${i}/hcp_outdated ;done
# manually comment out T2w in session_hcp.txt

# rerun setup hcp 
/u/project/cbearden/data/scripts/tools/qunex_bin/hoffman_submit_qunex.sh \
--qunex_command="setup_hcp" \
--qunex_options="--sessionsfolder=/u/project/cbearden/data/22qPrisma/qunex_studyfolder/sessions --sourcefile=session_hcp.txt" \
--scheduler_options="-l h_data=16G,h_rt=24:00:00" \
--logdir="/u/project/cbearden/data/22qPrisma/qunex_studyfolder/processing/logs/manual" \
--array="yes" \
--sessions="Q_0278_12132016 Q_0324_04182018"

# create batch file for sessions to rerun without T2
/u/project/cbearden/data/scripts/tools/qunex_bin/hoffman_submit_qunex.sh \
--qunex_command="create_batch" \
--qunex_options=" --overwrite=yes --sessionsfolder=/u/project/cbearden/data/22qPrisma/qunex_studyfolder/sessions --sourcefiles=session_hcp.txt --targetfile=/u/project/cbearden/data/22qPrisma/qunex_studyfolder/processing/22qPrisma_batch_rerun_noT2_n2.txt --paramfile=/u/project/cbearden/data/22qPrisma/qunex_studyfolder/sessions/specs/22qPrisma_params_no_t2.txt --sessions=Q_0278_12132016,Q_0324_04182018" \
--scheduler_options="-l h_data=4G,h_rt=4:00:00" \
--logdir="/u/project/cbearden/data/22qPrisma/qunex_studyfolder/processing/logs/manual" \
--array="no"


## PreFreeSurfer
/u/project/cbearden/data/scripts/tools/qunex_bin/hoffman_submit_qunex.sh \
--qunex_command="hcp_pre_freesurfer" \
--qunex_options="--hcp_processing_mode=LegacyStyleData --sessions=/u/project/cbearden/data/22qPrisma/qunex_studyfolder/processing/22qPrisma_batch_rerun_noT2_n2.txt --sessionsfolder=/u/project/cbearden/data/22qPrisma/qunex_studyfolder/sessions --parsessions=1 --overwrite=no" \
--scheduler_options="-l h_data=16G,h_rt=24:00:00,arch=intel*" \
--logdir="/u/project/cbearden/data/22qPrisma/qunex_studyfolder/processing/logs/manual" \
--array="yes" \
--sessions="Q_0278_12132016 Q_0324_04182018"

## FreeSurfer
# try with LegacyStyleData
/u/project/cbearden/data/scripts/tools/qunex_bin/hoffman_submit_qunex.sh \
--qunex_command="hcp_freesurfer" \
--qunex_options="--hcp_processing_mode=LegacyStyleData --sessions=/u/project/cbearden/data/22qPrisma/qunex_studyfolder/processing/22qPrisma_batch_rerun_noT2_n2.txt --sessionsfolder=/u/project/cbearden/data/22qPrisma/qunex_studyfolder/sessions --parsessions=1 --overwrite=no" \
--scheduler_options="-l h_data=16G,h_rt=48:00:00,highp,arch=intel*" \
--logdir="/u/project/cbearden/data/22qPrisma/qunex_studyfolder/processing/logs/manual" \
--array="yes" \
--sessions="Q_0278_12132016 Q_0324_04182018"

## PostFreeSurfer
# try with LegacyStyleData
/u/project/cbearden/data/scripts/tools/qunex_bin/hoffman_submit_qunex.sh \
--qunex_command="hcp_post_freesurfer" \
--qunex_options="--hcp_processing_mode=LegacyStyleData --sessions=/u/project/cbearden/data/22qPrisma/qunex_studyfolder/processing/22qPrisma_batch_rerun_noT2_n2.txt --sessionsfolder=/u/project/cbearden/data/22qPrisma/qunex_studyfolder/sessions --parsessions=1 --overwrite=no" \
--scheduler_options="-l h_data=16G,h_rt=24:00:00,arch=intel*" \
--logdir="/u/project/cbearden/data/22qPrisma/qunex_studyfolder/processing/logs/manual" \
--array="yes" \
--sessions="Q_0278_12132016 Q_0324_04182018"

## FMRI VOLUME
# try with HCPStyleData after running structurals as legacy
/u/project/cbearden/data/scripts/tools/qunex_bin/hoffman_submit_qunex.sh \
--qunex_command="hcp_fmri_volume" \
--qunex_options="--hcp_processing_mode=HCPStyleData --sessions=/u/project/cbearden/data/22qPrisma/qunex_studyfolder/processing/22qPrisma_batch_rerun_noT2_n2.txt --sessionsfolder=/u/project/cbearden/data/22qPrisma/qunex_studyfolder/sessions --parsessions=1 --overwrite=no" \
--scheduler_options="-l h_data=16G,h_rt=24:00:00,arch=intel*" \
--logdir="/u/project/cbearden/data/22qPrisma/qunex_studyfolder/processing/logs/manual" \
--array="yes" \
--sessions="Q_0278_12132016 Q_0324_04182018"

## FMRI SURFACE
# try with HCPStyleData after running structurals as legacy
/u/project/cbearden/data/scripts/tools/qunex_bin/hoffman_submit_qunex.sh \
--qunex_command="hcp_fmri_surface" \
--qunex_options="--hcp_processing_mode=HCPStyleData --sessions=/u/project/cbearden/data/22qPrisma/qunex_studyfolder/processing/22qPrisma_batch_rerun_noT2_n2.txt --sessionsfolder=/u/project/cbearden/data/22qPrisma/qunex_studyfolder/sessions --parsessions=1 --overwrite=no" \
--scheduler_options="-l h_data=16G,h_rt=24:00:00,arch=intel*" \
--logdir="/u/project/cbearden/data/22qPrisma/qunex_studyfolder/processing/logs/manual" \
--array="yes" \
--sessions="Q_0278_12132016 Q_0324_04182018"



# make new batch file for sessions to rerun (n=4 + + Q_0278_12052019 incomplete)
#sessions="Q_0246_10142016 Q_0263_11072016 Q_0271_10182016 Q_0291_11042016 Q_0278_12052019"

/u/project/cbearden/data/scripts/tools/qunex_bin/hoffman_submit_qunex.sh \
--qunex_command="create_batch" \
--qunex_options=" --overwrite=yes --sessionsfolder=/u/project/cbearden/data/22qPrisma/qunex_studyfolder/sessions --sourcefiles=session_hcp.txt --targetfile=/u/project/cbearden/data/22qPrisma/qunex_studyfolder/processing/22qPrisma_batch_rerun_n7.txt --paramfile=/u/project/cbearden/data/22qPrisma/qunex_studyfolder/sessions/specs/22qPrisma_params.txt --sessions=Q_0246_10142016,Q_0263_11072016,Q_0271_10182016,Q_0291_11042016,Q_0278_12052019" \
--scheduler_options="-l h_data=4G,h_rt=4:00:00,arch=intel*" \
--logdir="/u/project/cbearden/data/22qPrisma/qunex_studyfolder/processing/logs/manual" \
--array="no"

## PreFreeSurfer
/u/project/cbearden/data/scripts/tools/qunex_bin/hoffman_submit_qunex.sh \
--qunex_command="hcp_pre_freesurfer" \
--qunex_options="--sessions=/u/project/cbearden/data/22qPrisma/qunex_studyfolder/processing/22qPrisma_batch_rerun_n7.txt --sessionsfolder=/u/project/cbearden/data/22qPrisma/qunex_studyfolder/sessions --parsessions=1 --overwrite=no" \
--scheduler_options="-l h_data=16G,h_rt=24:00:00,arch=intel*" \
--logdir="/u/project/cbearden/data/22qPrisma/qunex_studyfolder/processing/logs/manual" \
--array="yes" \
--sessions="Q_0246_10142016 Q_0263_11072016 Q_0271_10182016 Q_0291_11042016 Q_0278_12052019"

## FreeSurfer
/u/project/cbearden/data/scripts/tools/qunex_bin/hoffman_submit_qunex.sh \
--qunex_command="hcp_freesurfer" \
--qunex_options="--sessions=/u/project/cbearden/data/22qPrisma/qunex_studyfolder/processing/22qPrisma_batch_rerun_n7.txt --sessionsfolder=/u/project/cbearden/data/22qPrisma/qunex_studyfolder/sessions --parsessions=1 --overwrite=no" \
--scheduler_options="-l h_data=16G,h_rt=48:00:00,highp,arch=intel*" \
--logdir="/u/project/cbearden/data/22qPrisma/qunex_studyfolder/processing/logs/manual" \
--array="yes" \
--sessions="Q_0246_10142016 Q_0263_11072016 Q_0271_10182016 Q_0291_11042016 Q_0278_12052019"

## PostFreeSurfer
/u/project/cbearden/data/scripts/tools/qunex_bin/hoffman_submit_qunex.sh \
--qunex_command="hcp_post_freesurfer" \
--qunex_options="--sessions=/u/project/cbearden/data/22qPrisma/qunex_studyfolder/processing/22qPrisma_batch_rerun_n7.txt --sessionsfolder=/u/project/cbearden/data/22qPrisma/qunex_studyfolder/sessions --parsessions=1 --overwrite=no" \
--scheduler_options="-l h_data=16G,h_rt=24:00:00,arch=intel*" \
--logdir="/u/project/cbearden/data/22qPrisma/qunex_studyfolder/processing/logs/manual" \
--array="yes" \
--sessions="Q_0246_10142016 Q_0263_11072016 Q_0271_10182016 Q_0291_11042016 Q_0278_12052019"

## FMRI VOLUME
/u/project/cbearden/data/scripts/tools/qunex_bin/hoffman_submit_qunex.sh \
--qunex_command="hcp_fmri_volume" \
--qunex_options="--sessions=/u/project/cbearden/data/22qPrisma/qunex_studyfolder/processing/22qPrisma_batch_rerun_n7.txt --sessionsfolder=/u/project/cbearden/data/22qPrisma/qunex_studyfolder/sessions --parsessions=1 --overwrite=no" \
--scheduler_options="-l h_data=16G,h_rt=24:00:00,arch=intel*" \
--logdir="/u/project/cbearden/data/22qPrisma/qunex_studyfolder/processing/logs/manual" \
--array="yes" \
--sessions="Q_0246_10142016 Q_0263_11072016 Q_0271_10182016 Q_0291_11042016 Q_0278_12052019"

## FMRI SURFACE
/u/project/cbearden/data/scripts/tools/qunex_bin/hoffman_submit_qunex.sh \
--qunex_command="hcp_fmri_surface" \
--qunex_options="--sessions=/u/project/cbearden/data/22qPrisma/qunex_studyfolder/processing/22qPrisma_batch_rerun_n7.txt --sessionsfolder=/u/project/cbearden/data/22qPrisma/qunex_studyfolder/sessions --parsessions=1 --overwrite=no" \
--scheduler_options="-l h_data=16G,h_rt=24:00:00,arch=intel*" \
--logdir="/u/project/cbearden/data/22qPrisma/qunex_studyfolder/processing/logs/manual" \
--array="yes" \
--sessions="Q_0246_10142016 Q_0263_11072016 Q_0271_10182016 Q_0291_11042016 Q_0278_12052019"


#####################################################################
### BOLD QC
#####################################################################
for i in Q_*;do echo $i;cat $i/session_hcp.txt; for k in /u/project/cbearden/data/22qPrisma/qunex_studyfolder/sessions/${i}/hcp/${i}/MNINonLinear/Results/*;do display ${k}/fMRIQC/snapshots/*fMRIQC.wb_scene2.png;done; echo "---";done

# looks like AP/PA distortion correction in wrong direction 
# Q_0346_04102017 is a good example
# copy hcp to backup
cp -rv /u/project/cbearden/data/22qPrisma/qunex_studyfolder/sessions/Q_0346_04102017/hcp /u/project/cbearden/data/22qPrisma/qunex_studyfolder/sessions/Q_0346_04102017/hcp_bkup

# mv images to backup
mv /u/project/cbearden/data/22qPrisma/qunex_studyfolder/sessions/Q_0346_04102017/images /u/project/cbearden/data/22qPrisma/qunex_studyfolder/sessions/Q_0346_04102017/images_bkup

# delete preprocessed bold info
rm -rf /u/project/cbearden/data/22qPrisma/qunex_studyfolder/sessions/Q_0346_04102017/hcp/Q_0346_04102017/1
rm -rf /u/project/cbearden/data/22qPrisma/qunex_studyfolder/sessions/Q_0346_04102017/hcp/Q_0346_04102017/2
rm -rf /u/project/cbearden/data/22qPrisma/qunex_studyfolder/sessions/Q_0346_04102017/hcp/Q_0346_04102017/MNINonLinear/Results

# changed 22qPrisma_batch_cleaned_n114_fixedAPPA.txt _hcp_bold_unwarpdir

# re-run hcp bold steps

## FMRI VOLUME
/u/project/cbearden/data/scripts/tools/qunex_bin/hoffman_submit_qunex.sh \
--qunex_command="hcp_fmri_volume" \
--qunex_options="--sessions=/u/project/cbearden/data/22qPrisma/qunex_studyfolder/processing/22qPrisma_batch_cleaned_n114_fixedAPPA.txt --sessionsfolder=/u/project/cbearden/data/22qPrisma/qunex_studyfolder/sessions --parsessions=1 --overwrite=yes" \
--scheduler_options="-l h_data=16G,h_rt=24:00:00,arch=intel*" \
--logdir="/u/project/cbearden/data/22qPrisma/qunex_studyfolder/processing/logs/manual" \
--array="yes" \
--sessions="Q_0346_04102017"

## FMRI SURFACE
/u/project/cbearden/data/scripts/tools/qunex_bin/hoffman_submit_qunex.sh \
--qunex_command="hcp_fmri_surface" \
--qunex_options="--sessions=/u/project/cbearden/data/22qPrisma/qunex_studyfolder/processing/22qPrisma_batch_cleaned_n114_fixedAPPA.txt --sessionsfolder=/u/project/cbearden/data/22qPrisma/qunex_studyfolder/sessions --parsessions=1 --overwrite=yes" \
--scheduler_options="-l h_data=16G,h_rt=24:00:00,arch=intel*" \
--logdir="/u/project/cbearden/data/22qPrisma/qunex_studyfolder/processing/logs/manual" \
--array="yes" \
--sessions="Q_0346_04102017"

#####################################################################
### rerun bold with correct distortion correction
#####################################################################

# first delete previous preprocessed BOLD
cd /u/project/cbearden/data/22qPrisma/qunex_studyfolder/sessions/
for i in Q_*; do 
#rm -rfv /u/project/cbearden/data/22qPrisma/qunex_studyfolder/sessions/${i}/hcp/${i}/[0-9]
#rm -rfv /u/project/cbearden/data/22qPrisma/qunex_studyfolder/sessions/${i}/hcp/${i}/MNINonLinear/Results
done

# fix /u/project/cbearden/data/22qPrisma/qunex_studyfolder/sessions/specs/22qPrisma_params.txt 
# change to _hcp_bold_unwarpdir     : AP=-y|PA=y

## create batch file
/u/project/cbearden/data/scripts/tools/qunex_bin/hoffman_submit_qunex.sh \
--qunex_command="create_batch" \
--qunex_options=" --overwrite=yes --sessionsfolder=/u/project/cbearden/data/22qPrisma/qunex_studyfolder/sessions --sourcefiles=session_hcp.txt --targetfile=/u/project/cbearden/data/22qPrisma/qunex_studyfolder/processing/22qPrisma_batch_fixed_unwarpdir_n115.txt --paramfile=/u/project/cbearden/data/22qPrisma/qunex_studyfolder/sessions/specs/22qPrisma_params.txt --sessions=Q_0005_11072017,Q_0017_10022017,Q_0019_03022020,Q_0036_08082017,Q_0036_08312018,Q_0036_09302019,Q_0037_08152017,Q_0041_10092017,Q_0051_02032017,Q_0105_03112020,Q_0105_12032018,Q_0114_12052017,Q_0141_06122018,Q_0141_08052019,Q_0147_12112017,Q_0147_12112018,Q_0196_01082020,Q_0213_05012017,Q_0214_05012017,Q_0217_01242017,Q_0217_02192020,Q_0235_05252017,Q_0238_02202018,Q_0240_09192017,Q_0240_11162018,Q_0246_10092018,Q_0246_10102017,Q_0246_10142016,Q_0260_06192017,Q_0260_06242019,Q_0260_06252018,Q_0263_02252019,Q_0263_02262018,Q_0263_11072016,Q_0271_10182016,Q_0277_12132016,Q_0278_11292017,Q_0278_12052019,Q_0278_12132016,Q_0279_11302017,Q_0279_12052019,Q_0279_12132016,Q_0285_03212017,Q_0285_06062018,Q_0286_03212017,Q_0287_06062018,Q_0288_06062018,Q_0289_03212017,Q_0289_06062018,Q_0291_11042016,Q_0291_11302018,Q_0304_12202016,Q_0310_01252018,Q_0310_02132017,Q_0310_04292019,Q_0319_03192018,Q_0319_03282017,Q_0321_03192018,Q_0321_03272017,Q_0324_04182018,Q_0326_10202017,Q_0326_12062018,Q_0327_10192017,Q_0327_12072018,Q_0331_06102019,Q_0331_06212018,Q_0331_06272017,Q_0333_04142017,Q_0334_12012016,Q_0336_01102017,Q_0345_04122017,Q_0345_08152018,Q_0345_09112019,Q_0346_04102017,Q_0346_04102018,Q_0348_04212017,Q_0348_08152018,Q_0350_04192017,Q_0350_09142018,Q_0353_04182018,Q_0353_05022017,Q_0355_05312018,Q_0356_05312018,Q_0361_10212019,Q_0361_11202018,Q_0369_04182018,Q_0369_06182019,Q_0371_08042020,Q_0374_05252018,Q_0381_08072018,Q_0381_09102019,Q_0382_08282018,Q_0383_08282018,Q_0387_08242018,Q_0387_12032019,Q_0390_09042018,Q_0390_09302019,Q_0391_09252018,Q_0395_11062018,Q_0397_10172019,Q_0402_01112019,Q_0404_03112019,Q_0407_06122019,Q_0408_05172019,Q_0414_07172019,Q_0415_07292019,Q_0416_07292019,Q_0425_11052019,Q_0429_01092020,Q_0432_02142020,Q_0433_02262020,Q_0443_06282021,Q_0446_06152021,Q_0459_08192021,Q_0461_09112021" \
--scheduler_options="-l h_data=2G,h_rt=1:00:00" \
--logdir="/u/project/cbearden/data/22qPrisma/qunex_studyfolder/processing/logs/manual" \
--array="no" 

## FMRI VOLUME
/u/project/cbearden/data/scripts/tools/qunex_bin/hoffman_submit_qunex.sh \
--qunex_command="hcp_fmri_volume" \
--qunex_options="--sessions=/u/project/cbearden/data/22qPrisma/qunex_studyfolder/processing/22qPrisma_batch_fixed_unwarpdir_n115.txt --sessionsfolder=/u/project/cbearden/data/22qPrisma/qunex_studyfolder/sessions --parsessions=1 --overwrite=no" \
--scheduler_options="-l h_data=16G,h_rt=24:00:00,arch=intel*" \
--logdir="/u/project/cbearden/data/22qPrisma/qunex_studyfolder/processing/logs/manual" \
--array="yes" \
--sessions="Q_0005_11072017 Q_0017_10022017 Q_0019_03022020 Q_0036_08082017 Q_0036_08312018 Q_0036_09302019 Q_0037_08152017 Q_0041_10092017 Q_0051_02032017 Q_0105_03112020 Q_0105_12032018 Q_0114_12052017 Q_0141_06122018 Q_0141_08052019 Q_0147_12112017 Q_0147_12112018 Q_0196_01082020 Q_0213_05012017 Q_0214_05012017 Q_0217_01242017 Q_0217_02192020 Q_0235_05252017 Q_0238_02202018 Q_0240_09192017 Q_0240_11162018 Q_0246_10092018 Q_0246_10102017 Q_0246_10142016 Q_0260_06192017 Q_0260_06242019 Q_0260_06252018 Q_0263_02252019 Q_0263_02262018 Q_0263_11072016 Q_0271_10182016 Q_0277_12132016 Q_0278_11292017 Q_0278_12052019 Q_0278_12132016 Q_0279_11302017 Q_0279_12052019 Q_0279_12132016 Q_0285_03212017 Q_0285_06062018 Q_0286_03212017 Q_0287_06062018 Q_0288_06062018 Q_0289_03212017 Q_0289_06062018 Q_0291_11042016 Q_0291_11302018 Q_0304_12202016 Q_0310_01252018 Q_0310_02132017 Q_0310_04292019 Q_0319_03192018 Q_0319_03282017 Q_0321_03192018 Q_0321_03272017 Q_0324_04182018 Q_0326_10202017 Q_0326_12062018 Q_0327_10192017 Q_0327_12072018 Q_0331_06102019 Q_0331_06212018 Q_0331_06272017 Q_0333_04142017 Q_0334_12012016 Q_0336_01102017 Q_0345_04122017 Q_0345_08152018 Q_0345_09112019 Q_0346_04102017 Q_0346_04102018 Q_0348_04212017 Q_0348_08152018 Q_0350_04192017 Q_0350_09142018 Q_0353_04182018 Q_0353_05022017 Q_0355_05312018 Q_0356_05312018 Q_0361_10212019 Q_0361_11202018 Q_0369_04182018 Q_0369_06182019 Q_0371_08042020 Q_0374_05252018 Q_0381_08072018 Q_0381_09102019 Q_0382_08282018 Q_0383_08282018 Q_0387_08242018 Q_0387_12032019 Q_0390_09042018 Q_0390_09302019 Q_0391_09252018 Q_0395_11062018 Q_0397_10172019 Q_0402_01112019 Q_0404_03112019 Q_0407_06122019 Q_0408_05172019 Q_0414_07172019 Q_0415_07292019 Q_0416_07292019 Q_0425_11052019 Q_0429_01092020 Q_0432_02142020 Q_0433_02262020 Q_0443_06282021 Q_0446_06152021 Q_0459_08192021 Q_0461_09112021"

## FMRI SURFACE
/u/project/cbearden/data/scripts/tools/qunex_bin/hoffman_submit_qunex.sh \
--qunex_command="hcp_fmri_surface" \
--qunex_options="--sessions=/u/project/cbearden/data/22qPrisma/qunex_studyfolder/processing/22qPrisma_batch_fixed_unwarpdir_n115.txt --sessionsfolder=/u/project/cbearden/data/22qPrisma/qunex_studyfolder/sessions --parsessions=1 --overwrite=no" \
--scheduler_options="-l h_data=16G,h_rt=24:00:00,arch=intel*" \
--logdir="/u/project/cbearden/data/22qPrisma/qunex_studyfolder/processing/logs/manual" \
--array="yes" \
--sessions="Q_0005_11072017 Q_0017_10022017 Q_0019_03022020 Q_0036_08082017 Q_0036_08312018 Q_0036_09302019 Q_0037_08152017 Q_0041_10092017 Q_0051_02032017 Q_0105_03112020 Q_0105_12032018 Q_0114_12052017 Q_0141_06122018 Q_0141_08052019 Q_0147_12112017 Q_0147_12112018 Q_0196_01082020 Q_0213_05012017 Q_0214_05012017 Q_0217_01242017 Q_0217_02192020 Q_0235_05252017 Q_0238_02202018 Q_0240_09192017 Q_0240_11162018 Q_0246_10092018 Q_0246_10102017 Q_0246_10142016 Q_0260_06192017 Q_0260_06242019 Q_0260_06252018 Q_0263_02252019 Q_0263_02262018 Q_0263_11072016 Q_0271_10182016 Q_0277_12132016 Q_0278_11292017 Q_0278_12052019 Q_0278_12132016 Q_0279_11302017 Q_0279_12052019 Q_0279_12132016 Q_0285_03212017 Q_0285_06062018 Q_0286_03212017 Q_0287_06062018 Q_0288_06062018 Q_0289_03212017 Q_0289_06062018 Q_0291_11042016 Q_0291_11302018 Q_0304_12202016 Q_0310_01252018 Q_0310_02132017 Q_0310_04292019 Q_0319_03192018 Q_0319_03282017 Q_0321_03192018 Q_0321_03272017 Q_0324_04182018 Q_0326_10202017 Q_0326_12062018 Q_0327_10192017 Q_0327_12072018 Q_0331_06102019 Q_0331_06212018 Q_0331_06272017 Q_0333_04142017 Q_0334_12012016 Q_0336_01102017 Q_0345_04122017 Q_0345_08152018 Q_0345_09112019 Q_0346_04102017 Q_0346_04102018 Q_0348_04212017 Q_0348_08152018 Q_0350_04192017 Q_0350_09142018 Q_0353_04182018 Q_0353_05022017 Q_0355_05312018 Q_0356_05312018 Q_0361_10212019 Q_0361_11202018 Q_0369_04182018 Q_0369_06182019 Q_0371_08042020 Q_0374_05252018 Q_0381_08072018 Q_0381_09102019 Q_0382_08282018 Q_0383_08282018 Q_0387_08242018 Q_0387_12032019 Q_0390_09042018 Q_0390_09302019 Q_0391_09252018 Q_0395_11062018 Q_0397_10172019 Q_0402_01112019 Q_0404_03112019 Q_0407_06122019 Q_0408_05172019 Q_0414_07172019 Q_0415_07292019 Q_0416_07292019 Q_0425_11052019 Q_0429_01092020 Q_0432_02142020 Q_0433_02262020 Q_0443_06282021 Q_0446_06152021 Q_0459_08192021 Q_0461_09112021"


#####################################################################
### BOLD QC
#####################################################################
cd /u/project/cbearden/data/22qPrisma/sessions/
for i in Q_*; do echo $i; for j in ${i}/hcp/${i}/MNINonLinear/Results/*; do echo $j; display ${j}/fMRIQC/snapshots/*scene2.png;done;done


#####################################################################
### re-run BOLD post-processing
#####################################################################
# https://bitbucket.org/oriadev/qunex/wiki/UsageDocs/BOLDPreprocessing.md
# https://bitbucket.org/oriadev/qunex/wiki/UsageDocs/MovementScrubbing.md

## map hcp data
/u/project/cbearden/data/scripts/tools/qunex_bin/hoffman_submit_qunex.sh \
--qunex_command="map_hcp_data" \
--qunex_options="--overwrite=yes --bolds=resting --sessions=/u/project/cbearden/data/22qPrisma/qunex_studyfolder/processing/22qPrisma_batch_fixed_unwarpdir_n115.txt --sessionsfolder=/u/project/cbearden/data/22qPrisma/qunex_studyfolder/sessions" \
--scheduler_options="-l h_data=20G,h_rt=1:00:00,arch=intel*" \
--logdir="/u/project/cbearden/data/22qPrisma/qunex_studyfolder/processing/logs/manual" \
--array="yes" \
--sessions="Q_0005_11072017 Q_0017_10022017 Q_0019_03022020 Q_0036_08082017 Q_0036_08312018 Q_0036_09302019 Q_0037_08152017 Q_0041_10092017 Q_0051_02032017 Q_0105_03112020 Q_0105_12032018 Q_0114_12052017 Q_0141_06122018 Q_0141_08052019 Q_0147_12112017 Q_0147_12112018 Q_0196_01082020 Q_0213_05012017 Q_0214_05012017 Q_0217_01242017 Q_0217_02192020 Q_0235_05252017 Q_0238_02202018 Q_0240_09192017 Q_0240_11162018 Q_0246_10092018 Q_0246_10102017 Q_0246_10142016 Q_0260_06192017 Q_0260_06242019 Q_0260_06252018 Q_0263_02252019 Q_0263_02262018 Q_0263_11072016 Q_0271_10182016 Q_0277_12132016 Q_0278_11292017 Q_0278_12052019 Q_0278_12132016 Q_0279_11302017 Q_0279_12052019 Q_0279_12132016 Q_0285_03212017 Q_0285_06062018 Q_0286_03212017 Q_0287_06062018 Q_0288_06062018 Q_0289_03212017 Q_0289_06062018 Q_0291_11042016 Q_0291_11302018 Q_0304_12202016 Q_0310_01252018 Q_0310_02132017 Q_0310_04292019 Q_0319_03192018 Q_0319_03282017 Q_0321_03192018 Q_0321_03272017 Q_0324_04182018 Q_0326_10202017 Q_0326_12062018 Q_0327_10192017 Q_0327_12072018 Q_0331_06102019 Q_0331_06212018 Q_0331_06272017 Q_0333_04142017 Q_0334_12012016 Q_0336_01102017 Q_0345_04122017 Q_0345_08152018 Q_0345_09112019 Q_0346_04102017 Q_0346_04102018 Q_0348_04212017 Q_0348_08152018 Q_0350_04192017 Q_0350_09142018 Q_0353_04182018 Q_0353_05022017 Q_0355_05312018 Q_0356_05312018 Q_0361_10212019 Q_0361_11202018 Q_0369_04182018 Q_0369_06182019 Q_0371_08042020 Q_0374_05252018 Q_0381_08072018 Q_0381_09102019 Q_0382_08282018 Q_0383_08282018 Q_0387_08242018 Q_0387_12032019 Q_0390_09042018 Q_0390_09302019 Q_0391_09252018 Q_0395_11062018 Q_0397_10172019 Q_0402_01112019 Q_0404_03112019 Q_0407_06122019 Q_0408_05172019 Q_0414_07172019 Q_0415_07292019 Q_0416_07292019 Q_0425_11052019 Q_0429_01092020 Q_0432_02142020 Q_0433_02262020 Q_0443_06282021 Q_0446_06152021 Q_0459_08192021 Q_0461_09112021"

## brain masks
/u/project/cbearden/data/scripts/tools/qunex_bin/hoffman_submit_qunex.sh \
--qunex_command="create_bold_brain_masks" \
--qunex_options="--overwrite=yes --bolds=resting --sessions=/u/project/cbearden/data/22qPrisma/qunex_studyfolder/processing/22qPrisma_batch_fixed_unwarpdir_n115.txt --sessionsfolder=/u/project/cbearden/data/22qPrisma/qunex_studyfolder/sessions" \
--scheduler_options="-l h_data=20G,h_rt=1:00:00,arch=intel*" \
--logdir="/u/project/cbearden/data/22qPrisma/qunex_studyfolder/processing/logs/manual" \
--array="yes" \
--sessions="Q_0005_11072017 Q_0017_10022017 Q_0019_03022020 Q_0036_08082017 Q_0036_08312018 Q_0036_09302019 Q_0037_08152017 Q_0041_10092017 Q_0051_02032017 Q_0105_03112020 Q_0105_12032018 Q_0114_12052017 Q_0141_06122018 Q_0141_08052019 Q_0147_12112017 Q_0147_12112018 Q_0196_01082020 Q_0213_05012017 Q_0214_05012017 Q_0217_01242017 Q_0217_02192020 Q_0235_05252017 Q_0238_02202018 Q_0240_09192017 Q_0240_11162018 Q_0246_10092018 Q_0246_10102017 Q_0246_10142016 Q_0260_06192017 Q_0260_06242019 Q_0260_06252018 Q_0263_02252019 Q_0263_02262018 Q_0263_11072016 Q_0271_10182016 Q_0277_12132016 Q_0278_11292017 Q_0278_12052019 Q_0278_12132016 Q_0279_11302017 Q_0279_12052019 Q_0279_12132016 Q_0285_03212017 Q_0285_06062018 Q_0286_03212017 Q_0287_06062018 Q_0288_06062018 Q_0289_03212017 Q_0289_06062018 Q_0291_11042016 Q_0291_11302018 Q_0304_12202016 Q_0310_01252018 Q_0310_02132017 Q_0310_04292019 Q_0319_03192018 Q_0319_03282017 Q_0321_03192018 Q_0321_03272017 Q_0324_04182018 Q_0326_10202017 Q_0326_12062018 Q_0327_10192017 Q_0327_12072018 Q_0331_06102019 Q_0331_06212018 Q_0331_06272017 Q_0333_04142017 Q_0334_12012016 Q_0336_01102017 Q_0345_04122017 Q_0345_08152018 Q_0345_09112019 Q_0346_04102017 Q_0346_04102018 Q_0348_04212017 Q_0348_08152018 Q_0350_04192017 Q_0350_09142018 Q_0353_04182018 Q_0353_05022017 Q_0355_05312018 Q_0356_05312018 Q_0361_10212019 Q_0361_11202018 Q_0369_04182018 Q_0369_06182019 Q_0371_08042020 Q_0374_05252018 Q_0381_08072018 Q_0381_09102019 Q_0382_08282018 Q_0383_08282018 Q_0387_08242018 Q_0387_12032019 Q_0390_09042018 Q_0390_09302019 Q_0391_09252018 Q_0395_11062018 Q_0397_10172019 Q_0402_01112019 Q_0404_03112019 Q_0407_06122019 Q_0408_05172019 Q_0414_07172019 Q_0415_07292019 Q_0416_07292019 Q_0425_11052019 Q_0429_01092020 Q_0432_02142020 Q_0433_02262020 Q_0443_06282021 Q_0446_06152021 Q_0459_08192021 Q_0461_09112021"

## bold stats
/u/project/cbearden/data/scripts/tools/qunex_bin/hoffman_submit_qunex.sh \
--qunex_command="compute_bold_stats" \
--qunex_options="--overwrite=yes --bolds=resting --sessions=/u/project/cbearden/data/22qPrisma/qunex_studyfolder/processing/22qPrisma_batch_fixed_unwarpdir_n115.txt --sessionsfolder=/u/project/cbearden/data/22qPrisma/qunex_studyfolder/sessions" \
--scheduler_options="-l h_data=20G,h_rt=1:00:00,arch=intel*" \
--logdir="/u/project/cbearden/data/22qPrisma/qunex_studyfolder/processing/logs/manual" \
--array="yes" \
--sessions="Q_0005_11072017 Q_0017_10022017 Q_0019_03022020 Q_0036_08082017 Q_0036_08312018 Q_0036_09302019 Q_0037_08152017 Q_0041_10092017 Q_0051_02032017 Q_0105_03112020 Q_0105_12032018 Q_0114_12052017 Q_0141_06122018 Q_0141_08052019 Q_0147_12112017 Q_0147_12112018 Q_0196_01082020 Q_0213_05012017 Q_0214_05012017 Q_0217_01242017 Q_0217_02192020 Q_0235_05252017 Q_0238_02202018 Q_0240_09192017 Q_0240_11162018 Q_0246_10092018 Q_0246_10102017 Q_0246_10142016 Q_0260_06192017 Q_0260_06242019 Q_0260_06252018 Q_0263_02252019 Q_0263_02262018 Q_0263_11072016 Q_0271_10182016 Q_0277_12132016 Q_0278_11292017 Q_0278_12052019 Q_0278_12132016 Q_0279_11302017 Q_0279_12052019 Q_0279_12132016 Q_0285_03212017 Q_0285_06062018 Q_0286_03212017 Q_0287_06062018 Q_0288_06062018 Q_0289_03212017 Q_0289_06062018 Q_0291_11042016 Q_0291_11302018 Q_0304_12202016 Q_0310_01252018 Q_0310_02132017 Q_0310_04292019 Q_0319_03192018 Q_0319_03282017 Q_0321_03192018 Q_0321_03272017 Q_0324_04182018 Q_0326_10202017 Q_0326_12062018 Q_0327_10192017 Q_0327_12072018 Q_0331_06102019 Q_0331_06212018 Q_0331_06272017 Q_0333_04142017 Q_0334_12012016 Q_0336_01102017 Q_0345_04122017 Q_0345_08152018 Q_0345_09112019 Q_0346_04102017 Q_0346_04102018 Q_0348_04212017 Q_0348_08152018 Q_0350_04192017 Q_0350_09142018 Q_0353_04182018 Q_0353_05022017 Q_0355_05312018 Q_0356_05312018 Q_0361_10212019 Q_0361_11202018 Q_0369_04182018 Q_0369_06182019 Q_0371_08042020 Q_0374_05252018 Q_0381_08072018 Q_0381_09102019 Q_0382_08282018 Q_0383_08282018 Q_0387_08242018 Q_0387_12032019 Q_0390_09042018 Q_0390_09302019 Q_0391_09252018 Q_0395_11062018 Q_0397_10172019 Q_0402_01112019 Q_0404_03112019 Q_0407_06122019 Q_0408_05172019 Q_0414_07172019 Q_0415_07292019 Q_0416_07292019 Q_0425_11052019 Q_0429_01092020 Q_0432_02142020 Q_0433_02262020 Q_0443_06282021 Q_0446_06152021 Q_0459_08192021 Q_0461_09112021"

## create stats report
/u/project/cbearden/data/scripts/tools/qunex_bin/hoffman_submit_qunex.sh \
--qunex_command="create_stats_report" \
--qunex_options="--overwrite=yes --bolds=resting --sessions=/u/project/cbearden/data/22qPrisma/qunex_studyfolder/processing/22qPrisma_batch_fixed_unwarpdir_n115.txt --sessionsfolder=/u/project/cbearden/data/22qPrisma/qunex_studyfolder/sessions" \
--scheduler_options="-l h_data=20G,h_rt=1:00:00,arch=intel*" \
--logdir="/u/project/cbearden/data/22qPrisma/qunex_studyfolder/processing/logs/manual" \
--array="yes" \
--sessions="Q_0005_11072017 Q_0017_10022017 Q_0019_03022020 Q_0036_08082017 Q_0036_08312018 Q_0036_09302019 Q_0037_08152017 Q_0041_10092017 Q_0051_02032017 Q_0105_03112020 Q_0105_12032018 Q_0114_12052017 Q_0141_06122018 Q_0141_08052019 Q_0147_12112017 Q_0147_12112018 Q_0196_01082020 Q_0213_05012017 Q_0214_05012017 Q_0217_01242017 Q_0217_02192020 Q_0235_05252017 Q_0238_02202018 Q_0240_09192017 Q_0240_11162018 Q_0246_10092018 Q_0246_10102017 Q_0246_10142016 Q_0260_06192017 Q_0260_06242019 Q_0260_06252018 Q_0263_02252019 Q_0263_02262018 Q_0263_11072016 Q_0271_10182016 Q_0277_12132016 Q_0278_11292017 Q_0278_12052019 Q_0278_12132016 Q_0279_11302017 Q_0279_12052019 Q_0279_12132016 Q_0285_03212017 Q_0285_06062018 Q_0286_03212017 Q_0287_06062018 Q_0288_06062018 Q_0289_03212017 Q_0289_06062018 Q_0291_11042016 Q_0291_11302018 Q_0304_12202016 Q_0310_01252018 Q_0310_02132017 Q_0310_04292019 Q_0319_03192018 Q_0319_03282017 Q_0321_03192018 Q_0321_03272017 Q_0324_04182018 Q_0326_10202017 Q_0326_12062018 Q_0327_10192017 Q_0327_12072018 Q_0331_06102019 Q_0331_06212018 Q_0331_06272017 Q_0333_04142017 Q_0334_12012016 Q_0336_01102017 Q_0345_04122017 Q_0345_08152018 Q_0345_09112019 Q_0346_04102017 Q_0346_04102018 Q_0348_04212017 Q_0348_08152018 Q_0350_04192017 Q_0350_09142018 Q_0353_04182018 Q_0353_05022017 Q_0355_05312018 Q_0356_05312018 Q_0361_10212019 Q_0361_11202018 Q_0369_04182018 Q_0369_06182019 Q_0371_08042020 Q_0374_05252018 Q_0381_08072018 Q_0381_09102019 Q_0382_08282018 Q_0383_08282018 Q_0387_08242018 Q_0387_12032019 Q_0390_09042018 Q_0390_09302019 Q_0391_09252018 Q_0395_11062018 Q_0397_10172019 Q_0402_01112019 Q_0404_03112019 Q_0407_06122019 Q_0408_05172019 Q_0414_07172019 Q_0415_07292019 Q_0416_07292019 Q_0425_11052019 Q_0429_01092020 Q_0432_02142020 Q_0433_02262020 Q_0443_06282021 Q_0446_06152021 Q_0459_08192021 Q_0461_09112021"

## extract nuisance signal
/u/project/cbearden/data/scripts/tools/qunex_bin/hoffman_submit_qunex.sh \
--qunex_command="extract_nuisance_signal" \
--qunex_options="--overwrite=yes --bolds=resting --sessions=/u/project/cbearden/data/22qPrisma/qunex_studyfolder/processing/22qPrisma_batch_fixed_unwarpdir_n115.txt --sessionsfolder=/u/project/cbearden/data/22qPrisma/qunex_studyfolder/sessions" \
--scheduler_options="-l h_data=20G,h_rt=1:00:00,arch=intel*" \
--logdir="/u/project/cbearden/data/22qPrisma/qunex_studyfolder/processing/logs/manual" \
--array="yes" \
--sessions="Q_0005_11072017 Q_0017_10022017 Q_0019_03022020 Q_0036_08082017 Q_0036_08312018 Q_0036_09302019 Q_0037_08152017 Q_0041_10092017 Q_0051_02032017 Q_0105_03112020 Q_0105_12032018 Q_0114_12052017 Q_0141_06122018 Q_0141_08052019 Q_0147_12112017 Q_0147_12112018 Q_0196_01082020 Q_0213_05012017 Q_0214_05012017 Q_0217_01242017 Q_0217_02192020 Q_0235_05252017 Q_0238_02202018 Q_0240_09192017 Q_0240_11162018 Q_0246_10092018 Q_0246_10102017 Q_0246_10142016 Q_0260_06192017 Q_0260_06242019 Q_0260_06252018 Q_0263_02252019 Q_0263_02262018 Q_0263_11072016 Q_0271_10182016 Q_0277_12132016 Q_0278_11292017 Q_0278_12052019 Q_0278_12132016 Q_0279_11302017 Q_0279_12052019 Q_0279_12132016 Q_0285_03212017 Q_0285_06062018 Q_0286_03212017 Q_0287_06062018 Q_0288_06062018 Q_0289_03212017 Q_0289_06062018 Q_0291_11042016 Q_0291_11302018 Q_0304_12202016 Q_0310_01252018 Q_0310_02132017 Q_0310_04292019 Q_0319_03192018 Q_0319_03282017 Q_0321_03192018 Q_0321_03272017 Q_0324_04182018 Q_0326_10202017 Q_0326_12062018 Q_0327_10192017 Q_0327_12072018 Q_0331_06102019 Q_0331_06212018 Q_0331_06272017 Q_0333_04142017 Q_0334_12012016 Q_0336_01102017 Q_0345_04122017 Q_0345_08152018 Q_0345_09112019 Q_0346_04102017 Q_0346_04102018 Q_0348_04212017 Q_0348_08152018 Q_0350_04192017 Q_0350_09142018 Q_0353_04182018 Q_0353_05022017 Q_0355_05312018 Q_0356_05312018 Q_0361_10212019 Q_0361_11202018 Q_0369_04182018 Q_0369_06182019 Q_0371_08042020 Q_0374_05252018 Q_0381_08072018 Q_0381_09102019 Q_0382_08282018 Q_0383_08282018 Q_0387_08242018 Q_0387_12032019 Q_0390_09042018 Q_0390_09302019 Q_0391_09252018 Q_0395_11062018 Q_0397_10172019 Q_0402_01112019 Q_0404_03112019 Q_0407_06122019 Q_0408_05172019 Q_0414_07172019 Q_0415_07292019 Q_0416_07292019 Q_0425_11052019 Q_0429_01092020 Q_0432_02142020 Q_0433_02262020 Q_0443_06282021 Q_0446_06152021 Q_0459_08192021 Q_0461_09112021"

## preprocess bold CIFTI no GSR
/u/project/cbearden/data/scripts/tools/qunex_bin/hoffman_submit_qunex.sh \
--qunex_command="preprocess_bold" \
--qunex_options="--overwrite=yes --bolds=resting --bold_actions=s,h,r,c,l --bold_nuisance=m,V,WM,1d --image_target=dtseries --sessions=/u/project/cbearden/data/22qPrisma/qunex_studyfolder/processing/22qPrisma_batch_fixed_unwarpdir_n115.txt --sessionsfolder=/u/project/cbearden/data/22qPrisma/qunex_studyfolder/sessions" \
--scheduler_options="-l h_data=20G,h_rt=4:00:00,arch=intel*" \
--logdir="/u/project/cbearden/data/22qPrisma/qunex_studyfolder/processing/logs/manual" \
--array="yes" \
--sessions="Q_0005_11072017 Q_0017_10022017 Q_0019_03022020 Q_0036_08082017 Q_0036_08312018 Q_0036_09302019 Q_0037_08152017 Q_0041_10092017 Q_0051_02032017 Q_0105_03112020 Q_0105_12032018 Q_0114_12052017 Q_0141_06122018 Q_0141_08052019 Q_0147_12112017 Q_0147_12112018 Q_0196_01082020 Q_0213_05012017 Q_0214_05012017 Q_0217_01242017 Q_0217_02192020 Q_0235_05252017 Q_0238_02202018 Q_0240_09192017 Q_0240_11162018 Q_0246_10092018 Q_0246_10102017 Q_0246_10142016 Q_0260_06192017 Q_0260_06242019 Q_0260_06252018 Q_0263_02252019 Q_0263_02262018 Q_0263_11072016 Q_0271_10182016 Q_0277_12132016 Q_0278_11292017 Q_0278_12052019 Q_0278_12132016 Q_0279_11302017 Q_0279_12052019 Q_0279_12132016 Q_0285_03212017 Q_0285_06062018 Q_0286_03212017 Q_0287_06062018 Q_0288_06062018 Q_0289_03212017 Q_0289_06062018 Q_0291_11042016 Q_0291_11302018 Q_0304_12202016 Q_0310_01252018 Q_0310_02132017 Q_0310_04292019 Q_0319_03192018 Q_0319_03282017 Q_0321_03192018 Q_0321_03272017 Q_0324_04182018 Q_0326_10202017 Q_0326_12062018 Q_0327_10192017 Q_0327_12072018 Q_0331_06102019 Q_0331_06212018 Q_0331_06272017 Q_0333_04142017 Q_0334_12012016 Q_0336_01102017 Q_0345_04122017 Q_0345_08152018 Q_0345_09112019 Q_0346_04102017 Q_0346_04102018 Q_0348_04212017 Q_0348_08152018 Q_0350_04192017 Q_0350_09142018 Q_0353_04182018 Q_0353_05022017 Q_0355_05312018 Q_0356_05312018 Q_0361_10212019 Q_0361_11202018 Q_0369_04182018 Q_0369_06182019 Q_0371_08042020 Q_0374_05252018 Q_0381_08072018 Q_0381_09102019 Q_0382_08282018 Q_0383_08282018 Q_0387_08242018 Q_0387_12032019 Q_0390_09042018 Q_0390_09302019 Q_0391_09252018 Q_0395_11062018 Q_0397_10172019 Q_0402_01112019 Q_0404_03112019 Q_0407_06122019 Q_0408_05172019 Q_0414_07172019 Q_0415_07292019 Q_0416_07292019 Q_0425_11052019 Q_0429_01092020 Q_0432_02142020 Q_0433_02262020 Q_0443_06282021 Q_0446_06152021 Q_0459_08192021 Q_0461_09112021"

## preprocess bold CIFTI GSR
/u/project/cbearden/data/scripts/tools/qunex_bin/hoffman_submit_qunex.sh \
--qunex_command="preprocess_bold" \
--qunex_options="--overwrite=yes --bolds=resting --bold_actions=s,h,r,c,l --bold_nuisance=m,V,WM,WB,1d --image_target=dtseries  --sessions=/u/project/cbearden/data/22qPrisma/qunex_studyfolder/processing/22qPrisma_batch_fixed_unwarpdir_n115.txt --sessionsfolder=/u/project/cbearden/data/22qPrisma/qunex_studyfolder/sessions" \
--scheduler_options="-l h_data=20G,h_rt=4:00:00,arch=intel*" \
--logdir="/u/project/cbearden/data/22qPrisma/qunex_studyfolder/processing/logs/manual" \
--array="yes" \
--sessions="Q_0005_11072017 Q_0017_10022017 Q_0019_03022020 Q_0036_08082017 Q_0036_08312018 Q_0036_09302019 Q_0037_08152017 Q_0041_10092017 Q_0051_02032017 Q_0105_03112020 Q_0105_12032018 Q_0114_12052017 Q_0141_06122018 Q_0141_08052019 Q_0147_12112017 Q_0147_12112018 Q_0196_01082020 Q_0213_05012017 Q_0214_05012017 Q_0217_01242017 Q_0217_02192020 Q_0235_05252017 Q_0238_02202018 Q_0240_09192017 Q_0240_11162018 Q_0246_10092018 Q_0246_10102017 Q_0246_10142016 Q_0260_06192017 Q_0260_06242019 Q_0260_06252018 Q_0263_02252019 Q_0263_02262018 Q_0263_11072016 Q_0271_10182016 Q_0277_12132016 Q_0278_11292017 Q_0278_12052019 Q_0278_12132016 Q_0279_11302017 Q_0279_12052019 Q_0279_12132016 Q_0285_03212017 Q_0285_06062018 Q_0286_03212017 Q_0287_06062018 Q_0288_06062018 Q_0289_03212017 Q_0289_06062018 Q_0291_11042016 Q_0291_11302018 Q_0304_12202016 Q_0310_01252018 Q_0310_02132017 Q_0310_04292019 Q_0319_03192018 Q_0319_03282017 Q_0321_03192018 Q_0321_03272017 Q_0324_04182018 Q_0326_10202017 Q_0326_12062018 Q_0327_10192017 Q_0327_12072018 Q_0331_06102019 Q_0331_06212018 Q_0331_06272017 Q_0333_04142017 Q_0334_12012016 Q_0336_01102017 Q_0345_04122017 Q_0345_08152018 Q_0345_09112019 Q_0346_04102017 Q_0346_04102018 Q_0348_04212017 Q_0348_08152018 Q_0350_04192017 Q_0350_09142018 Q_0353_04182018 Q_0353_05022017 Q_0355_05312018 Q_0356_05312018 Q_0361_10212019 Q_0361_11202018 Q_0369_04182018 Q_0369_06182019 Q_0371_08042020 Q_0374_05252018 Q_0381_08072018 Q_0381_09102019 Q_0382_08282018 Q_0383_08282018 Q_0387_08242018 Q_0387_12032019 Q_0390_09042018 Q_0390_09302019 Q_0391_09252018 Q_0395_11062018 Q_0397_10172019 Q_0402_01112019 Q_0404_03112019 Q_0407_06122019 Q_0408_05172019 Q_0414_07172019 Q_0415_07292019 Q_0416_07292019 Q_0425_11052019 Q_0429_01092020 Q_0432_02142020 Q_0433_02262020 Q_0443_06282021 Q_0446_06152021 Q_0459_08192021 Q_0461_09112021"

#####################################################################
### seed-based BOLD functional connectivity
#####################################################################
# https://bitbucket.org/oriadev/qunex/wiki/UsageDocs/BOLDFunctionalConnectivity.md

# subcortical seeds -- bandpass, GSR, reading boldn for bold rest from session_hcp.txt
# bold1
sessions="Q_0005_11072017 Q_0017_10022017 Q_0019_03022020 Q_0036_08082017 Q_0036_08312018 Q_0036_09302019 Q_0037_08152017 Q_0041_10092017 Q_0051_02032017 Q_0105_03112020 Q_0105_12032018 Q_0114_12052017 Q_0141_06122018 Q_0141_08052019 Q_0147_12112017 Q_0147_12112018 Q_0196_01082020 Q_0213_05012017 Q_0214_05012017 Q_0217_01242017 Q_0217_02192020 Q_0235_05252017 Q_0238_02202018 Q_0240_09192017 Q_0240_11162018 Q_0246_10092018 Q_0246_10102017 Q_0246_10142016 Q_0260_06192017 Q_0260_06242019 Q_0260_06252018 Q_0263_02252019 Q_0263_02262018 Q_0263_11072016 Q_0271_10182016 Q_0277_12132016 Q_0278_11292017 Q_0278_12052019 Q_0278_12132016 Q_0279_11302017 Q_0279_12052019 Q_0279_12132016 Q_0285_03212017 Q_0285_06062018 Q_0286_03212017 Q_0287_06062018 Q_0288_06062018 Q_0289_03212017 Q_0289_06062018 Q_0291_11042016 Q_0291_11302018 Q_0304_12202016 Q_0310_01252018 Q_0310_02132017 Q_0310_04292019 Q_0319_03192018 Q_0319_03282017 Q_0321_03192018 Q_0321_03272017 Q_0324_04182018 Q_0326_10202017 Q_0326_12062018 Q_0327_10192017 Q_0327_12072018 Q_0331_06102019 Q_0331_06212018 Q_0331_06272017 Q_0333_04142017 Q_0334_12012016 Q_0336_01102017 Q_0345_04122017 Q_0345_08152018 Q_0345_09112019 Q_0346_04102017 Q_0346_04102018 Q_0348_04212017 Q_0348_08152018 Q_0350_04192017 Q_0350_09142018 Q_0353_04182018 Q_0353_05022017 Q_0355_05312018 Q_0356_05312018 Q_0361_10212019 Q_0361_11202018 Q_0369_04182018 Q_0369_06182019 Q_0371_08042020 Q_0374_05252018 Q_0381_08072018 Q_0381_09102019 Q_0382_08282018 Q_0383_08282018 Q_0387_08242018 Q_0387_12032019 Q_0390_09042018 Q_0390_09302019 Q_0391_09252018 Q_0395_11062018 Q_0397_10172019 Q_0402_01112019 Q_0404_03112019 Q_0407_06122019 Q_0408_05172019 Q_0414_07172019 Q_0415_07292019 Q_0416_07292019 Q_0425_11052019 Q_0429_01092020 Q_0432_02142020 Q_0433_02262020 Q_0443_06282021 Q_0446_06152021 Q_0459_08192021 Q_0461_09112021"
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
sessions="Q_0005_11072017 Q_0017_10022017 Q_0019_03022020 Q_0036_08082017 Q_0036_08312018 Q_0036_09302019 Q_0037_08152017 Q_0041_10092017 Q_0051_02032017 Q_0105_03112020 Q_0105_12032018 Q_0114_12052017 Q_0141_06122018 Q_0141_08052019 Q_0147_12112017 Q_0147_12112018 Q_0196_01082020 Q_0213_05012017 Q_0214_05012017 Q_0217_01242017 Q_0217_02192020 Q_0235_05252017 Q_0238_02202018 Q_0240_09192017 Q_0240_11162018 Q_0246_10092018 Q_0246_10102017 Q_0246_10142016 Q_0260_06192017 Q_0260_06242019 Q_0260_06252018 Q_0263_02252019 Q_0263_02262018 Q_0263_11072016 Q_0271_10182016 Q_0277_12132016 Q_0278_11292017 Q_0278_12052019 Q_0278_12132016 Q_0279_11302017 Q_0279_12052019 Q_0279_12132016 Q_0285_03212017 Q_0285_06062018 Q_0286_03212017 Q_0287_06062018 Q_0288_06062018 Q_0289_03212017 Q_0289_06062018 Q_0291_11042016 Q_0291_11302018 Q_0304_12202016 Q_0310_01252018 Q_0310_02132017 Q_0310_04292019 Q_0319_03192018 Q_0319_03282017 Q_0321_03192018 Q_0321_03272017 Q_0324_04182018 Q_0326_10202017 Q_0326_12062018 Q_0327_10192017 Q_0327_12072018 Q_0331_06102019 Q_0331_06212018 Q_0331_06272017 Q_0333_04142017 Q_0334_12012016 Q_0336_01102017 Q_0345_04122017 Q_0345_08152018 Q_0345_09112019 Q_0346_04102017 Q_0346_04102018 Q_0348_04212017 Q_0348_08152018 Q_0350_04192017 Q_0350_09142018 Q_0353_04182018 Q_0353_05022017 Q_0355_05312018 Q_0356_05312018 Q_0361_10212019 Q_0361_11202018 Q_0369_04182018 Q_0369_06182019 Q_0371_08042020 Q_0374_05252018 Q_0381_08072018 Q_0381_09102019 Q_0382_08282018 Q_0383_08282018 Q_0387_08242018 Q_0387_12032019 Q_0390_09042018 Q_0390_09302019 Q_0391_09252018 Q_0395_11062018 Q_0397_10172019 Q_0402_01112019 Q_0404_03112019 Q_0407_06122019 Q_0408_05172019 Q_0414_07172019 Q_0415_07292019 Q_0416_07292019 Q_0425_11052019 Q_0429_01092020 Q_0432_02142020 Q_0433_02262020 Q_0443_06282021 Q_0446_06152021 Q_0459_08192021 Q_0461_09112021"
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
### edit BOLD names in session_hcp.txt 
#####################################################################

# originally AP and PA bold both coded as "resting"
# want to change to restingAP and restingPA so that subsequent scripts can more easily differentiate 
# will make BOLD post-processing code above obsolete (need to change --bolds)
cd /u/project/cbearden/data/22qPrisma/qunex_studyfolder/sessions
for i in Q_*; do
mv ${i}/session_hcp.txt ${i}/session_hcp_deprecated.txt
cat ${i}/session_hcp_deprecated.txt | sed s/resting\:\ phenc\(AP\)\:rfMRI_REST_AP/restingAP\:\ phenc\(AP\)\:rfMRI_REST_AP/g | sed s/resting\:\ phenc\(PA\)\:rfMRI_REST_PA/restingPA\:\ phenc\(PA\)\:rfMRI_REST_PA/g > ${i}/session_hcp.txt
done

