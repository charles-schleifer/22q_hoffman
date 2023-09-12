#!/bin/sh

# script to copy all raw dicoms from raw folder to qunex inbox

# raw study dir
sdir="/u/project/cbearden/data/raw/22qPrisma/"
# target dir
tdir="/u/project/cbearden/data/22qPrisma/qunex_studyfolder/sessions/inbox/MR/"

# copy all raw dicoms, renaming to $sesh_$run_$dicom to avoid name conflicts
for spath in $sdir/Q_0*; do
	sesh="$(basename -- $spath)"
	for rpath in ${spath}/Prisma*/*/BEARDEN*/*; do
		run="$(basename -- $rpath)"
		for dpath in ${rpath}/*; do
			dicom="$(basename -- $dpath)"
			mkdir -p ${tdir}/${sesh} 
			cp ${dpath} ${tdir}/${sesh}/${sesh}_${run}_${dicom} 
		done
	done
done