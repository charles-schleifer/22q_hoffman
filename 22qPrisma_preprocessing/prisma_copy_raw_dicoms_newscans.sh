#!/bin/sh

# script to copy all raw dicoms from raw folder to qunex inbox

# raw study dir
sdir="/u/project/cbearden/data/raw/22qPrisma/"
# target dir
tdir="/u/project/cbearden/data/22qPrisma/qunex_studyfolder/sessions/inbox/MR/"

# list of scans
scans="Q_0477_01052022 Q_0484_01042022 Q_0508_06232022 Q_0519_05312022 Q_0520_06012022 Q_0521_05202022 Q_0525_06072022 Q_0526_06242022 Q_0527_07112022 Q_0528_07202022 Q_0529_07202022 Q_0541_07182022 Q_0549_10182022 Q_0561_11032022 Q_0568_10252022"

# copy all raw dicoms, renaming to $sesh_$run_$dicom to avoid name conflicts
for sesh in ${scans}; do
	spath=${sdir}/${sesh}
	echo "copying from ${spath}"
    for rpath in ${spath}/Prisma*/*/BEARDEN*/*; do
		run="$(basename -- $rpath)"
		for dpath in ${rpath}/*; do
			dicom="$(basename -- $dpath)"
			mkdir -p ${tdir}/${sesh} 
			cp -v ${dpath} ${tdir}/${sesh}/${sesh}_${run}_${dicom} 
		done
	done
done