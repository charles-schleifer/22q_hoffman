# Collection of scripts to perform individual subject level analyses
most analyses are R scripts, accompanied by one or two other scripts to submit and run jobs on the cluster

1. Thalamic cortical functional network connectivity
  * submit_extract_tc_individual.sh --> run_extract_tc_individual.sh --> 22q_multisite_networkTC_extract_ROIs.R
  *

3. Thalamic cortical anatomical network connectivity
  * submit_thal_fs_cifti.sh --> thalamus_freesurfer_cifti.sh
    * does anatomical segmentation
  * submit_anatomical_tc.sh --> run_anatomical_TC.sh --> 22q_multisite_freesurfer_TC.R

4. Parcellated whole brain functional connectivity
  *
  * 

5. Local connectivity (Network Homogeneity)
  * submit_network_homogeneity.sh --> run_network_homogeneity.sh --> parcellated_network_homogeneity.R
  * computes average FC between all voxels in each cluster

5. Brain signal variability (RSFA)
  *
  *

