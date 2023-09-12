#!/bin/sh

# script to create csv with scanner type and list of runs for all raw 22q data 
# loops through all sessions in raw/22q
# if next subdir starts with T* scanner is Trio, if P* scanner is prisma
# run list is the contents of the 3rd level subdir 

rdir="/u/project/cbearden/data/raw/22q"
outfile="/u/project/cbearden/data/raw/22q/session_info_22q_raw.csv"
echo "session,scanner,n_ADNI_MPRAGE,n_RESTING,all_runs" > $outfile

for path in ${rdir}/Q_*; do 
	echo $path
	case=$(basename $path)
	echo $case
	
	if (test -d ${path}/T* ); then 
		scanner="Trio"
	elif (test -d ${path}/P* ); then 
		scanner="Prisma"
	else 
		scanner="unknown"
	fi
	echo $scanner
	
	if [[ $scanner == "Trio" ]]; then
		scans=$(ls ${path}/T*/[0-9]*/*/ | xargs)
	elif [[ $scanner == "Prisma" ]]; then
		scans=$(ls ${path}/P*/[0-9]*/*/ | xargs)
	fi
	
	restingn=$(echo ${scans} | grep -o "RESTING" | wc -l)
	t1n=$(echo ${scans} | grep -o "ADNI_MPRAGE" | wc -l)
	
	echo $scans
	echo "${case},${scanner},${t1n},${restingn},${scans}" >> $outfile
done