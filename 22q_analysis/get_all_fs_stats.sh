#!/bin/sh

basepath="/u/project/cbearden/data/"

paths="22q/qunex_studyfolder/sessions/ 22qPrisma/qunex_studyfolder/sessions/ Enigma/SUNY/qunex_studyfolder/sessions/ Enigma/Rome/qunex_studyfolder/sessions/ Enigma/IoP/qunex_studyfolder/sessions/ NAPLS_BOLD/NAPLS2/sessions/S_sessions/"

opath="/u/home/s/schleife/hcp_fs_vols/"

for studypath in $paths; do
	# get sessions as any dir in studypath with letter followed by number
	seshpaths=${basepath}/${studypath}/*[a-zA-Z]*[0-9]*
	for spath in $seshpaths; do
		sesh=$(basename $spath)
		mkdir -p ${opath}/${sesh}/
		cp -rv ${basepath}/${studypath}/${sesh}/hcp/${sesh}/T1w/${sesh}/stats ${opath}/${sesh}/
	done
done