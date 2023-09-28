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

# overwrite text file recording sessions to manually edit
echo "need manual edit/check of session_hcp.txt" > ${seshdir}/specs/check_t1_t2_for_these_sessions.txt	

for sesh in $sessions; do
	for tn in T1w T2w; do 
 		# count how many lines have T1w or T2w, find by matching pattern [0-9] : ${tn} because if matching just $tn can overlap multiple protocol names that contain T2 or T1
		n=$(cat ${seshdir}/${sesh}/session_hcp.txt | grep "[0-9] : ${tn}" | wc -l)
		# if there are two lines then comment out the second
		if [[ n -eq 2 ]]; then
			line=$(cat /u/project/cbearden/data/22qPrisma/qunex_studyfolder/sessions/${sesh}/session_hcp.txt | grep $tn | tail -n1)
			 sed -i "s/${line}/\#${line}/" ${seshdir}/${sesh}/session_hcp.txt 
			
		# if only one line matches, do nothing, else record subject 
  		elif [[ n -eq 1 ]]; then
  			continue
  		else
			echo "${sesh} has ${n} ${tn} images, need to manually edit session_hcp.txt"
			echo "${sesh} : ${tn} : ${n}" >> ${seshdir}/specs/check_t1_t2_for_these_sessions.txt		
		fi
	done
 	# edit subject field from Q to Q_nnnn in session_hcp.txt file
	subject="Q_$(echo ${sesh} | cut -d "_" -f 2)"
	sed -i "/subject/c subject: ${subject}" ${seshdir}/${sesh}/session_hcp.txt 
done
