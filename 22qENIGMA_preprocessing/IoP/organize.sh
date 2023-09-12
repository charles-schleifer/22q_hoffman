#!/bin/bash

rawdir=/u/project/cbearden/data/Enigma/IoP/raw/
for s in ${rawdir}/G* ;do
	sub=$(basename ${s})
	echo $sub
	zipdir=${rawdir}/${sub}/dcm_unzip
	mkdir $zipdir
	# unzip
	for d in ${rawdir}/${sub}/DICOM/*/*tar.bz2; do 
		tar -xvjf ${d} -C ${zipdir}
	done
	# now copy to inbox and name to avoid collisions
	idir=/u/project/cbearden/data/Enigma/IoP/qunex_studyfolder/sessions/inbox/MR/${sub}
	mkdir $idir
	for d in ${zipdir}/* ; do 
		dir=$(basename ${d})
		for f in ${zipdir}/${dir}/*dcm ;do 
			cp -v ${f} ${idir}/${dir}_$(basename ${f})
		done
	done
done

