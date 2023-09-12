#!/bin/sh

source /u/local/Modules/default/init/modules.sh
module load R 

logdir="/u/project/cbearden/data/22q/qunex_studyfolder/processing/logs/manual/"

#sdir="/u/project/cbearden/data/22q/qunex_studyfolder/sessions/"
#for s in ${sdir}/Q_*; do
#	sesh=$(basename $s)
#	qsub -cwd -V -o ${logdir}/22q_bparc_save_individual.$(date +%s).o -e ${logdir}/22q_bparc_save_individual.$(date +%s).e -l h_data=16G,h_rt=24:00:00,arch=intel*  /u/project/cbearden/data/22q/qunex_studyfolder/analysis/scripts/run_bparcel_fc_individual.sh --sessions_dir=${sdir} --sesh=${sesh} --file_end="_Atlas_s_hpss_res-mVWM1d_lpss.dtseries.nii" --bold_name_use="resting"
#	#qsub -cwd -V -o ${logdir}/22q_bparc_save_individual.$(date +%s).o -e ${logdir}/22q_bparc_save_individual.$(date +%s).e -l h_data=16G,h_rt=24:00:00,arch=intel*  /u/project/cbearden/data/22q/qunex_studyfolder/analysis/scripts/run_bparcel_fc_individual.sh --sessions_dir=${sdir} --sesh=${sesh} --file_end="_Atlas_s_hpss_res-mVWMWB1d_lpss.dtseries.nii" --bold_name_use="resting"
#done

#sdir="/u/project/cbearden/data/22qPrisma/qunex_studyfolder/sessions/"
#for s in ${sdir}/Q_*; do
#	sesh=$(basename $s)
#	qsub -cwd -V -o ${logdir}/22q_bparc_save_individual.$(date +%s).o -e ${logdir}/22q_bparc_save_individual.$(date +%s).e -l h_data=16G,h_rt=24:00:00,arch=intel*  /u/project/cbearden/data/22q/qunex_studyfolder/analysis/scripts/run_bparcel_fc_individual.sh --sessions_dir=${sdir} --sesh=${sesh} --file_end="_Atlas_s_hpss_res-mVWM1d_lpss.dtseries.nii" --bold_name_use="restingAP"
#	#qsub -cwd -V -o ${logdir}/22q_bparc_save_individual.$(date +%s).o -e ${logdir}/22q_bparc_save_individual.$(date +%s).e -l h_data=16G,h_rt=24:00:00,arch=intel*  /u/project/cbearden/data/22q/qunex_studyfolder/analysis/scripts/run_bparcel_fc_individual.sh --sessions_dir=${sdir} --sesh=${sesh} --file_end="_Atlas_s_hpss_res-mVWMWB1d_lpss.dtseries.nii" --bold_name_use="restingAP"
#done

sdir="/u/project/cbearden/data/Enigma/IoP/qunex_studyfolder/sessions/"
for s in ${sdir}/GQAIMS*; do
	sesh=$(basename $s)
	qsub -cwd -V -o ${logdir}/22q_bparc_noGSR.$(date +%s).o -e ${logdir}/22q_bparc_noGSR.$(date +%s).e -l h_data=16G,h_rt=24:00:00,arch=intel*  /u/project/cbearden/data/22q/qunex_studyfolder/analysis/scripts/run_bparcel_fc_individual.sh --sessions_dir=${sdir} --sesh=${sesh} --file_end="_Atlas_s_hpss_res-mVWM1d_lpss.dtseries.nii" --bold_name_use="resting"
	qsub -cwd -V -o ${logdir}/22q_bparc_GSR.$(date +%s).o -e ${logdir}/22q_bparc_GSR.$(date +%s).e -l h_data=16G,h_rt=24:00:00,arch=intel*  /u/project/cbearden/data/22q/qunex_studyfolder/analysis/scripts/run_bparcel_fc_individual.sh --sessions_dir=${sdir} --sesh=${sesh} --file_end="_Atlas_s_hpss_res-mVWMWB1d_lpss.dtseries.nii" --bold_name_use="resting"
done

sdir="/u/project/cbearden/data/Enigma/SUNY/qunex_studyfolder/sessions/"
for s in ${sdir}/X*; do
	sesh=$(basename $s)
	qsub -cwd -V -o ${logdir}/22q_bparc_noGSR.$(date +%s).o -e ${logdir}/22q_bparc_noGSR.$(date +%s).e -l h_data=16G,h_rt=24:00:00,arch=intel*  /u/project/cbearden/data/22q/qunex_studyfolder/analysis/scripts/run_bparcel_fc_individual.sh --sessions_dir=${sdir} --sesh=${sesh} --file_end="_Atlas_s_hpss_res-mVWM1d_lpss.dtseries.nii" --bold_name_use="resting"
	qsub -cwd -V -o ${logdir}/22q_bparc_GSR.$(date +%s).o -e ${logdir}/22q_bparc_GSR.$(date +%s).e -l h_data=16G,h_rt=24:00:00,arch=intel*  /u/project/cbearden/data/22q/qunex_studyfolder/analysis/scripts/run_bparcel_fc_individual.sh --sessions_dir=${sdir} --sesh=${sesh} --file_end="_Atlas_s_hpss_res-mVWMWB1d_lpss.dtseries.nii" --bold_name_use="resting"
done

sdir="/u/project/cbearden/data/Enigma/Rome/qunex_studyfolder/sessions/"
for s in ${sdir}/*[0-9]; do
	sesh=$(basename $s)
	qsub -cwd -V -o ${logdir}/22q_bparc_noGSR.$(date +%s).o -e ${logdir}/22q_bparc_noGSR.$(date +%s).e -l h_data=16G,h_rt=24:00:00,arch=intel*  /u/project/cbearden/data/22q/qunex_studyfolder/analysis/scripts/run_bparcel_fc_individual.sh --sessions_dir=${sdir} --sesh=${sesh} --file_end="_Atlas_s_hpss_res-mVWM1d_lpss.dtseries.nii" --bold_name_use="resting"
	qsub -cwd -V -o ${logdir}/22q_bparc_GSR.$(date +%s).o -e ${logdir}/22q_bparc_GSR.$(date +%s).e -l h_data=16G,h_rt=24:00:00,arch=intel*  /u/project/cbearden/data/22q/qunex_studyfolder/analysis/scripts/run_bparcel_fc_individual.sh --sessions_dir=${sdir} --sesh=${sesh} --file_end="_Atlas_s_hpss_res-mVWMWB1d_lpss.dtseries.nii" --bold_name_use="resting"
done