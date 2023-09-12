# C. Schleifer 4/5/2022
# Script to get mean FD from .bstats


# clear environment
rm(list = ls(all.names = TRUE))

# list of packages to load
packages <- c("dplyr", "tidyr", "magrittr", "stringr")

# Install packages not yet installed
# Note: ciftiTools install fails if R is started without enough memory
installed_packages <- packages %in% rownames(installed.packages())
# comment out line below to skip install
if (any(installed_packages == FALSE)) {install.packages(packages[!installed_packages])}

# Packages loading
invisible(lapply(packages, library, character.only = TRUE))

# set up hoffman path
hoffman <- "/u/project/cbearden/data/"


# function to get mapping between boldn and run name from session_hcp.txt
get_boldn_names <- function(sesh,sessions_dir){
  hcptxt <- read.table(file.path(sessions_dir,sesh,"session_hcp.txt"),sep=":",comment.char="#",fill=T,strip.white=T,col.names=c(1:4)) %>% as.data.frame()
  hcpbolds <- hcptxt %>% filter(grepl("bold[0-9]",X2))
  df_out <- cbind(rep(sesh,times=nrow(hcpbolds)),hcpbolds$X2,hcpbolds$X3)
  colnames(df_out) <- c("sesh","bold_n","bold_name")
  return(df_out)
}


# function to get %udvarsme from images/functional/movement/boldn.bstats
get_mean_fd <- function(sesh,sessions_dir,bold_name_use){
  mov_dir <- file.path(sessions_dir,sesh,"images/functional/movement")
  sesh_bolds <- get_boldn_names(sesh=sesh,sessions_dir=sessions_dir) %>% as.data.frame %>% filter(bold_name == bold_name_use)
  if(nrow(sesh_bolds) > 0){
    boldns_use <- sesh_bolds$bold_n %>% as.vector
    for(i in 1:length(boldns_use)){
      boldn <- boldns_use[i] %>% as.character
      boldn_path <- file.path(mov_dir,paste(boldn,".bstats",sep=""))
      # read bstats as lines of text
      bstats <- readLines(boldn_path)
      # get the line containing the string "mean"
      meanline <- bstats[which(lapply(bstats, function(l)grepl("mean",l, fixed=TRUE)) == TRUE)]
      print(meanline)
      # get the value in the final column by removing extra whitespace, splitting at space, and taking the last element of the vector
      fdmean <- str_split(str_squish(meanline), pattern=" ")[[1]] %>% tail(n=1) %>% as.numeric
      df_out <- data.frame(sesh=sesh, bold_n=boldn, bold_name=bold_name_use, fd_mean=fdmean)
      return(df_out)
    }
  }
}




run_sesh_list <- function(sessions_dir,sesh_pattern,after_dir,bold_name_use,file_end,exclude=""){
  print(paste("sessions_dir =",sessions_dir))
  print(paste("sesh_pattern =",sesh_pattern))
  print(paste("after_dir =",after_dir))
  print(paste("bold_name_use =",bold_name_use))
  print(paste("file_end =",file_end))
  
  # get list of all sessions in sessions_dir
  sesh_all_initial <- list.files(sessions_dir,pattern=sesh_pattern)
  # remove excluded sessions
  sesh_all <- setdiff(sesh_all_initial,exclude) %>% as.vector
  
  # read bold info
  fd_all <- lapply(sesh_all, function(s) get_mean_fd(sesh=s,sessions_dir=sessions_dir,bold_name_use=bold_name_use)) %>% do.call(rbind,.) %>% as.data.frame
}

#### DO WORK


# GSR
# 22qPrisma
gsr_fd_prisma <- run_sesh_list(sessions_dir = file.path(hoffman,"22qPrisma/qunex_studyfolder/sessions"),  sesh_pattern = "Q_[0-9]",  bold_name_use = "restingAP",  after_dir ="/images/functional/",  file_end = "_Atlas_s_hpss_res-mVWMWB1d_lpss.dtseries.nii")
gsr_fd_prisma$site <- "prisma"

# 22qTrio
gsr_fd_trio <- run_sesh_list(sessions_dir = file.path(hoffman,"22q/qunex_studyfolder/sessions"),  sesh_pattern = "Q_[0-9]",  bold_name_use = "resting",  after_dir ="/images/functional/",  file_end = "_Atlas_s_hpss_res-mVWMWB1d_lpss.dtseries.nii")
gsr_fd_trio$site <- "trio"
  
# SUNY
gsr_fd_suny <- run_sesh_list(sessions_dir = file.path(hoffman,"Enigma/SUNY/qunex_studyfolder/sessions"),  sesh_pattern = "X[0-9]",  bold_name_use = "resting",  after_dir ="/images/functional/",  file_end = "_Atlas_s_hpss_res-mVWMWB1d_lpss.dtseries.nii")
gsr_fd_suny$site <- "suny"
  
# IoP
gsr_fd_iop <- run_sesh_list(sessions_dir = file.path(hoffman,"Enigma/IoP/qunex_studyfolder/sessions"), sesh_pattern = "GQAIMS[0-9]", bold_name_use = "resting", after_dir ="/images/functional/", file_end = "_Atlas_s_hpss_res-mVWMWB1d_lpss.dtseries.nii")
gsr_fd_iop$site <- "iop"
  
# Rome
gsr_fd_rome  <- run_sesh_list(sessions_dir = file.path(hoffman,"Enigma/Rome/qunex_studyfolder/sessions"),  sesh_pattern = "[0-9]",  bold_name_use = "resting",  after_dir ="/images/functional/",  file_end = "_Atlas_s_hpss_res-mVWMWB1d_lpss.dtseries.nii")
gsr_fd_rome$site <- "rome"

gsr_all <- rbind(gsr_fd_prisma, gsr_fd_trio, gsr_fd_suny, gsr_fd_iop, gsr_fd_rome)

write.table(gsr_all, file="/u/project/cbearden/data/22q/qunex_studyfolder/analysis/fcMRI/22q_multisite_fd_mean.csv", sep=",", eol = "\n", col.names = TRUE, row.names=FALSE)


# qsub -cwd -V -o /u/project/cbearden/data/22q/qunex_studyfolder/processing/logs/manual/22q_multisite_parcel_fc_save_individual.o -e /u/project/cbearden/data/22q/qunex_studyfolder/processing/logs/manual/22q_multisite_parcel_fc_save_individual.e -l h_data=64G,h_rt=330:00:00,arch=intel*,highp /u/project/cbearden/data/22q/qunex_studyfolder/analysis/scripts/submit_parcel_fc.sh 
