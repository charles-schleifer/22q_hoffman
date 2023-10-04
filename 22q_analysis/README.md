# Collection of scripts to perform individual subject level analyses
most analyses are R scripts, accompanied by one or two other scripts to submit and run jobs on the cluster

1. Thalamic cortical functional network connectivity
   * submit_extract_tc_individual.sh --> run_extract_tc_individual.sh --> 22q_multisite_networkTC_extract_ROIs.R
     *  computes functional connectivity between thalamic and cortical networks in CAB-NP parcellation


3. Thalamic cortical anatomical network connectivity
   * submit_thal_fs_cifti.sh --> thalamus_freesurfer_cifti.sh
     * does anatomical segmentation
   * submit_anatomical_tc.sh --> run_anatomical_TC.sh --> 22q_multisite_freesurfer_TC.R
     * computes functional connectivity between anatomically defined thalamic and cortical regions as in Huang et al 2021  


4. Parcellated whole brain functional connectivity
   * submit_bparcel_fc_individual.sh --> run_bparcel_fc_individual.sh --> 22q_multisite_bparcel_fc_arg_input.R
     * computes whole brain parcellated functional connectivity matrix


5. Local connectivity (Network Homogeneity)
   * submit_network_homogeneity.sh --> run_network_homogeneity.sh --> parcellated_network_homogeneity.R
     * computes average FC between all voxels in each parcel


5. Brain signal variability (RSFA)
   * submit_voxel_RSFA.sh --> run_voxel_RSFA.sh --> 22q_voxel_RSFA_CIFTI.R
     * computes resting state fluctuation amplitude as the average temporal standard deviation of fMRI signal in each parcel
    
6. QC-FC
   * submit_qcfc.sh --> qcfc_hoffman.R
     * correlates framewise displacement and functional connectivity   

