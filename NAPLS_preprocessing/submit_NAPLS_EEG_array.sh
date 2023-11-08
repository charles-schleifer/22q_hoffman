#!/bin/sh

# name your job
job="testjob" # set a name

# set your study directory
indir="/u/home/s/schleife" # change from my home directory to something else
mkdir -p ${indir}/logs

# path to bash script which will call your matlab function
# edit this path for whatever script you make
runscript="/u/project/cbearden/data/scripts/charlie/22q_hoffman/NAPLS_preprocessing/run_NAPLS_EEG_array.sh"

# choose how many jobs in array
# set to 5 for test example
length=5 # change to get your actual number of jobs to run

# qsub command
qsub -cwd -V -N ${job} -o ${indir}/logs/ -e ${indir}/logs/ -t 1-${length}:1 -l h_data=32G,h_rt=24:00:00 $runscript

