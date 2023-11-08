#!/bin/sh

# get job array index
i=${SGE_TASK_ID}

# path to folder with matlab script
path="/u/project/cbearden/data/scripts/charlie/22q_hoffman/NAPLS_preprocessing/"
cd $path

# run matlab script with index as argument
# name of function must be the same as the name of the matlab script, which must be in your $path directory
matlab -nodisplay -nosplash -nojvm -r "NAPLS_EEG_array(${i})"