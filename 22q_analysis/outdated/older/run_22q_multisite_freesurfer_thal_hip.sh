#!/bin/bash

# Set up freesurfer. Use CCN install, version 7.3.2
export FREESURFER_HOME=/u/project/CCN/apps/freesurfer/rh7/7.3.2/
export SUBJECTS_DIR=$FREESURFER_HOME/subjects
source $FREESURFER_HOME/SetUpFreeSurfer.sh

# study directories
trio='/u/project/cbearden/data/22q/qunex_studyfolder/sessions/'
prisma='/u/project/cbearden/data/22qPrisma/qunex_studyfolder/sessions/'
kcl='/u/project/cbearden/data/Enigma/IoP/qunex_studyfolder/sessions/'
suny='/u/project/cbearden/data/Enigma/SUNY/qunex_studyfolder/sessions/'
rome='/u/project/cbearden/data/Enigma/Rome/qunex_studyfolder/sessions/'
trio_sMRI='/u/project/cbearden/data/22q/qunex_studyfolder/sessions_sMRIonly/'
prisma_sMRI='/u/project/cbearden/data/22qPrisma/qunex_studyfolder/sessions_sMRIonly/'


# loop through all studies
#for study in $trio $prisma $kcl $suny $rome; do 
for study in $trio_sMRI $prisma_sMRI; do 
  echo $study
  # get studydir path and list of sessions for each study
  case $study in
    ${trio})
      studydir=$trio
      sessions=${studydir}/Q_*
      ;;
    ${prisma})
      studydir=$prisma
      sessions=${studydir}/Q_*
      ;;
    ${trio_sMRI})
      studydir=$trio_sMRI
      sessions=${studydir}/Q_*
      ;;
    ${prisma_sMRI})
      studydir=$prisma_sMRI
      sessions=${studydir}/Q_*
      ;;
    ${kcl})
      studydir=$kcl
      sessions=${studydir}/GQAIMS*
      ;;
    ${suny})
      studydir=$suny
      sessions=${studydir}/X*
      ;;
    ${rome})
      studydir=$rome
      sessions=$(echo ${rome}/C* ${rome}/D*)
      ;;    
  esac
  # loop through list of sessions and run thalamic and hipp/amygdala segmentation
  for sesh in $sessions; do 
  	bn=$(basename $sesh)
  	echo "...submitting subject: ${bn}"
  	sd=${studydir}/${bn}/hcp/${bn}/T1w
  	echo $sd
  	# write temp file with command to submit to scheduler
  	tmpfile1=~/tmp1$(date +%s)
  	echo '#!/bin/bash' > $tmpfile1
  	echo 'export FREESURFER_HOME=/u/project/CCN/apps/freesurfer/rh7/7.3.2/' >> $tmpfile1
	echo 'export SUBJECTS_DIR=$FREESURFER_HOME/subjects' >> $tmpfile1
	echo 'source $FREESURFER_HOME/SetUpFreeSurfer.sh' >> $tmpfile1
	echo "segment_subregions thalamus --cross ${bn} --sd ${sd}" >> $tmpfile1
	echo "segment_subregions hippo-amygdala --cross ${bn} --sd ${sd}" >> $tmpfile1
	qsub -cwd -V -o /u/project/cbearden/data/22q/qunex_studyfolder/processing/logs/manual/22q_freesurfer_thal_hip.${bn}.$(date +%s).o -e /u/project/cbearden/data/22q/qunex_studyfolder/processing/logs/manual/22q_freesurfer_thal_hip.${bn}.$(date +%s).e -l h_data=32G,h_rt=24:00:00,arch=intel* $tmpfile1
	
  	#segment_subregions thalamus --cross $bn --sd $sd
  	#segment_subregions hippo-amygdala --cross $bn --sd $sd
  done
done

# qsub -cwd -V -o /u/project/cbearden/data/22q/qunex_studyfolder/processing/logs/manual/22q_freesurfer_thal_hip.$(date +%s).o -e /u/project/cbearden/data/22q/qunex_studyfolder/processing/logs/manual/22q_freesurfer_thal_hip.$(date +%s).e -l h_data=32G,h_rt=100:00:00,highp,arch=intel* /u/project/cbearden/data/22q/qunex_studyfolder/analysis/scripts/run_22q_multisite_freesurfer_thal_hip.sh
