#!/bin/sh

source /u/local/Modules/default/init/modules.sh
module load R 

logdir="/u/project/cbearden/data/NAPLS_BOLD/NAPLS2/processing/logs/manual/"

# NAPLS2
sdir="/u/project/cbearden/data/NAPLS_BOLD/NAPLS2/sessions/S_sessions/"
for s in ${sdir}/*07_S*; do
#for s in ${sdir}/*_S*; do
	sesh=$(basename $s)
	echo $sesh
	#qsub -cwd -V -o ${logdir}/${sesh}_NetHo_noGSR.$(date +%s).o -e ${logdir}/${sesh}_NetHo_noGSR.$(date +%s).e -l h_data=16G,h_rt=10:00:00  /u/project/cbearden/data/22q/qunex_studyfolder/analysis/scripts/run_network_homogeneity.sh --sessions_dir=${sdir} --sesh=${sesh} --file_end="_Atlas_s_hpss_res-mVWM1d_lpss.dtseries.nii" --bold_name_use="RESTING" 
	qsub -cwd -V -o ${logdir}/${sesh}_NetHo_GSR.$(date +%s).o -e ${logdir}/${sesh}_NetHo_GSR.$(date +%s).e -l h_data=16G,h_rt=10:00:00  /u/project/cbearden/data/22q/qunex_studyfolder/analysis/scripts/run_network_homogeneity.sh --sessions_dir=${sdir} --sesh=${sesh} --file_end="_Atlas_s_hpss_res-mVWMWB1d_lpss.dtseries.nii" --bold_name_use="RESTING" 
done


