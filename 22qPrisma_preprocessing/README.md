# Overview of 22q Prisma preprocessing 
* Structural and functional scans are preprocessed with a modified version of the Human Connectome Project (HCP) pipelines [(Glasser et al. 2013)](https://pubmed.ncbi.nlm.nih.gov/23668970/)
* This is accomplished with the Quantitative Neuroimaging Environment & Toolbox [(QuNex)](https://www.frontiersin.org/articles/10.3389/fninf.2023.1104508/full) 
  * This runs on the hoffman2 cluster as a singularity container. Containerized jobs are submitted with [hoffman_submit_qunex.sh](https://github.com/charles-schleifer/22q_hoffman/blob/main/hoffman_submit/hoffman_submit_qunex.sh)
  * QuNex documentation: [https://qunex.readthedocs.io/en/latest/](https://qunex.readthedocs.io/en/latest/)
  * Example commands to preprocess T1w T2w and multi-band BOLD from raw DICOMs to nuisance-regressed and motion-corrected NIFTI/CIFTI images are in [22qPrisma_qunex_preprocess_template.sh](https://github.com/charles-schleifer/22q_hoffman/blob/main/22qPrisma_preprocessing/22qPrisma_qunex_preprocess_template.sh)

# Preprocessing steps
A) prepare raw data and batch files
 1. copy dicoms from raw directory to qunex_studyfolder/sessions/inbox/MR with a script like [prisma_copy_raw_dicoms_2023.sh](https://github.com/charles-schleifer/22q_hoffman/blob/main/22qPrisma_preprocessing/prisma_copy_raw_dicoms_2023.sh) 
 2. create folders for each new session in qunex_studyfolder/sessions/ and convert DICOMS to NIFTI with `import_dicom`

B) HCP minimal preprocessing steps

C) BOLD post-processing
