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
--qunex_options="--studyfolder=/u/project/cbearden/data/Enigma/SUNY/qunex_studyfolder" \
--scheduler_options="-l h_data=8G,h_rt=2:00:00" \
--logdir="/u/project/cbearden/data/Enigma/SUNY/" \
--array="no" 

# 2. organize dicoms into inbox
bash /u/project/cbearden/data/Enigma/SUNY/qunex_studyfolder/processing/scripts/SUNY_organize_raw.sh

## 3. import DICOMs 
/u/project/cbearden/data/scripts/tools/qunex_bin/hoffman_submit_qunex.sh \
--qunex_command="import_dicom" \
--qunex_options="--sessionsfolder=/u/project/cbearden/data/Enigma/SUNY/qunex_studyfolder/sessions --gzip=yes --check=any" \
--scheduler_options="-l h_data=16G,h_rt=24:00:00" \
--logdir="/u/project/cbearden/data/Enigma/SUNY/qunex_studyfolder/processing/logs/manual" \
--array="no" 

## 4. set up HCP mapping file
# get list of unique runs to use when manually setting up mapping file
seshdir=/u/project/cbearden/data/Enigma/SUNY/qunex_studyfolder/sessions/
rm ${seshdir}/specs/all_runs.txt
for i in ${seshdir}/X*; do cat ${i}/session.txt | grep '^[0-9]' >> ${seshdir}/specs/all_runs.txt; done
cut ${seshdir}/specs/all_runs.txt -d : -f 2 | sort | uniq > ${seshdir}/specs/unique_runs.txt

# 5. only run names are "BOLD - RESTING" "MPRAGE_SAG_BWM" so mapping file is easy
echo "MPRAGE_SAG_BWM => T1w" > /u/project/cbearden/data/Enigma/SUNY/qunex_studyfolder/sessions/specs/SUNY_HCP_mapping.txt
echo "BOLD - RESTING => bold:resting" >> /u/project/cbearden/data/Enigma/SUNY/qunex_studyfolder/sessions/specs/SUNY_HCP_mapping.txt

## 6. HCP mapping
/u/project/cbearden/data/scripts/tools/qunex_bin/hoffman_submit_qunex.sh \
--qunex_command="create_session_info" \
--qunex_options="--overwrite=no --sourcefile=session.txt --targetfile=session_hcp.txt --pipelines=hcp --mapping=/u/project/cbearden/data/Enigma/SUNY/qunex_studyfolder/sessions/specs/SUNY_HCP_mapping.txt --sessionsfolder=/u/project/cbearden/data/Enigma/SUNY/qunex_studyfolder/sessions" \
--scheduler_options="-l h_data=8G,h_rt=4:00:00" \
--logdir="/u/project/cbearden/data/Enigma/SUNY/qunex_studyfolder/processing/logs/manual" \
--array="no" 

# 7. get list of sessions with a BOLD run
for i in /u/project/cbearden/data/Enigma/SUNY/qunex_studyfolder/sessions/X*; do if [ 0 -ne $(cat $i/session_hcp.txt | grep -c "BOLD") ];then echo $(basename $i);fi;done
#sessions="X002 X004 X005 X008 X010 X014 X018 X019 X020 X023 X024 X027 X028 X029 X030 X031 X032 X034 X041 X042 X043 X047 X061 X064 X066 X068 X073 X078 X084 X086 X108 X109 X111 X117 X119 X123 X124 X125 X126 X128 X132 X135 X137 X138 X139 X143 X145 X146 X149 X152 X155 X157 X166 X167 X170 X174 X176 X183 X189 X191 X192 X194 X196 X198 X203 X204 X205 X206 X214 X215 X218 X225 X228 X231 X232 X233 X234 X236"

## 8. Setup HCP
/u/project/cbearden/data/scripts/tools/qunex_bin/hoffman_submit_qunex.sh \
--qunex_command="setup_hcp" \
--qunex_options="--sessionsfolder=/u/project/cbearden/data/Enigma/SUNY/qunex_studyfolder/sessions --sourcefile=session_hcp.txt" \
--scheduler_options="-l h_data=8G,h_rt=4:00:00" \
--logdir="/u/project/cbearden/data/Enigma/SUNY/qunex_studyfolder/processing/logs/manual" \
--array="yes" \
--sessions="X002 X004 X005 X008 X010 X014 X018 X019 X020 X023 X024 X027 X028 X029 X030 X031 X032 X034 X041 X042 X043 X047 X061 X064 X066 X068 X073 X078 X084 X086 X108 X109 X111 X117 X119 X123 X124 X125 X126 X128 X132 X135 X137 X138 X139 X143 X145 X146 X149 X152 X155 X157 X166 X167 X170 X174 X176 X183 X189 X191 X192 X194 X196 X198 X203 X204 X205 X206 X214 X215 X218 X225 X228 X231 X232 X233 X234 X236"

## 9. create batch file
# first copy over param file from 22qTrio 
cp /u/project/cbearden/data/22q/qunex_studyfolder/sessions/specs/22q_trio_params.txt /u/project/cbearden/data/Enigma/SUNY/qunex_studyfolder/sessions/specs/SUNY_params.txt
# IMPORTANT: need to manually edit SUNY params to match acquisition.
# BOLD TR=2
# TO-DO: check if interleaved acquisition _hcp_bold_slicetimerparams : --odd
# currently setting params to skip slice time correction _hcp_bold_doslicetime   : NONE
/u/project/cbearden/data/scripts/tools/qunex_bin/hoffman_submit_qunex.sh \
--qunex_command="create_batch" \
--qunex_options=" --overwrite=yes --sessionsfolder=/u/project/cbearden/data/Enigma/SUNY/qunex_studyfolder/sessions --sourcefiles=session_hcp.txt --targetfile=/u/project/cbearden/data/Enigma/SUNY/qunex_studyfolder/processing/SUNY_batch.txt --paramfile=/u/project/cbearden/data/Enigma/SUNY/qunex_studyfolder/sessions/specs/SUNY_params.txt --sessions=X002,X004,X005,X008,X010,X014,X018,X019,X020,X023,X024,X027,X028,X029,X030,X031,X032,X034,X041,X042,X043,X047,X061,X064,X066,X068,X073,X078,X084,X086,X108,X109,X111,X117,X119,X123,X124,X125,X126,X128,X132,X135,X137,X138,X139,X143,X145,X146,X149,X152,X155,X157,X166,X167,X170,X174,X176,X183,X189,X191,X192,X194,X196,X198,X203,X204,X205,X206,X214,X215,X218,X225,X228,X231,X232,X233,X234,X236" \
--scheduler_options="-l h_data=4G,h_rt=4:00:00" \
--logdir="/u/project/cbearden/data/Enigma/SUNY/qunex_studyfolder/processing/logs/manual" \
--array="no" 

#####################################################################
### HCP steps
#####################################################################

## 10. PreFreeSurfer
/u/project/cbearden/data/scripts/tools/qunex_bin/hoffman_submit_qunex.sh \
--qunex_command="hcp_pre_freesurfer" \
--qunex_options="--sessions=/u/project/cbearden/data/Enigma/SUNY/qunex_studyfolder/processing/SUNY_batch.txt --sessionsfolder=/u/project/cbearden/data/Enigma/SUNY/qunex_studyfolder/sessions --parsessions=1 --overwrite=no" \
--scheduler_options="-l h_data=16G,h_rt=24:00:00" \
--logdir="/u/project/cbearden/data/Enigma/SUNY/qunex_studyfolder/processing/logs/manual" \
--array="yes" \
--sessions="X002 X004 X005 X008 X010 X014 X018 X019 X020 X023 X024 X027 X028 X029 X030 X031 X032 X034 X041 X042 X043 X047 X061 X064 X066 X068 X073 X078 X084 X086 X108 X109 X111 X117 X119 X123 X124 X125 X126 X128 X132 X135 X137 X138 X139 X143 X145 X146 X149 X152 X155 X157 X166 X167 X170 X174 X176 X183 X189 X191 X192 X194 X196 X198 X203 X204 X205 X206 X214 X215 X218 X225 X228 X231 X232 X233 X234 X236"

## 11. FreeSurfer
/u/project/cbearden/data/scripts/tools/qunex_bin/hoffman_submit_qunex.sh \
--qunex_command="hcp_freesurfer" \
--qunex_options="--sessions=/u/project/cbearden/data/Enigma/SUNY/qunex_studyfolder/processing/SUNY_batch.txt --sessionsfolder=/u/project/cbearden/data/Enigma/SUNY/qunex_studyfolder/sessions --parsessions=1 --overwrite=no" \
--scheduler_options="-l h_data=16G,h_rt=48:00:00,highp" \
--logdir="/u/project/cbearden/data/Enigma/SUNY/qunex_studyfolder/processing/logs/manual" \
--array="yes" \
--sessions="X002 X004 X005 X008 X010 X014 X018 X019 X020 X023 X024 X027 X028 X029 X030 X031 X032 X034 X041 X042 X043 X047 X061 X064 X066 X068 X073 X078 X084 X086 X108 X109 X111 X117 X119 X123 X124 X125 X126 X128 X132 X135 X137 X138 X139 X143 X145 X146 X149 X152 X155 X157 X166 X167 X170 X174 X176 X183 X189 X191 X192 X194 X196 X198 X203 X204 X205 X206 X214 X215 X218 X225 X228 X231 X232 X233 X234 X236"

## 12. PostFreeSurfer
/u/project/cbearden/data/scripts/tools/qunex_bin/hoffman_submit_qunex.sh \
--qunex_command="hcp_post_freesurfer" \
--qunex_options="--sessions=/u/project/cbearden/data/Enigma/SUNY/qunex_studyfolder/processing/SUNY_batch.txt --sessionsfolder=/u/project/cbearden/data/Enigma/SUNY/qunex_studyfolder/sessions --parsessions=1 --overwrite=no" \
--scheduler_options="-l h_data=16G,h_rt=24:00:00" \
--logdir="/u/project/cbearden/data/Enigma/SUNY/qunex_studyfolder/processing/logs/manual" \
--array="yes" \
--sessions="X002 X004 X005 X008 X010 X014 X018 X019 X020 X023 X024 X027 X028 X029 X030 X031 X032 X034 X041 X042 X043 X047 X061 X064 X066 X068 X073 X078 X084 X086 X108 X109 X111 X117 X119 X123 X124 X125 X126 X128 X132 X135 X137 X138 X139 X143 X145 X146 X149 X152 X155 X157 X166 X167 X170 X174 X176 X183 X189 X191 X192 X194 X196 X198 X203 X204 X205 X206 X214 X215 X218 X225 X228 X231 X232 X233 X234 X236"

## 13. FMRI VOLUME
/u/project/cbearden/data/scripts/tools/qunex_bin/hoffman_submit_qunex.sh \
--qunex_command="hcp_fmri_volume" \
--qunex_options="--sessions=/u/project/cbearden/data/Enigma/SUNY/qunex_studyfolder/processing/SUNY_batch.txt --sessionsfolder=/u/project/cbearden/data/Enigma/SUNY/qunex_studyfolder/sessions --parsessions=1 --overwrite=no" \
--scheduler_options="-l h_data=16G,h_rt=24:00:00" \
--logdir="/u/project/cbearden/data/Enigma/SUNY/qunex_studyfolder/processing/logs/manual" \
--array="yes" \
--sessions="X002 X004 X005 X008 X010 X014 X018 X019 X020 X023 X024 X027 X028 X029 X030 X031 X032 X034 X041 X042 X043 X047 X061 X064 X066 X068 X073 X078 X084 X086 X108 X109 X111 X117 X119 X123 X124 X125 X126 X128 X132 X135 X137 X138 X139 X143 X145 X146 X149 X152 X155 X157 X166 X167 X170 X174 X176 X183 X189 X191 X192 X194 X196 X198 X203 X204 X205 X206 X214 X215 X218 X225 X228 X231 X232 X233 X234 X236"

## 14. FMRI SURFACE
/u/project/cbearden/data/scripts/tools/qunex_bin/hoffman_submit_qunex.sh \
--qunex_command="hcp_fmri_surface" \
--qunex_options="--sessions=/u/project/cbearden/data/Enigma/SUNY/qunex_studyfolder/processing/SUNY_batch.txt --sessionsfolder=/u/project/cbearden/data/Enigma/SUNY/qunex_studyfolder/sessions --parsessions=1 --overwrite=no" \
--scheduler_options="-l h_data=16G,h_rt=24:00:00" \
--logdir="/u/project/cbearden/data/Enigma/SUNY/qunex_studyfolder/processing/logs/manual" \
--array="yes" \
--sessions="X002 X004 X005 X008 X010 X014 X018 X019 X020 X023 X024 X027 X028 X029 X030 X031 X032 X034 X041 X042 X043 X047 X061 X064 X066 X068 X073 X078 X084 X086 X108 X109 X111 X117 X119 X123 X124 X125 X126 X128 X132 X135 X137 X138 X139 X143 X145 X146 X149 X152 X155 X157 X166 X167 X170 X174 X176 X183 X189 X191 X192 X194 X196 X198 X203 X204 X205 X206 X214 X215 X218 X225 X228 X231 X232 X233 X234 X236"

#####################################################################
### BOLD post-processing
#####################################################################
# https://bitbucket.org/oriadev/qunex/wiki/UsageDocs/BOLDPreprocessing.md
# https://bitbucket.org/oriadev/qunex/wiki/UsageDocs/MovementScrubbing.md

## map hcp data
/u/project/cbearden/data/scripts/tools/qunex_bin/hoffman_submit_qunex.sh \
--qunex_command="map_hcp_data" \
--qunex_options=" --overwrite=yes --bolds=resting --sessions=/u/project/cbearden/data/Enigma/SUNY/qunex_studyfolder/processing/SUNY_batch.txt --sessionsfolder=/u/project/cbearden/data/Enigma/SUNY/qunex_studyfolder/sessions" \
--scheduler_options="-l h_data=20G,h_rt=4:00:00,arch=intel*" \
--array="yes" \
--logdir="/u/project/cbearden/data/Enigma/SUNY/qunex_studyfolder/processing/logs/manual" \
--sessions="X002 X004 X005 X008 X010 X014 X018 X019 X020 X023 X024 X027 X028 X029 X030 X031 X032 X034 X041 X042 X043 X047 X061 X064 X066 X068 X073 X078 X084 X086 X108 X109 X111 X117 X119 X123 X124 X125 X126 X128 X132 X135 X137 X138 X139 X143 X145 X146 X149 X152 X155 X157 X166 X167 X170 X174 X176 X183 X189 X191 X192 X194 X196 X198 X203 X204 X205 X206 X214 X215 X218 X225 X228 X231 X232 X233 X234 X236"

## brain masks
/u/project/cbearden/data/scripts/tools/qunex_bin/hoffman_submit_qunex.sh \
--qunex_command="create_bold_brain_masks" \
--qunex_options="--overwrite=yes --sessions=/u/project/cbearden/data/Enigma/SUNY/qunex_studyfolder/processing/SUNY_batch.txt --sessionsfolder=/u/project/cbearden/data/Enigma/SUNY/qunex_studyfolder/sessions" \
--scheduler_options="-l h_data=20G,h_rt=4:00:00,arch=intel*" \
--array="yes" \
--logdir="/u/project/cbearden/data/Enigma/SUNY/qunex_studyfolder/processing/logs/manual" \
--sessions="X002 X004 X005 X008 X010 X014 X018 X019 X020 X023 X024 X027 X028 X029 X030 X031 X032 X034 X041 X042 X043 X047 X061 X064 X066 X068 X073 X078 X084 X086 X108 X109 X111 X117 X119 X123 X124 X125 X126 X128 X132 X135 X137 X138 X139 X143 X145 X146 X149 X152 X155 X157 X166 X167 X170 X174 X176 X183 X189 X191 X192 X194 X196 X198 X203 X204 X205 X206 X214 X215 X218 X225 X228 X231 X232 X233 X234 X236"

## bold stats
/u/project/cbearden/data/scripts/tools/qunex_bin/hoffman_submit_qunex.sh \
--qunex_command="compute_bold_stats" \
--qunex_options="--overwrite=yes --bolds=resting --sessions=/u/project/cbearden/data/Enigma/SUNY/qunex_studyfolder/processing/SUNY_batch.txt --sessionsfolder=/u/project/cbearden/data/Enigma/SUNY/qunex_studyfolder/sessions" \
--scheduler_options="-l h_data=20G,h_rt=4:00:00,arch=intel*" \
--array="yes" \
--logdir="/u/project/cbearden/data/Enigma/SUNY/qunex_studyfolder/processing/logs/manual" \
--sessions="X002 X004 X005 X008 X010 X014 X018 X019 X020 X023 X024 X027 X028 X029 X030 X031 X032 X034 X041 X042 X043 X047 X061 X064 X066 X068 X073 X078 X084 X086 X108 X109 X111 X117 X119 X123 X124 X125 X126 X128 X132 X135 X137 X138 X139 X143 X145 X146 X149 X152 X155 X157 X166 X167 X170 X174 X176 X183 X189 X191 X192 X194 X196 X198 X203 X204 X205 X206 X214 X215 X218 X225 X228 X231 X232 X233 X234 X236"
   
## create stats report
/u/project/cbearden/data/scripts/tools/qunex_bin/hoffman_submit_qunex.sh \
--qunex_command="create_stats_report" \
--qunex_options="--overwrite=yes --bolds=resting --sessions=/u/project/cbearden/data/Enigma/SUNY/qunex_studyfolder/processing/SUNY_batch.txt --sessionsfolder=/u/project/cbearden/data/Enigma/SUNY/qunex_studyfolder/sessions" \
--scheduler_options="-l h_data=20G,h_rt=4:00:00,arch=intel*" \
--array="yes" \
--logdir="/u/project/cbearden/data/Enigma/SUNY/qunex_studyfolder/processing/logs/manual" \
--sessions="X002 X004 X005 X008 X010 X014 X018 X019 X020 X023 X024 X027 X028 X029 X030 X031 X032 X034 X041 X042 X043 X047 X061 X064 X066 X068 X073 X078 X084 X086 X108 X109 X111 X117 X119 X123 X124 X125 X126 X128 X132 X135 X137 X138 X139 X143 X145 X146 X149 X152 X155 X157 X166 X167 X170 X174 X176 X183 X189 X191 X192 X194 X196 X198 X203 X204 X205 X206 X214 X215 X218 X225 X228 X231 X232 X233 X234 X236"

## extract nuisance signal
/u/project/cbearden/data/scripts/tools/qunex_bin/hoffman_submit_qunex.sh \
--qunex_command="extract_nuisance_signal" \
--qunex_options="--overwrite=yes --bolds=resting --sessions=/u/project/cbearden/data/Enigma/SUNY/qunex_studyfolder/processing/SUNY_batch.txt --sessionsfolder=/u/project/cbearden/data/Enigma/SUNY/qunex_studyfolder/sessions" \
--scheduler_options="-l h_data=20G,h_rt=4:00:00,arch=intel*" \
--array="yes" \
--logdir="/u/project/cbearden/data/Enigma/SUNY/qunex_studyfolder/processing/logs/manual" \
--sessions="X002 X004 X005 X008 X010 X014 X018 X019 X020 X023 X024 X027 X028 X029 X030 X031 X032 X034 X041 X042 X043 X047 X061 X064 X066 X068 X073 X078 X084 X086 X108 X109 X111 X117 X119 X123 X124 X125 X126 X128 X132 X135 X137 X138 X139 X143 X145 X146 X149 X152 X155 X157 X166 X167 X170 X174 X176 X183 X189 X191 X192 X194 X196 X198 X203 X204 X205 X206 X214 X215 X218 X225 X228 X231 X232 X233 X234 X236"

## preprocess bold CIFTI no GSR
/u/project/cbearden/data/scripts/tools/qunex_bin/hoffman_submit_qunex.sh \
--qunex_command="preprocess_bold" \
--qunex_options="--overwrite=yes --bolds=resting --bold_actions=s,h,r,c,l --bold_nuisance=m,V,WM,1d --image_target=dtseries --sessions=/u/project/cbearden/data/Enigma/SUNY/qunex_studyfolder/processing/SUNY_batch.txt --sessionsfolder=/u/project/cbearden/data/Enigma/SUNY/qunex_studyfolder/sessions" \
--scheduler_options="-l h_data=20G,h_rt=4:00:00,arch=intel*" \
--array="yes" \
--logdir="/u/project/cbearden/data/Enigma/SUNY/qunex_studyfolder/processing/logs/manual" \
--sessions="X002 X004 X005 X008 X010 X014 X018 X019 X020 X023 X024 X027 X028 X029 X030 X031 X032 X034 X041 X042 X043 X047 X061 X064 X066 X068 X073 X078 X084 X086 X108 X109 X111 X117 X119 X123 X124 X125 X126 X128 X132 X135 X137 X138 X139 X143 X145 X146 X149 X152 X155 X157 X166 X167 X170 X174 X176 X183 X189 X191 X192 X194 X196 X198 X203 X204 X205 X206 X214 X215 X218 X225 X228 X231 X232 X233 X234 X236"

## preprocess bold CIFTI GSR
/u/project/cbearden/data/scripts/tools/qunex_bin/hoffman_submit_qunex.sh \
--qunex_command="preprocess_bold" \
--qunex_options="--overwrite=yes --bolds=resting --bold_actions=s,h,r,c,l --bold_nuisance=m,V,WM,WB,1d --image_target=dtseries --sessions=/u/project/cbearden/data/Enigma/SUNY/qunex_studyfolder/processing/SUNY_batch.txt --sessionsfolder=/u/project/cbearden/data/Enigma/SUNY/qunex_studyfolder/sessions" \
--scheduler_options="-l h_data=20G,h_rt=4:00:00,arch=intel*" \
--array="yes" \
--logdir="/u/project/cbearden/data/Enigma/SUNY/qunex_studyfolder/processing/logs/manual" \
--sessions="X002 X004 X005 X008 X010 X014 X018 X019 X020 X023 X024 X027 X028 X029 X030 X031 X032 X034 X041 X042 X043 X047 X061 X064 X066 X068 X073 X078 X084 X086 X108 X109 X111 X117 X119 X123 X124 X125 X126 X128 X132 X135 X137 X138 X139 X143 X145 X146 X149 X152 X155 X157 X166 X167 X170 X174 X176 X183 X189 X191 X192 X194 X196 X198 X203 X204 X205 X206 X214 X215 X218 X225 X228 X231 X232 X233 X234 X236"


#####################################################################
### re-run failed sessions
#####################################################################
sessions="X002 X004 X005 X008 X010 X014 X018 X019 X020 X023 X024 X027 X028 X029 X030 X031 X032 X034 X041 X042 X043 X047 X061 X064 X066 X068 X073 X078 X084 X086 X108 X109 X111 X117 X119 X123 X124 X125 X126 X128 X132 X135 X137 X138 X139 X143 X145 X146 X149 X152 X155 X157 X166 X167 X170 X174 X176 X183 X189 X191 X192 X194 X196 X198 X203 X204 X205 X206 X214 X215 X218 X225 X228 X231 X232 X233 X234 X236"
# check which sessions finished
#for i in $sessions; do if [[ -f ${i}/images/functional/bold1_Atlas_s_hpss_res-mVWMWB1d_lpss.dtseries.nii  ]]; then echo ${i} has processed BOLD; fi; done
#for i in $sessions; do if [[ ! -f ${i}/images/functional/bold1_Atlas_s_hpss_res-mVWMWB1d_lpss.dtseries.nii  ]]; then echo ${i} missing processed BOLD; fi; done
for i in $sessions; do if [[ -f ${i}/images/functional/bold1_Atlas_s_hpss_res-mVWMWB1d_lpss.dtseries.nii  ]] || [[ -f ${i}/images/functional/bold2_Atlas_s_hpss_res-mVWMWB1d_lpss.dtseries.nii  ]]; then echo ${i} has processed BOLD; else echo ${i} MISSING; fi; done

# sessions that didn't finish
rerun_sessions="X023 X028 X152"
# sessions with BOLD but no t1w: "X234"
# sessions with no BOLD: "X121 X171 X219 X222 X235 X237"

# re-run each step for these sessions
# Setup HCP
/u/project/cbearden/data/scripts/tools/qunex_bin/hoffman_submit_qunex.sh \
--qunex_command="setup_hcp" \
--qunex_options="--sessionsfolder=/u/project/cbearden/data/Enigma/SUNY/qunex_studyfolder/sessions --sourcefile=session_hcp.txt" \
--scheduler_options="-l h_data=20G,h_rt=4:00:00,arch=intel*" \
--logdir="/u/project/cbearden/data/Enigma/SUNY/qunex_studyfolder/processing/logs/manual" \
--array="yes" \
--sessions="X028"
# PreFreeSurfer
/u/project/cbearden/data/scripts/tools/qunex_bin/hoffman_submit_qunex.sh \
--qunex_command="hcp_pre_freesurfer" \
--qunex_options="--sessions=/u/project/cbearden/data/Enigma/SUNY/qunex_studyfolder/processing/SUNY_batch.txt --sessionsfolder=/u/project/cbearden/data/Enigma/SUNY/qunex_studyfolder/sessions --parsessions=1 --overwrite=no" \
--scheduler_options="-l h_data=20G,h_rt=24:00:00,arch=intel*" \
--logdir="/u/project/cbearden/data/Enigma/SUNY/qunex_studyfolder/processing/logs/manual" \
--array="yes" \
--sessions="X028"
# FreeSurfer
/u/project/cbearden/data/scripts/tools/qunex_bin/hoffman_submit_qunex.sh \
--qunex_command="hcp_freesurfer" \
--qunex_options="--sessions=/u/project/cbearden/data/Enigma/SUNY/qunex_studyfolder/processing/SUNY_batch.txt --sessionsfolder=/u/project/cbearden/data/Enigma/SUNY/qunex_studyfolder/sessions --parsessions=1 --overwrite=no" \
--scheduler_options="-l h_data=20G,h_rt=24:00:00,arch=intel*" \
--logdir="/u/project/cbearden/data/Enigma/SUNY/qunex_studyfolder/processing/logs/manual" \
--array="yes" \
--sessions="X028"
# PostFreeSurfer
/u/project/cbearden/data/scripts/tools/qunex_bin/hoffman_submit_qunex.sh \
--qunex_command="hcp_post_freesurfer" \
--qunex_options="--sessions=/u/project/cbearden/data/Enigma/SUNY/qunex_studyfolder/processing/SUNY_batch.txt --sessionsfolder=/u/project/cbearden/data/Enigma/SUNY/qunex_studyfolder/sessions --parsessions=1 --overwrite=no" \
--scheduler_options="-l h_data=20G,h_rt=24:00:00,arch=intel*" \
--logdir="/u/project/cbearden/data/Enigma/SUNY/qunex_studyfolder/processing/logs/manual" \
--array="yes" \
--sessions="X028"
# FMRI VOLUME
/u/project/cbearden/data/scripts/tools/qunex_bin/hoffman_submit_qunex.sh \
--qunex_command="hcp_fmri_volume" \
--qunex_options="--sessions=/u/project/cbearden/data/Enigma/SUNY/qunex_studyfolder/processing/SUNY_batch.txt --sessionsfolder=/u/project/cbearden/data/Enigma/SUNY/qunex_studyfolder/sessions --parsessions=1 --overwrite=no" \
--scheduler_options="-l h_data=20G,h_rt=24:00:00,arch=intel*" \
--logdir="/u/project/cbearden/data/Enigma/SUNY/qunex_studyfolder/processing/logs/manual" \
--array="yes" \
--sessions="X028"
# FMRI SURFACE
/u/project/cbearden/data/scripts/tools/qunex_bin/hoffman_submit_qunex.sh \
--qunex_command="hcp_fmri_surface" \
--qunex_options="--sessions=/u/project/cbearden/data/Enigma/SUNY/qunex_studyfolder/processing/SUNY_batch.txt --sessionsfolder=/u/project/cbearden/data/Enigma/SUNY/qunex_studyfolder/sessions --parsessions=1 --overwrite=no" \
--scheduler_options="-l h_data=20G,h_rt=24:00:00,arch=intel*" \
--logdir="/u/project/cbearden/data/Enigma/SUNY/qunex_studyfolder/processing/logs/manual" \
--array="yes" \
--sessions="X028"
# map hcp data
/u/project/cbearden/data/scripts/tools/qunex_bin/hoffman_submit_qunex.sh \
--qunex_command="map_hcp_data" \
--qunex_options=" --overwrite=yes --bolds=resting --sessions=/u/project/cbearden/data/Enigma/SUNY/qunex_studyfolder/processing/SUNY_batch.txt --sessionsfolder=/u/project/cbearden/data/Enigma/SUNY/qunex_studyfolder/sessions" \
--scheduler_options="-l h_data=20G,h_rt=4:00:00,arch=intel*" \
--array="yes" \
--logdir="/u/project/cbearden/data/Enigma/SUNY/qunex_studyfolder/processing/logs/manual" \
--sessions="X028"
# brain masks
/u/project/cbearden/data/scripts/tools/qunex_bin/hoffman_submit_qunex.sh \
--qunex_command="create_bold_brain_masks" \
--qunex_options="--overwrite=yes --sessions=/u/project/cbearden/data/Enigma/SUNY/qunex_studyfolder/processing/SUNY_batch.txt --sessionsfolder=/u/project/cbearden/data/Enigma/SUNY/qunex_studyfolder/sessions" \
--scheduler_options="-l h_data=20G,h_rt=4:00:00,arch=intel*" \
--array="yes" \
--logdir="/u/project/cbearden/data/Enigma/SUNY/qunex_studyfolder/processing/logs/manual" \
--sessions="X028"
# bold stats
/u/project/cbearden/data/scripts/tools/qunex_bin/hoffman_submit_qunex.sh \
--qunex_command="compute_bold_stats" \
--qunex_options="--overwrite=yes --bolds=resting --sessions=/u/project/cbearden/data/Enigma/SUNY/qunex_studyfolder/processing/SUNY_batch.txt --sessionsfolder=/u/project/cbearden/data/Enigma/SUNY/qunex_studyfolder/sessions" \
--scheduler_options="-l h_data=20G,h_rt=4:00:00,arch=intel*" \
--array="yes" \
--logdir="/u/project/cbearden/data/Enigma/SUNY/qunex_studyfolder/processing/logs/manual" \
--sessions="X028"
# create stats report
/u/project/cbearden/data/scripts/tools/qunex_bin/hoffman_submit_qunex.sh \
--qunex_command="create_stats_report" \
--qunex_options="--overwrite=yes --bolds=resting --sessions=/u/project/cbearden/data/Enigma/SUNY/qunex_studyfolder/processing/SUNY_batch.txt --sessionsfolder=/u/project/cbearden/data/Enigma/SUNY/qunex_studyfolder/sessions" \
--scheduler_options="-l h_data=20G,h_rt=4:00:00,arch=intel*" \
--array="yes" \
--logdir="/u/project/cbearden/data/Enigma/SUNY/qunex_studyfolder/processing/logs/manual" \
--sessions="X028"
# extract nuisance signal
/u/project/cbearden/data/scripts/tools/qunex_bin/hoffman_submit_qunex.sh \
--qunex_command="extract_nuisance_signal" \
--qunex_options="--overwrite=yes --bolds=resting --sessions=/u/project/cbearden/data/Enigma/SUNY/qunex_studyfolder/processing/SUNY_batch.txt --sessionsfolder=/u/project/cbearden/data/Enigma/SUNY/qunex_studyfolder/sessions" \
--scheduler_options="-l h_data=20G,h_rt=4:00:00,arch=intel*" \
--array="yes" \
--logdir="/u/project/cbearden/data/Enigma/SUNY/qunex_studyfolder/processing/logs/manual" \
--sessions="X028"
# preprocess bold CIFTI no GSR
/u/project/cbearden/data/scripts/tools/qunex_bin/hoffman_submit_qunex.sh \
--qunex_command="preprocess_bold" \
--qunex_options="--overwrite=yes --bolds=resting --bold_actions=s,h,r,c,l --bold_nuisance=m,V,WM,1d --image_target=dtseries --sessions=/u/project/cbearden/data/Enigma/SUNY/qunex_studyfolder/processing/SUNY_batch.txt --sessionsfolder=/u/project/cbearden/data/Enigma/SUNY/qunex_studyfolder/sessions" \
--scheduler_options="-l h_data=20G,h_rt=4:00:00,arch=intel*" \
--array="yes" \
--logdir="/u/project/cbearden/data/Enigma/SUNY/qunex_studyfolder/processing/logs/manual" \
--sessions="X023 X152"
# preprocess bold CIFTI GSR
/u/project/cbearden/data/scripts/tools/qunex_bin/hoffman_submit_qunex.sh \
--qunex_command="preprocess_bold" \
--qunex_options="--overwrite=yes --bolds=resting --bold_actions=s,h,r,c,l --bold_nuisance=m,V,WM,WB,1d --image_target=dtseries --sessions=/u/project/cbearden/data/Enigma/SUNY/qunex_studyfolder/processing/SUNY_batch.txt --sessionsfolder=/u/project/cbearden/data/Enigma/SUNY/qunex_studyfolder/sessions" \
--scheduler_options="-l h_data=20G,h_rt=4:00:00,arch=intel*" \
--array="yes" \
--logdir="/u/project/cbearden/data/Enigma/SUNY/qunex_studyfolder/processing/logs/manual" \
--sessions="X028"


# final check for check GSR and noGSR for everything in sessions dir
cd /u/project/cbearden/data/Enigma/SUNY/qunex_studyfolder/sessions
sessions=X*
echo GSR
for i in $sessions; do if [[ -f ${i}/images/functional/bold1_Atlas_s_hpss_res-mVWMWB1d_lpss.dtseries.nii  ]] || [[ -f ${i}/images/functional/bold2_Atlas_s_hpss_res-mVWMWB1d_lpss.dtseries.nii  ]]; then echo ${i} has processed BOLD; else echo ${i} MISSING; fi; done
echo noGSR
for i in $sessions; do if [[ -f ${i}/images/functional/bold1_Atlas_s_hpss_res-mVWM1d_lpss.dtseries.nii  ]] || [[ -f ${i}/images/functional/bold2_Atlas_s_hpss_res-mVWM1d_lpss.dtseries.nii  ]]; then echo ${i} has processed BOLD; else echo ${i} MISSING; fi; done



#####################################################################
### re-run seed-based BOLD functional connectivity
#####################################################################
# https://bitbucket.org/oriadev/qunex/wiki/UsageDocs/BOLDFunctionalConnectivity.md

# subcortical seeds -- bandpass, GSR, reading boldn for bold rest from session_hcp.txt
# n=77
sessions="X002 X004 X005 X008 X010 X014 X018 X019 X020 X023 X024 X027 X028 X029 X030 X031 X032 X034 X041 X042 X043 X047 X061 X064 X066 X068 X073 X078 X084 X086 X108 X109 X111 X117 X119 X123 X124 X125 X126 X128 X132 X135 X137 X138 X139 X143 X145 X146 X149 X152 X155 X157 X166 X167 X170 X174 X176 X183 X189 X191 X192 X194 X196 X198 X203 X204 X205 X206 X214 X215 X218 X225 X228 X231 X232 X233 X236"
sdir=/u/project/cbearden/data/Enigma/SUNY/qunex_studyfolder/sessions/
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
--logdir="/u/project/cbearden/data/Enigma/SUNY/qunex_studyfolder/processing/logs/manual" \
--sessions=${sesh}
done

# subcortical seeds -- bandpass, no GSR, reading boldn for bold rest from session_hcp.txt
# n=77
sessions="X002 X004 X005 X008 X010 X014 X018 X019 X020 X023 X024 X027 X028 X029 X030 X031 X032 X034 X041 X042 X043 X047 X061 X064 X066 X068 X073 X078 X084 X086 X108 X109 X111 X117 X119 X123 X124 X125 X126 X128 X132 X135 X137 X138 X139 X143 X145 X146 X149 X152 X155 X157 X166 X167 X170 X174 X176 X183 X189 X191 X192 X194 X196 X198 X203 X204 X205 X206 X214 X215 X218 X225 X228 X231 X232 X233 X236"
sdir=/u/project/cbearden/data/Enigma/SUNY/qunex_studyfolder/sessions/
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
--logdir="/u/project/cbearden/data/Enigma/SUNY/qunex_studyfolder/processing/logs/manual" \
--sessions=${sesh}
done


#####################################################################
### Global BOLD functional connectivity
#####################################################################

## Global Brain Connectivity
# GSR, bandpass
sessions="X002 X004 X005 X008 X010 X014 X018 X019 X020 X023 X024 X027 X028 X029 X030 X031 X032 X034 X041 X042 X043 X047 X061 X064 X066 X068 X073 X078 X084 X086 X108 X109 X111 X117 X119 X123 X124 X125 X126 X128 X132 X135 X137 X138 X139 X143 X145 X146 X149 X152 X155 X157 X166 X167 X170 X174 X176 X183 X189 X191 X192 X194 X196 X198 X203 X204 X205 X206 X214 X215 X218 X225 X228 X231 X232 X233 X236"
sdir=/u/project/cbearden/data/Enigma/SUNY/qunex_studyfolder/sessions/
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
--logdir="/u/project/cbearden/data/Enigma/SUNY/qunex_studyfolder/processing/logs/manual" \
--sessions=${sesh}
done


## Global Brain Connectivity
# no GSR, bandpass
sessions="X002 X004 X005 X008 X010 X014 X018 X019 X020 X023 X024 X027 X028 X029 X030 X031 X032 X034 X041 X042 X043 X047 X061 X064 X066 X068 X073 X078 X084 X086 X108 X109 X111 X117 X119 X123 X124 X125 X126 X128 X132 X135 X137 X138 X139 X143 X145 X146 X149 X152 X155 X157 X166 X167 X170 X174 X176 X183 X189 X191 X192 X194 X196 X198 X203 X204 X205 X206 X214 X215 X218 X225 X228 X231 X232 X233 X236"
sdir=/u/project/cbearden/data/Enigma/SUNY/qunex_studyfolder/sessions/
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
--logdir="/u/project/cbearden/data/Enigma/SUNY/qunex_studyfolder/processing/logs/manual" \
--sessions=${sesh}
done




#####################################################################
### test ComBat with a couple cases 
#####################################################################

test_combat_sesh="X002 X004 X005 X008 X010"
for i in $test_combat_sesh; do display /u/project/cbearden/data/Enigma/SUNY/qunex_studyfolder/sessions/${i}/hcp/${i}/MNINonLinear/StructuralQC/snapshots/*scene1.png;done

# run this on local computer to copy data over
test_combat_sesh="X002 X004 X005 X008 X010"
uname="schleife"
name_suffix="_Atlas_s_hpss_res-mVWMWB1d_lpss.dtseries.nii"
for i in $test_combat_sesh; do mkdir ~/Desktop/22q_multisite/test/${i}; rsync -avz ${uname}@hoffman2.idre.ucla.edu:/u/project/cbearden/data/Enigma/SUNY/qunex_studyfolder/sessions/${i}/images/functional/bold1${name_suffix} ~/Desktop/22q_multisite/test/${i}/rest${name_suffix};done

# get scan dates from DICOM-report.txt
for i in /u/project/cbearden/data/Enigma/SUNY/qunex_studyfolder/sessions/X*; do cat ${i}/dicom/DICOM-Report.txt | grep "Report for" | sed 's/Report\ for\ //g'| sed s/\ \([a-zA-Z0-9]*\)\ scanned\ on//g | cut -d ' ' -f 1,2 | sed s/\ /\,/g;done > /u/project/cbearden/data/Enigma/SUNY/qunex_studyfolder/sessions/specs/SUNY_scan_dates.txt





