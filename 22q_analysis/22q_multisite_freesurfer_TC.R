# C. Schleifer 8/4/2023
# Script to extract BOLD time series from individual freesurfer thalamic and cortical ROIs and compute all correlations
# Inputs: preprocessed BOLDs, motion scrubbing file, freesurfer thal atlas converted to CIFTI, freesurfer DK surface
# Should be run on hoffman2 server due to memory and i/o constraints on local machine. Subsequent steps can be run locally (see striatum_thalamus_rsn_fc.Rmd)

# clear environment
rm(list = ls(all.names = TRUE))

# list of packages to load
packages <- c("optparse","ciftiTools", "dplyr", "tidyr", "magrittr", "DescTools","parallel")

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
#sesh="Q_0001_09242012"
sessions_dir=opt$sessions_dir
#sessions_dir <- file.path(hoffman,"22q/qunex_studyfolder/sessions")
bold_name_use=opt$bold_name_use
#bold_name_use="resting"
after_dir=opt$after_dir
#after_dir="/images/functional/"
file_end=opt$file_end
#file_end="_Atlas_s_hpss_res-mVWMWB1d_lpss.dtseries.nii"

## load parcellation data
#ji_path <- file.path(hoffman,"/22q/qunex_studyfolder/analysis/fcMRI/roi/ColeAnticevicNetPartition-master")
#ji_key <- read.table(file.path(ji_path,"/CortexSubcortex_ColeAnticevic_NetPartition_wSubcorGSR_parcels_LR_LabelKey.txt"),header=T)
#ji_net_keys <- ji_key[,c("NETWORKKEY","NETWORK")] %>% distinct %>% arrange(NETWORKKEY)
#print(ji_net_keys)
#xii_Ji_network <- read_cifti(file.path(ji_path,"/data/CortexSubcortex_ColeAnticevic_NetPartition_wSubcorGSR_netassignments_LR.dscalar.nii"), brainstructures = "all")

# read subject-level thalamic atlas cifti
#xii_subcort_structs <- read_cifti(file.path(hoffman,"22q/qunex_studyfolder/analysis/fcMRI/roi/structures.dtseries.nii"), brainstructures = "all")
#sesh="Q_0001_09242012"
thal_path <- file.path(sessions_dir,sesh,"hcp",sesh,"T1w",sesh,"mri/ThalamicNuclei_Atlas_2mm.dscalar.nii")
xii_thal_orig <- read_cifti(thal_path, brainstructures = "all")
#view_xifti_volume(xii_thal_orig)

# read subject-level cortical DK atlas cifti (32K mesh)
dk_name <- paste0(sesh,".aparc.32k_fs_LR.dlabel.nii")
#dk_path <- file.path(hoffman,"22q/qunex_studyfolder/sessions",sesh,"hcp",sesh,"MNINonLinear/fsaverage_LR32k",dk_name)
dk_path <- file.path(sessions_dir,sesh,"hcp",sesh,"MNINonLinear/fsaverage_LR32k",dk_name)
xii_dk_orig <- read_cifti(dk_path, brainstructures = "all")
#view_xifti_surface(xii_dk_orig)

## group surface regions
# first get key with labels and values for DK dlabel
dk_key <- xii_dk_orig$meta$cifti$labels %>% as.data.frame
colnames(dk_key) <- c("Key","Red","Green","Blue","Alpha")
dk_key$label <- rownames(dk_key)

# match region names to Huang et al 2021 groupings
dk_groups <- list(prefrontal=c("superiorfrontal",
                           "caudalanteriorcingulate",
                           "rostralanteriorcingulate",
                           "medialorbitofrontal",
                           "lateralorbitofrontal",
                           "rostralmiddlefrontal",
                           "parsopercularis",
                           "parsorbitalis",
                           "parstriangularis"), 
              parietal=c("inferiorparietal",
                         "superiorparietal",
                         "precuneus",
                         "isthmuscingulate",
                         "posteriorcingulate",
                         "supramarginal"),
              temporal=c("superiortemporal",
                         "transversetemporal",
                         "middletemporal",
                         "fusiform",
                         "inferiortemporal",
                         "parahippocampal",
                         "entorhinal"),
              motor=c("caudalmiddlefrontal",
                      "paracentral",
                      "precentral"),
              somatosensory="postcentral",
              visual=c("pericalcarine",
                       "lateraloccipital",
                       "lingual",
                       "cuneus"))


# get groupings for left and right hemispheres
dk_left <- lapply(dk_groups, function(x) paste0("L_",x))
names(dk_left) <- paste0("L_",names(dk_left))
dk_right <- lapply(dk_groups, function(x) paste0("R_",x))
names(dk_right) <- paste0("R_",names(dk_right))
dk_all <- c(dk_left, dk_right)

# all region names
dk_all_regions <- unlist(dk_all) %>% as.vector %>% sort

# merge names to manually check matching spelling and missing regions
dk_check <- merge(x=dk_key, y=data.frame(label=dk_all_regions, name=dk_all_regions, exists="x"), by="label", all.x=TRUE, all.y=TRUE)

# get dscalar atlas from dlabel
xii_dk_scalar <- convert_xifti(xii_dk_orig, to="dscalar")

# get scalar values corresponding to each group of regions
dk_group_nums_l <- lapply(dk_left, function(x) dk_key[x,"Key"])
dk_group_nums_r <- lapply(dk_right, function(x) dk_key[x,"Key"])

# get cifti vertices corresponding to each group of regions 
dk_vertex_groups_l <- lapply(dk_group_nums_l, function(x)which(xii_dk_scalar$data$cortex_left %in% x))
dk_vertex_groups_r <- lapply(dk_group_nums_r, function(x)which(xii_dk_scalar$data$cortex_right %in% x))

# create new blank cifti with only zeros or NaNs
xii_blank <- xii_dk_scalar/xii_dk_scalar-1

# create cifti relabeled by region groups
xii_group <- xii_blank
ngroup <- length(dk_vertex_groups_l)
new_roi_ids <- NULL
new_roi_names <- NULL
for (i in 1:ngroup){
  # get different numbers for left and right IDs
  n <- plyr::round_any(ngroup+1, accuracy=10, f=ceiling)
  i_l <- i
  i_r <- n+i
  # update roi key left
  new_roi_ids <- c(new_roi_ids,i_l)
  new_roi_names <- c(new_roi_names,names(dk_vertex_groups_l[i]))
  # update roi key right
  new_roi_ids <- c(new_roi_ids,i_r)
  new_roi_names <- c(new_roi_names,names(dk_vertex_groups_r[i]))
  # get cifti row indices to change
  rows_l <- dk_vertex_groups_l[[i]]
  rows_r <- dk_vertex_groups_r[[i]]
  # edit cifti
  xii_group$data$cortex_left[rows_l,] <- i_l
  xii_group$data$cortex_right[rows_r,] <- i_r
}

# make new roi key
new_roi_key <- data.frame(id=new_roi_ids, name=new_roi_names)
out_path_key <- file.path(sessions_dir, sesh, after_dir, "anatomical_roi_key.csv")
write.table(new_roi_key, file=out_path_key, col.names=T, row.names=F, quote=F, na="NA", sep=",", eol = "\n")

# set unused regions to NA to finalize new atlas
l_unused <- which(!xii_group$data$cortex_left %in% new_roi_key$id)
xii_group$data$cortex_left[l_unused,] <- NA 
r_unused <- which(!xii_group$data$cortex_right %in% new_roi_key$id)
xii_group$data$cortex_right[r_unused,] <- NA 

#view_xifti_surface(xii_group)

# match thal IDs to Huang et al 2021 groupings
# These networks were (1) prefrontal–mediodorsal (2) motor–ventral lateral (3) somatosensory–ventral posterolateral (4) temporal–medial geniculate (5) parietal–pulvinar (6) occipital–lateral geniculate (7) hippocampus–anterior nuclear groups
thal_groups <- list(prefrontal=c(12,13),
                  parietal=c(20,21,22,23),
                  temporal=09,
                  motor=c(26,27,28,29,30),
                  somatosensory=33,
                  visual=15)

thal_left <- lapply(thal_groups, function(x) 8100+x)
names(thal_left) <- paste0("L_", names(thal_left))
thal_right <- lapply(thal_groups, function(x) 8200+x)
names(thal_right) <- paste0("R_", names(thal_right))

# get cifti vertices corresponding to each group of regions 
thal_vertex_groups_l <- lapply(thal_left, function(x)which(xii_thal_orig$data$subcort %in% x))
thal_vertex_groups_r <- lapply(thal_right, function(x)which(xii_thal_orig$data$subcort %in% x))

# create new blank cifti with only zeros or NaNs
xii_blank_thal <- xii_thal_orig/xii_thal_orig-1

# create cifti relabeled by region groups
xii_thal_new <- xii_blank_thal
ngroup_thal <- length(thal_vertex_groups_l)
new_roi_ids_thal <- NULL
new_roi_names_thal <- NULL
for (i in 1:ngroup_thal){
  # get different numbers for left and right IDs
  n <- plyr::round_any(ngroup_thal+1, accuracy=10, f=ceiling)
  i_l <- i
  i_r <- n+i
  # update roi key left
  new_roi_ids_thal <- c(new_roi_ids_thal,i_l)
  new_roi_names_thal <- c(new_roi_names_thal,names(thal_vertex_groups_l[i]))
  # update roi key right
  new_roi_ids_thal <- c(new_roi_ids_thal,i_r)
  new_roi_names_thal <- c(new_roi_names_thal,names(thal_vertex_groups_r[i]))
  # get cifti row indices to change
  rows_l <- thal_vertex_groups_l[[i]]
  rows_r <- thal_vertex_groups_r[[i]]
  # edit cifti
  xii_thal_new$data$subcort[rows_l,] <- i_l
  xii_thal_new$data$subcort[rows_r,] <- i_r
}

# make new roi key
new_roi_key_thal <- data.frame(id=new_roi_ids_thal, name=new_roi_names_thal)

# set unused regions to NA to finalize new atlas
thal_unused <- which(!xii_thal_new$data$subcort %in% new_roi_key_thal$id)
xii_thal_new$data$subcort[thal_unused,] <- NA 
xii_thal_new <- remove_xifti(xii_thal_new, remove=c("cortex_left","cortex_right"))

#view_xifti_volume(xii_thal_new, slices=seq(30,46, by=2))

# combine surface and subcort ciftis
xii_new_atlas <- combine_xifti(xii_group, xii_thal_new)
xii_new_atlas$data$subcort <- xii_thal_new$data$subcort

#view_xifti_volume(xii_new_atlas, crop=FALSE)

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
cort_mask <- xii_new_atlas
cort_mask$data$cortex_left <- as.matrix(rep(1,times=length(cort_mask$data$cortex_left)))
cort_mask$data$cortex_right <- as.matrix(rep(1,times=length(cort_mask$data$cortex_right)))
cort_mask$data$subcort <- as.matrix(rep(0,times=length(cort_mask$data$subcort)))
# thal mask
thal_mask <- xii_new_atlas
thal_mask$data$cortex_left <- as.matrix(rep(0,times=length(thal_mask$data$cortex_left)))
thal_mask$data$cortex_right <- as.matrix(rep(0,times=length(thal_mask$data$cortex_right)))
thal_mask$data$subcort <- as.matrix(rep(1,times=length(thal_mask$data$subcort)))# mask ji networks

xii_new_atlas_cort <- xii_new_atlas * cort_mask
xii_new_atlas_thal <- xii_new_atlas * thal_mask

#view_xifti(xii_new_atlas_cort)
#view_xifti(xii_new_atlas_thal)

  
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


## wrapper for above functions to compute motion-scrubbed WITHIN NETWORK thalamic-cortical FC for single subject
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
  
  # extract from each freeurfer based network
  print("...calculating within-network TC connectivity for anatomical networks")
  cort_mats <- lapply(new_roi_key$id, function(v) extract_voxels_within_roi_timeseries(val=v,bold_dtseries=bold_scrub,rois_dscalar=xii_new_atlas_cort))
  thal_mats <- lapply(new_roi_key_thal$id, function(v) extract_voxels_within_roi_timeseries(val=v,bold_dtseries=bold_scrub,rois_dscalar=xii_new_atlas_thal))
  
  # get means
  cort_means <- lapply(1:length(new_roi_key$id), function(v) roi_means(bold_mat = cort_mats[[v]], roi_name=new_roi_key$name[v])) %>% do.call(cbind,.)
  colnames(cort_means) <- new_roi_key$name
  thal_means <- lapply(1:length(new_roi_key_thal$id), function(v) roi_means(bold_mat = thal_mats[[v]], roi_name=new_roi_key_thal$name[v])) %>% do.call(cbind,.) 
  colnames(thal_means) <- new_roi_key_thal$name
  #colnames(net_rsfa) <- c("t_sd","t_mean")
  
  # save extracted results
  out_path_c <- file.path(dirname(rest_path),paste(bold_name_use,"_cortical_network_mean_timeseries",gsub(".dtseries.nii","",file_end),"_FS_anatomical.csv",sep=""))
  print(paste("...saving result to:",out_path_c,sep=" "))
  write.table(cort_means, file=out_path_c, col.names=T, row.names=F, quote=F, na="NA", sep=",", eol = "\n")
  
  out_path_t <- file.path(dirname(rest_path),paste(bold_name_use,"_thalamic_network_mean_timeseries",gsub(".dtseries.nii","",file_end),"_FS_anatomical.csv",sep=""))
  print(paste("...saving result to:",out_path_t,sep=" "))
  write.table(thal_means, file=out_path_t, col.names=T, row.names=F, quote=F, na="NA", sep=",", eol = "\n")
  
  # thal networks to use for connectivity
  thal_nets <- new_roi_key_thal$name
  # placeholder data frame for TCC matrix
  #tc_mat <- matrix(data=NA, nrow=length(thal_nets), ncol=length(thal_nets)) %>% as.data.frame
  #colnames(tc_mat) <- paste0("Cortical_",thal_nets)
  #rownames(tc_mat) <- paste0("Thalamic_",thal_nets)
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
      #tc_mat[paste0("Thalamic_",tnet),paste0("Cortical_",cnet)] <- fc
      tc_out[i,c("Thalamus","Cortex","pearson_r_Fz")] <- c(tnet, cnet, fc)
      # increment row
      i <- i+1
    }
  }
  # save TCC
  out_path_tc <- file.path(dirname(rest_path),paste(bold_name_use,"_network_TCC_matrix",gsub(".dtseries.nii","",file_end),"_FS_anatomical.csv",sep=""))
  print(paste("...saving TCC result to:",out_path_tc,sep=" "))
  write.table(tc_out, file=out_path_tc, col.names=T, row.names=F, quote=F, na="NA", sep=",", eol = "\n")
}




#### DO WORK

main_extract_net_TC(sessions_dir=sessions_dir,  sesh=sesh,  bold_name_use=bold_name_use,  after_dir=after_dir,  file_end=file_end)


