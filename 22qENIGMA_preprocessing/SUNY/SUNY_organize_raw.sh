#!/bin/bash

# script to organize SUNY data and prepare for qunex preprocessing
# BOLD and T2 dicoms are in one location and T1w in another
# need to organize all dicoms in to sessions/inbox/MR/${sesh}/${runname}_*.dcm

# study directory to build
sdir="/u/project/cbearden/data/SUNY"
qsdir=${sdir}/qunex_studyfolder/sessions/
qidir=${qsdir}/inbox/MR/

# main directory containing BOLD and T2 data
bold_t2_dir="/u/project/cbearden/mschrein/homedir/FromLeah"
# directory names inside bold_t2_dir with data
bold_t2_dirs="002_109 019_236 084_228 111_203"

# directory with T1w data (subdirs that end with *-t1w)
t1w_dir="/u/project/cbearden/data/raw/Enigma/SUNY"

# organize T1w
echo "organizing T1w..."
for path in $(ls -d ${t1w_dir}/*-t1w); do
	bn=$(basename ${path})
	sesh=$(echo ${bn} | cut -d "-" -f 1)
	odir=${qidir}/${sesh}
	if (test ! -d ${odir}); then
		mkdir ${odir}
		#echo ${odir}
	fi
	for dcm in $(ls ${path}); do
		dcmpath=${path}/${dcm}
		cp -v ${dcmpath} ${odir}/t1w_${dcm}
		#echo "dcmpath:  ${dcmpath}"
		#echo "target: ${odir}/t1w_${dcm}"
	done
done


# organize BOLD and T2w
echo "organizing BOLD and T2w..."
for dir in ${bold_t2_dirs}; do
	subdir=${bold_t2_dir}/${dir}
	for sesh in $(ls ${subdir}); do
		rawpath=${subdir}/${sesh}/raw
		odir=${qidir}/${sesh}
		if (test ! -d ${odir}); then
			mkdir ${odir}
			#echo ${odir}
		fi
		for run in $(ls ${rawpath});do
			for dcm in $(ls ${rawpath}/${run}/dicom);do
				dcmpath=${rawpath}/${run}/dicom/${dcm}
				cp -v ${dcmpath} ${odir}/${run}_${dcm}
				#echo "dcm:  ${dcm}"
				#echo "target: ${odir}/${run}_${dcm}"
			done
		done
	done
done