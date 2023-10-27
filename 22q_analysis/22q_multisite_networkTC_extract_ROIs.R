# C. Schleifer 8/1/2023
# Script to extract BOLD time series from thalamic and cortical networks and compute all correlations
# Inputs: preprocessed BOLDs, motion scrubbing file, CAB-NP atlas cifti, subcortical structures cifti
# Should be run on hoffman2 server due to memory and i/o constraints on local machine. Subsequent steps can be run locally 

# clear environment
rm(list = ls(all.names = TRUE))

# list of packages to load
packages <- c("optparse","ciftiTools", "dplyr", "tidyr", "DescTools")

# install packages not yet installed
# note: ciftiTools install fails if R is started without enough memory
installed_packages <- packages %in% rownames(installed.packages())
# comment out line below to skip install
if (any(installed_packages == FALSE)) {install.packages(packages[!installed_packages])}

# load packages
invisible(lapply(packages, library, character.only = TRUE))

# set up workbench
# wbpath <- "/Applications/workbench/bin_macosx64/"
wbpath <- "/u/project/cbearden/data/scripts/tools/workbench/bin_rh_linux64/wb_command"
ciftiTools.setOption("wb_path", wbpath)

# set up hoffman path
hoffman <- "/u/project/cbearden/data/"
#hoffman <- "~/Desktop/hoffman_mount/"

# get command line options
option_list <- list(
  make_option(c("--sessions_dir"), type="character", default=NULL, 
              help="study directory", metavar="character"),
  make_option(c("--sesh"), type="character", default=NULL, 
              help="MRI ID", metavar="character"),
  make_option(c("--after_dir"), type="character", default="/images/functional/", 
              help="directory within session", metavar="character"),
  make_option(c("--file_end"), type="character", default=NULL, 
              help="file name end to look for", metavar="character"),
  make_option(c("--bold_name_use"), type="character", default="resting", 
              help="bold name to use", metavar="character")
) 

opt_parser <- OptionParser(option_list=option_list)
opt <- parse_args(opt_parser)

sesh=opt$sesh
sessions_dir=opt$sessions_dir
bold_name_use=opt$bold_name_use
after_dir=opt$after_dir
file_end=opt$file_end

# load parcellation data
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
  roi_rows <- which(as.matrix(rois_dscalar) == val)
  bold_roi <- as.matrix(bold_dtseries)[roi_rows,]
  bold_roi_mean <- apply(bold_roi,2,mean)
  return(bold_roi_mean)
}

# wrapper to run extract_single_roi_timeseries for multiple rois
extract_rois_timeseries <- function(bold_dtseries,rois_dscalar,rois_values,name_prefix){
  output <- lapply(rois_values, function(v) extract_single_roi_timeseries(bold_dtseries=bold_dtseries,rois_dscalar=rois_dscalar,val=v)) %>% do.call(rbind,.) %>% as.data.frame
  rois_names <- ji_net_keys[rois_values,2]
  rownames(output) <- paste(name_prefix,rois_names,sep="")
  #rownames(output) <- paste(name_prefix,rois_values,sep="")
  return(output)
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

# function to output time series averaged over all voxels
roi_means <- function(bold_mat, roi_name){
  # get the mean time series for each ROI
  bold_mean <- apply(bold_mat,2,mean)
  # make data frame
  bold_df <- data.frame(tempname=as.vector(bold_mean))
  colnames(bold_df) <- roi_name
  return(bold_df)
}

# wrapper for above functions to compute motion-scrubbed WITHIN NETWORK thalamic-cortical FC for single subject
main_extract_net_TC <- function(sesh, sessions_dir, bold_name_use, after_dir, file_end){
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
  thal_mats <- lapply(c(1:12), function(v) extract_voxels_within_roi_timeseries(val=v,bold_dtseries=bold_scrub,rois_dscalar=xii_Ji_net_thal))
  
  # get means
  cort_means <- lapply(c(1:12), function(v) roi_means(bold_mat = cort_mats[[v]], roi_name=ji_net_keys[v,"NETWORK"])) %>% do.call(cbind,.)
  colnames(cort_means) <- ji_net_keys$NETWORK %>% gsub("-","_",.)
  thal_means <- lapply(c(1:12), function(v) roi_means(bold_mat = thal_mats[[v]], roi_name=ji_net_keys[v,"NETWORK"])) %>% do.call(cbind,.) 
  colnames(thal_means) <- ji_net_keys$NETWORK %>% gsub("-","_",.)
  #colnames(net_rsfa) <- c("t_sd","t_mean")
  
  # save extracted results
  out_path_c <- file.path(dirname(rest_path),paste(bold_name_use,"_cortical_network_mean_timeseries",gsub(".dtseries.nii","",file_end),"_CABNP.csv",sep=""))
  print(paste("...saving result to:",out_path_c,sep=" "))
  write.table(cort_means, file=out_path_c, col.names=T, row.names=F, quote=F, na="NA", sep=",", eol = "\n")
  
  out_path_t <- file.path(dirname(rest_path),paste(bold_name_use,"_thalamic_network_mean_timeseries",gsub(".dtseries.nii","",file_end),"_CABNP.csv",sep=""))
  print(paste("...saving result to:",out_path_t,sep=" "))
  write.table(thal_means, file=out_path_t, col.names=T, row.names=F, quote=F, na="NA", sep=",", eol = "\n")
  
  # thal networks to use for connectivity
  thal_nets <- c("Visual1","Visual2","Somatomotor","Cingulo_Opercular","Dorsal_Attention","Frontoparietal","Auditory","Default","Posterior_Multimodal")
 
  # placeholder data frame for TCC matrix
  nastring <- rep(NA, times=length(thal_nets)^2)
  tc_out <- data.frame(Thalamus=nastring, Cortex=nastring, pearson_r_Fz=nastring)
  
  # TCC between every pair of networks
  i=1
  for(tnet in thal_nets){
    for(cnet in thal_nets){
      # get thal and cortex time series for chosen networks
      tseries <- as.vector(thal_means[,tnet])
      cseries <- as.vector(cort_means[,cnet])
      # get connectivity
      fc <- FisherZ(as.numeric(cor(x=tseries, y=cseries, method="pearson", use="na.or.complete")))
      # save in data frame
      tc_out[i,c("Thalamus","Cortex","pearson_r_Fz")] <- c(tnet, cnet, fc)
      # increment row
      i <- i+1
    }
  }
  
  # save TCC
  out_path_tc <- file.path(dirname(rest_path),paste(bold_name_use,"_network_TCC_matrix",gsub(".dtseries.nii","",file_end),"_CABNP.csv",sep=""))
  print(paste("...saving TCC result to:",out_path_tc,sep=" "))
  write.table(tc_out, file=out_path_tc, col.names=T, row.names=F, quote=F, na="NA", sep=",", eol = "\n")
  #write.table(tc_out, file="~/Desktop/test.csv", col.names=T, row.names=F, quote=F, na="NA", sep=",", eol = "\n")
}

## DO WORK
main_extract_net_TC(sessions_dir=sessions_dir,  sesh=sesh,  bold_name_use=bold_name_use,  after_dir=after_dir,  file_end=file_end)



# qsub -cwd -V -o /u/project/cbearden/data/22q/qunex_studyfolder/processing/logs/manual/22q_TCC_save_individual.$(date +%s).o -e /u/project/cbearden/data/22q/qunex_studyfolder/processing/logs/manual/22q_TCC_save_individual.$(date +%s).e -l h_data=32G,h_rt=24:00:00,arch=intel* /u/project/cbearden/data/22q/qunex_studyfolder/analysis/scripts/submit_networkTC.sh 
