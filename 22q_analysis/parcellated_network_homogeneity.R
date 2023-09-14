# C. Schleifer 9/14/2023
# Script to compute parcellated network homogeneity
# Inputs: preprocessed BOLDs, motion scrubbing file, paths and filenames
# Should be submitted as an array on hoffman using a wrapper script to submit one job per subject (submit_network_homogeneity.sh -> run_network_homogeneity.sh -> parcellated_network_homogeneity.R)

# clear environment
rm(list = ls(all.names = TRUE))

# list of packages to load
packages <- c("optparse", "ciftiTools", "dplyr", "tidyr", "magrittr", "DescTools","parallel")

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
  make_option(c("--overwrite"), type="character", default=TRUE, 
              help="overwrite [T/F]", metavar="character"),
  make_option(c("--bold_name_use"), type="character", default="resting", 
              help="bold name to use", metavar="character")) 
# parse options
opt_parser <- OptionParser(option_list=option_list)
opt <- parse_args(opt_parser)
# set variables from options
sesh=opt$sesh
sessions_dir=opt$sessions_dir
bold_name_use=opt$bold_name_use
after_dir=opt$after_dir
file_end=opt$file_end
overwrite=opt$overwrite
#test options
#sesh="Q_0001_10152010"
#sessions_dir="/u/project/cbearden/data/22q/qunex_studyfolder/sessions/"
#bold_name_use="resting"
#after_dir="/images/functional/"
#file_end="_Atlas_s_hpss_res-mVWM1d_lpss.dtseries.nii"
#overwrite=TRUE

# load parcellation data
ji_path <- file.path(hoffman,"/22q/qunex_studyfolder/analysis/fcMRI/roi/ColeAnticevicNetPartition-master")
ji_key <- read.table(file.path(ji_path,"/CortexSubcortex_ColeAnticevic_NetPartition_wSubcorGSR_parcels_LR_LabelKey.txt"),header=T)
ji_net_keys <- ji_key[,c("NETWORKKEY","NETWORK")] %>% distinct %>% arrange(NETWORKKEY)
xii_Ji_network <- read_cifti(file.path(ji_path,"/data/CortexSubcortex_ColeAnticevic_NetPartition_wSubcorGSR_netassignments_LR.dscalar.nii"), brainstructures = "all")
xii_Ji_parcel <- read_cifti(file.path(ji_path,"/data/CortexSubcortex_ColeAnticevic_NetPartition_wSubcorGSR_parcels_LR.dscalar.nii"), brainstructures = "all")

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

# function to compute average network homogeneity for an ROI
roi_NetHo <- function(bold_roi_mat){
  # mean for ROI
  # if ROI has multiple voxels, input will be a matrix
  if("matrix" %in% class(bold_roi_mat)){
    # if no rows for some reason, set outputs to NA, else get mean time series for ROI
    if(is.null(nrow(bold_roi_mat))){
      out <- data.frame(netHo=NA)
    }else{
      # for each voxel, compute connectivity to all other voxels in roi and add to list
      netho <- NULL
      for(v1 in 1:nrow(bold_roi_mat)){
        corlist <- NULL
        for(v2 in 1:nrow(bold_roi_mat)){
          if(v1!=v2){
            # calculate FC
            vcor <- FisherZ(as.numeric(cor(x=bold_roi_mat[v1,], y=bold_roi_mat[v2,], method="pearson")))
            # add to list
            corlist <- c(corlist,vcor)
          }
        }
        # calculate netho as mean of all correlations for a given voxel and add to list
        netho <- cbind(netho, mean(corlist))
      }
      # get mean network homogeneity
      result <- mean(netho)
      out <- data.frame(netHo=result)
    }
    # if ROI is single voxel, output is NA
  }else if("numeric" %in% class(bold_roi_mat)){
    out <- data.frame(netHo=NA)
  }
  return(out)
}

## wrapper for above functions to compute motion-scrubbed PARCEL NetHo for single subject
main_compute_parc_NetHo <- function(sesh, sessions_dir, bold_name_use, after_dir, file_end){
  out_path <- file.path(sessions_dir,sesh,"images/functional",paste0(bold_name_use,"_ParcelNetHo",gsub(".dtseries.nii","",file_end),"_whole_brain_CABNP.csv"))
  if(file.exists(out_path)){
    print(paste(out_path, "already exists", sep=" "))
  }else{
    print(paste("STARTING:", sesh, sep=" "))
    # get %udvarsme from images/functional/movement/boldn.scrub
    percent_udvarsme_all <- get_percent_udvarsme(sesh=sesh,sessions_dir=sessions_dir,bold_name_use=bold_name_use) %>% as.data.frame
    percent_udvarsme_all$percent_udvarsme <- as.numeric(percent_udvarsme_all$percent_udvarsme)
    percent_udvarsme_all$percent_use <- as.numeric(percent_udvarsme_all$percent_use)
    
    # get path for processed bold rest based on percent_udvarsme_all$bold_n
    print("...getting BOLD path")
    rest_path <- as.data.frame(get_rest_path(sessions_dir=sessions_dir, session=sesh, after_dir=after_dir, file_end = file_end, motion_stats=percent_udvarsme_all))$fpath
    
    # read bold 
    print("...reading BOLD CIFTI")
    bold_input <- read_cifti(rest_path, brainstructures = "all")
    
    # get full movement scrubbing info for session
    print("...performing movement scrubbing based on udvarsme")
    mov_scrub <- get_mov_scrub(sesh=sesh, sessions_dir=sessions_dir, bold_name_use=bold_name_use)
    
    # scrub bad frames from bold
    bold_scrub <- do_bold_scrub(mov=mov_scrub, xii=bold_input, metric="udvarsme",drop_first=5) 
    
    # extract from each CAB-NP parcel
    print("...calculating within-parcel NetHo for CAB-NP parcels")
    parc_mats <- lapply(c(ji_key$INDEX), function(v) extract_voxels_within_roi_timeseries(val=v,bold_dtseries=bold_scrub,rois_dscalar=xii_Ji_parcel))
    
    parc_netHo <- lapply(c(ji_key$INDEX), function(v) roi_NetHo(bold_roi_mat = parc_mats[[v]])) %>% do.call(rbind,.) %>% as.data.frame
    colnames(parc_netHo) <- c("NetHo")
    
    # merge with ji key
    fc_result <- cbind(ji_key[,c("INDEX","LABEL","HEMISPHERE","NETWORK","NETWORKKEY","GLASSERLABELNAME")],parc_netHo)
    
    # save result
    #out_path <- file.path(dirname(rest_path),paste(bold_name_use,"_ParcelNetHo",gsub(".dtseries.nii","",file_end),"_whole_brain_CABNP.csv",sep=""))
    print(paste("...saving result to:",out_path,sep=" "))
    write.table(fc_result, file=out_path, col.names=T, row.names=F, quote=F, na="NA", sep=",", eol = "\n")
    #return(fc_result)
  }
  print(paste("... ",sesh," complete"))
}


# do work
print("Preparing to compute regional network homogeneity...")
print(paste("sessions_dir =",sessions_dir))
print(paste("session =",sesh))
print(paste("after_dir =",after_dir))
print(paste("bold_name_use =",bold_name_use))
print(paste("file_end =",file_end))

main_compute_parc_NetHo(sesh=sesh, sessions_dir=sessions_dir, bold_name_use=bold_name_use, after_dir=after_dir, file_end=file_end)
