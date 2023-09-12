#!/bin/bash

#=============================================================================================================================================
# Script to run a job array of QuNex commands against a Singularity container on Hoffman2.
# C. Schleifer, 7/01/2021
# modified 7/20/21 to run jobs either in parallel (array=yes) or as a single batch (array=no)
# modified 8/12/21 to automatically request rh7 node and load Singularity
# modified 8/13/21 to use sessionids/sessions option depending on the qunex command used when array=yes
# modified 8/16/21 to avoid name conflicts for qtmp files by changing to "qtmp$(date +"%s")${i}"
# modified 9/24/21 to remove checks for rh7 node that were specific to old OS on hoffman2 prior to 9/22 update.
# modified 10/14/21 to use array for fc_compute_wrapper
# modified 10/20/21 to take logdir as an option to control where job logs output
#=============================================================================================================================================


show_usage() {

cat << EOF

=============================================================================================================================================
Script to run a job array of QuNex commands against a Singularity container on Hoffman2.
This script takes a QuNex call, a list of sessions, and Univa Grid Engine options. 
It writes temporary scripts with QuNex calls to be run within the container for each session, 
and a temporary script to pass to qsub to execute an array of Singularity containers.
Primary log files will be saved in standard QuNex locations. 
Additional logs will output in the directory from which the command was run.
 
USAGE: hoffman_submit_qunex.sh --qunex_command="" --qunex_options="" --scheduler_options="" --array="" --sessions="" 
    --qunex_command        qunex command to run (e.g. hcp_pre_freesurfer)
    --qunex_options        all options for qunex command. NOTE: do not use quotes for individual options, put everything in one set of quotes
    --scheduler_options    options for hoffman2 scheduler.
    --array                [yes/no] whether to submit as job array with one job per session (yes) or as a single job (no)
    --sessions             space delimited list of sessions to process in job array (omit if --array=no)
    
EXAMPLE:
/u/project/cbearden/data/scripts/tools/qunex_bin/hoffman_submit_qunex.sh \\
--qunex_command="hcp_pre_freesurfer" \\
--qunex_options="--sessions=/u/project/cbearden/data/22q/qunex_studyfolder/processing/22q_trio_batch.txt --sessionsfolder=/u/project/cbearden/data/22q/qunex_studyfolder/sessions --parsessions=1 --overwrite=no" \\
--scheduler_options="-l h_data=16G,h_rt=24:00:00" \\
--array="yes" \\
--sessions="Q_0001_09242012 Q_0001_10152010"

QuNex Documentation:
https://qunex.readthedocs.io/en/latest/
=============================================================================================================================================

EOF
}

show_usage

# parse command line arguments
for a in "$@"; do
  case $a in
    --qunex_command=*)
      qunex_command="${a#*=}"
      shift 
      ;;
    --qunex_options=*)
      qunex_options="${a#*=}"
      shift 
      ;;
    --scheduler_options=*)
      scheduler_options="${a#*=}"
      shift 
      ;;
    --sessions=*)
      sessions="${a#*=}"
      sessions=(${sessions})
      length=${#sessions[@]}
      shift 
      ;;
    --array=*)
      array="${a#*=}"
      shift 
      ;;    
    --logdir=*)
      logdir="${a#*=}"
      shift 
      ;;

    *)
      echo "ERROR. Unknown option: ${a}"
      exit 0
      ;;
  esac
done
echo "qunex_command = ${qunex_command}"
echo "qunex_options = ${qunex_options}"
echo "scheduler_options = ${scheduler_options}"
echo "array = ${array}"
echo "sessions = ${sessions[@]}"
echo "logdir = ${logdir}"
echo ""

# set logdir to home if empty
if [[ -z ${logdir} ]]; then
	echo "... logdir not specified. Setting to home directory ~/"
	logdir=~/
fi

# load singularity
source /u/local/Modules/default/init/modules.sh
module load singularity/3.7.1

# check that singularity is loaded
if [[ ":$PATH:" != *"singularity/3.7.1"* ]]; then  
	echo "...attempting to load Singularity"
	module load singularity
	if [[ ":$PATH:" != *"singularity/3.7.1"* ]]; then
		echo "ERROR. Singularity not loaded. Check that you are on a node with CentOS7" 
		exit 0
	fi
fi

# if --array=yes then submit as a job array with one job per session
if [[ "${array}" == "yes" ]]; then 
	
	# check that sessions are listed
	if [[ -z ${sessions} ]]; then
		echo "ERROR. --sessions can not be empty if --array=yes"
		exit 0
	fi
	
	# create array of temp file names for qunex commands (one per subject)
	qfiles=()
	i=0; while (($i<$length)); do
		qfiles+=("qtmp$(date +"%s")${i}")
		let i++
	done
	
	# write temp script with qunex command for each session, adding --sessionids=$sesh to the base qunex_command 
	i=0; while (($i<$length)); do
		qfile=${qfiles[$i]}
		sesh=${sessions[$i]}
		# confirm that sessions have been listed
		if test -z "$qfile" || test -z "$sesh"; then
			echo "...something went wrong: session or qfile variable is empty"
			echo "session: ${sesh}"
			echo "qfile: ${qfile}"
			let i++
			continue
		fi
		# set up qunex session option correctly for the command used
		case $qunex_command in
		  # functions that use --sessionids
		  hcp_pre_freesurfer|hcp_freesurfer|hcp_post_freesurfer|hcp_fmri_volume|hcp_fmri_surface|hcp_diffusion|map_hcp_data|create_bold_brain_masks|compute_bold_stats|create_stats_report|extract_nuisance_signal|preprocess_bold)
		    sesh_qunex_command="${qunex_command} ${qunex_options} --sessionids=${sesh}"
		    ;;
		  # functions that use --sessions
		  import_dicom|setup_hcp|run_qc|fc_compute_wrapper)
		    sesh_qunex_command="${qunex_command} ${qunex_options} --sessions=${sesh}"	
		    ;;
		  # don't try array with functions not listed above
		  *)
		    echo "...Array functionality not implemented for ${qunex_command}. Try submitting as a single job (array=no)" 
		    echo "...Exiting."
		    exit 0
		esac
		qfile=~/$qfile
		echo "...writing temporary qunex command file for ${sesh}:"
		echo "source /opt/qunex/env/qunex_environment.sh" > ${qfile}
		echo "bash /opt/qunex/bin/qunex.sh ${sesh_qunex_command}" >> ${qfile}
		echo "rm ${qfile}" >> ${qfile}
		cat ${qfile}
		echo ""
		let i++
	done
	
	# write temp script with singularity command and lines to parse job array 
	stmp=~/stmp
	echo "...writing temporary singularity command file:"
	echo "qfiles=(${qfiles[@]})"     >  ${stmp}
	echo "n=\$((\$SGE_TASK_ID - 1))" >> ${stmp}
	echo "qfile=\${qfiles[\$n]}"     >> ${stmp}
	echo "singularity exec --userns /u/project/cbearden/data/scripts/tools/qunex_suite-0.90.6/ bash ~/\${qfile}" >> ${stmp}
	cat ${stmp}
	echo ""
	
	# submit job array with one job per session
	job=${qunex_command}_array.$(date +"%s")
	queuing_command="qsub -cwd -V -o ${logdir}/${job}.o -e ${logdir}/${job}.e -N ${job} -t 1-${length}:1 ${scheduler_options}"
	echo "...using grid engine to submit array of n=${length} ${qunex_command} jobs"
	echo "...qunex will save logs in default studyfolder locations. check for additional logs in the directory in which the command was run"
	echo "queue command: ${queuing_command}"
	$queuing_command $stmp
	#rm $stmp

# if --array=no then submit as a single job 
elif [[ "${array}" == "no" ]]; then 
	
	# write temp script with qunex command for batch of sessions
	qfile=~/qtmp
	sesh_qunex_command="${qunex_command} ${qunex_options}"
	echo "...writing temporary qunex command file for batch of subjects"
	echo "source /opt/qunex/env/qunex_environment.sh" > ${qfile}
	echo "bash /opt/qunex/bin/qunex.sh ${sesh_qunex_command}" >> ${qfile}
	echo "rm ${qfile}" >> ${qfile}
	cat ${qfile}
	echo ""
	
	# write temp script with singularity command
	stmp=~/stmp
	echo "...writing temporary singularity command file:"
	echo "singularity exec --userns /u/project/cbearden/data/scripts/tools/qunex_suite-0.90.6/ bash ${qfile}" > ${stmp}
	cat ${stmp}
	echo ""

	# submit job array with one job per session
	job=${qunex_command}_batch.$(date +"%s")
	queuing_command="qsub -cwd -V -o ${logdir}/${job}.o -e ${logdir}/${job}.e -N ${job} ${scheduler_options}"
	echo "...using grid engine to submit a single job for ${qunex_command}"
	echo "...qunex will save logs in default studyfolder locations. check for additional logs in the directory in which the command was run"
	echo "queue command: ${queuing_command}"
	$queuing_command $stmp
	
else
	echo "ERROR. --array must be \"yes\" or \"no\""
	exit 0
fi





