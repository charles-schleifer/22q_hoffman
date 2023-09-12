# script to read UCLA MRI_S_IDs and submit longitudinal freesurfer calls to scheduler

# clear workspace
rm(list = ls(all.names = TRUE))

## use SSHFS to mount hoffman2 server (download SSHFS for mac: https://osxfuse.github.io/)
## TODO: set hoffman2 username
#uname <- "schleife"
## set local path to mount server
#hoffman <- "~/Desktop/hoffman_mount"
## create directory if needed 
#if(!file.exists(hoffman)){dir.create(hoffman)}
## make string to run as system command
#mntcommand <- paste0("umount -f ", hoffman,"; sshfs ",uname,"@hoffman2.idre.ucla.edu:/u/project/cbearden/data ",hoffman)
## if hoffman directory is empty, use system command and sshfs to mount server, if not empty assume already mounted and skip
#if(length(list.files(hoffman)) == 0){system(mntcommand)}else{print(paste(hoffman,"is not empty...skipping SSHFS step"))}
hoffman <- "/u/project/cbearden/data/"

# list packages to load
#packages <- c("devtools","conflicted","here","magrittr", "dplyr", "tidyr", "ggplot2","ggpubr","RColorBrewer", "ciftiTools","tableone", "data.table", "reshape2","neuroCombat")
packages <- c("conflicted","magrittr", "dplyr","stringr")

# install packages if not yet installed
# note: ciftiTools install fails if R is started without enough memory on cluster (try 16G)
all_packages <- rownames(installed.packages())
installed_packages <- packages %in% all_packages
if (any(installed_packages == FALSE)){install.packages(packages[!installed_packages])}

# load packages
invisible(lapply(packages, library, character.only = TRUE))

# install neuroComBat from github 
# https://github.com/Jfortin1/neuroCombat_Rpackage
#install_github("jfortin1/neuroCombatData")
#install_github("jfortin1/neuroCombat_Rpackage")

# use the filter function from dplyr, not stats
conflict_prefer("filter", "dplyr")


# path to recon-all directory
recondir <- file.path(hoffman,"22q_T1w_all/sessions_recon-all")

# get sesions and split IDs into subject numbers and dates
sessions <- list.files(recondir, pattern ="Q_[0-9][0-9][0-9][0-9]_")
sesh_info <- sessions %>% str_split(.,pattern="_") %>% do.call(rbind,.) %>% as.data.frame %>% rename("prefix"="V1","subject_number"="V2",raw_date="V3")
sesh_info$MRI_S_ID <- sessions
sesh_info$subject <- paste0(sesh_info$prefix,"_",sesh_info$subject_number)
sesh_info$date <- as.Date(sesh_info$raw_date, "%m%d%Y")


# for each session, construct freesurfer longitudinal command 
fscall_base <- "recon-all -sd /u/project/cbearden/data/22q_T1w_all/sessions_recon-all/"
for(sesh in sesh_info$MRI_S_ID){
  print(sesh)
  sub <- filter(sesh_info, MRI_S_ID==sesh)[1,"subject"]
  print(sub)
  fscall <- paste(fscall_base, "-long", sesh, sub, "-all")
  # create script to submit freesurfer command
  fname <- paste0(sesh,"_recon-all_long.sh")
  fpath <- file.path("/u/project/cbearden/data/22q_T1w_all/sessions_recon-all/commands",fname)
  cat("#!/bin/bash", file=fpath, sep="\n")
  cat("export FREESURFER_HOME=/u/project/CCN/apps/freesurfer/rh7/7.3.2/", sep="\n", file=fpath, append=TRUE)
  cat("source $FREESURFER_HOME/SetUpFreeSurfer.sh", sep="\n", file=fpath, append=TRUE)
  cat(fscall, file=fpath, sep="\n", append=TRUE)
  # submit to scheduler
  logdir <- "/u/project/cbearden/data/22q_T1w_all/sessions_recon-all/logs"
  qsub_command <- paste("qsub -cwd -V -o", file.path(logdir,"recon-all_log_tp.$(date +%s).o"), "-e", file.path(logdir,"recon-all_log_tp.$(date +%s).e"), "-l h_data=8G,h_rt=24:00:00,arch=intel*", fpath)
  system(qsub_command)
}





