# C. Schleifer 4/5/2022
# Script to compute functional connectivity within and between individual parcels in CAB-NP atlas
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
#wbpath <- "/u/project/CCN/apps/hcp/current/workbench/bin_rh_linux64/wb_command" # wasn't working with CCN version
wbpath <- "/u/project/cbearden/data/scripts/tools/workbench/bin_rh_linux64/wb_command"
ciftiTools.setOption("wb_path", wbpath)

# set up hoffman path
hoffman <- "/u/project/cbearden/data/"

## load parcellation data
ji_path <- file.path(hoffman,"/22q/qunex_studyfolder/analysis/fcMRI/roi/ColeAnticevicNetPartition-master")
ji_key <- read.table(file.path(ji_path,"/CortexSubcortex_ColeAnticevic_NetPartition_wSubcorGSR_parcels_LR_LabelKey.txt"),header=T)
ji_net_keys <- ji_key[,c("NETWORKKEY","NETWORK")] %>% distinct %>% arrange(NETWORKKEY)
print(ji_net_keys)
#xii_Ji_network <- read_cifti(file.path(ji_path,"/data/CortexSubcortex_ColeAnticevic_NetPartition_wSubcorGSR_netassignments_LR.dscalar.nii"), brainstructures = "all")
xii_Ji_parcel <- read_cifti(file.path(ji_path,"/data/CortexSubcortex_ColeAnticevic_NetPartition_wSubcorGSR_parcels_LR.dscalar.nii"), brainstructures = "all")

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


# function to get mapping between boldn and run name from session_hcp.txt
get_boldn_names <- function(sesh,sessions_dir){
  hcptxt <- read.table(file.path(sessions_dir,sesh,"session_hcp.txt"),sep=":",comment.char="#",fill=T,strip.white=T,col.names=c(1:4)) %>% as.data.frame()
  hcpbolds <- hcptxt %>% filter(grepl("bold",X2))
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
  roi_rows <- which(as.matrix(rois_dscalar) == val)
  bold_roi <- as.matrix(bold_dtseries)[roi_rows,]
  # take mean if roi is more than 1 voxel, else consider that 1 voxel as mean
  if(!is.null(nrow(bold_roi))){
    bold_roi_mean <- apply(bold_roi,2,mean)
  }else{
    bold_roi_mean <- bold_roi
  }
  return(bold_roi_mean)
}

# wrapper to run extract_single_roi_timeseries for multiple rois with numeric values for names
extract_rois_timeseries_valnames <- function(bold_dtseries,rois_dscalar,rois_values,name_prefix){
  output <- lapply(rois_values, function(v) extract_single_roi_timeseries(bold_dtseries=bold_dtseries,rois_dscalar=rois_dscalar,val=v)) %>% do.call(rbind,.) %>% as.data.frame
  rois_names <- ji_net_keys[rois_values,2]
  #rownames(output) <- paste(name_prefix,rois_names,sep="")
  rownames(output) <- paste(name_prefix,rois_values,sep="")
  return(output)
}

# function to extract matrix with BOLD timeseries for each grayordinate in an roi (e.g. for restricted gbc)
extract_voxels_within_roi_timeseries <- function(bold_dtseries,rois_dscalar,val){
  roi_rows <- which(as.matrix(rois_dscalar) == val)
  bold_roi <- as.matrix(bold_dtseries)[roi_rows,]
  return(bold_roi)
}

# function to make column to determine duplicate rows
cross_sort_col <- function(a,b){
  sorted <- sort(c(a,b))
  new_col <- paste(sorted[1],sorted[2],sep="_")
  return(new_col)
}

# function to get lower triangle crossing for two lists
# note: this version expects rois to have character names (not numeric)
crossing_lower_tri <- function(a_list,b_list){
  cross_initial <- crossing(a=a_list, b=b_list) 
  cross <- cross_initial %>% filter(a != b)
  new_col <- lapply(1:nrow(cross), function(r) cross_sort_col(a=as.character(cross[r,"a"]), b=as.character(cross[r,"b"]))) %>% do.call(rbind,.) %>% as.data.frame %>% setNames(.,"sort_col")
  cross_sort <- cbind(cross,new_col)
  indices <- which(duplicated(cross_sort$sort_col))
  output <- cross_sort[indices,]
  return(output)
}


# version for numeric named rois (e.g. for grayordinates within network) 
crossing_lower_tri_num <- function(a_list,b_list){
  cross_initial <- crossing(a=a_list, b=b_list) 
  cross <- cross_initial %>% filter(a != b)
  new_col <- lapply(1:nrow(cross), function(r) cross_sort_col(a=as.numeric(cross[r,"a"]), b=as.numeric(cross[r,"b"]))) %>% do.call(rbind,.) %>% as.data.frame %>% setNames(.,"sort_col")
  cross_sort <- cbind(cross,new_col)
  indices <- which(duplicated(cross_sort$sort_col))
  output <- cross_sort[indices,]
  return(output)
}

# function to compute functional connectivity between all unique pairs of rois. Usage: lapply to the output of extract_rois_timeseries. 
roi_fc_matrix <- function(df){
  rois <- rownames(df)
  # get all pairs of rois to test correlation for
  roi_combos <- crossing_lower_tri(a_list=rois,b_list=rois)
  # initialize empty vector to hold results
  corr_list <- NULL
  # loop through each combination of rois and calculate fisher z-transformed pearson r
  for(r in 1:nrow(roi_combos)){
    roi1 <- roi_combos[r,1] 
    roi2 <- roi_combos[r,2] 
    data_roi1 <- as.matrix(df)[roi1,]
    data_roi2 <- as.matrix(df)[roi2,]
    pearsonFz <- as.numeric(FisherZ(cor(x=data_roi1, y=data_roi2, method="pearson", use="na.or.complete")))
    corr_list <- rbind(corr_list,pearsonFz)
  }
  output <- cbind(roi_combos[,c("a","b")], corr_list) %>% as.data.frame
  colnames(output) <- c("roi_1","roi_2","pearson_r_Fz")
  return(output)
}


# function to compute Fz correlation between each unique grayordinate in an ROI and that ROI's average timeseries
# faster than within_roi_mean_fullmat
within_roi_mean_gbc <- function(bold_roi_mat){
  # if ROI has multiple rows, take mean and calculate rGBC for each row
  if(!is.null(nrow(bold_roi_mat))){
    bold_roi_mean <- apply(bold_roi_mat,2,mean)
    # for each row of bold_roi_mean df, correlate the timeseries in the bold_mask rows 
    fc <- mclapply(1:nrow(bold_roi_mat), function(r) FisherZ(as.numeric(cor(x=as.numeric(bold_roi_mat[r,]), y=as.numeric(bold_roi_mean), method="pearson", use="na.or.complete")))) %>% do.call(rbind,.) %>% as.vector
    output <- as.data.frame(cbind(mean(fc), sd(fc), sd(fc)/sqrt(nrow(bold_roi_mat)),nrow(bold_roi_mat)))
  # if nrow is null it is most likely due to the parcel containing a single voxel
  # set output to NA
  }else{
    output <- as.data.frame(cbind("NA","NA","NA","NA"))
  }
  colnames(output) <- c("fc_mean","fc_standard_dev","fc_standard_err","n_grayordinates")
  print(output)
  return(output)
}

## wrapper for above functions to compute motion-scrubbed BETWEEN PARCEL fc for single subject
# sesh = "Q_0001_10152010"
# sessions_dir = file.path(hoffman,"22q/qunex_studyfolder/sessions")
# bold_name_use = "resting"
# after_dir ="/images/functional/"
# file_end = "_Atlas_s_hpss_res-mVWMWB1d_lpss.dtseries.nii"
main_compute_bparc_fc <- function(sesh, sessions_dir, bold_name_use, after_dir, file_end){
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
  
  # extract from each CAB-NP parcel
  print(paste("...extracting signal from CAB-NP parcels 1:",max(as.matrix(xii_Ji_parcel)),sep=""))
  wb_jiParc_timeseries <- extract_rois_timeseries_valnames(bold_dtseries=bold_scrub, rois_dscalar=xii_Ji_parcel, rois_values=sort(unique(as.matrix(xii_Ji_parcel))), name_prefix="")
  
  # compute FC
  print("...computing FC")
  fc_result <- roi_fc_matrix(as.data.frame(wb_jiParc_timeseries))
  print(paste(sesh,"DONE",paste=" "))
  
  # save result
  out_path <- file.path(dirname(rest_path),paste("resting_fc_matrix",gsub(".dtseries.nii","",file_end),"_whole_brain_CABNP_between_parc.csv",sep=""))
  print(paste("...saving result to:",out_path,sep=" "))
  write.table(fc_result, file=out_path, col.names=T, row.names=F, quote=F, na="NA", sep=",", eol = "\n")
}


## wrapper for above functions to compute motion-scrubbed WITHIN PARCEL gbc for single subject
main_compute_wparc_fc <- function(sesh, sessions_dir, bold_name_use, after_dir, file_end){
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
  print("...calculating within-parcel FC for CAB-NP parcels")
  parc_mats <- lapply(c(1:max(as.matrix(xii_Ji_parcel))), function(v) extract_voxels_within_roi_timeseries(val=v,bold_dtseries=bold_scrub,rois_dscalar=xii_Ji_parcel))
  within_parc_fc <- lapply(c(1:max(as.matrix(xii_Ji_parcel))), function(v) within_roi_mean_gbc(bold_roi_mat = parc_mats[[v]])) %>% do.call(rbind,.) %>% as.data.frame

  # merge with ji net key
  fc_result <- cbind(ji_key,within_parc_fc)
  
  # save result
  out_path <- file.path(dirname(rest_path),paste("resting_fc_means",gsub(".dtseries.nii","",file_end),"_whole_brain_CABNP_within_parc.csv",sep=""))
  print(paste("...saving result to:",out_path,sep=" "))
  write.table(fc_result, file=out_path, col.names=T, row.names=F, quote=F, na="NA", sep=",", eol = "\n")
}


# function to run fc for all sessions matching sesh_pattern in session_dir that have the file specified by after_dir, bold_name_use, and file_end
# sesh_pattern = "Q_[0-9]"
run_sesh_list <- function(sessions_dir,sesh_pattern,after_dir,bold_name_use,file_end){
  print("Preparing to compute FC for all sessions in sessions_dir with existing input data")
  print(paste("sessions_dir =",sessions_dir))
  print(paste("sesh_pattern =",sesh_pattern))
  print(paste("after_dir =",after_dir))
  print(paste("bold_name_use =",bold_name_use))
  print(paste("file_end =",file_end))
  
  # get list of all sessions in sessions_dir
  sesh_all <- list.files(sessions_dir,pattern=sesh_pattern)
  
  # get subset of list with movement scrubbing info available 
  scrub_exists_all <- lapply(sesh_all, function(s) check_mov_scrub(sesh=s,sessions_dir=sessions_dir,bold_name_use=bold_name_use)) %>% do.call(rbind,.) %>% as.data.frame
  sesh_with_scrub <- sesh_all[which(scrub_exists_all == T)]
  sesh_without_scrub <- sesh_all[which(scrub_exists_all == F)]
  print("Sessions without BOLD scrubbing info (skipping):")
  print(sesh_without_scrub)
  
  # read bold info
  percent_udvarsme_all <- lapply(sesh_with_scrub, function(s) get_percent_udvarsme(sesh=s,sessions_dir=sessions_dir,bold_name_use=bold_name_use)) %>% do.call(rbind,.) %>% as.data.frame
  
  # get path for processed bold rest based on percent_udvarsme_all$bold_n
  rest_path_all <- lapply(sesh_with_scrub, function(s) get_rest_path(session=s, sessions_dir=sessions_dir, after_dir=after_dir, file_end=file_end, motion_stats=percent_udvarsme_all)) %>% do.call(rbind,.) %>% as.data.frame
  
  # check that input files exist
  exists_tf <- lapply(rest_path_all$fpath,file.exists) %>% do.call(rbind,.) %>% as.data.frame
  existing_files <- rest_path_all$fpath[which(exists_tf == T)]
  sesh_use <- rest_path_all$sesh[which(exists_tf == T)]
  missing_files <- rest_path_all$fpath[which(exists_tf == F)]
  
  # calculate within and between network FC for all sessions with data (sesh_use)
#  lapply(sesh_use, function(s) main_compute_wparc_fc(sesh=s, sessions_dir=sessions_dir, bold_name_use=bold_name_use, after_dir=after_dir, file_end=file_end))
  lapply(sesh_use, function(s) main_compute_bparc_fc(sesh=s, sessions_dir=sessions_dir, bold_name_use=bold_name_use, after_dir=after_dir, file_end=file_end))
}




#### DO WORK
### between parcel fc, and within parcel gbc
## GSR
# 22qTrio
#run_sesh_list(sessions_dir = file.path(hoffman,"22q/qunex_studyfolder/sessions"), sesh_pattern = "Q_[0-9]", bold_name_use = "resting", after_dir ="/images/functional/", file_end = "_Atlas_s_hpss_res-mVWMWB1d_lpss.dtseries.nii")

# SUNY
run_sesh_list(sessions_dir = file.path(hoffman,"Enigma/SUNY/qunex_studyfolder/sessions"), sesh_pattern = "X[0-9]", bold_name_use = "resting", after_dir ="/images/functional/", file_end = "_Atlas_s_hpss_res-mVWMWB1d_lpss.dtseries.nii")

# IoP
run_sesh_list(sessions_dir = file.path(hoffman,"Enigma/IoP/qunex_studyfolder/sessions"), sesh_pattern = "GQAIMS[0-9]", bold_name_use = "resting", after_dir ="/images/functional/", file_end = "_Atlas_s_hpss_res-mVWMWB1d_lpss.dtseries.nii")

# Rome
run_sesh_list(sessions_dir = file.path(hoffman,"Enigma/Rome/qunex_studyfolder/sessions"), sesh_pattern = "[0-9]", bold_name_use = "resting", after_dir ="/images/functional/", file_end = "_Atlas_s_hpss_res-mVWMWB1d_lpss.dtseries.nii")



#### no GSR
## 22qTrio
yrun_sesh_list(sessions_dir = file.path(hoffman,"22q/qunex_studyfolder/sessions"), sesh_pattern = "Q_[0-9]", bold_name_use = "resting", after_dir ="/images/functional/", file_end = "_Atlas_s_hpss_res-mVWM1d_lpss.dtseries.nii")

# SUNY
run_sesh_list(sessions_dir = file.path(hoffman,"Enigma/SUNY/qunex_studyfolder/sessions"), sesh_pattern = "X[0-9]", bold_name_use = "resting", after_dir ="/images/functional/",file_end = "_Atlas_s_hpss_res-mVWM1d_lpss.dtseries.nii")

# IoP
run_sesh_list(sessions_dir = file.path(hoffman,"Enigma/IoP/qunex_studyfolder/sessions"), sesh_pattern = "GQAIMS[0-9]", bold_name_use = "resting", after_dir ="/images/functional/", file_end = "_Atlas_s_hpss_res-mVWM1d_lpss.dtseries.nii")

# Rome
run_sesh_list(sessions_dir = file.path(hoffman,"Enigma/Rome/qunex_studyfolder/sessions"), sesh_pattern = "[0-9]", bold_name_use = "resting", after_dir ="/images/functional/", file_end = "_Atlas_s_hpss_res-mVWM1d_lpss.dtseries.nii")




# qsub -cwd -V -o /u/project/cbearden/data/22q/qunex_studyfolder/processing/logs/manual/22qTrio_parcel_fc_save_individual.o -e /u/project/cbearden/data/22q/qunex_studyfolder/processing/logs/manual/22qTrio_parcel_fc_save_individual.e -l h_data=32G,h_rt=64:00:00,arch=intel*,highp /u/project/cbearden/data/22q/qunex_studyfolder/analysis/scripts/submit_parcel_fc.sh 
