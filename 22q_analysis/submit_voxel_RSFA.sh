#!/bin/sh

source /u/local/Modules/default/init/modules.sh
module load R 

logdir="/u/project/cbearden/data/22q/qunex_studyfolder/processing/logs/manual/"

# UCLA trio
sdir="/u/project/cbearden/data/22q/qunex_studyfolder/sessions/"
for s in ${sdir}/Q_*; do
	sesh=$(basename $s)
	echo $sesh
	qsub -cwd -V -o ${logdir}/${sesh}_voxel_RSFA_noGSR.$(date +%s).o -e ${logdir}/${sesh}_voxel_RSFA_noGSR.$(date +%s).e -l h_data=16G,h_rt=10:00:00  /u/project/cbearden/data/22q/qunex_studyfolder/analysis/scripts/run_voxel_RSFA.sh --sessions_dir=${sdir} --sesh=${sesh} --file_end="_Atlas_s_hpss_res-mVWM1d_lpss.dtseries.nii" --bold_name_use="resting"
	qsub -cwd -V -o ${logdir}/${sesh}_voxel_RSFA_GSR.$(date +%s).o -e ${logdir}/${sesh}_voxel_RSFA_GSR.$(date +%s).e -l h_data=16G,h_rt=10:00:00  /u/project/cbearden/data/22q/qunex_studyfolder/analysis/scripts/run_voxel_RSFA.sh --sessions_dir=${sdir} --sesh=${sesh} --file_end="_Atlas_s_hpss_res-mVWMWB1d_lpss.dtseries.nii" --bold_name_use="resting"
done

# UCLA prisma
sdir="/u/project/cbearden/data/22qPrisma/qunex_studyfolder/sessions/"
for s in ${sdir}/Q_*; do
	sesh=$(basename $s)
	echo $sesh
	qsub -cwd -V -o ${logdir}/${sesh}_voxel_RSFA_noGSR.$(date +%s).o -e ${logdir}/${sesh}_voxel_RSFA_noGSR.$(date +%s).e -l h_data=16G,h_rt=10:00:00  /u/project/cbearden/data/22q/qunex_studyfolder/analysis/scripts/run_voxel_RSFA.sh --sessions_dir=${sdir} --sesh=${sesh} --file_end="_Atlas_s_hpss_res-mVWM1d_lpss.dtseries.nii" --bold_name_use="restingAP"
	qsub -cwd -V -o ${logdir}/${sesh}_voxel_RSFA_GSR.$(date +%s).o -e ${logdir}/${sesh}_voxel_RSFA_GSR.$(date +%s).e -l h_data=16G,h_rt=10:00:00  /u/project/cbearden/data/22q/qunex_studyfolder/analysis/scripts/run_voxel_RSFA.sh --sessions_dir=${sdir} --sesh=${sesh} --file_end="_Atlas_s_hpss_res-mVWMWB1d_lpss.dtseries.nii" --bold_name_use="restingAP"
done

# IoP
sdir="/u/project/cbearden/data/Enigma/IoP/qunex_studyfolder/sessions/"
for s in ${sdir}/GQAIMS*; do
	sesh=$(basename $s)
	echo $sesh
	qsub -cwd -V -o ${logdir}/${sesh}_voxel_RSFA_noGSR.$(date +%s).o -e ${logdir}/${sesh}_voxel_RSFA_noGSR.$(date +%s).e -l h_data=16G,h_rt=10:00:00  /u/project/cbearden/data/22q/qunex_studyfolder/analysis/scripts/run_voxel_RSFA.sh --sessions_dir=${sdir} --sesh=${sesh} --file_end="_Atlas_s_hpss_res-mVWM1d_lpss.dtseries.nii" --bold_name_use="resting"
	qsub -cwd -V -o ${logdir}/${sesh}_voxel_RSFA_GSR.$(date +%s).o -e ${logdir}/${sesh}_voxel_RSFA_GSR.$(date +%s).e -l h_data=16G,h_rt=10:00:00  /u/project/cbearden/data/22q/qunex_studyfolder/analysis/scripts/run_voxel_RSFA.sh --sessions_dir=${sdir} --sesh=${sesh} --file_end="_Atlas_s_hpss_res-mVWMWB1d_lpss.dtseries.nii" --bold_name_use="resting"
done

# SUNY
sdir="/u/project/cbearden/data/Enigma/SUNY/qunex_studyfolder/sessions/"
for s in ${sdir}/X*; do
	sesh=$(basename $s)
	echo $sesh
	qsub -cwd -V -o ${logdir}/${sesh}_voxel_RSFA_noGSR.$(date +%s).o -e ${logdir}/${sesh}_voxel_RSFA_noGSR.$(date +%s).e -l h_data=16G,h_rt=10:00:00  /u/project/cbearden/data/22q/qunex_studyfolder/analysis/scripts/run_voxel_RSFA.sh --sessions_dir=${sdir} --sesh=${sesh} --file_end="_Atlas_s_hpss_res-mVWM1d_lpss.dtseries.nii" --bold_name_use="resting"
	qsub -cwd -V -o ${logdir}/${sesh}_voxel_RSFA_GSR.$(date +%s).o -e ${logdir}/${sesh}_voxel_RSFA_GSR.$(date +%s).e -l h_data=16G,h_rt=10:00:00  /u/project/cbearden/data/22q/qunex_studyfolder/analysis/scripts/run_voxel_RSFA.sh --sessions_dir=${sdir} --sesh=${sesh} --file_end="_Atlas_s_hpss_res-mVWMWB1d_lpss.dtseries.nii" --bold_name_use="resting"
done

# Rome
sdir="/u/project/cbearden/data/Enigma/Rome/qunex_studyfolder/sessions/"
for s in ${sdir}/*[0-9]; do
	sesh=$(basename $s)
	echo $sesh
	qsub -cwd -V -o ${logdir}/${sesh}_voxel_RSFA_noGSR.$(date +%s).o -e ${logdir}/${sesh}_voxel_RSFA_noGSR.$(date +%s).e -l h_data=16G,h_rt=10:00:00  /u/project/cbearden/data/22q/qunex_studyfolder/analysis/scripts/run_voxel_RSFA.sh --sessions_dir=${sdir} --sesh=${sesh} --file_end="_Atlas_s_hpss_res-mVWM1d_lpss.dtseries.nii" --bold_name_use="resting"
	qsub -cwd -V -o ${logdir}/${sesh}_voxel_RSFA_GSR.$(date +%s).o -e ${logdir}/${sesh}_voxel_RSFA_GSR.$(date +%s).e -l h_data=16G,h_rt=10:00:00  /u/project/cbearden/data/22q/qunex_studyfolder/analysis/scripts/run_voxel_RSFA.sh --sessions_dir=${sdir} --sesh=${sesh} --file_end="_Atlas_s_hpss_res-mVWMWB1d_lpss.dtseries.nii" --bold_name_use="resting"
done



# qsub -cwd -V -o /u/project/cbearden/data/22q/qunex_studyfolder/processing/logs/manual//test_voxel_RSFA_GSR.$(date +%s).o -e /u/project/cbearden/data/22q/qunex_studyfolder/processing/logs/manual//test_voxel_RSFA_GSR.$(date +%s).e -l h_data=16G,h_rt=4:00:00  /u/project/cbearden/data/22q/qunex_studyfolder/analysis/scripts/run_voxel_RSFA.sh --sessions_dir="/u/project/cbearden/data/22q/qunex_studyfolder/sessions" --sesh="Q_0001_09242012" --file_end="_Atlas_s_hpss_res-mVWMWB1d_lpss.dtseries.nii" --bold_name_use="resting"