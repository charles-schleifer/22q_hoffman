#!/bin/sh

source /u/local/Modules/default/init/modules.sh
module load R 

logdir="/u/project/cbearden/data/22q/qunex_studyfolder/processing/logs/manual/"

# UCLA trio
sdir="/u/project/cbearden/data/22q/qunex_studyfolder/sessions/"
for s in ${sdir}/Q_*; do
	sesh=$(basename $s)
	echo $sesh
	qsub -cwd -V -o ${logdir}/${sesh}_extract_tc_GSR.$(date +%s).o -e ${logdir}/${sesh}_extract_tc_GSR.$(date +%s).e -l h_data=16G,h_rt=10:00:00  /u/project/cbearden/data/22q/qunex_studyfolder/analysis/scripts/run_extract_tc_individual.sh --sessions_dir=${sdir} --sesh=${sesh} --file_end="_Atlas_s_hpss_res-mVWMWB1d_lpss.dtseries.nii" --bold_name_use="resting"
done

# UCLA prisma
sdir="/u/project/cbearden/data/22qPrisma/qunex_studyfolder/sessions/"
for s in ${sdir}/Q_*; do
	sesh=$(basename $s)
	echo $sesh
	qsub -cwd -V -o ${logdir}/${sesh}_extract_tc_GSR.$(date +%s).o -e ${logdir}/${sesh}_extract_tc_GSR.$(date +%s).e -l h_data=16G,h_rt=10:00:00  /u/project/cbearden/data/22q/qunex_studyfolder/analysis/scripts/run_extract_tc_individual.sh --sessions_dir=${sdir} --sesh=${sesh} --file_end="_Atlas_s_hpss_res-mVWMWB1d_lpss.dtseries.nii" --bold_name_use="restingAP"
done

