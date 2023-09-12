#!/bin/sh

# C. Schleifer 12/08/21
# Script to batch preprocess SUNY 22q data using qunex container
# Script should not be run directly. Execute functions one by one


#####################################################################
### organize and prepare data
#####################################################################

## 1. set up study folder
/u/project/cbearden/data/scripts/tools/qunex_bin/hoffman_submit_qunex.sh \
--qunex_command="create_study" \
--qunex_options="--studyfolder=/u/project/cbearden/data/Enigma/IoP/qunex_studyfolder" \
--scheduler_options="-l h_data=4G,h_rt=1:00:00" \
--logdir="/u/project/cbearden/data/Enigma/IoP/" \
--array="no" 

# 2. organize dicoms into inbox
# test for single subject
#rawdir=/u/project/cbearden/data/Enigma/IoP/raw/
#sub=GQAIMS96
#sub=GQAIMS02
#zipdir=${rawdir}/${sub}/dcm_unzip
#mkdir $zipdir
## untar files
#for d in ${rawdir}/${sub}/DICOM/*/*tar.bz2; do tar -xvjf ${d} -C ${zipdir};done
## copy to inbox and rename to avoid collision 
#idir=/u/project/cbearden/data/Enigma/IoP/qunex_studyfolder/sessions/inbox/MR/${sub}
#idir=/u/project/cbearden/data/Enigma/IoP/qunex_studyfolder/test_sessions/inbox/MR/${sub}
#mkdir $idir
#for d in ${zipdir}/*; do dir=$(basename ${d});for f in ${zipdir}/${dir}/*dcm ; do cp -v ${f} ${idir}/${dir}_$(basename ${f});done;done

# several subjects have multiple dates in the DICOM dir. GQAIMS20B GQAIMS71
# organize all
rawdir=/u/project/cbearden/data/Enigma/IoP/raw/
for s in ${rawdir}/G* ;do
	sub=$(basename ${s})
	echo $sub
	zipdir=${rawdir}/${sub}/dcm_unzip
	mkdir $zipdir
	# unzip
	for d in ${rawdir}/${sub}/DICOM/*/*tar.bz2; do 
		tar -xvjf ${d} -C ${zipdir}
	done
	# now copy to inbox and name to avoid collisions
	idir=/u/project/cbearden/data/Enigma/IoP/qunex_studyfolder/sessions/inbox/MR/${sub}
	mkdir $idir
	for d in ${zipdir}/* ; do 
		dir=$(basename ${d})
		for f in ${zipdir}/${dir}/*dcm ;do 
			cp -v ${f} ${idir}/${dir}_$(basename ${f})
		done
	done
done


## 3. import DICOMs 
/u/project/cbearden/data/scripts/tools/qunex_bin/hoffman_submit_qunex.sh \
--qunex_command="import_dicom" \
--qunex_options="--sessionsfolder=/u/project/cbearden/data/Enigma/IoP/qunex_studyfolder/sessions --gzip=yes --check=any" \
--scheduler_options="-l h_data=16G,h_rt=24:00:00" \
--logdir="/u/project/cbearden/data/Enigma/IoP/qunex_studyfolder/processing/logs/manual" \
--array="no" 

## 4. set up HCP mapping file
# get list of unique runs to use when manually setting up mapping file
seshdir=/u/project/cbearden/data/Enigma/IoP/qunex_studyfolder/sessions/
#rm ${seshdir}/specs/all_runs.txt
for i in ${seshdir}/G*; do cat ${i}/session.txt | grep '^[0-9]' >> ${seshdir}/specs/all_runs.txt; done
cut ${seshdir}/specs/all_runs.txt -d : -f 2 | sort | uniq > ${seshdir}/specs/unique_runs.txt

# 5. only run names are "BOLD - RESTING" "MPRAGE_SAG_BWM" so mapping file is easy
echo "ADNI MPRAGE => T1w" > /u/project/cbearden/data/Enigma/IoP/qunex_studyfolder/sessions/specs/IoP_HCP_mapping.txt
echo "BOLD - RESTING => bold:resting" >> /u/project/cbearden/data/Enigma/IoP/qunex_studyfolder/sessions/specs/IoP_HCP_mapping.txt

## 6. HCP mapping
/u/project/cbearden/data/scripts/tools/qunex_bin/hoffman_submit_qunex.sh \
--qunex_command="create_session_info" \
--qunex_options="--overwrite=no --sourcefile=session.txt --targetfile=session_hcp.txt --pipelines=hcp --mapping=/u/project/cbearden/data/Enigma/IoP/qunex_studyfolder/sessions/specs/IoP_HCP_mapping.txt --sessionsfolder=/u/project/cbearden/data/Enigma/IoP/qunex_studyfolder/sessions" \
--scheduler_options="-l h_data=8G,h_rt=4:00:00" \
--logdir="/u/project/cbearden/data/Enigma/IoP/qunex_studyfolder/processing/logs/manual" \
--array="no" 

# 7. get list of sessions with a BOLD run

all_sessions="GQAIMS01 GQAIMS02 GQAIMS03 GQAIMS04 GQAIMS05 GQAIMS06 GQAIMS07 GQAIMS08 GQAIMS09 GQAIMS11 GQAIMS12 GQAIMS13 GQAIMS15 GQAIMS16 GQAIMS17 GQAIMS18 GQAIMS20 GQAIMS21 GQAIMS22 GQAIMS23 GQAIMS24 GQAIMS25 GQAIMS27 GQAIMS28 GQAIMS29 GQAIMS30 GQAIMS31 GQAIMS32 GQAIMS33 GQAIMS34 GQAIMS35 GQAIMS37 GQAIMS38 GQAIMS39 GQAIMS40 GQAIMS41 GQAIMS42 GQAIMS43 GQAIMS44 GQAIMS46 GQAIMS47 GQAIMS48 GQAIMS49 GQAIMS50 GQAIMS51 GQAIMS52 GQAIMS53 GQAIMS55 GQAIMS56 GQAIMS57 GQAIMS58 GQAIMS59 GQAIMS60 GQAIMS61 GQAIMS62 GQAIMS63 GQAIMS64 GQAIMS65 GQAIMS66 GQAIMS67 GQAIMS69 GQAIMS71 GQAIMS72 GQAIMS73 GQAIMS74 GQAIMS75 GQAIMS76 GQAIMS77 GQAIMS78 GQAIMS79 GQAIMS80 GQAIMS81 GQAIMS82 GQAIMS83 GQAIMS84 GQAIMS85 GQAIMS86 GQAIMS87 GQAIMS88 GQAIMS89 GQAIMS90 GQAIMS91 GQAIMS92 GQAIMS93 GQAIMS94 GQAIMS95 GQAIMS96"
for i in /u/project/cbearden/data/Enigma/IoP/qunex_studyfolder/sessions/G*; do if [ 0 -ne $(cat $i/session_hcp.txt | grep -c "BOLD") ];then echo $(basename $i) has BOLD; else echo $(basename $i) MISSING;fi;done
#sessions="GQAIMS01 GQAIMS02 GQAIMS03 GQAIMS04 GQAIMS05 GQAIMS06 GQAIMS07 GQAIMS08 GQAIMS09 GQAIMS11 GQAIMS12 GQAIMS13 GQAIMS15 GQAIMS16 GQAIMS17 GQAIMS18 GQAIMS20 GQAIMS21 GQAIMS22 GQAIMS23 GQAIMS24 GQAIMS25 GQAIMS27 GQAIMS28 GQAIMS29 GQAIMS30 GQAIMS31 GQAIMS32 GQAIMS33 GQAIMS34 GQAIMS35 GQAIMS37 GQAIMS39 GQAIMS40 GQAIMS41 GQAIMS42 GQAIMS43 GQAIMS47 GQAIMS49 GQAIMS50 GQAIMS51 GQAIMS52 GQAIMS53 GQAIMS55 GQAIMS56 GQAIMS58 GQAIMS59 GQAIMS60 GQAIMS61 GQAIMS62 GQAIMS63 GQAIMS64 GQAIMS65 GQAIMS66 GQAIMS67 GQAIMS69 GQAIMS72 GQAIMS73 GQAIMS76 GQAIMS79 GQAIMS80 GQAIMS82 GQAIMS83 GQAIMS84 GQAIMS85 GQAIMS86 GQAIMS87 GQAIMS88 GQAIMS89 GQAIMS90 GQAIMS91 GQAIMS92 GQAIMS93 GQAIMS94"



## 8. Setup HCP
/u/project/cbearden/data/scripts/tools/qunex_bin/hoffman_submit_qunex.sh \
--qunex_command="setup_hcp" \
--qunex_options="--sessionsfolder=/u/project/cbearden/data/Enigma/IoP/qunex_studyfolder/sessions --sourcefile=session_hcp.txt" \
--scheduler_options="-l h_data=8G,h_rt=4:00:00" \
--logdir="/u/project/cbearden/data/Enigma/IoP/qunex_studyfolder/processing/logs/manual" \
--array="yes" \
--sessions="GQAIMS01 GQAIMS01B GQAIMS02 GQAIMS02B GQAIMS03 GQAIMS04 GQAIMS04B GQAIMS05 GQAIMS05B GQAIMS06 GQAIMS07 GQAIMS08 GQAIMS08B GQAIMS09 GQAIMS11 GQAIMS11B GQAIMS12 GQAIMS13 GQAIMS15 GQAIMS17 GQAIMS18 GQAIMS20 GQAIMS21 GQAIMS22 GQAIMS23 GQAIMS24 GQAIMS25 GQAIMS27 GQAIMS28 GQAIMS29 GQAIMS30 GQAIMS31 GQAIMS32 GQAIMS33 GQAIMS34 GQAIMS35 GQAIMS37 GQAIMS39 GQAIMS40 GQAIMS40B GQAIMS41 GQAIMS42 GQAIMS43 GQAIMS47 GQAIMS49 GQAIMS50 GQAIMS51 GQAIMS52 GQAIMS53 GQAIMS55 GQAIMS56 GQAIMS58 GQAIMS59 GQAIMS60 GQAIMS61 GQAIMS62 GQAIMS63 GQAIMS64 GQAIMS65 GQAIMS66 GQAIMS67 GQAIMS70 GQAIMS72 GQAIMS73 GQAIMS76 GQAIMS79 GQAIMS80 GQAIMS82 GQAIMS83 GQAIMS84 GQAIMS85 GQAIMS86 GQAIMS87 GQAIMS88 GQAIMS89 GQAIMS90 GQAIMS91 GQAIMS92 GQAIMS93 GQAIMS94"

## 9. create batch file
# first copy over param file from 22qTrio 
cp /u/project/cbearden/data/22q/qunex_studyfolder/sessions/specs/22q_trio_params.txt /u/project/cbearden/data/Enigma/IoP/qunex_studyfolder/sessions/specs/IoP_params.txt
# IMPORTANT: need to manually edit IoP params to match acquisition.
# BOLD TR=2
# TO-DO: check if interleaved acquisition _hcp_bold_slicetimerparams : --odd
# currently setting params to skip slice time correction _hcp_bold_doslicetime  : NONE
/u/project/cbearden/data/scripts/tools/qunex_bin/hoffman_submit_qunex.sh \
--qunex_command="create_batch" \
--qunex_options=" --overwrite=yes --sessionsfolder=/u/project/cbearden/data/Enigma/IoP/qunex_studyfolder/sessions --sourcefiles=session_hcp.txt --targetfile=/u/project/cbearden/data/Enigma/IoP/qunex_studyfolder/processing/IoP_batch.txt --paramfile=/u/project/cbearden/data/Enigma/IoP/qunex_studyfolder/sessions/specs/IoP_params.txt --sessions=GQAIMS01,GQAIMS01B,GQAIMS02,GQAIMS02B,GQAIMS03,GQAIMS04,GQAIMS04B,GQAIMS05,GQAIMS05B,GQAIMS06,GQAIMS07,GQAIMS08,GQAIMS08B,GQAIMS09,GQAIMS11,GQAIMS11B,GQAIMS12,GQAIMS13,GQAIMS15,GQAIMS17,GQAIMS18,GQAIMS20,GQAIMS21,GQAIMS22,GQAIMS23,GQAIMS24,GQAIMS25,GQAIMS27,GQAIMS28,GQAIMS29,GQAIMS30,GQAIMS31,GQAIMS32,GQAIMS33,GQAIMS34,GQAIMS35,GQAIMS37,GQAIMS39,GQAIMS40,GQAIMS40B,GQAIMS41,GQAIMS42,GQAIMS43,GQAIMS47,GQAIMS49,GQAIMS50,GQAIMS51,GQAIMS52,GQAIMS53,GQAIMS55,GQAIMS56,GQAIMS58,GQAIMS59,GQAIMS60,GQAIMS61,GQAIMS62,GQAIMS63,GQAIMS64,GQAIMS65,GQAIMS66,GQAIMS67,,GQAIMS70,GQAIMS72,GQAIMS73,GQAIMS76,GQAIMS79,GQAIMS80,GQAIMS82,GQAIMS83,GQAIMS84,GQAIMS85,GQAIMS86,GQAIMS87,GQAIMS88,GQAIMS89,GQAIMS90,GQAIMS91,GQAIMS92,GQAIMS93,GQAIMS94" \
--scheduler_options="-l h_data=4G,h_rt=4:00:00" \
--logdir="/u/project/cbearden/data/Enigma/IoP/qunex_studyfolder/processing/logs/manual" \
--array="no" 

#####################################################################
### HCP steps
#####################################################################

## 10. PreFreeSurfer
/u/project/cbearden/data/scripts/tools/qunex_bin/hoffman_submit_qunex.sh \
--qunex_command="hcp_pre_freesurfer" \
--qunex_options="--sessions=/u/project/cbearden/data/Enigma/IoP/qunex_studyfolder/processing/IoP_batch.txt --sessionsfolder=/u/project/cbearden/data/Enigma/IoP/qunex_studyfolder/sessions --parsessions=1 --overwrite=no" \
--scheduler_options="-l h_data=16G,h_rt=24:00:00,arch=intel*" \
--logdir="/u/project/cbearden/data/Enigma/IoP/qunex_studyfolder/processing/logs/manual" \
--array="yes" \
--sessions="GQAIMS01 GQAIMS02 GQAIMS03 GQAIMS04 GQAIMS05 GQAIMS06 GQAIMS07 GQAIMS08 GQAIMS09 GQAIMS11 GQAIMS12 GQAIMS13 GQAIMS15 GQAIMS16 GQAIMS17 GQAIMS18 GQAIMS20 GQAIMS21 GQAIMS22 GQAIMS23 GQAIMS24 GQAIMS25 GQAIMS27 GQAIMS28 GQAIMS29 GQAIMS30 GQAIMS31 GQAIMS32 GQAIMS33 GQAIMS34 GQAIMS35 GQAIMS37 GQAIMS39 GQAIMS40 GQAIMS41 GQAIMS42 GQAIMS43 GQAIMS47 GQAIMS49 GQAIMS50 GQAIMS51 GQAIMS52 GQAIMS53 GQAIMS55 GQAIMS56 GQAIMS58 GQAIMS59 GQAIMS60 GQAIMS61 GQAIMS62 GQAIMS63 GQAIMS64 GQAIMS65 GQAIMS66 GQAIMS67 GQAIMS69 GQAIMS72 GQAIMS73 GQAIMS76 GQAIMS79 GQAIMS80 GQAIMS82 GQAIMS83 GQAIMS84 GQAIMS85 GQAIMS86 GQAIMS87 GQAIMS88 GQAIMS89 GQAIMS90 GQAIMS91 GQAIMS92 GQAIMS93 GQAIMS94"

## 11. FreeSurfer
/u/project/cbearden/data/scripts/tools/qunex_bin/hoffman_submit_qunex.sh \
--qunex_command="hcp_freesurfer" \
--qunex_options="--sessions=/u/project/cbearden/data/Enigma/IoP/qunex_studyfolder/processing/IoP_batch.txt --sessionsfolder=/u/project/cbearden/data/Enigma/IoP/qunex_studyfolder/sessions --parsessions=1 --overwrite=no" \
--scheduler_options="-l h_data=20G,h_rt=48:00:00,arch=intel*,highp" \
--logdir="/u/project/cbearden/data/Enigma/IoP/qunex_studyfolder/processing/logs/manual" \
--array="yes" \
--sessions="GQAIMS01 GQAIMS02 GQAIMS03 GQAIMS04 GQAIMS05 GQAIMS06 GQAIMS07 GQAIMS08 GQAIMS09 GQAIMS11 GQAIMS12 GQAIMS13 GQAIMS15 GQAIMS16 GQAIMS17 GQAIMS18 GQAIMS20 GQAIMS21 GQAIMS22 GQAIMS23 GQAIMS24 GQAIMS25 GQAIMS27 GQAIMS28 GQAIMS29 GQAIMS30 GQAIMS31 GQAIMS32 GQAIMS33 GQAIMS34 GQAIMS35 GQAIMS37 GQAIMS39 GQAIMS40 GQAIMS41 GQAIMS42 GQAIMS43 GQAIMS47 GQAIMS49 GQAIMS50 GQAIMS51 GQAIMS52 GQAIMS53 GQAIMS55 GQAIMS56 GQAIMS58 GQAIMS59 GQAIMS60 GQAIMS61 GQAIMS62 GQAIMS63 GQAIMS64 GQAIMS65 GQAIMS66 GQAIMS67 GQAIMS69 GQAIMS72 GQAIMS73 GQAIMS76 GQAIMS79 GQAIMS80 GQAIMS82 GQAIMS83 GQAIMS84 GQAIMS85 GQAIMS86 GQAIMS87 GQAIMS88 GQAIMS89 GQAIMS90 GQAIMS91 GQAIMS92 GQAIMS93 GQAIMS94"

## 12. PostFreeSurfer
/u/project/cbearden/data/scripts/tools/qunex_bin/hoffman_submit_qunex.sh \
--qunex_command="hcp_post_freesurfer" \
--qunex_options="--sessions=/u/project/cbearden/data/Enigma/IoP/qunex_studyfolder/processing/IoP_batch.txt --sessionsfolder=/u/project/cbearden/data/Enigma/IoP/qunex_studyfolder/sessions --parsessions=1 --overwrite=no" \
--scheduler_options="-l h_data=16G,h_rt=24:00:00,arch=intel*" \
--logdir="/u/project/cbearden/data/Enigma/IoP/qunex_studyfolder/processing/logs/manual" \
--array="yes" \
--sessions="GQAIMS01 GQAIMS02 GQAIMS03 GQAIMS04 GQAIMS05 GQAIMS06 GQAIMS07 GQAIMS08 GQAIMS09 GQAIMS11 GQAIMS12 GQAIMS13 GQAIMS15 GQAIMS16 GQAIMS17 GQAIMS18 GQAIMS20 GQAIMS21 GQAIMS22 GQAIMS23 GQAIMS24 GQAIMS25 GQAIMS27 GQAIMS28 GQAIMS29 GQAIMS30 GQAIMS31 GQAIMS32 GQAIMS33 GQAIMS34 GQAIMS35 GQAIMS37 GQAIMS39 GQAIMS40 GQAIMS41 GQAIMS42 GQAIMS43 GQAIMS47 GQAIMS49 GQAIMS50 GQAIMS51 GQAIMS52 GQAIMS53 GQAIMS55 GQAIMS56 GQAIMS58 GQAIMS59 GQAIMS60 GQAIMS61 GQAIMS62 GQAIMS63 GQAIMS64 GQAIMS65 GQAIMS66 GQAIMS67 GQAIMS69 GQAIMS72 GQAIMS73 GQAIMS76 GQAIMS79 GQAIMS80 GQAIMS82 GQAIMS83 GQAIMS84 GQAIMS85 GQAIMS86 GQAIMS87 GQAIMS88 GQAIMS89 GQAIMS90 GQAIMS91 GQAIMS92 GQAIMS93 GQAIMS94"

## 13. FMRI VOLUME
/u/project/cbearden/data/scripts/tools/qunex_bin/hoffman_submit_qunex.sh \
--qunex_command="hcp_fmri_volume" \
--qunex_options="--sessions=/u/project/cbearden/data/Enigma/IoP/qunex_studyfolder/processing/IoP_batch.txt --sessionsfolder=/u/project/cbearden/data/Enigma/IoP/qunex_studyfolder/sessions --parsessions=1 --overwrite=no" \
--scheduler_options="-l h_data=16G,h_rt=24:00:00,arch=intel*" \
--logdir="/u/project/cbearden/data/Enigma/IoP/qunex_studyfolder/processing/logs/manual" \
--array="yes" \
--sessions="GQAIMS01 GQAIMS02 GQAIMS03 GQAIMS04 GQAIMS05 GQAIMS06 GQAIMS07 GQAIMS08 GQAIMS09 GQAIMS11 GQAIMS12 GQAIMS13 GQAIMS15 GQAIMS16 GQAIMS17 GQAIMS18 GQAIMS20 GQAIMS21 GQAIMS22 GQAIMS23 GQAIMS24 GQAIMS25 GQAIMS27 GQAIMS28 GQAIMS29 GQAIMS30 GQAIMS31 GQAIMS32 GQAIMS33 GQAIMS34 GQAIMS35 GQAIMS37 GQAIMS39 GQAIMS40 GQAIMS41 GQAIMS42 GQAIMS43 GQAIMS47 GQAIMS49 GQAIMS50 GQAIMS51 GQAIMS52 GQAIMS53 GQAIMS55 GQAIMS56 GQAIMS58 GQAIMS59 GQAIMS60 GQAIMS61 GQAIMS62 GQAIMS63 GQAIMS64 GQAIMS65 GQAIMS66 GQAIMS67 GQAIMS69 GQAIMS72 GQAIMS73 GQAIMS76 GQAIMS79 GQAIMS80 GQAIMS82 GQAIMS83 GQAIMS84 GQAIMS85 GQAIMS86 GQAIMS87 GQAIMS88 GQAIMS89 GQAIMS90 GQAIMS91 GQAIMS92 GQAIMS93 GQAIMS94"

## 14. FMRI SURFACE
/u/project/cbearden/data/scripts/tools/qunex_bin/hoffman_submit_qunex.sh \
--qunex_command="hcp_fmri_surface" \
--qunex_options="--sessions=/u/project/cbearden/data/Enigma/IoP/qunex_studyfolder/processing/IoP_batch.txt --sessionsfolder=/u/project/cbearden/data/Enigma/IoP/qunex_studyfolder/sessions --parsessions=1 --overwrite=no" \
--scheduler_options="-l h_data=16G,h_rt=24:00:00,arch=intel*" \
--logdir="/u/project/cbearden/data/Enigma/IoP/qunex_studyfolder/processing/logs/manual" \
--array="yes" \
--sessions="GQAIMS01 GQAIMS02 GQAIMS03 GQAIMS04 GQAIMS05 GQAIMS06 GQAIMS07 GQAIMS08 GQAIMS09 GQAIMS11 GQAIMS12 GQAIMS13 GQAIMS15 GQAIMS16 GQAIMS17 GQAIMS18 GQAIMS20 GQAIMS21 GQAIMS22 GQAIMS23 GQAIMS24 GQAIMS25 GQAIMS27 GQAIMS28 GQAIMS29 GQAIMS30 GQAIMS31 GQAIMS32 GQAIMS33 GQAIMS34 GQAIMS35 GQAIMS37 GQAIMS39 GQAIMS40 GQAIMS41 GQAIMS42 GQAIMS43 GQAIMS47 GQAIMS49 GQAIMS50 GQAIMS51 GQAIMS52 GQAIMS53 GQAIMS55 GQAIMS56 GQAIMS58 GQAIMS59 GQAIMS60 GQAIMS61 GQAIMS62 GQAIMS63 GQAIMS64 GQAIMS65 GQAIMS66 GQAIMS67 GQAIMS69 GQAIMS72 GQAIMS73 GQAIMS76 GQAIMS79 GQAIMS80 GQAIMS82 GQAIMS83 GQAIMS84 GQAIMS85 GQAIMS86 GQAIMS87 GQAIMS88 GQAIMS89 GQAIMS90 GQAIMS91 GQAIMS92 GQAIMS93 GQAIMS94"


#####################################################################
### BOLD post-processing
#####################################################################
# https://bitbucket.org/oriadev/qunex/wiki/UsageDocs/BOLDPreprocessing.md
# https://bitbucket.org/oriadev/qunex/wiki/UsageDocs/MovementScrubbing.md

## map hcp data
/u/project/cbearden/data/scripts/tools/qunex_bin/hoffman_submit_qunex.sh \
--qunex_command="map_hcp_data" \
--qunex_options=" --overwrite=yes --bolds=resting --sessions=/u/project/cbearden/data/Enigma/IoP/qunex_studyfolder/processing/IoP_batch.txt --sessionsfolder=/u/project/cbearden/data/Enigma/IoP/qunex_studyfolder/sessions" \
--scheduler_options="-l h_data=20G,h_rt=4:00:00,arch=intel*" \
--array="yes" \
--logdir="/u/project/cbearden/data/Enigma/IoP/qunex_studyfolder/processing/logs/manual" \
--sessions="GQAIMS01 GQAIMS02 GQAIMS03 GQAIMS04 GQAIMS05 GQAIMS06 GQAIMS07 GQAIMS08 GQAIMS09 GQAIMS11 GQAIMS12 GQAIMS13 GQAIMS15 GQAIMS16 GQAIMS17 GQAIMS18 GQAIMS20 GQAIMS21 GQAIMS22 GQAIMS23 GQAIMS24 GQAIMS25 GQAIMS27 GQAIMS28 GQAIMS29 GQAIMS30 GQAIMS31 GQAIMS32 GQAIMS33 GQAIMS34 GQAIMS35 GQAIMS37 GQAIMS39 GQAIMS40 GQAIMS41 GQAIMS42 GQAIMS43 GQAIMS47 GQAIMS49 GQAIMS50 GQAIMS51 GQAIMS52 GQAIMS53 GQAIMS55 GQAIMS56 GQAIMS58 GQAIMS59 GQAIMS60 GQAIMS61 GQAIMS62 GQAIMS63 GQAIMS64 GQAIMS65 GQAIMS66 GQAIMS67 GQAIMS69 GQAIMS72 GQAIMS73 GQAIMS76 GQAIMS79 GQAIMS80 GQAIMS82 GQAIMS83 GQAIMS84 GQAIMS85 GQAIMS86 GQAIMS87 GQAIMS88 GQAIMS89 GQAIMS90 GQAIMS91 GQAIMS92 GQAIMS93 GQAIMS94"

## brain masks
/u/project/cbearden/data/scripts/tools/qunex_bin/hoffman_submit_qunex.sh \
--qunex_command="create_bold_brain_masks" \
--qunex_options="--overwrite=yes --sessions=/u/project/cbearden/data/Enigma/IoP/qunex_studyfolder/processing/IoP_batch.txt --sessionsfolder=/u/project/cbearden/data/Enigma/IoP/qunex_studyfolder/sessions" \
--scheduler_options="-l h_data=20G,h_rt=4:00:00,arch=intel*" \
--array="yes" \
--logdir="/u/project/cbearden/data/Enigma/IoP/qunex_studyfolder/processing/logs/manual" \
--sessions="GQAIMS01 GQAIMS02 GQAIMS03 GQAIMS04 GQAIMS05 GQAIMS06 GQAIMS07 GQAIMS08 GQAIMS09 GQAIMS11 GQAIMS12 GQAIMS13 GQAIMS15 GQAIMS16 GQAIMS17 GQAIMS18 GQAIMS20 GQAIMS21 GQAIMS22 GQAIMS23 GQAIMS24 GQAIMS25 GQAIMS27 GQAIMS28 GQAIMS29 GQAIMS30 GQAIMS31 GQAIMS32 GQAIMS33 GQAIMS34 GQAIMS35 GQAIMS37 GQAIMS39 GQAIMS40 GQAIMS41 GQAIMS42 GQAIMS43 GQAIMS47 GQAIMS49 GQAIMS50 GQAIMS51 GQAIMS52 GQAIMS53 GQAIMS55 GQAIMS56 GQAIMS58 GQAIMS59 GQAIMS60 GQAIMS61 GQAIMS62 GQAIMS63 GQAIMS64 GQAIMS65 GQAIMS66 GQAIMS67 GQAIMS69 GQAIMS72 GQAIMS73 GQAIMS76 GQAIMS79 GQAIMS80 GQAIMS82 GQAIMS83 GQAIMS84 GQAIMS85 GQAIMS86 GQAIMS87 GQAIMS88 GQAIMS89 GQAIMS90 GQAIMS91 GQAIMS92 GQAIMS93 GQAIMS94"

## bold stats
/u/project/cbearden/data/scripts/tools/qunex_bin/hoffman_submit_qunex.sh \
--qunex_command="compute_bold_stats" \
--qunex_options="--overwrite=yes --bolds=resting --sessions=/u/project/cbearden/data/Enigma/IoP/qunex_studyfolder/processing/IoP_batch.txt --sessionsfolder=/u/project/cbearden/data/Enigma/IoP/qunex_studyfolder/sessions" \
--scheduler_options="-l h_data=20G,h_rt=4:00:00,arch=intel*" \
--array="yes" \
--logdir="/u/project/cbearden/data/Enigma/IoP/qunex_studyfolder/processing/logs/manual" \
--sessions="GQAIMS01 GQAIMS02 GQAIMS03 GQAIMS04 GQAIMS05 GQAIMS06 GQAIMS07 GQAIMS08 GQAIMS09 GQAIMS11 GQAIMS12 GQAIMS13 GQAIMS15 GQAIMS16 GQAIMS17 GQAIMS18 GQAIMS20 GQAIMS21 GQAIMS22 GQAIMS23 GQAIMS24 GQAIMS25 GQAIMS27 GQAIMS28 GQAIMS29 GQAIMS30 GQAIMS31 GQAIMS32 GQAIMS33 GQAIMS34 GQAIMS35 GQAIMS37 GQAIMS39 GQAIMS40 GQAIMS41 GQAIMS42 GQAIMS43 GQAIMS47 GQAIMS49 GQAIMS50 GQAIMS51 GQAIMS52 GQAIMS53 GQAIMS55 GQAIMS56 GQAIMS58 GQAIMS59 GQAIMS60 GQAIMS61 GQAIMS62 GQAIMS63 GQAIMS64 GQAIMS65 GQAIMS66 GQAIMS67 GQAIMS69 GQAIMS72 GQAIMS73 GQAIMS76 GQAIMS79 GQAIMS80 GQAIMS82 GQAIMS83 GQAIMS84 GQAIMS85 GQAIMS86 GQAIMS87 GQAIMS88 GQAIMS89 GQAIMS90 GQAIMS91 GQAIMS92 GQAIMS93 GQAIMS94"
  
## create stats report
/u/project/cbearden/data/scripts/tools/qunex_bin/hoffman_submit_qunex.sh \
--qunex_command="create_stats_report" \
--qunex_options="--overwrite=yes --bolds=resting --sessions=/u/project/cbearden/data/Enigma/IoP/qunex_studyfolder/processing/IoP_batch.txt --sessionsfolder=/u/project/cbearden/data/Enigma/IoP/qunex_studyfolder/sessions" \
--scheduler_options="-l h_data=20G,h_rt=4:00:00,arch=intel*" \
--array="yes" \
--logdir="/u/project/cbearden/data/Enigma/IoP/qunex_studyfolder/processing/logs/manual" \
--sessions="GQAIMS01 GQAIMS02 GQAIMS03 GQAIMS04 GQAIMS05 GQAIMS06 GQAIMS07 GQAIMS08 GQAIMS09 GQAIMS11 GQAIMS12 GQAIMS13 GQAIMS15 GQAIMS16 GQAIMS17 GQAIMS18 GQAIMS20 GQAIMS21 GQAIMS22 GQAIMS23 GQAIMS24 GQAIMS25 GQAIMS27 GQAIMS28 GQAIMS29 GQAIMS30 GQAIMS31 GQAIMS32 GQAIMS33 GQAIMS34 GQAIMS35 GQAIMS37 GQAIMS39 GQAIMS40 GQAIMS41 GQAIMS42 GQAIMS43 GQAIMS47 GQAIMS49 GQAIMS50 GQAIMS51 GQAIMS52 GQAIMS53 GQAIMS55 GQAIMS56 GQAIMS58 GQAIMS59 GQAIMS60 GQAIMS61 GQAIMS62 GQAIMS63 GQAIMS64 GQAIMS65 GQAIMS66 GQAIMS67 GQAIMS69 GQAIMS72 GQAIMS73 GQAIMS76 GQAIMS79 GQAIMS80 GQAIMS82 GQAIMS83 GQAIMS84 GQAIMS85 GQAIMS86 GQAIMS87 GQAIMS88 GQAIMS89 GQAIMS90 GQAIMS91 GQAIMS92 GQAIMS93 GQAIMS94"

## extract nuisance signal
/u/project/cbearden/data/scripts/tools/qunex_bin/hoffman_submit_qunex.sh \
--qunex_command="extract_nuisance_signal" \
--qunex_options="--overwrite=yes --bolds=resting --sessions=/u/project/cbearden/data/Enigma/IoP/qunex_studyfolder/processing/IoP_batch.txt --sessionsfolder=/u/project/cbearden/data/Enigma/IoP/qunex_studyfolder/sessions" \
--scheduler_options="-l h_data=20G,h_rt=4:00:00,arch=intel*" \
--array="yes" \
--logdir="/u/project/cbearden/data/Enigma/IoP/qunex_studyfolder/processing/logs/manual" \
--sessions="GQAIMS01 GQAIMS02 GQAIMS03 GQAIMS04 GQAIMS05 GQAIMS06 GQAIMS07 GQAIMS08 GQAIMS09 GQAIMS11 GQAIMS12 GQAIMS13 GQAIMS15 GQAIMS16 GQAIMS17 GQAIMS18 GQAIMS20 GQAIMS21 GQAIMS22 GQAIMS23 GQAIMS24 GQAIMS25 GQAIMS27 GQAIMS28 GQAIMS29 GQAIMS30 GQAIMS31 GQAIMS32 GQAIMS33 GQAIMS34 GQAIMS35 GQAIMS37 GQAIMS39 GQAIMS40 GQAIMS41 GQAIMS42 GQAIMS43 GQAIMS47 GQAIMS49 GQAIMS50 GQAIMS51 GQAIMS52 GQAIMS53 GQAIMS55 GQAIMS56 GQAIMS58 GQAIMS59 GQAIMS60 GQAIMS61 GQAIMS62 GQAIMS63 GQAIMS64 GQAIMS65 GQAIMS66 GQAIMS67 GQAIMS69 GQAIMS72 GQAIMS73 GQAIMS76 GQAIMS79 GQAIMS80 GQAIMS82 GQAIMS83 GQAIMS84 GQAIMS85 GQAIMS86 GQAIMS87 GQAIMS88 GQAIMS89 GQAIMS90 GQAIMS91 GQAIMS92 GQAIMS93 GQAIMS94"

## preprocess bold CIFTI no GSR
/u/project/cbearden/data/scripts/tools/qunex_bin/hoffman_submit_qunex.sh \
--qunex_command="preprocess_bold" \
--qunex_options="--overwrite=yes --bolds=resting --bold_actions=s,h,r,c,l --bold_nuisance=m,V,WM,1d --image_target=dtseries --sessions=/u/project/cbearden/data/Enigma/IoP/qunex_studyfolder/processing/IoP_batch.txt --sessionsfolder=/u/project/cbearden/data/Enigma/IoP/qunex_studyfolder/sessions" \
--scheduler_options="-l h_data=20G,h_rt=4:00:00,arch=intel*" \
--array="yes" \
--logdir="/u/project/cbearden/data/Enigma/IoP/qunex_studyfolder/processing/logs/manual" \
--sessions="GQAIMS01 GQAIMS02 GQAIMS03 GQAIMS04 GQAIMS05 GQAIMS06 GQAIMS07 GQAIMS08 GQAIMS09 GQAIMS11 GQAIMS12 GQAIMS13 GQAIMS15 GQAIMS16 GQAIMS17 GQAIMS18 GQAIMS20 GQAIMS21 GQAIMS22 GQAIMS23 GQAIMS24 GQAIMS25 GQAIMS27 GQAIMS28 GQAIMS29 GQAIMS30 GQAIMS31 GQAIMS32 GQAIMS33 GQAIMS34 GQAIMS35 GQAIMS37 GQAIMS39 GQAIMS40 GQAIMS41 GQAIMS42 GQAIMS43 GQAIMS47 GQAIMS49 GQAIMS50 GQAIMS51 GQAIMS52 GQAIMS53 GQAIMS55 GQAIMS56 GQAIMS58 GQAIMS59 GQAIMS60 GQAIMS61 GQAIMS62 GQAIMS63 GQAIMS64 GQAIMS65 GQAIMS66 GQAIMS67 GQAIMS69 GQAIMS72 GQAIMS73 GQAIMS76 GQAIMS79 GQAIMS80 GQAIMS82 GQAIMS83 GQAIMS84 GQAIMS85 GQAIMS86 GQAIMS87 GQAIMS88 GQAIMS89 GQAIMS90 GQAIMS91 GQAIMS92 GQAIMS93 GQAIMS94"

## preprocess bold CIFTI GSR
/u/project/cbearden/data/scripts/tools/qunex_bin/hoffman_submit_qunex.sh \
--qunex_command="preprocess_bold" \
--qunex_options="--overwrite=yes --bolds=resting --bold_actions=s,h,r,c,l --bold_nuisance=m,V,WM,WB,1d --image_target=dtseries --sessions=/u/project/cbearden/data/Enigma/IoP/qunex_studyfolder/processing/IoP_batch.txt --sessionsfolder=/u/project/cbearden/data/Enigma/IoP/qunex_studyfolder/sessions" \
--scheduler_options="-l h_data=20G,h_rt=4:00:00,arch=intel*" \
--array="yes" \
--logdir="/u/project/cbearden/data/Enigma/IoP/qunex_studyfolder/processing/logs/manual" \
--sessions="GQAIMS01 GQAIMS02 GQAIMS03 GQAIMS04 GQAIMS05 GQAIMS06 GQAIMS07 GQAIMS08 GQAIMS09 GQAIMS11 GQAIMS12 GQAIMS13 GQAIMS15 GQAIMS16 GQAIMS17 GQAIMS18 GQAIMS20 GQAIMS21 GQAIMS22 GQAIMS23 GQAIMS24 GQAIMS25 GQAIMS27 GQAIMS28 GQAIMS29 GQAIMS30 GQAIMS31 GQAIMS32 GQAIMS33 GQAIMS34 GQAIMS35 GQAIMS37 GQAIMS39 GQAIMS40 GQAIMS41 GQAIMS42 GQAIMS43 GQAIMS47 GQAIMS49 GQAIMS50 GQAIMS51 GQAIMS52 GQAIMS53 GQAIMS55 GQAIMS56 GQAIMS58 GQAIMS59 GQAIMS60 GQAIMS61 GQAIMS62 GQAIMS63 GQAIMS64 GQAIMS65 GQAIMS66 GQAIMS67 GQAIMS69 GQAIMS72 GQAIMS73 GQAIMS76 GQAIMS79 GQAIMS80 GQAIMS82 GQAIMS83 GQAIMS84 GQAIMS85 GQAIMS86 GQAIMS87 GQAIMS88 GQAIMS89 GQAIMS90 GQAIMS91 GQAIMS92 GQAIMS93 GQAIMS94"

#####################################################################
### Catch up sessions that didn't finish
#####################################################################

# check which sessions are didn't complete BOLD mapping
echo "" > /u/project/cbearden/data/Enigma/IoP/qunex_studyfolder/sessions/specs/sessions_missing_BOLD_postprocessing.txt; for i in G*; do if (test -f ${i}/images/functional/bold1_Atlas.dtseries.nii); then echo ${i} GOOD; else echo ${i} >> /u/project/cbearden/data/Enigma/IoP/qunex_studyfolder/sessions/specs/sessions_missing_BOLD_postprocessing.txt;fi;done

/u/project/cbearden/data/scripts/tools/qunex_bin/hoffman_submit_qunex.sh \
--qunex_command="map_hcp_data" \
--qunex_options=" --overwrite=yes --bolds=resting --sessions=/u/project/cbearden/data/Enigma/IoP/qunex_studyfolder/processing/IoP_batch.txt --sessionsfolder=/u/project/cbearden/data/Enigma/IoP/qunex_studyfolder/sessions" \
--scheduler_options="-l h_data=20G,h_rt=4:00:00,arch=intel*" \
--array="yes" \
--logdir="/u/project/cbearden/data/Enigma/IoP/qunex_studyfolder/processing/logs/manual" \
--sessions="GQAIMS02 GQAIMS07 GQAIMS08 GQAIMS11 GQAIMS16 GQAIMS29 GQAIMS30 GQAIMS31 GQAIMS33 GQAIMS35 GQAIMS38 GQAIMS42 GQAIMS43 GQAIMS44 GQAIMS46 GQAIMS47 GQAIMS48 GQAIMS51 GQAIMS53 GQAIMS55 GQAIMS56 GQAIMS57 GQAIMS58 GQAIMS59 GQAIMS60 GQAIMS61 GQAIMS62 GQAIMS63 GQAIMS64 GQAIMS65 GQAIMS66 GQAIMS67 GQAIMS70 GQAIMS71 GQAIMS72 GQAIMS73 GQAIMS74 GQAIMS75 GQAIMS76 GQAIMS77 GQAIMS78 GQAIMS79 GQAIMS80 GQAIMS81 GQAIMS82 GQAIMS83 GQAIMS84 GQAIMS85 GQAIMS86 GQAIMS87 GQAIMS88 GQAIMS89 GQAIMS90 GQAIMS91 GQAIMS92 GQAIMS93 GQAIMS94 GQAIMS95 GQAIMS96"


## figure out why session 76 is failing bold volume
# try editing IoP_batch.txt and comment out bold1 for GQAIMS76, was failing after bold1 and not running bold2
## 13. FMRI VOLUME
/u/project/cbearden/data/scripts/tools/qunex_bin/hoffman_submit_qunex.sh \
--qunex_command="hcp_fmri_volume" \
--qunex_options="--sessions=/u/project/cbearden/data/Enigma/IoP/qunex_studyfolder/processing/IoP_batch.txt --sessionsfolder=/u/project/cbearden/data/Enigma/IoP/qunex_studyfolder/sessions --parsessions=1 --overwrite=no" \
--scheduler_options="-l h_data=16G,h_rt=24:00:00,arch=intel*" \
--logdir="/u/project/cbearden/data/Enigma/IoP/qunex_studyfolder/processing/logs/manual" \
--array="yes" \
--sessions="GQAIMS76"

## 14. FMRI SURFACE
/u/project/cbearden/data/scripts/tools/qunex_bin/hoffman_submit_qunex.sh \
--qunex_command="hcp_fmri_surface" \
--qunex_options="--sessions=/u/project/cbearden/data/Enigma/IoP/qunex_studyfolder/processing/IoP_batch.txt --sessionsfolder=/u/project/cbearden/data/Enigma/IoP/qunex_studyfolder/sessions --parsessions=1 --overwrite=no" \
--scheduler_options="-l h_data=16G,h_rt=24:00:00,arch=intel*" \
--logdir="/u/project/cbearden/data/Enigma/IoP/qunex_studyfolder/processing/logs/manual" \
--array="yes" \
--sessions="GQAIMS76"

# check which sessions finished preproc
sessions="GQAIMS01 GQAIMS01B GQAIMS02 GQAIMS02B GQAIMS03 GQAIMS04 GQAIMS04B GQAIMS05 GQAIMS05B GQAIMS06 GQAIMS07 GQAIMS08 GQAIMS08B GQAIMS09 GQAIMS11 GQAIMS11B GQAIMS12 GQAIMS13 GQAIMS15 GQAIMS17 GQAIMS18 GQAIMS20 GQAIMS21 GQAIMS22 GQAIMS23 GQAIMS24 GQAIMS25 GQAIMS27 GQAIMS28 GQAIMS29 GQAIMS30 GQAIMS31 GQAIMS32 GQAIMS33 GQAIMS34 GQAIMS35 GQAIMS37 GQAIMS39 GQAIMS40 GQAIMS40B GQAIMS41 GQAIMS42 GQAIMS43 GQAIMS47 GQAIMS49 GQAIMS50 GQAIMS51 GQAIMS52 GQAIMS53 GQAIMS55 GQAIMS56 GQAIMS58 GQAIMS59 GQAIMS60 GQAIMS61 GQAIMS62 GQAIMS63 GQAIMS64 GQAIMS65 GQAIMS66 GQAIMS67 GQAIMS70 GQAIMS72 GQAIMS73 GQAIMS76 GQAIMS79 GQAIMS80 GQAIMS82 GQAIMS83 GQAIMS84 GQAIMS85 GQAIMS86 GQAIMS87 GQAIMS88 GQAIMS89 GQAIMS90 GQAIMS91 GQAIMS92 GQAIMS93 GQAIMS94"
for i in $sessions; do if [[ -f ${i}/images/functional/bold1_Atlas_s_hpss_res-mVWMWB1d_lpss.dtseries.nii ]]; then echo ${i} has processed BOLD; fi; done
for i in $sessions; do if [[ ! -f ${i}/images/functional/bold1_Atlas_s_hpss_res-mVWMWB1d_lpss.dtseries.nii ]]; then echo ${i} missing processed BOLD; fi; done


### restart from import_dicom for sessions that were labeled as misnamed in tracking sheet.
# for raw data, scan id is the dir name inside GQAIMS*/DICOM/ e.g. 016339
# – 16339 scanned 23rd May
# GQAIMS69 – 16385 scanned 24th June (labelled as 68 by mistake)
# GQAIMS70 – 16398 scanned 2nd July (labelled as 69 by mistake)
# GQAIMS84 – 16630 scanned 28th Nov
# GQAIMS85 – 16632 scanned 28th Nov (same day under same number)

# first move these processed sessions to a new folder (84 and 85 are fine)
mlabel=" GQAIMS69 GQAIMS70"
mkdir /u/project/cbearden/data/Enigma/IoP/qunex_studyfolder/sessions/mislabelled
for i in $mlabel; do mv -v /u/project/cbearden/data/Enigma/IoP/qunex_studyfolder/sessions/${i} /u/project/cbearden/data/Enigma/IoP/qunex_studyfolder/sessions/mislabelled;done

# fix the mislabelled sessions
# 
mkdir -p /u/project/cbearden/data/Enigma/IoP/raw/fixed_mislabelled/ 
cp -rv /u/project/cbearden/data/Enigma/IoP/raw//DICOM/016339 /u/project/cbearden/data/Enigma/IoP/raw/fixed_mislabelled/ 
# GQAIMS69
mkdir -p /u/project/cbearden/data/Enigma/IoP/raw/fixed_mislabelled/GQAIMS69 
cp -rv /u/project/cbearden/data/Enigma/IoP/raw//DICOM/016385 /u/project/cbearden/data/Enigma/IoP/raw/fixed_mislabelled/GQAIMS69 
# GQAIMS70 (copying from data/raw because version of GQAIMS69 unzipped in data/Enigma/IoP/raw is empty)
mkdir -p /u/project/cbearden/data/Enigma/IoP/raw/fixed_mislabelled/GQAIMS70 
cp -rv /u/project/cbearden/data/raw/Enigma/IoP/GQAIMS70/DICOM/016398 /u/project/cbearden/data/Enigma/IoP/raw/GQAIMS69/DICOM/016385 

# unzip dicoms 
mkdir /u/project/cbearden/data/Enigma/IoP/raw/fixed_mislabelled//dcm_unzip
mkdir /u/project/cbearden/data/Enigma/IoP/raw/fixed_mislabelled/GQAIMS69/dcm_unzip
for sub in GQAIMS69; do for d in /u/project/cbearden/data/Enigma/IoP/raw/fixed_mislabelled/${sub}/*/*tar.bz2; do tar -xvjf ${d} -C /u/project/cbearden/data/Enigma/IoP/raw/fixed_mislabelled/${sub}/dcm_unzip;done;done
# copy to qunex inbox
for sub in GQAIMS69; do idir=/u/project/cbearden/data/Enigma/IoP/qunex_studyfolder/sessions/inbox/MR/${sub}; mkdir $idir; for d in /u/project/cbearden/data/Enigma/IoP/raw/fixed_mislabelled/${sub}/dcm_unzip/* ; do dir=$(basename ${d});for f in /u/project/cbearden/data/Enigma/IoP/raw/fixed_mislabelled/${sub}/dcm_unzip//${dir}/*dcm ;do cp -v ${f} ${idir}/${dir}_$(basename ${f});done;done;done

# fix GQAIMS16 which has two different folders with dicoms from the same scan
mv -v /u/project/cbearden/data/Enigma/IoP/qunex_studyfolder/sessions/GQAIMS16 /u/project/cbearden/data/Enigma/IoP/qunex_studyfolder/sessions/outdated
mkdir -p /u/project/cbearden/data/Enigma/IoP/raw/fixed_mislabelled/GQAIMS16
cp -rv /u/project/cbearden/data/Enigma/IoP/raw/GQAIMS16/DICOM/014334 /u/project/cbearden/data/Enigma/IoP/raw/fixed_mislabelled/GQAIMS16/014334
cp -rv /u/project/cbearden/data/Enigma/IoP/raw/GQAIMS16/GQAIMS16/DICOM/014334/* /u/project/cbearden/data/Enigma/IoP/raw/fixed_mislabelled/GQAIMS16/014334/
mkdir /u/project/cbearden/data/Enigma/IoP/raw/fixed_mislabelled/GQAIMS16/dcm_unzip
for sub in GQAIMS16; do for d in /u/project/cbearden/data/Enigma/IoP/raw/fixed_mislabelled/${sub}/*/*tar.bz2; do tar -xvjf ${d} -C /u/project/cbearden/data/Enigma/IoP/raw/fixed_mislabelled/${sub}/dcm_unzip;done;done
for sub in GQAIMS16; do idir=/u/project/cbearden/data/Enigma/IoP/qunex_studyfolder/sessions/inbox/MR/${sub}; mkdir $idir; for d in /u/project/cbearden/data/Enigma/IoP/raw/fixed_mislabelled/${sub}/dcm_unzip/* ; do dir=$(basename ${d});for f in /u/project/cbearden/data/Enigma/IoP/raw/fixed_mislabelled/${sub}/dcm_unzip//${dir}/*dcm ;do cp -v ${f} ${idir}/${dir}_$(basename ${f});done;done;done

## import DICOMs 
/u/project/cbearden/data/scripts/tools/qunex_bin/hoffman_submit_qunex.sh \
--qunex_command="import_dicom" \
--qunex_options="--sessionsfolder=/u/project/cbearden/data/Enigma/IoP/qunex_studyfolder/sessions --gzip=yes --check=any" \
--scheduler_options="-l h_data=16G,h_rt=24:00:00,arch=intel*" \
--logdir="/u/project/cbearden/data/Enigma/IoP/qunex_studyfolder/processing/logs/manual" \
--array="no" 
## HCP mapping
/u/project/cbearden/data/scripts/tools/qunex_bin/hoffman_submit_qunex.sh \
--qunex_command="create_session_info" \
--qunex_options="--overwrite=no --sourcefile=session.txt --targetfile=session_hcp.txt --pipelines=hcp --mapping=/u/project/cbearden/data/Enigma/IoP/qunex_studyfolder/sessions/specs/IoP_HCP_mapping.txt --sessionsfolder=/u/project/cbearden/data/Enigma/IoP/qunex_studyfolder/sessions" \
--scheduler_options="-l h_data=8G,h_rt=4:00:00,arch=intel*" \
--logdir="/u/project/cbearden/data/Enigma/IoP/qunex_studyfolder/processing/logs/manual" \
--array="no" 
## create batch file (update previous to include three new sessions)
/u/project/cbearden/data/scripts/tools/qunex_bin/hoffman_submit_qunex.sh \
--qunex_command="create_batch" \
--qunex_options=" --overwrite=yes --sessionsfolder=/u/project/cbearden/data/Enigma/IoP/qunex_studyfolder/sessions --sourcefiles=session_hcp.txt --targetfile=/u/project/cbearden/data/Enigma/IoP/qunex_studyfolder/processing/IoP_batch.txt --paramfile=/u/project/cbearden/data/Enigma/IoP/qunex_studyfolder/sessions/specs/IoP_params.txt --sessions=GQAIMS01,GQAIMS01B,GQAIMS02,GQAIMS02B,GQAIMS03,GQAIMS04,GQAIMS04B,GQAIMS05,GQAIMS05B,GQAIMS06,GQAIMS07,GQAIMS08,GQAIMS08B,GQAIMS09,GQAIMS11,GQAIMS11B,GQAIMS12,GQAIMS13,GQAIMS15,GQAIMS16,GQAIMS17,GQAIMS18,GQAIMS20,GQAIMS21,GQAIMS22,GQAIMS23,GQAIMS24,GQAIMS25,GQAIMS27,GQAIMS28,GQAIMS29,GQAIMS30,GQAIMS31,GQAIMS32,GQAIMS33,GQAIMS34,GQAIMS35,GQAIMS37,GQAIMS39,GQAIMS40,GQAIMS40B,GQAIMS41,GQAIMS42,GQAIMS43,GQAIMS47,GQAIMS49,GQAIMS50,GQAIMS51,GQAIMS52,GQAIMS53,GQAIMS55,GQAIMS56,GQAIMS58,GQAIMS59,GQAIMS60,GQAIMS61,GQAIMS62,GQAIMS63,GQAIMS64,GQAIMS65,GQAIMS66,GQAIMS67,,GQAIMS69,GQAIMS70,GQAIMS72,GQAIMS73,GQAIMS76,GQAIMS79,GQAIMS80,GQAIMS82,GQAIMS83,GQAIMS84,GQAIMS85,GQAIMS86,GQAIMS87,GQAIMS88,GQAIMS89,GQAIMS90,GQAIMS91,GQAIMS92,GQAIMS93,GQAIMS94" \
--scheduler_options="-l h_data=4G,h_rt=4:00:00,arch=intel*" \
--logdir="/u/project/cbearden/data/Enigma/IoP/qunex_studyfolder/processing/logs/manual" \
--array="no" 
## setup hcp
/u/project/cbearden/data/scripts/tools/qunex_bin/hoffman_submit_qunex.sh \
--qunex_command="setup_hcp" \
--qunex_options="--sessionsfolder=/u/project/cbearden/data/Enigma/IoP/qunex_studyfolder/sessions --sourcefile=session_hcp.txt" \
--scheduler_options="-l h_data=8G,h_rt=4:00:00,arch=intel*" \
--logdir="/u/project/cbearden/data/Enigma/IoP/qunex_studyfolder/processing/logs/manual" \
--array="yes" \
--sessions="GQAIMS16 GQAIMS69"
## PreFreeSurfer
/u/project/cbearden/data/scripts/tools/qunex_bin/hoffman_submit_qunex.sh \
--qunex_command="hcp_pre_freesurfer" \
--qunex_options="--sessions=/u/project/cbearden/data/Enigma/IoP/qunex_studyfolder/processing/IoP_batch.txt --sessionsfolder=/u/project/cbearden/data/Enigma/IoP/qunex_studyfolder/sessions --parsessions=1 --overwrite=no" \
--scheduler_options="-l h_data=16G,h_rt=24:00:00,arch=intel*" \
--logdir="/u/project/cbearden/data/Enigma/IoP/qunex_studyfolder/processing/logs/manual" \
--array="yes" \
--sessions="GQAIMS16 GQAIMS69"
## FreeSurfer
/u/project/cbearden/data/scripts/tools/qunex_bin/hoffman_submit_qunex.sh \
--qunex_command="hcp_freesurfer" \
--qunex_options="--sessions=/u/project/cbearden/data/Enigma/IoP/qunex_studyfolder/processing/IoP_batch.txt --sessionsfolder=/u/project/cbearden/data/Enigma/IoP/qunex_studyfolder/sessions --parsessions=1 --overwrite=no" \
--scheduler_options="-l h_data=20G,h_rt=48:00:00,arch=intel*,highp" \
--logdir="/u/project/cbearden/data/Enigma/IoP/qunex_studyfolder/processing/logs/manual" \
--array="yes" \
--sessions="GQAIMS16 GQAIMS69"
## PostFreeSurfer
/u/project/cbearden/data/scripts/tools/qunex_bin/hoffman_submit_qunex.sh \
--qunex_command="hcp_post_freesurfer" \
--qunex_options="--sessions=/u/project/cbearden/data/Enigma/IoP/qunex_studyfolder/processing/IoP_batch.txt --sessionsfolder=/u/project/cbearden/data/Enigma/IoP/qunex_studyfolder/sessions --parsessions=1 --overwrite=no" \
--scheduler_options="-l h_data=16G,h_rt=24:00:00,arch=intel*" \
--logdir="/u/project/cbearden/data/Enigma/IoP/qunex_studyfolder/processing/logs/manual" \
--array="yes" \
--sessions="GQAIMS16 GQAIMS69"
## FMRI VOLUME
/u/project/cbearden/data/scripts/tools/qunex_bin/hoffman_submit_qunex.sh \
--qunex_command="hcp_fmri_volume" \
--qunex_options="--sessions=/u/project/cbearden/data/Enigma/IoP/qunex_studyfolder/processing/IoP_batch.txt --sessionsfolder=/u/project/cbearden/data/Enigma/IoP/qunex_studyfolder/sessions --parsessions=1 --overwrite=no" \
--scheduler_options="-l h_data=16G,h_rt=24:00:00,arch=intel*" \
--logdir="/u/project/cbearden/data/Enigma/IoP/qunex_studyfolder/processing/logs/manual" \
--array="yes" \
--sessions="GQAIMS16 GQAIMS69"
## FMRI SURFACE
/u/project/cbearden/data/scripts/tools/qunex_bin/hoffman_submit_qunex.sh \
--qunex_command="hcp_fmri_surface" \
--qunex_options="--sessions=/u/project/cbearden/data/Enigma/IoP/qunex_studyfolder/processing/IoP_batch.txt --sessionsfolder=/u/project/cbearden/data/Enigma/IoP/qunex_studyfolder/sessions --parsessions=1 --overwrite=no" \
--scheduler_options="-l h_data=16G,h_rt=24:00:00,arch=intel*" \
--logdir="/u/project/cbearden/data/Enigma/IoP/qunex_studyfolder/processing/logs/manual" \
--array="yes" \
--sessions="GQAIMS76"
## map hcp data
/u/project/cbearden/data/scripts/tools/qunex_bin/hoffman_submit_qunex.sh \
--qunex_command="map_hcp_data" \
--qunex_options=" --overwrite=yes --bolds=resting --sessions=/u/project/cbearden/data/Enigma/IoP/qunex_studyfolder/processing/IoP_batch.txt --sessionsfolder=/u/project/cbearden/data/Enigma/IoP/qunex_studyfolder/sessions" \
--scheduler_options="-l h_data=20G,h_rt=1:00:00,arch=intel*" \
--array="yes" \
--logdir="/u/project/cbearden/data/Enigma/IoP/qunex_studyfolder/processing/logs/manual" \
--sessions="GQAIMS76"
## brain masks
/u/project/cbearden/data/scripts/tools/qunex_bin/hoffman_submit_qunex.sh \
--qunex_command="create_bold_brain_masks" \
--qunex_options="--overwrite=yes --sessions=/u/project/cbearden/data/Enigma/IoP/qunex_studyfolder/processing/IoP_batch.txt --sessionsfolder=/u/project/cbearden/data/Enigma/IoP/qunex_studyfolder/sessions" \
--scheduler_options="-l h_data=20G,h_rt=1:00:00,arch=intel*" \
--array="yes" \
--logdir="/u/project/cbearden/data/Enigma/IoP/qunex_studyfolder/processing/logs/manual" \
--sessions="GQAIMS76"
## bold stats
/u/project/cbearden/data/scripts/tools/qunex_bin/hoffman_submit_qunex.sh \
--qunex_command="compute_bold_stats" \
--qunex_options="--overwrite=yes --bolds=resting --sessions=/u/project/cbearden/data/Enigma/IoP/qunex_studyfolder/processing/IoP_batch.txt --sessionsfolder=/u/project/cbearden/data/Enigma/IoP/qunex_studyfolder/sessions" \
--scheduler_options="-l h_data=20G,h_rt=1:00:00,arch=intel*" \
--array="yes" \
--logdir="/u/project/cbearden/data/Enigma/IoP/qunex_studyfolder/processing/logs/manual" \
--sessions="GQAIMS76"
## create stats report
/u/project/cbearden/data/scripts/tools/qunex_bin/hoffman_submit_qunex.sh \
--qunex_command="create_stats_report" \
--qunex_options="--overwrite=yes --bolds=resting --sessions=/u/project/cbearden/data/Enigma/IoP/qunex_studyfolder/processing/IoP_batch.txt --sessionsfolder=/u/project/cbearden/data/Enigma/IoP/qunex_studyfolder/sessions" \
--scheduler_options="-l h_data=20G,h_rt=1:00:00,arch=intel*" \
--array="yes" \
--logdir="/u/project/cbearden/data/Enigma/IoP/qunex_studyfolder/processing/logs/manual" \
--sessions="GQAIMS76"
## extract nuisance signal
/u/project/cbearden/data/scripts/tools/qunex_bin/hoffman_submit_qunex.sh \
--qunex_command="extract_nuisance_signal" \
--qunex_options="--overwrite=yes --bolds=resting --sessions=/u/project/cbearden/data/Enigma/IoP/qunex_studyfolder/processing/IoP_batch.txt --sessionsfolder=/u/project/cbearden/data/Enigma/IoP/qunex_studyfolder/sessions" \
--scheduler_options="-l h_data=20G,h_rt=1:00:00,arch=intel*" \
--array="yes" \
--logdir="/u/project/cbearden/data/Enigma/IoP/qunex_studyfolder/processing/logs/manual" \
--sessions="GQAIMS76"
## preprocess bold CIFTI no GSR
/u/project/cbearden/data/scripts/tools/qunex_bin/hoffman_submit_qunex.sh \
--qunex_command="preprocess_bold" \
--qunex_options="--overwrite=yes --bolds=resting --bold_actions=s,h,r,c,l --bold_nuisance=m,V,WM,1d --image_target=dtseries --sessions=/u/project/cbearden/data/Enigma/IoP/qunex_studyfolder/processing/IoP_batch.txt --sessionsfolder=/u/project/cbearden/data/Enigma/IoP/qunex_studyfolder/sessions" \
--scheduler_options="-l h_data=20G,h_rt=1:00:00,arch=intel*" \
--array="yes" \
--logdir="/u/project/cbearden/data/Enigma/IoP/qunex_studyfolder/processing/logs/manual" \
--sessions="GQAIMS76"
## preprocess bold CIFTI GSR
/u/project/cbearden/data/scripts/tools/qunex_bin/hoffman_submit_qunex.sh \
--qunex_command="preprocess_bold" \
--qunex_options="--overwrite=yes --bolds=resting --bold_actions=s,h,r,c,l --bold_nuisance=m,V,WM,WB,1d --image_target=dtseries --sessions=/u/project/cbearden/data/Enigma/IoP/qunex_studyfolder/processing/IoP_batch.txt --sessionsfolder=/u/project/cbearden/data/Enigma/IoP/qunex_studyfolder/sessions" \
--scheduler_options="-l h_data=20G,h_rt=1:00:00,arch=intel*" \
--array="yes" \
--logdir="/u/project/cbearden/data/Enigma/IoP/qunex_studyfolder/processing/logs/manual" \
--sessions="GQAIMS76"


# final check for check GSR and noGSR for everything in sessions dir
cd /u/project/cbearden/data/Enigma/IoP/qunex_studyfolder/sessions
sessions=G*
echo GSR
for i in $sessions; do if [[ -f ${i}/images/functional/bold1_Atlas_s_hpss_res-mVWMWB1d_lpss.dtseries.nii  ]] || [[ -f ${i}/images/functional/bold2_Atlas_s_hpss_res-mVWMWB1d_lpss.dtseries.nii  ]]; then echo ${i} has processed BOLD; else echo ${i} MISSING; fi; done
echo noGSR
for i in $sessions; do if [[ -f ${i}/images/functional/bold1_Atlas_s_hpss_res-mVWM1d_lpss.dtseries.nii  ]] || [[ -f ${i}/images/functional/bold2_Atlas_s_hpss_res-mVWM1d_lpss.dtseries.nii  ]]; then echo ${i} has processed BOLD; else echo ${i} MISSING; fi; done


#####################################################################
### re-check T1w QC
#####################################################################
sessions="GQAIMS01 GQAIMS02 GQAIMS03 GQAIMS04 GQAIMS05 GQAIMS06 GQAIMS07 GQAIMS08 GQAIMS09 GQAIMS11 GQAIMS12 GQAIMS13 GQAIMS15 GQAIMS16 GQAIMS17 GQAIMS18 GQAIMS20 GQAIMS21 GQAIMS22 GQAIMS23 GQAIMS24 GQAIMS25 GQAIMS27 GQAIMS28 GQAIMS29 GQAIMS30 GQAIMS31 GQAIMS32 GQAIMS33 GQAIMS34 GQAIMS35 GQAIMS37 GQAIMS39 GQAIMS40 GQAIMS41 GQAIMS42 GQAIMS43 GQAIMS47 GQAIMS49 GQAIMS50 GQAIMS51 GQAIMS52 GQAIMS53 GQAIMS55 GQAIMS56 GQAIMS58 GQAIMS59 GQAIMS60 GQAIMS61 GQAIMS62 GQAIMS63 GQAIMS64 GQAIMS65 GQAIMS66 GQAIMS67 GQAIMS69 GQAIMS72 GQAIMS73 GQAIMS76 GQAIMS79 GQAIMS80 GQAIMS82 GQAIMS83 GQAIMS84 GQAIMS85 GQAIMS86 GQAIMS87 GQAIMS88 GQAIMS89 GQAIMS90 GQAIMS91 GQAIMS92 GQAIMS93 GQAIMS94"

# check T1w QC image for each session, while manually recording results in 22q_BOLD_Longitudinal_multisite_QC_cs.xlsx
# fail any session with obvious bad T1 (motion, intense banding, signal dropout in brain), pass all others
# note if failing for a neuroanatomical variation
for sesh in $sessions; do echo ${sesh}; display /u/project/cbearden/data/Enigma/IoP/qunex_studyfolder/sessions/${sesh}/hcp/${sesh}/MNINonLinear/StructuralQC/snapshots/${sesh}.structuralQC.wb_scene1.png;done



#####################################################################
### Seed-based BOLD functional connectivity
#####################################################################
# https://bitbucket.org/oriadev/qunex/wiki/UsageDocs/BOLDFunctionalConnectivity.md


# subcortical seeds -- bandpass, GSR, reading boldn for bold rest from session_hcp.txt
# n=65
sessions="GQAIMS01 GQAIMS02 GQAIMS03 GQAIMS04 GQAIMS05 GQAIMS06 GQAIMS07 GQAIMS08 GQAIMS09 GQAIMS11 GQAIMS12 GQAIMS13 GQAIMS15 GQAIMS16 GQAIMS17 GQAIMS20 GQAIMS21 GQAIMS22 GQAIMS23 GQAIMS24 GQAIMS28 GQAIMS29 GQAIMS30 GQAIMS31 GQAIMS33 GQAIMS34 GQAIMS35 GQAIMS37 GQAIMS39 GQAIMS41 GQAIMS42 GQAIMS43 GQAIMS47 GQAIMS49 GQAIMS50 GQAIMS51 GQAIMS52 GQAIMS53 GQAIMS58 GQAIMS59 GQAIMS61 GQAIMS62 GQAIMS63 GQAIMS64 GQAIMS65 GQAIMS66 GQAIMS67 GQAIMS69 GQAIMS72 GQAIMS73 GQAIMS76 GQAIMS79 GQAIMS80 GQAIMS82 GQAIMS84 GQAIMS85 GQAIMS86 GQAIMS87 GQAIMS88 GQAIMS89 GQAIMS90 GQAIMS91 GQAIMS92 GQAIMS93 GQAIMS94"
sdir=/u/project/cbearden/data/Enigma/IoP/qunex_studyfolder/sessions/
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
--logdir="/u/project/cbearden/data/Enigma/IoP/qunex_studyfolder/processing/logs/manual" \
--sessions=${sesh}
done

# subcortical seeds -- bandpass, no GSR, reading boldn for bold rest from session_hcp.txt
# n=65
sessions="GQAIMS01 GQAIMS02 GQAIMS03 GQAIMS04 GQAIMS05 GQAIMS06 GQAIMS07 GQAIMS08 GQAIMS09 GQAIMS11 GQAIMS12 GQAIMS13 GQAIMS15 GQAIMS16 GQAIMS17 GQAIMS20 GQAIMS21 GQAIMS22 GQAIMS23 GQAIMS24 GQAIMS28 GQAIMS29 GQAIMS30 GQAIMS31 GQAIMS33 GQAIMS34 GQAIMS35 GQAIMS37 GQAIMS39 GQAIMS41 GQAIMS42 GQAIMS43 GQAIMS47 GQAIMS49 GQAIMS50 GQAIMS51 GQAIMS52 GQAIMS53 GQAIMS58 GQAIMS59 GQAIMS61 GQAIMS62 GQAIMS63 GQAIMS64 GQAIMS65 GQAIMS66 GQAIMS67 GQAIMS69 GQAIMS72 GQAIMS73 GQAIMS76 GQAIMS79 GQAIMS80 GQAIMS82 GQAIMS84 GQAIMS85 GQAIMS86 GQAIMS87 GQAIMS88 GQAIMS89 GQAIMS90 GQAIMS91 GQAIMS92 GQAIMS93 GQAIMS94"
sdir=/u/project/cbearden/data/Enigma/IoP/qunex_studyfolder/sessions/
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
--logdir="/u/project/cbearden/data/Enigma/IoP/qunex_studyfolder/processing/logs/manual" \
--sessions=${sesh}
done


#####################################################################
### Global BOLD functional connectivity
#####################################################################

## Global Brain Connectivity
# GSR, bandpass
sessions="GQAIMS01 GQAIMS02 GQAIMS03 GQAIMS04 GQAIMS05 GQAIMS06 GQAIMS07 GQAIMS08 GQAIMS09 GQAIMS11 GQAIMS12 GQAIMS13 GQAIMS15 GQAIMS16 GQAIMS17 GQAIMS20 GQAIMS21 GQAIMS22 GQAIMS23 GQAIMS24 GQAIMS28 GQAIMS29 GQAIMS30 GQAIMS31 GQAIMS33 GQAIMS34 GQAIMS35 GQAIMS37 GQAIMS39 GQAIMS41 GQAIMS42 GQAIMS43 GQAIMS47 GQAIMS49 GQAIMS50 GQAIMS51 GQAIMS52 GQAIMS53 GQAIMS58 GQAIMS59 GQAIMS61 GQAIMS62 GQAIMS63 GQAIMS64 GQAIMS65 GQAIMS66 GQAIMS67 GQAIMS69 GQAIMS72 GQAIMS73 GQAIMS76 GQAIMS79 GQAIMS80 GQAIMS82 GQAIMS84 GQAIMS85 GQAIMS86 GQAIMS87 GQAIMS88 GQAIMS89 GQAIMS90 GQAIMS91 GQAIMS92 GQAIMS93 GQAIMS94"
sdir=/u/project/cbearden/data/Enigma/IoP/qunex_studyfolder/sessions/
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
--logdir="/u/project/cbearden/data/Enigma/IoP/qunex_studyfolder/processing/logs/manual" \
--sessions=${sesh}
done


## Global Brain Connectivity
# no GSR, bandpass
sessions="GQAIMS01 GQAIMS02 GQAIMS03 GQAIMS04 GQAIMS05 GQAIMS06 GQAIMS07 GQAIMS08 GQAIMS09 GQAIMS11 GQAIMS12 GQAIMS13 GQAIMS15 GQAIMS16 GQAIMS17 GQAIMS20 GQAIMS21 GQAIMS22 GQAIMS23 GQAIMS24 GQAIMS28 GQAIMS29 GQAIMS30 GQAIMS31 GQAIMS33 GQAIMS34 GQAIMS35 GQAIMS37 GQAIMS39 GQAIMS41 GQAIMS42 GQAIMS43 GQAIMS47 GQAIMS49 GQAIMS50 GQAIMS51 GQAIMS52 GQAIMS53 GQAIMS58 GQAIMS59 GQAIMS61 GQAIMS62 GQAIMS63 GQAIMS64 GQAIMS65 GQAIMS66 GQAIMS67 GQAIMS69 GQAIMS72 GQAIMS73 GQAIMS76 GQAIMS79 GQAIMS80 GQAIMS82 GQAIMS84 GQAIMS85 GQAIMS86 GQAIMS87 GQAIMS88 GQAIMS89 GQAIMS90 GQAIMS91 GQAIMS92 GQAIMS93 GQAIMS94"
sdir=/u/project/cbearden/data/Enigma/IoP/qunex_studyfolder/sessions/
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
--logdir="/u/project/cbearden/data/Enigma/IoP/qunex_studyfolder/processing/logs/manual" \
--sessions=${sesh}
done

