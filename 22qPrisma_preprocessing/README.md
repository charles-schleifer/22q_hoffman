# Overview of 22q Prisma preprocessing 
* Structural and functional scans are preprocessed with a modified version of the Human Connectome Project (HCP) pipelines [(Glasser et al. 2013)](https://pubmed.ncbi.nlm.nih.gov/23668970/)
* This is accomplished with the Quantitative Neuroimaging Environment & Toolbox [(QuNex; Ji et al. 2023)](https://www.frontiersin.org/articles/10.3389/fninf.2023.1104508/full) 
  * This runs on the hoffman2 cluster as a singularity container. Containerized jobs are submitted with [hoffman_submit_qunex.sh](https://github.com/charles-schleifer/22q_hoffman/blob/main/hoffman_submit/hoffman_submit_qunex.sh)
  * QuNex documentation: [https://qunex.readthedocs.io/en/latest/](https://qunex.readthedocs.io/en/latest/)
  * Example commands to preprocess T1w T2w and multi-band BOLD from raw DICOMs to nuisance-regressed and motion-corrected NIFTI/CIFTI images are in [22qPrisma_qunex_preprocess_template.sh](https://github.com/charles-schleifer/22q_hoffman/blob/main/22qPrisma_preprocessing/22qPrisma_qunex_preprocess_template.sh)

# Preprocessing steps
A) prepare raw data and batch files
 1. copy dicoms from raw directory to qunex_studyfolder/sessions/inbox/MR with a script like [prisma_copy_raw_dicoms_2023.sh](https://github.com/charles-schleifer/22q_hoffman/blob/main/22qPrisma_preprocessing/prisma_copy_raw_dicoms_2023.sh) 
    * notes: if the path to the raw data changes you will need to update this script
 2. create folders for each new session in qunex_studyfolder/sessions/ and convert DICOMS to NIFTI with `import_dicom`
 3. create session_hcp.txt from session_hcp.txt using the name mappings in your --mapping file with `create_session_info` (e.g., "T1w_MPR" mapped to "T1w")
    * notes: if the names of the scans in the DICOM metadata change you will need to update the text file specified in the --mapping option for this command
 4. run script to comment out duplicate structurals and edit subject header: [edit_session_hcp.sh](https://github.com/charles-schleifer/22q_hoffman/blob/main/22qPrisma_preprocessing/edit_session_hcp.sh)
    * notes: this is because many of the 22qPrisma scans have two T1w and T2w images (with and without normalization) due to scanner settings. If structural scans were re-run during a session you will need to manually choose which images to use by commenting out the unused lines in session_hcp.txt
 5. map NIFTI images from nii directory to hcp preprocessing directory with `setup_hcp`
 6. create a batch file that concatenates your study parameters with all your session_hcp.txt files with `create_batch`

B) HCP minimal preprocessing steps
 1. initial structural image processing with `hcp_pre_freesurfer`
 2. anatomical segmentation with `hcp_freesurfer`
 3. creation of CIFTI image with `hcp_post_freesurfer`
 4. processing BOLD image in volume space with `hcp_fmri_volume`
 5. transformation of fMRI results to CIFTI space with `hcp_fmri_surface` 

C) BOLD post-processing
