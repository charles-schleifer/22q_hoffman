#!/bin/bash

# C.Schleifer 8/2021
# script to edit session_hcp.txt files to only use the first T1w and T2w (without intensity normalization) and edit subject field

# get seshdir and sessions from arguments
for a in "$@"; do
  case $a in
    --seshdir=*)
      seshdir="${a#*=}"
      shift 
      ;;
    --sessions=*)
      sessions="${a#*=}"
      shift 
      ;;
      
    *)
      echo "ERROR. Unknown option: ${a}"
      exit 0
      ;;
  esac
done
echo seshdir: $seshdir
echo sessions: $sessions

cd $seshdir

for sesh in $sessions; do
	for tn in T1w T2w; do 
		n=$(cat ${seshdir}/${sesh}/session_hcp.txt | grep $tn | wc -l)
		if [[ n -eq 2 ]]; then
			line=$(cat /u/project/cbearden/data/22qPrisma/qunex_studyfolder/sessions/${sesh}/session_hcp.txt | grep $tn | tail -n1)
			 sed -i "s/${line}/\#${line}/" ${seshdir}/${sesh}/session_hcp.txt 
			
		else
			echo "${sesh} has ${n} ${tn} images, need to manually edit session_hcp.txt"
			echo "${sesh} : ${tn} : ${n}" >> ${seshdir}/specs/check_t1_t2_for_these_sessions.txt		
		fi
	done	
	subject="Q_$(echo ${sesh} | cut -d "_" -f 2)"
	sed -i "/subject/c subject: ${subject}" ${seshdir}/${sesh}/session_hcp.txt 
done
