# 22q_hoffman
Collection of scripts for preprocessing and first-level analysis of structural and functional MRI data on hoffman cluster

* hoffman_submit: wrapper to submit QuNex singularity container jobs on hoffman grid engine 
*  22q_preprocessing: scripts for HCP minimal preprocessing and additional BOLD steps with QuNex (for legacy 22q data collected on Siemens Trio)
* 22qPrisma_preprocessing: same as 22q_preprocessing for newer 22q data collected on Siemens Prisma
* 22qENIGMA_preprocessing: scripts for QuNex HCP preprocessing of 22q/TD data from Rome, London, and NY
* 22a_T1w_ADNI: processing and analysis of ADNI T1w images using longitudinal FreeSurfer and subcortical structures segmentation
* 22q_analysis: scripts for generation of individual subject rs-fMRI derived measures
    * includes: thalamocortical connectivity (functional and anatomical seeds), parcellated connectivity, parcel level network homogeneity (NetHo),  and brain signal variability (RSFA)
    * relevant for UCLA 22q data, ENIGMA 22q, and NAPLS CHR
 
