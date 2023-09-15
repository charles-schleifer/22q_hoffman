# subset of 22q_within_network_GBC.Rmd to be run on hoffman2

## set up packages
# load ciftiTools
if(!require('ciftiTools', quietly=TRUE)){install.packages('ciftiTools')}

# set up workbench
#wbpath <- "/u/project/CCN/apps/hcp/current/workbench/bin_rh_linux64/wb_command"
# wasn't working with CCN version
wbpath <- "/u/project/cbearden/data/scripts/tools/workbench/bin_rh_linux64/wb_command"
ciftiTools.setOption("wb_path", wbpath)

# set up hoffman path
hoffman <- "/u/project/cbearden/data/"

# additional libs
if(!require('dplyr', quietly=TRUE)){install.packages('dplyr')}
if(!require('tidyr', quietly=TRUE)){install.packages('tidyr')}
if(!require('tibble', quietly=TRUE)){install.packages('tibble')}
if(!require('ggplot2', quietly=TRUE)){install.packages('ggplot2')}
if(!require('parallel', quietly=TRUE)){install.packages('tidyr')}
if(!require('magrittr', quietly=TRUE)){install.packages('magrittr')}
if(!require('tableone', quietly=TRUE)){install.packages('tableone')}
if(!require('DescTools', quietly=TRUE)){install.packages('DescTools')}

## load parcellation data
ji_path <- "/u/project/cbearden/data/22q/qunex_studyfolder/analysis/fcMRI/roi/ColeAnticevicNetPartition-master"
ji_key <- read.table(file.path(ji_path,"/CortexSubcortex_ColeAnticevic_NetPartition_wSubcorGSR_parcels_LR_LabelKey.txt"),header=T)
ji_net_keys <- ji_key[,c("NETWORKKEY","NETWORK")] %>% distinct %>% arrange(NETWORKKEY)
print(ji_net_keys)
xii_Ji_parcel <- read_cifti(file.path(ji_path,"/data/CortexSubcortex_ColeAnticevic_NetPartition_wSubcorGSR_parcels_LR.dscalar.nii"), brainstructures = "all")
xii_Ji_network <- read_cifti(file.path(ji_path,"/data/CortexSubcortex_ColeAnticevic_NetPartition_wSubcorGSR_netassignments_LR.dscalar.nii"), brainstructures = "all")

## get motion data for all sessions by reading movement scrubbing files on hoffman
# set hoffman path (from cbearden/data) to trio sessions folder
sessions_dir <- file.path(hoffman,"22q/qunex_studyfolder/sessions")

# get list of sessions
qunex_22q_sessions <- list.files(sessions_dir,pattern="Q_[0-9]")

# function to get mapping between boldn and run name from session_hcp.txt
get_boldn_names <- function(sesh,sessions_dir){
  hcptxt <- read.table(file.path(sessions_dir,sesh,"session_hcp.txt"),sep=":",comment.char="#",fill=T,strip.white=T,col.names=c(1:4)) %>% as.data.frame()
  hcpbolds <- hcptxt %>% filter(grepl("bold",X2))
  df_out <- cbind(rep(sesh,times=nrow(hcpbolds)),hcpbolds$X2,hcpbolds$X3)
  colnames(df_out) <- c("sesh","bold_n","bold_name")
  return(df_out)
}

boldn_names <- lapply(qunex_22q_sessions,function(s) get_boldn_names(sesh=s,sessions_dir=sessions_dir)) %>% do.call(rbind,.) %>% as.data.frame

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

# get udvarsme stats
percent_udvarsme_all <- lapply(qunex_22q_sessions,function(s) get_percent_udvarsme(sesh=s,sessions_dir=sessions_dir,bold_name_use="resting")) %>% do.call(rbind,.) %>% as.data.frame
percent_udvarsme_all$percent_udvarsme <- as.numeric(percent_udvarsme_all$percent_udvarsme)
percent_udvarsme_all$percent_use <- as.numeric(percent_udvarsme_all$percent_use)
# get sessions with over 50% bad frames
percent_udvarsme_over50 <- filter(percent_udvarsme_all,percent_udvarsme_all$percent_udvarsme > 50)$sesh
percent_udvarsme_under50 <- filter(percent_udvarsme_all,percent_udvarsme_all$percent_udvarsme < 50)$sesh

## get SISTAT data
# set location of exported sistat data
dir <- "/u/project/cbearden/data/22q/qunex_studyfolder/analysis/behavior/"
csvdir <- paste(dir,"csv",sep="/")
#setwd(csvdir)

# get list of files in directory
files <- list.files(csvdir)
fpaths <- lapply(files, function(file) paste(csvdir,file,sep="/"))

# clean names
fnames <- gsub(".csv","",files)
fnames <- gsub("Re22Q_","",fnames)
fnames <- gsub("Form_","",fnames)
fnames <- gsub("Qry_","",fnames)

# read all, set to na: "-9999", "-9998","." 
input_all <- lapply(fpaths, read.csv, header=T, na.strings=c(".","-9999","-9998"), strip.white=T, sep=",")
names(input_all) <- fnames
df_all <- lapply(input_all, function(x) data.frame(x))
trio_scans   <- read.table(paste(dir,'/22q_all_trio_scans_10082021.txt',sep=""))[[1]]
prisma_scans <- read.table(paste(dir,'/22q_all_prisma_scans_10082021.txt',sep=""))[[1]]

# function to match mri ID to scanner
get_scanner <- function(x) {
  if (x %in% trio_scans) {
    return('trio')
  } else if (x %in% prisma_scans) {
    return('prisma')
  } else if (x %in% prisma_scans & x %in% trio_scans) {
    return('ERROR. present in both lists')
  } else {
    return('NA')  
  }
}

# get vector of scanner names
demo_scanner <- data.frame(sapply(df_all$demo_mri$MRI_S_ID, get_scanner))
colnames(demo_scanner) <- 'SCANNER'

# add scanner to df
df_all$demo_mri <- add_column(df_all$demo_mri,demo_scanner,.after='MRI_S_ID')

# read list of usable scans
IDs_usable <- read.table(paste(dir,'/22q_scans_use_trio_n195_prisma_n114.txt',sep=""))[[1]]

# remove percent_udvarsme_over50 scans from usable
IDs_usable_mov <- setdiff(IDs_usable,percent_udvarsme_over50)

# subset demo_mri for used scans
df_usable_scans <- df_all$demo_mri %>% filter(MRI_S_ID %in% IDs_usable_mov)

# change sex coding from 0/1 to F/M 
#df_usable_scans$SEX <- demo_use_scans$SEX %>% gsub("0","F",.) %>% gsub("1","M",.) %>% as.factor
df_usable_scans$SEX <- factor(df_usable_scans$SEX,labels=c("F","M"))

# get only sessions with SIPS G1SEV
#sips <- df_all$SIPS

# function to add column to code timepoints relative to sample used (i.e. if visit 1 and 1.12 missing, then 1.24 is baseline)
# trio/prisma coded as T/P-visit_n where T-1 would be the subject's first trio scan and P-1 the first prisma, P-2 the second...
# function should be applied to the indicies of rows (r) in a subset of demo_mri
gettp <- function(r, df){
  sub <- df$SUBJECTID[[r]]
  visit <- df$CONVERTEDVISITNUM[[r]]
  all_visits <- df$CONVERTEDVISITNUM[which(df$SUBJECTID == sub)] %>% sort
  n_visits <- length(all_visits)
  nt_visits <-length(which(all_visits < 2))
  np_visits <- length(which(all_visits >= 2))
  visit_index <- which(all_visits == visit)
  if (visit < 2){
    label=paste("T-",visit_index,sep="")
  }else if (visit >= 2){
    p_visits <- all_visits[which(all_visits >= 2)] %>% sort
    p_visit_index <- which(p_visits == visit)
    label=paste("P-",p_visit_index,sep="")
  }
  return(c(sub,visit,label,n_visits,nt_visits,np_visits))
}

# get timepoints
timepoints <- sapply(1:nrow(df_usable_scans),function(r) gettp(r,df_usable_scans)) %>% t %>% as.data.frame
colnames(timepoints) <- c("SUBJECTID","CONVERTEDVISITNUM","converted_timepoint","n_timepoints","n_trio","n_prisma")
df_usable_scans_tp <- cbind(df_usable_scans,timepoints[,3:6])

# subset to hcs del
df_usable_scans_hcs_del <- df_usable_scans_tp %>% filter(SUBJECT_IDENTITY=="CONTROL" | SUBJECT_IDENTITY =="PATIENT-DEL")

# ugly lines below are to do some convoluted subsetting for age matching for a cross-sectional analysis
# want to take the older timepoints for some of the younger controls
# first get hcs+del scans between age 13 and 30 and use trio timepoint 1
df_usable_scans_hcs_del_g13u30_t1 <- df_usable_scans_hcs_del %>% filter(AGE >= 13 & AGE < 30 & converted_timepoint == "T-1")
# get hcs+del trio scans between age 7 and 13
df_usable_scans_hcs_del_g7u13 <- df_usable_scans_hcs_del %>% filter(AGE >= 7 & AGE < 13 & SCANNER == "trio")
# take timepoint 1 for del 7-13yo scans
df_usable_scans_del_g7u13_t1 <- df_usable_scans_hcs_del_g7u13 %>% filter(converted_timepoint == "T-1",SUBJECT_IDENTITY=="PATIENT-DEL")
# subset hcs
df_usable_scans_hcs_g7u13 <- df_usable_scans_hcs_del_g7u13 %>% filter(SUBJECT_IDENTITY=="CONTROL")
# take timepoint 2 for hcs 7-13yo scans if available
df_usable_scans_hcs_g7u13_t2 <- df_usable_scans_hcs_g7u13 %>% filter(converted_timepoint == "T-2")
# take timepoint 1 for the rest of the 7-13yo hcs
df_usable_scans_hcs_g7u13_t1 <- df_usable_scans_hcs_g7u13 %>% filter(converted_timepoint == "T-1" & !SUBJECTID %in% df_usable_scans_hcs_g7u13_t2$SUBJECTID)
# combine 13-30 year old both groups T-1 with the 7-13yo deletion T-1 scans and the 7-13yo hcs scans using T-2 when available and T-1 otherwise 
df_usable_scans_hcs_del_g7u30_xs <- rbind(df_usable_scans_hcs_del_g13u30_t1,df_usable_scans_del_g7u13_t1,df_usable_scans_hcs_g7u13_t2,df_usable_scans_hcs_g7u13_t1)

# need to remove some of the 7-8yo controls to match ages, will order them by %udvarsme and remove worst until ages match
hcs_7yo <- df_usable_scans_hcs_del_g7u30_xs %>% filter(AGE == 7 & SUBJECT_IDENTITY == "CONTROL")
hcs_7yo_mov <- percent_udvarsme_all %>% filter(sesh %in% hcs_7yo$MRI_S_ID)
hcs_7yo_mov_ordered <- hcs_7yo_mov[order(-hcs_7yo_mov$percent_udvarsme),]
hcs_7yo_remove <- hcs_7yo_mov_ordered[1:7,1]

hcs_8yo <- df_usable_scans_hcs_del_g7u30_xs %>% filter(AGE == 8 & SUBJECT_IDENTITY == "CONTROL")
hcs_8yo_mov <- percent_udvarsme_all %>% filter(sesh %in% hcs_8yo$MRI_S_ID)
hcs_8yo_mov_ordered <- hcs_8yo_mov[order(-hcs_8yo_mov$percent_udvarsme),]
hcs_8yo_remove <- hcs_8yo_mov_ordered[1:3,1]

hcs_remove <- c(hcs_7yo_remove,hcs_8yo_remove)

df_usable_scans_hcs_del_xs <- df_usable_scans_hcs_del_g7u30_xs %>% filter(!MRI_S_ID %in% hcs_remove)
demo_match_summary <- CreateTableOne(data=df_usable_scans_hcs_del_xs,vars=c("AGE","SEX"),strata="SUBJECT_IDENTITY",addOverall=F)
print(demo_match_summary)

# get scan lists
hcs_list <- filter(df_usable_scans_hcs_del_xs, SUBJECT_IDENTITY == "CONTROL")$MRI_S_ID
del_list <- filter(df_usable_scans_hcs_del_xs, SUBJECT_IDENTITY == "PATIENT-DEL")$MRI_S_ID

## load 22q CIFTI data
# function to get path for processed bold rest based on percent_udvarsme_all$bold_n
get_rest_path  <- function(session,studydir,file_end,afterdir,motion_stats){
  boldn <- as.character(filter(motion_stats,sesh==session)$bold_n)
  file <- paste(boldn,file_end,sep="")
  fpath <- file.path(studydir,session,afterdir,file)
  return(fpath)
}

# function to read list of ciftis and create list object with each xifti result
# input is the full path, e.g. output from get_rest_path
read_cifti_list <- function(fpath){
  print(fpath)
  xii <- read_cifti(fpath, brainstructures = "all")
  return(xii)
}

# read list of files 
xii_hcs_rest <- lapply(hcs_list, function(s) read_cifti_list(get_rest_path(studydir = file.path(hoffman,"/22q/qunex_studyfolder/sessions/"), session=as.character(s), afterdir="/images/functional/", file_end = "_Atlas_s_hpss_res-mVWMWB1d_lpss.dtseries.nii", motion_stats=percent_udvarsme_all)))
xii_del_rest <- lapply(del_list, function(s) read_cifti_list(get_rest_path(studydir = file.path(hoffman,"/22q/qunex_studyfolder/sessions/"), session=as.character(s), afterdir="/images/functional/", file_end = "_Atlas_s_hpss_res-mVWMWB1d_lpss.dtseries.nii", motion_stats=percent_udvarsme_all)))

# need to do motion scrubbing based on udvarsme
sessions_dir <- file.path(hoffman,"22q/qunex_studyfolder/sessions")
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

# get movement scrubbing info
all_list <- c(hcs_list,del_list)
mov_scrub_all <- lapply(all_list,function(s) get_mov_scrub(sesh=s, sessions_dir=sessions_dir, bold_name_use="resting"))
names(mov_scrub_all) <- all_list

# function to scrub bad frames from bold data
do_bold_scrub <- function(mov,xii,metric){
  scrub_dat <- mov[,metric]
  keep_frames <- which(scrub_dat == 0)
  xii_scrub <- select_xifti(xii, keep_frames)
  return(xii_scrub)
}

# wrapper to scrub list of bolds
bold_scrub_list <- function(mov_list, id_list, xii_list, metric){
  if(length(id_list) != length(xii_list)){
    print("Error! id and xii lists must match in length and order")
    quit()
  }
  output <- lapply(1:length(xii_list), function(i) do_bold_scrub(metric=metric, xii=xii_list[[i]], mov=mov_list[[id_list[i]]]))
}

# scrub based on udvarsme
xii_hcs_rest_scrub <- bold_scrub_list(mov_list=mov_scrub_all, id_list=hcs_list, xii_list=xii_hcs_rest, metric="udvarsme")
#xii_hcs_rest <- NULL
xii_del_rest_scrub <- bold_scrub_list(mov_list=mov_scrub_all, id_list=del_list, xii_list=xii_del_rest, metric="udvarsme")
#xii_del_rest <- NULL

### start of within-network GBC code
# function to convert xii to matrix
xii_to_mat <- function(xii){
  mat <- as.matrix(xii)
  return(mat)
}

hcs_bold_mat <- lapply(xii_hcs_rest_scrub, xii_to_mat)
#save(hcs_bold_mat, file="/Users/charlie/Dropbox/PhD/bearden_lab/22q/analyses/within_network_GBC/hcs_bold_mat.RData")
#hcs_bold_mat <- NULL
del_bold_mat <- lapply(xii_del_rest_scrub, xii_to_mat)
#save(del_bold_mat, file="/Users/charlie/Dropbox/PhD/bearden_lab/22q/analyses/within_network_GBC/del_bold_mat.RData")
#del_bold_mat <- NULL
ji_net_mat <- xii_to_mat(xii_Ji_network)
#save(ji_net_mat, file="/Users/charlie/Dropbox/PhD/bearden_lab/22q/analyses/within_network_GBC/ji_net_mat.RData")
#ji_net_mat <- NULL

# function to compute Fz correlation between each voxel in an ROI and the average timecourse in that ROI
# takes bold and mask matrices (e.g. output of xii_to_mat)
within_roi_gbc <- function(bold_mat,mask_mat,mask_vals){
  print(mask_vals)
  # mask must be one column
  if(ncol(mask_mat) != 1){
    print("Error! Mask matrix must have single column")
    quit()
  }
  # mask and bold must have same number rows
  if(nrow(mask_mat) != nrow(bold_mat)){
    print("Error! Mask and BOLD must have same number of rows")
    quit()
  }
  # get xifti rows in mask
  mask_inds <- which(mask_mat %in% mask_vals)
  # get ROI average time series 
  bold_mask <- as.matrix(bold_mat[mask_inds,])
  mask_avg <- as.vector(apply(bold_mask,2,mean))
  # get correlation between avg time series and each individual grayordinate series
  cor_list <- mclapply(mask_inds, function(r) as.numeric(FisherZ(cor(x=as.vector(bold_mat[r,]), y=mask_avg, method="pearson", use="na.or.complete")))) %>% do.call(rbind,.) %>% as.matrix
  # return the Fz connectivity matrix for the ROI
  return(cor_list)
  #avg <- mean(cor_list)
  #return(avg)
}

# wrapper for within_roi_gbc to loop through multiple ROIs. mask_val_list should be a list object, can have multiple values for a single roi (single list index)
within_multiple_roi_gbc <- function(bold_mat,mask_mat,mask_vals_list){
  output <- lapply(mask_vals_list, function(v) mask_vals=as.vector(v),bold_mat=bold_mat, mask_mat=mask_mat)
  return(output)
}

# load matrices on hoffman
#load("/u/project/cbearden/data/22q/qunex_studyfolder/analysis/fcMRI/network_GBC/ji_net_mat.RData")
#load("/u/project/cbearden/data/22q/qunex_studyfolder/analysis/fcMRI/network_GBC/hcs_bold_mat.RData")
#load("/u/project/cbearden/data/22q/qunex_studyfolder/analysis/fcMRI/network_GBC/del_bold_mat.RData")

# calculate within network FC for all (1:12) ji networks in del and hcs 
jiNet_vals_list <- list(1,2,3,4,5,6,7,8,9,10,11,12)
del_withinNetFC <- lapply(del_bold_mat, function(mat) within_multiple_roi_gbc(bold_mat=mat, mask_mat=ji_net_mat, mask_vals_list=jiNet_vals_list))
save(del_withinNetFC, file="/u/project/cbearden/data/22q/qunex_studyfolder/analysis/fcMRI/network_GBC/del_withinNetFC.RData")
#del_jiNet_gbc <- NULL

hcs_withinNetFC <- lapply(hcs_bold_mat, function(mat) within_multiple_roi_gbc(bold_mat=mat, mask_mat=ji_net_mat, mask_vals_list=jiNet_vals_list))
save(hcs_withinNetFC, file="/u/project/cbearden/data/22q/qunex_studyfolder/analysis/fcMRI/network_GBC/hcs_withinNetFC.RData")
#hcs_jiNet_gbc <- NULL
