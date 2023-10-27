# Overview of 22q Prisma preprocessing 
* Structural and functional scans are preprocessed with a modified version of the Human Connectome Project (HCP) pipelines [(Glasser et al. 2013)](https://pubmed.ncbi.nlm.nih.gov/23668970/)
* This is accomplished with the Quantitative Neuroimaging Environment & Toolbox [(QuNex; Ji et al. 2023)](https://www.frontiersin.org/articles/10.3389/fninf.2023.1104508/full) 
  * This runs on the hoffman2 cluster as a singularity container, to which jobs are submitted with [hoffman_submit_qunex.sh](https://github.com/charles-schleifer/22q_hoffman/blob/main/hoffman_submit/hoffman_submit_qunex.sh)
  * QuNex documentation: [https://qunex.readthedocs.io/en/latest/](https://qunex.readthedocs.io/en/latest/)
  * Example commands to preprocess T1w T2w and multi-band BOLD from raw DICOMs to nuisance-regressed and motion-corrected NIFTI/CIFTI images are in [22qPrisma_qunex_preprocess_template.sh](https://github.com/charles-schleifer/22q_hoffman/blob/main/22qPrisma_preprocessing/22qPrisma_qunex_preprocess_template.sh)

# Preprocessing steps
#### Notes: 
* preprocessing consists of a set of functions that are run sequentially on the data, each requiring the outputs of the previous step
* steps are outlined below
* details for each command can be found in the [online documentation](https://www.frontiersin.org/articles/10.3389/fninf.2023.1104508/full) or by running an interactive QuNex container and typing the desired function name into the command line
* the full commands for submitting each step on the hoffman cluster are here: [22qPrisma_qunex_preprocess_template.sh](https://github.com/charles-schleifer/22q_hoffman/blob/main/22qPrisma_preprocessing/22qPrisma_qunex_preprocess_template.sh)

## A) prepare raw data and batch files
 1. copy dicoms from raw directory to qunex_studyfolder/sessions/inbox/MR with a script like [prisma_copy_raw_dicoms_2023.sh](https://github.com/charles-schleifer/22q_hoffman/blob/main/22qPrisma_preprocessing/prisma_copy_raw_dicoms_2023.sh) 
    * notes: if the path to the raw data changes you will need to update this script
 2. create folders for each new session in qunex_studyfolder/sessions/ and convert DICOMS to NIFTI with `import_dicom`
 3. create session_hcp.txt from session_hcp.txt using the name mappings in your --mapping file with `create_session_info` (e.g., "T1w_MPR" mapped to "T1w")
    * notes: if the names of the scans in the DICOM metadata change you will need to update the text file specified in the --mapping option for this command
 4. run script to comment out duplicate structurals and edit subject header: [edit_session_hcp.sh](https://github.com/charles-schleifer/22q_hoffman/blob/main/22qPrisma_preprocessing/edit_session_hcp.sh)
    * notes: this is because many of the 22qPrisma scans have two T1w and T2w images (with and without normalization) due to scanner settings. If structural scans were re-run during a session (e.g., subject moved and T1w was re-ran) you will need to manually choose which images to use by commenting out the unused lines in session_hcp.txt
 5. map NIFTI images from nii directory to hcp preprocessing directory with `setup_hcp`
 6. create a batch file that concatenates your study parameters with all your session_hcp.txt files with `create_batch`
    * notes: 1) unlike other hoffman_submit_qunex commands, list all sessions after "--sessions=" *within* the "--qunex_options" string 2) make a separate batch file for sessions missing T2w scans as these require different parameters.

## B) HCP minimal preprocessing steps
 1. initial structural image processing with `hcp_pre_freesurfer`
 2. anatomical segmentation with `hcp_freesurfer`
 3. creation of CIFTI image with `hcp_post_freesurfer`
 4. processing BOLD image in volume space with `hcp_fmri_volume`
 5. transformation of fMRI results to CIFTI space with `hcp_fmri_surface`

#### Notes: 
* these steps may take several hours each to complete (freesurfer may take upwards of 10h)

## C) BOLD post-processing

1. map minimally preprocessed results to images directory with `map_hcp_data`
2. create brain masks with `create_bold_brain_masks`
3. generate movement and snr stats with `compute_bold_stats`
4. create stats report with `create_stats_report`
5. extract nuisance signal from ventricles, deep white matter, etc. with `extract_nuisance_signal`
6. preprocess fMRI image with `preprocess_bold`  

#### Notes: 
* these steps run much more quickly than the HCP steps
* outputs are in the images directory
* logs are in the same format as prior steps
* --bolds string specifies bold names (from session_hcp.txt) to process, separated by commas
* --bold_actions "s"=spatial smoothing, "h"=highpass filter, "r"=nuisance regression, "c"= save betas, "l"=lowpass  
* --bold_nuisance "m"=movement, "V"=ventricles, "WM"=white matter, "WB"=whole brain (i.e., global signal regression, include with caution), "1d"=first derivatives of previous regressors
  * these options would lead to a BOLD output that is smoothed, bandpass filtered, and nuisance regressed based on movement, ventricles, white matter, and global signal.
    * that file would be named bold1_Atlas_s_hpss_res-mVWMWB1d_lpss.dtseries.nii
      * the version without global signal regression would be bold1_Atlas_s_hpss_res-mVWM1d_lpss.dtseries.nii
      * and without GSR and lowpass filtering would be bold1_Atlas_s_hpss_res-mVWM1d.dtseries.nii
      * the first string in the name "boldn" corresponds to the bold number in the session_hcp.txt file
       * in a study, it may be the case that bolds are run in different orders by subject and bold1 is not always the resting state bold or whichever you are interested in, and you may need to read the session_hcp.txt files during your analysis to get the correct boldn for each session (see get_boldn_names function in [22q_multisite_networkTC_extract_ROIs.R](https://github.com/charles-schleifer/22q_hoffman/blob/main/22q_analysis/22q_multisite_networkTC_extract_ROIs.R) for an example  
 * *important*: frames flagged for motion are still included in this image, and will be ignored by QuNex functional connectivity commands but not other packages
    * if doing further analysis outside of QuNex (e.g., with ciftiTools), you will need to read the relevant movement file from images/functional/movement/boldn.scrub to exclude frames flagged for motion (i.e., frames where the column "use"==0; see do_bold_scrub function in [22q_multisite_networkTC_extract_ROIs.R](https://github.com/charles-schleifer/22q_hoffman/blob/main/22q_analysis/22q_multisite_networkTC_extract_ROIs.R) 

# Troubleshooting
* check your jobs on hoffman with `qstat -u your_username`
  * state "qw" means queued, "r" means running
* once your job is done running, check the qunex_studyfolder/processing/logs/comlogs
  * you can filter for only your files with `ls -ltr /u/project/cbearden/data/22qPrisma/qunex_studyfolder/processing/logs/comlogs | grep your_username`  
  * these comlogs will show you if each command for each session is running (name will start with "tmp"), "done", or exited in "error", and the log contents will give more information
  * if your command started to run but didn't finish (e.g., you don't have any running jobs but in your comlogs folder the relevant logs start with "tmp" and not "done") try resubmitting with different --qunex_options, you may require more memory or time
* if your job is done, run the next step
* if there is an error for a specific session, read the error message in comlogs, and the relevant logfile in "--logdir" (this log is messier but sometimes has useful info, .o files have output messages and .e files have error messages)
* first step for a failed session is to check the session_hcp.txt file
  * did it fail because the data don't exist (e.g. only localizers and fieldmaps were collected but no T1w etc.)? if so, move the data from qunex_studyfolder/sessions/ to a descriptively named folder in qunex_studyfolder/sessions/unused_sessions/ such as the BOLD_missing directory
  * if there are multiple copies of the same structural image type (e.g., two T1w in session_hcp.txt) ensure that only one remains without a "#" before it in the file and that the remaining line corresponds to a high quality NIFTI (can use a viewer like MRIcron or FSLeyes to look at the image in the nii directory, number names correspond to left column numbers in session_hcp.txt). If after visual inspection there are no high quality T1w images, move the session folder to qunex_studyfolder/sessions/unused_sessions/T1_bad
  * if the session is missing T2w but has T1w and BOLDs, it can still be processed with alternative parameters, specifically --hcp_processing_mode=LegacyStyleData for the structural preprocessing steps (up through post-freesurfer), then --hcp_processing_mode=HCPStyleData for the final HCP fMRI steps (to correctly process the multi-band BOLD data). See notes for `create_batch`
   
