#!/bin/bash

# Script to comment out lines of session_hcp.txt excluding T1w based on QC of raw NIIs for sessions with >1 T1w
# C. Schleifer 8/2021


file=/u/project/cbearden/data/22q/qunex_studyfolder/sessions/QC/rawNII/raw_nii_qc.csv

n=$(awk '{print NR}' $file | tail -n 1)

i=0; while (($i<=$n)); do 
	line=$(head -n $i $file | tail -n 1)
	if [[ $line == Q_* ]]; then 
		echo $line
		echo ""
		use=$(echo $line | cut -d , -f 4 | tr -d '[:space:]')
		sesh=$(echo $line | cut -d , -f 1 | tr -d '[:space:]')
		nii=$(echo $line | cut -d , -f 3 | tr -d '[:space:]')
		if [[ $use == 0 ]]; then
			orig=/u/project/cbearden/data/22q/qunex_studyfolder/sessions/${sesh}/session_hcp_orig.txt
			hcp=/u/project/cbearden/data/22q/qunex_studyfolder/sessions/${sesh}/session_hcp.txt
			if [[ ! -f $orig ]]; then
				cp -v $hcp $orig
			fi
			in=$(cat $hcp | grep ^${nii})
			out="\#${in}"
			sed -i "s/$in/$out/" $hcp
			cat $hcp
		fi
		echo "---"
	fi 
	let i++
done
