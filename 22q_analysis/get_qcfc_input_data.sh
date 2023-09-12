#!/bin/bash

# get between parcel connectivity CSVs for all subjects in trio and prisma

opath="/u/project/cbearden/data/22q/qunex_studyfolder/analysis/fcMRI/sessions/"

for sdir in /u/project/cbearden/data/22q/qunex_studyfolder/sessions/ /u/project/cbearden/data/22qPrisma/qunex_studyfolder/sessions/; do
	for spath in ${sdir}/Q_*; do
		sesh=$(basename $spath)
		fpath=${opath}/${sesh}/images/functional/
		mkdir -p $fpath
		cp -v ${spath}/images/functional/resting*_fc_matrix_Atlas_s_hpss_res-mVWM1d_lpss_CABNP_between_parcel.csv $fpath
		cp -v ${spath}/images/functional/resting*_fc_matrix_Atlas_s_hpss_res-mVWMWB1d_lpss_CABNP_between_parcel.csv $fpath
	done
done