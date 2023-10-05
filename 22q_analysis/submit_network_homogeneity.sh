#!/bin/sh

source /u/local/Modules/default/init/modules.sh
module load R 

# SUNY
logdir="/u/project/cbearden/data/Enigma/SUNY/qunex_studyfolder/processing/logs/manual/"
sdir="/u/project/cbearden/data/Enigma/SUNY/qunex_studyfolder/sessions/"
for s in ${sdir}/X*; do
	sesh=$(basename $s)
	echo $sesh
	qsub -cwd -V -o ${logdir}/${sesh}_NetHo_noGSR.$(date +%s).o -e ${logdir}/${sesh}_NetHo_noGSR.$(date +%s).e -l h_data=20G,h_rt=10:00:00  /u/project/cbearden/data/22q/qunex_studyfolder/analysis/scripts/run_network_homogeneity.sh --sessions_dir=${sdir} --sesh=${sesh} --file_end="_Atlas_s_hpss_res-mVWM1d_lpss.dtseries.nii" --bold_name_use="resting" 
	qsub -cwd -V -o ${logdir}/${sesh}_NetHo_GSR.$(date +%s).o -e ${logdir}/${sesh}_NetHo_GSR.$(date +%s).e -l h_data=20G,h_rt=10:00:00  /u/project/cbearden/data/22q/qunex_studyfolder/analysis/scripts/run_network_homogeneity.sh --sessions_dir=${sdir} --sesh=${sesh} --file_end="_Atlas_s_hpss_res-mVWMWB1d_lpss.dtseries.nii" --bold_name_use="resting" 
done


#### won't run below this line
exit

# Rome
logdir="/u/project/cbearden/data/Enigma/Rome/qunex_studyfolder/processing/logs/manual/"
sdir="/u/project/cbearden/data/Enigma/Rome/qunex_studyfolder/sessions/"
for s in ${sdir}/*[0-9]; do
	sesh=$(basename $s)
	echo $sesh
	qsub -cwd -V -o ${logdir}/${sesh}_NetHo_noGSR.$(date +%s).o -e ${logdir}/${sesh}_NetHo_noGSR.$(date +%s).e -l h_data=20G,h_rt=10:00:00  /u/project/cbearden/data/22q/qunex_studyfolder/analysis/scripts/run_network_homogeneity.sh --sessions_dir=${sdir} --sesh=${sesh} --file_end="_Atlas_s_hpss_res-mVWM1d_lpss.dtseries.nii" --bold_name_use="resting" 
	qsub -cwd -V -o ${logdir}/${sesh}_NetHo_GSR.$(date +%s).o -e ${logdir}/${sesh}_NetHo_GSR.$(date +%s).e -l h_data=20G,h_rt=10:00:00  /u/project/cbearden/data/22q/qunex_studyfolder/analysis/scripts/run_network_homogeneity.sh --sessions_dir=${sdir} --sesh=${sesh} --file_end="_Atlas_s_hpss_res-mVWMWB1d_lpss.dtseries.nii" --bold_name_use="resting" 
done


# 22qPrisma
logdir="/u/project/cbearden/data/22qPrisma/qunex_studyfolder/processing/logs/manual/"
sdir="/u/project/cbearden/data/22qPrisma/qunex_studyfolder/sessions/"
sessions="Q_0391_09252018 Q_0402_01112019 Q_0414_07172019 Q_0415_07292019 Q_0429_01092020 Q_0446_06152021 Q_0459_08192021 Q_0519_05312022 Q_0526_06242022 Q_0527_07112022 Q_0561_11032022"
#for s in ${sdir}/*07_S*; do
for sesh in $sessions; do
	#sesh=$(basename $s)
	echo $sesh
	qsub -cwd -V -o ${logdir}/${sesh}_NetHo_noGSR.$(date +%s).o -e ${logdir}/${sesh}_NetHo_noGSR.$(date +%s).e -l h_data=20G,h_rt=10:00:00  /u/project/cbearden/data/22q/qunex_studyfolder/analysis/scripts/run_network_homogeneity.sh --sessions_dir=${sdir} --sesh=${sesh} --file_end="_Atlas_s_hpss_res-mVWM1d_lpss.dtseries.nii" --bold_name_use="restingAP" 
	#qsub -cwd -V -o ${logdir}/${sesh}_NetHo_GSR.$(date +%s).o -e ${logdir}/${sesh}_NetHo_GSR.$(date +%s).e -l h_data=20G,h_rt=10:00:00  /u/project/cbearden/data/22q/qunex_studyfolder/analysis/scripts/run_network_homogeneity.sh --sessions_dir=${sdir} --sesh=${sesh} --file_end="_Atlas_s_hpss_res-mVWMWB1d_lpss.dtseries.nii" --bold_name_use="restingAP" 
done


