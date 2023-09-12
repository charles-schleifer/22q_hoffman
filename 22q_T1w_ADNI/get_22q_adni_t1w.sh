#!/bin/bash
# script to find and copy all ADNI_MPRAGE T1w scans from multiple locations for prisma and trio data

# path to hoffman data
hoffman="/u/project/cbearden/data/"

# study dirs
trio="/22q/qunex_studyfolder/sessions/"
prisma="/22qPrisma/qunex_studyfolder/sessions/"
triosmri="/22q/qunex_studyfolder/sessions_sMRIonly/"
prismasmri="/22qPrisma/qunex_studyfolder/sessions_sMRIonly/"
prismasmriadni="/22qPrisma/qunex_studyfolder/sessions_sMRIonly/ADNI_only"

# output path to organize files
opath="/u/project/cbearden/data/22q_T1w_all/"
echo "MISSING_ADNI_MPRAGE" > ${opath}/missing_adni_sessions.txt

# loop through subjects in each study
for study in $trio $prisma $triosmri $prismasmri $prismasmriadni; do
	echo $study
	case $study in
		${prismasmriadni})
		studydir=${hoffman}/${prismasmriadni}
		sessions=$(ls -d ${studydir}/Q_*)
		;;		
		${triosmri})
		studydir=${hoffman}/${triosmri}
		sessions=$(ls -d ${studydir}/Q_*)
		;;
		${prismasmri})
		studydir=${hoffman}/${prismasmri}
		sessions=$(ls -d ${studydir}/Q_*)
		;;		
		${trio})
		studydir=${hoffman}/${trio}
		sessions=$(ls -d ${studydir}/Q_*)
		;;
		${prisma})
		studydir=${hoffman}/${prisma}
		sessions=$(ls -d ${studydir}/Q_*)
		;;
	esac
	for seshpath in $sessions; do
		sesh=$(basename $seshpath)
		echo $sesh
		# set up paths
		seshdir=${studydir}/${sesh}
		# get ADNI_MPRAGE nii numbers from session_hcp.txt
		adni=$(cat ${seshdir}/session_hcp.txt | grep "ADNI_MPRAGE" | cut -d " "  -f 1)
		if [[  -z $adni  ]];then
			echo $sesh >> ${opath}/missing_adni_sessions.txt
		else
			odir=${opath}/sessions/${sesh}/nifti
			mkdir -p $odir
			cp -v ${seshdir}/session_hcp.txt $odir
			for n in $adni; do
				cp -v ${seshdir}/nii/${n}.* $odir
			done
		fi
	done
done

