# C. Schleifer 6/3/2022
# Script to compute GBC for whole network (to whole brain)
# Inputs: preprocessed BOLDs, motion scrubbing file, CAB-NP atlas cifti, subcortical structures cifti
# Should be run on hoffman2 server due to memory and i/o constraints on local machine. Subsequent steps can be run locally (see striatum_thalamus_rsn_fc.Rmd)

# clear environment
rm(list = ls(all.names = TRUE))

# list of packages to load
packages <- c("ciftiTools", "dplyr", "tidyr", "magrittr", "DescTools","parallel")

# Install packages not yet installed
# Note: ciftiTools install fails if R is started without enough memory
installed_packages <- packages %in% rownames(installed.packages())
# comment out line below to skip install
if (any(installed_packages == FALSE)) {install.packages(packages[!installed_packages])}

# Packages loading
invisible(lapply(packages, library, character.only = TRUE))

# set up workbench
# wbpath <- "/Applications/workbench/bin_macosx64/"
wbpath <- "/u/project/cbearden/data/scripts/tools/workbench/bin_rh_linux64/wb_command"
ciftiTools.setOption("wb_path", wbpath)

# set up hoffman path
hoffman <- "/u/project/cbearden/data/"
#hoffman <- "~/Desktop/hoffman_mount/"

## load parcellation data
ji_path <- file.path(hoffman,"/22q/qunex_studyfolder/analysis/fcMRI/roi/ColeAnticevicNetPartition-master")
ji_key <- read.table(file.path(ji_path,"/CortexSubcortex_ColeAnticevic_NetPartition_wSubcorGSR_parcels_LR_LabelKey.txt"),header=T)
ji_net_keys <- ji_key[,c("NETWORKKEY","NETWORK")] %>% distinct %>% arrange(NETWORKKEY)
print(ji_net_keys)
xii_Ji_network <- read_cifti(file.path(ji_path,"/data/CortexSubcortex_ColeAnticevic_NetPartition_wSubcorGSR_netassignments_LR.dscalar.nii"), brainstructures = "all")

# read cifti with subcortical structures labeled 
xii_subcort_structs <- read_cifti(file.path(hoffman,"22q/qunex_studyfolder/analysis/fcMRI/roi/structures.dtseries.nii"), brainstructures = "all")

# function to create binary mask for ROIs, setting grayordinates with value in keep_vals to 1 and all others to 0. keep_vals should a number or vector of numbers
mask_values <- function(value,keep_vals){
  if(is.na(value)){
    return(NA)
  }else if(value %in% keep_vals){
    return(as.numeric(1))  
  }else{
    return(as.numeric(0))  
  }
}


# create cortex mask (cortex=1, subcort=0)
cort_mask <- xii_Ji_network
cort_mask$data$cortex_left <- as.matrix(rep(1,times=length(cort_mask$data$cortex_left)))
cort_mask$data$cortex_right <- as.matrix(rep(1,times=length(cort_mask$data$cortex_right)))
cort_mask$data$subcort <- as.matrix(rep(0,times=length(cort_mask$data$subcort)))
# thal mask
thal_mask <- apply_xifti(xii_subcort_structs, margin=1,function(v) mask_values(value=v,keep_vals=c(20,21)))
# mask ji networks
xii_Ji_net_cort <- xii_Ji_network * cort_mask
xii_Ji_net_thal <- xii_Ji_network * thal_mask

# function to get mapping between boldn and run name from session_hcp.txt
get_boldn_names <- function(sesh,sessions_dir){
  hcptxt <- read.table(file.path(sessions_dir,sesh,"session_hcp.txt"),sep=":",comment.char="#",fill=T,strip.white=T,col.names=c(1:4)) %>% as.data.frame()
  hcpbolds <- hcptxt %>% filter(grepl("bold[0-9]",X2))
  df_out <- cbind(rep(sesh,times=nrow(hcpbolds)),hcpbolds$X2,hcpbolds$X3)
  colnames(df_out) <- c("sesh","bold_n","bold_name")
  return(df_out)
}

# function to get %udvarsme from images/functional/movement/boldn.scrub
get_percent_udvarsme <- function(sesh,sessions_dir,bold_name_use){
  mov_dir <- file.path(sessions_dir,sesh,"images/functional/movement")
  sesh_bolds <- get_boldn_names(sesh=sesh,sessions_dir=sessions_dir) %>% as.data.frame %>% filter(bold_name == bold_name_use)
  if(nrow(sesh_bolds) > 0){
    boldns_use <- sesh_bolds$bold_n %>% as.vector
    for(i in 1:length(boldns_use)){
      boldn <- boldns_use[i] %>% as.character
      boldn_path <- file.path(mov_dir,paste(boldn,".scrub",sep=""))
      mov_scrub <- read.table(boldn_path, header=T)
      percent_udvarsme <- (sum(mov_scrub$udvarsme == 1)/length(mov_scrub$udvarsme)*100) %>% as.numeric %>% signif(3)
      percent_use <- (sum(mov_scrub$udvarsme == 0)/length(mov_scrub$udvarsme)*100) %>% as.numeric %>% signif(3)
      df_out <- cbind(sesh,boldn,bold_name_use,percent_udvarsme,percent_use)
      colnames(df_out) <- c("sesh","bold_n","bold_name","percent_udvarsme","percent_use")
      return(df_out)
    }
  }
}

# function to check if movement scrub results are present
check_mov_scrub <- function(sesh,sessions_dir,bold_name_use){
  sesh_bolds <- get_boldn_names(sesh=sesh,sessions_dir=sessions_dir) %>% as.data.frame %>% filter(bold_name == bold_name_use)
  mov_dir <- file.path(sessions_dir,sesh,"images/functional/movement")
  scrub_exists <- file.exists(file.path(mov_dir,paste(sesh_bolds$bold_n,".scrub",sep="")))
  return(scrub_exists)
}

# function to get path for processed bold rest based on percent_udvarsme_all$bold_n
get_rest_path  <- function(session,sessions_dir,file_end,after_dir,motion_stats){
  boldn <- as.character(filter(motion_stats,sesh==session)$bold_n)
  file <- paste(boldn,file_end,sep="")
  fpath <- file.path(sessions_dir,session,after_dir,file)
  out <- cbind(fpath,session)
  colnames(out) <- c("fpath","sesh")
  return(out)
}

# function to get full movement scrubbing info for sessions
get_mov_scrub <- function(sesh,sessions_dir,bold_name_use){
  mov_dir <- file.path(sessions_dir,sesh,"images/functional/movement")
  sesh_bolds <- get_boldn_names(sesh=sesh,sessions_dir=sessions_dir) %>% as.data.frame %>% filter(bold_name == bold_name_use)
  if(nrow(sesh_bolds) > 0){
    boldns_use <- sesh_bolds$bold_n %>% as.vector
    for(i in 1:length(boldns_use)){
      boldn <- boldns_use[i] %>% as.character
      boldn_path <- file.path(mov_dir,paste(boldn,".scrub",sep=""))
      mov_scrub <- read.table(boldn_path, header=T)
      return(mov_scrub)
    }
  }
}

# function to scrub bad frames from bold data, dropping first n frames 1:drop_first
do_bold_scrub <- function(mov,xii,metric,drop_first){
  scrub_dat <- mov[,metric]
  scrub_dat[c(1:drop_first)] <- 1
  keep_frames <- which(scrub_dat == 0)
  xii_scrub <- select_xifti(xii, keep_frames)
  return(xii_scrub)
}

# function to extract from BOLD xifti an average timeseries for rois
# input is bold dtseries, roi dscalar, and a vector of values corresponding to rois to use in the dscalar
# rois in dscalar must be identified by a single value (e.g. if you want bilateral, l and r should have same value in dscalar)
extract_single_roi_timeseries <- function(bold_dtseries,rois_dscalar,val){
  print(paste("...extracting ROI:",val))
  if(nrow(as.matrix(bold_dtseries)) == nrow(as.matrix(rois_dscalar))){
    roi_rows <- which(as.matrix(rois_dscalar) == val)
    bold_roi <- as.matrix(bold_dtseries)[roi_rows,]
    bold_roi_mean <- apply(bold_roi,2,mean)
    return(bold_roi_mean)
  }else{
    stop("ERROR: input bold and atlas must have the same number of rows")
  }
}

# wrapper to run extract_single_roi_timeseries for multiple rois
extract_rois_timeseries <- function(bold_dtseries,rois_dscalar,rois_values,name_prefix){
  output <- lapply(rois_values, function(v) extract_single_roi_timeseries(bold_dtseries=bold_dtseries,rois_dscalar=rois_dscalar,val=v)) %>% do.call(rbind,.) %>% as.data.frame
  rois_names <- ji_net_keys[rois_values,2]
  rownames(output) <- paste(name_prefix,rois_names,sep="")
  #rownames(output) <- paste(name_prefix,rois_values,sep="")
  return(output)
}

# function to extract average whole-brain timeseries (all grayordinates)
extract_wb_timeseries_mat <- function(bold_dtseries){
  print(paste("...extracting WB timeseries:"))
  bold_roi <- as.matrix(bold_dtseries)
  return(bold_roi)
}

# function to extract matrix with BOLD timeseries for each grayordinate in an roi
extract_voxels_within_roi_timeseries <- function(bold_dtseries,rois_dscalar,val){
  if(nrow(as.matrix(bold_dtseries)) == nrow(as.matrix(rois_dscalar))){
    roi_rows <- which(as.matrix(rois_dscalar) == val)
    bold_roi <- as.matrix(bold_dtseries)[roi_rows,]
    return(bold_roi)
  }else{
    stop("ERROR: input bold and atlas must have the same number of rows")
  }
}

# function to make column to determine duplicate rows
cross_sort_col <- function(a,b){
  sorted <- sort(c(a,b))
  new_col <- paste(sorted[1],sorted[2],sep="_")
  return(new_col)
}


# function to compute Fz correlation between two rois
roi_to_roi_fc <- function(bold_mat1, bold_mat2){
  # get the mean time series for each ROI
  bold_mean1 <- apply(bold_mat1,2,mean)
  bold_mean2 <- apply(bold_mat2,2,mean)
  # correlate
  fc <- FisherZ(as.numeric(cor(x=bold_mean1, y=bold_mean2, method="pearson", use="na.or.complete")))
  return(fc)
}

## wrapper for above functions to compute motion-scrubbed global brain connectivity for cortical networks in single subject
main_compute_net_GBC <- function(sesh, sessions_dir, bold_name_use, after_dir, file_end){
  print(paste("STARTING:", sesh, sep=" "))
  
  # get %udvarsme from images/functional/movement/boldn.scrub
  percent_udvarsme_all <- get_percent_udvarsme(sesh=sesh,sessions_dir=sessions_dir,bold_name_use=bold_name_use) %>% as.data.frame
  percent_udvarsme_all$percent_udvarsme <- as.numeric(percent_udvarsme_all$percent_udvarsme)
  percent_udvarsme_all$percent_use <- as.numeric(percent_udvarsme_all$percent_use)
  
  # get path for processed bold rest based on percent_udvarsme_all$bold_n
  print("...getting BOLD path")
  rest_path <- as.data.frame(get_rest_path(sessions_dir=sessions_dir, session=sesh, after_dir=after_dir, file_end = file_end, motion_stats=percent_udvarsme_all))$fpath
  #rest_path <- get_rest_path(sessions_dir=sessions_dir, session=sesh, after_dir=after_dir, file_end=file_end) %>% do.call(rbind,.) %>% as.data.frame
  
  # read bold 
  print("...reading BOLD CIFTI")
  bold_input <- read_cifti(rest_path, brainstructures = "all")
  
  # get full movement scrubbing info for session
  print("...performing movement scrubbing based on udvarsme")
  mov_scrub <- get_mov_scrub(sesh=sesh, sessions_dir=sessions_dir, bold_name_use=bold_name_use)
  
  # scrub bad frames from bold
  bold_scrub <- do_bold_scrub(mov=mov_scrub, xii=bold_input, metric="udvarsme",drop_first=5) 
  
  # extract from each CAB-NP network
  print("...calculating within-network TC connectivity for CAB-NP networks")
  cort_mats <- lapply(c(1:12), function(v) extract_voxels_within_roi_timeseries(val=v,bold_dtseries=bold_scrub,rois_dscalar=xii_Ji_net_cort))
  wb_mat <-  extract_wb_timeseries_mat(bold_dtseries=bold_scrub)
  
  net_gbc <- lapply(c(1:12), function(v) roi_to_roi_fc(bold_mat1 = cort_mats[[v]], bold_mat2 = wb_mat)) %>% do.call(rbind,.) %>% as.data.frame
  colnames(net_gbc) <- "GBC_Fz"

  # merge with ji net key
  fc_result <- cbind(ji_net_keys,net_gbc)
  
  # save result
  out_path <- file.path(dirname(rest_path),paste(bold_name_use,"_fc_network_Cortex_GBC",gsub(".dtseries.nii","",file_end),"_CABNP.csv",sep=""))
  print(paste("...saving result to:",out_path,sep=" "))
  write.table(fc_result, file=out_path, col.names=T, row.names=F, quote=F, na="NA", sep=",", eol = "\n")
  #return(fc_result)
}



# function to compute TC connectivity for all sessions matching sesh_pattern in session_dir that have the file specified by after_dir, bold_name_use, and file_end
# sesh_pattern = "Q_[0-9]"
run_sesh_list <- function(sessions_dir,sesh_pattern,after_dir,bold_name_use,file_end,exclude=""){
  print("Preparing to compute TC connectivity for all sessions in sessions_dir with existing input data")
  print(paste("sessions_dir =",sessions_dir))
  print(paste("sesh_pattern =",sesh_pattern))
  print(paste("after_dir =",after_dir))
  print(paste("bold_name_use =",bold_name_use))
  print(paste("file_end =",file_end))
  
  # get list of all sessions in sessions_dir
  sesh_all_initial <- list.files(sessions_dir,pattern=sesh_pattern)
  # remove excluded sessions
  sesh_all <- setdiff(sesh_all_initial,exclude) %>% as.vector
  
  # get subset of list with movement scrubbing info available 
  scrub_exists_all <- lapply(sesh_all, function(s) check_mov_scrub(sesh=s,sessions_dir=sessions_dir,bold_name_use=bold_name_use)) %>% do.call(rbind,.) %>% as.data.frame
  sesh_with_scrub <- sesh_all[which(scrub_exists_all[,1] == T)]
  sesh_without_scrub <- sesh_all[which(scrub_exists_all[,1] == F)]
  print("Sessions without BOLD scrubbing info (skipping):")
  print(sesh_without_scrub)
  
  # read bold info
  percent_udvarsme_all <- lapply(sesh_with_scrub, function(s) get_percent_udvarsme(sesh=s,sessions_dir=sessions_dir,bold_name_use=bold_name_use)) %>% do.call(rbind,.) %>% as.data.frame
  
  print(percent_udvarsme_all)
  # get path for processed bold rest based on percent_udvarsme_all$bold_n
  rest_path_all <- lapply(sesh_with_scrub, function(s) get_rest_path(session=s, sessions_dir=sessions_dir, after_dir=after_dir, file_end=file_end, motion_stats=percent_udvarsme_all)) %>% do.call(rbind,.) %>% as.data.frame
  
  # check that input files exist
  exists_tf <- lapply(rest_path_all$fpath,file.exists) %>% do.call(rbind,.) %>% as.data.frame
  existing_files <- rest_path_all$fpath[which(exists_tf == T)]
  sesh_use <- rest_path_all$sesh[which(exists_tf == T)]
  missing_files <- rest_path_all$fpath[which(exists_tf == F)]
  
  # calculate within and between network FC for all sessions with data (sesh_use)
  lapply(sesh_use, function(s) main_compute_net_GBC(sesh=s, sessions_dir=sessions_dir, bold_name_use=bold_name_use, after_dir=after_dir, file_end=file_end))
}

# sessions to exclude
#exclude_sessions <- c("Q_0217_01242017","Q_0279_12132016","Q_0334_12012016")
exclude_sessions <- NULL

#### DO WORK
### between network, and within network gbc
## GSR
# 22qTrio
run_sesh_list(sessions_dir = file.path(hoffman,"22q/qunex_studyfolder/sessions"),  sesh_pattern = "Q_[0-9]",  bold_name_use = "resting",  after_dir ="/images/functional/",  file_end = "_Atlas_s_hpss_res-mVWMWB1d_lpss.dtseries.nii")

# 22qPrisma
run_sesh_list(sessions_dir = file.path(hoffman,"22qPrisma/qunex_studyfolder/sessions"),  sesh_pattern = "Q_[0-9]",  bold_name_use = "restingAP",  after_dir ="/images/functional/",  file_end = "_Atlas_s_hpss_res-mVWMWB1d_lpss.dtseries.nii", exclude=exclude_sessions)

# SUNY
#run_sesh_list(sessions_dir = file.path(hoffman,"Enigma/SUNY/qunex_studyfolder/sessions"),  sesh_pattern = "X[0-9]",  bold_name_use = "resting",  after_dir ="/images/functional/",  file_end = "_Atlas_s_hpss_res-mVWMWB1d_lpss.dtseries.nii")

# IoP
#run_sesh_list(sessions_dir = file.path(hoffman,"Enigma/IoP/qunex_studyfolder/sessions"), sesh_pattern = "GQAIMS[0-9]", bold_name_use = "resting", after_dir ="/images/functional/", file_end = "_Atlas_s_hpss_res-mVWMWB1d_lpss.dtseries.nii")

# Rome
#run_sesh_list(sessions_dir = file.path(hoffman,"Enigma/Rome/qunex_studyfolder/sessions"),  sesh_pattern = "[0-9]",  bold_name_use = "resting",  after_dir ="/images/functional/",  file_end = "_Atlas_s_hpss_res-mVWMWB1d_lpss.dtseries.nii")


### no GSR
# 22qTrio
run_sesh_list(sessions_dir = file.path(hoffman,"22q/qunex_studyfolder/sessions"),  sesh_pattern = "Q_[0-9]",  bold_name_use = "resting",  after_dir ="/images/functional/",  file_end = "_Atlas_s_hpss_res-mVWM1d_lpss.dtseries.nii")

# 22qPrisma
run_sesh_list(sessions_dir = file.path(hoffman,"22qPrisma/qunex_studyfolder/sessions"),  sesh_pattern = "Q_[0-9]",  bold_name_use = "restingAP",  after_dir ="/images/functional/",  file_end = "_Atlas_s_hpss_res-mVWM1d_lpss.dtseries.nii", exclude=exclude_sessions)

# SUNY
#run_sesh_list(sessions_dir = file.path(hoffman,"Enigma/SUNY/qunex_studyfolder/sessions"),  sesh_pattern = "X[0-9]",  bold_name_use = "resting",  after_dir ="/images/functional/",  file_end = "_Atlas_s_hpss_res-mVWM1d_lpss.dtseries.nii")

# IoP
#run_sesh_list(sessions_dir = file.path(hoffman,"Enigma/IoP/qunex_studyfolder/sessions"), sesh_pattern = "GQAIMS[0-9]", bold_name_use = "resting",  after_dir ="/images/functional/",  file_end = "_Atlas_s_hpss_res-mVWM1d_lpss.dtseries.nii")

# Rome
#run_sesh_list(sessions_dir = file.path(hoffman,"Enigma/Rome/qunex_studyfolder/sessions"),  sesh_pattern = "[0-9]",  bold_name_use = "resting",  after_dir ="/images/functional/",  file_end = "_Atlas_s_hpss_res-mVWM1d_lpss.dtseries.nii")




# qsub -cwd -V -o /u/project/cbearden/data/22q/qunex_studyfolder/processing/logs/manual/22q_GBC_save_individual.$(date +%s).o -e /u/project/cbearden/data/22q/qunex_studyfolder/processing/logs/manual/22q_GBC_save_individual.$(date +%s).e -l h_data=32G,h_rt=24:00:00,arch=intel* /u/project/cbearden/data/22q/qunex_studyfolder/analysis/scripts/submit_networkGBC.sh 
