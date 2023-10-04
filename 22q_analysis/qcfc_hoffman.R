

# clear workspace
rm(list = ls(all.names = TRUE))


# set local path to mount server
hoffman <- "/u/project/cbearden/data"
# create directory if needed 

# install longCombat for first time
#install.packages("devtools")
#devtools::install_github("jcbeer/longCombat")

# list packages to load
# ciftiTools dependency rgl may need XQuartz installed in order to visualize surfaces
#packages <- c("conflicted", "here", "magrittr", "mgcv", "gratia", "lme4", "lmerTest", "invgamma", "longCombat", "ciftiTools", "readxl", "dplyr", "data.table", "DescTools","tableone", "tibble", "reshape2", "viridis", "scico", "ggplot2", "gridExtra", "ggpubr","stringr")
#packages <- c("conflicted", "here", "magrittr", "readxl", "dplyr", "data.table", "DescTools","tableone", "tibble", "reshape2", "viridis", "scico", "ggplot2", "gridExtra", "ggpubr","stringr", "parallel")
packages <- c("conflicted", "magrittr", "dplyr","readxl", "data.table", "stringr", "tictoc")

# install packages if not yet installed
all_packages <- rownames(installed.packages())
installed_packages <- packages %in% all_packages
if (any(installed_packages == FALSE)){install.packages(packages[!installed_packages])}

# load packages
invisible(lapply(packages, library, character.only = TRUE))

# use the filter function from dplyr, not stats
conflict_prefer("filter", "dplyr")


## Load individual connectivity CSVs
# paths to sessions directories
#trio_dir <- file.path(hoffman,"22q/qunex_studyfolder/sessions")
#prisma_dir <- file.path(hoffman,"22qPrisma/qunex_studyfolder/sessions")
file_dir <- file.path(hoffman,"/22q/qunex_studyfolder/analysis/fcMRI/sessions")

# get list of sessions
all_sessions <- list.files(file_dir, pattern="Q_[0-9]")

#trio_sessions <- list.files(trio_dir,pattern="Q_[0-9]")
#prisma_sessions <- list.files(prisma_dir,pattern="Q_[0-9]")
# exclude Q_0390_09302019 for now due to no AP BOLD; test excluding "Q_0321_03272017","Q_0334_12012016" to ensure restingAP* vs resting* prisma are the same
#exclude_sessions <- c("Q_0390_09302019","Q_0321_03272017","Q_0334_12012016")
#exclude_sessions <- c("Q_0390_09302019","Q_0477_01052022","Q_0484_01042022","Q_0508_06232022","Q_0519_05312022","Q_0520_06012022","Q_0521_05202022","Q_0525_06072022","Q_0526_06242022","Q_0527_07112022","Q_0528_07202022","Q_0529_07202022","Q_0541_07182022","Q_0549_10182022","Q_0561_11032022","Q_0568_10252022")

# exclude only Q_0390_09302019 (missing AP BOLD)
exclude_sessions <- "Q_0390_09302019"
#prisma_sessions <- prisma_sessions[! prisma_sessions %in% exclude_sessions]
#all_sessions <- c(trio_sessions,prisma_sessions)
all_sessions <- all_sessions[! all_sessions %in% exclude_sessions]

# function to read parcellated connectivity results and add columns for roi pair name, site, and ID 
read_bparc_results <- function(sdir, fname, sesh){
  print(sesh)
  output <- as.data.frame(read.csv(file.path(sdir,sesh,"images/functional",fname)))
  output$MRI_S_ID <- sesh
  return(output)
}


# read for trio and prisma then combine
all_bparc_gsr <- lapply(all_sessions, function(s) read_bparc_results(sesh=s,sdir=file_dir,fname=dir(file.path(file_dir,s,"images/functional/") ,pattern="resting.*_fc_matrix_Atlas_s_hpss_res-mVWMWB1d_lpss_CABNP_between_parcel.csv"))) %>% do.call(rbind,.) %>% as.data.frame

all_bparc_nogsr <- lapply(all_sessions, function(s) read_bparc_results(sesh=s,sdir=file_dir,fname=dir(file.path(file_dir,s,"images/functional/") ,pattern="resting.*_fc_matrix_Atlas_s_hpss_res-mVWM1d_lpss_CABNP_between_parcel.csv"))) %>% do.call(rbind,.) %>% as.data.frame

# add column with roi1 and roi2 numbers
all_bparc_gsr$rois <- paste0(all_bparc_gsr$roi_1,"_",all_bparc_gsr$roi_2)
all_bparc_nogsr$rois <- paste0(all_bparc_nogsr$roi_1,"_",all_bparc_nogsr$roi_2)

# read motion data
movement <- read.csv("/u/project/cbearden/data/22q/qunex_studyfolder/analysis/fcMRI/22q_multisite_fd_mean.csv", header=TRUE)

# cast to wide for combat
#setDT(all_tc)
#all_tc_wide <- reshape2::dcast(all_tc, MRI_S_ID + site ~ NETWORK, value.var="TC_Fz") 


## load sistat data and get lists of scans to use

# set location of directory with ucla sistat CSVs
csvdir_ucla <- "/u/project/cbearden/data/22q/qunex_studyfolder/analysis/behavior/demographics/ucla_sistat"

# get list of files_ucla in directory
files_ucla <- list.files(csvdir_ucla)
fpaths <- lapply(files_ucla, function(file) paste(csvdir_ucla,file,sep="/"))

# clean names
fnames <- gsub(".csv","",files_ucla)
fnames <- gsub("Re22Q_","",fnames)
fnames <- gsub("Form_","",fnames)
fnames <- gsub("Qry_","",fnames)

# read all, set to na: "-9999", "-9998","." 
input_all_ucla <- lapply(fpaths, read.csv, header=T, na.strings=c(".","-9999","-9998"), strip.white=T, sep=",")
names(input_all_ucla) <- fnames
df_all_ucla <- lapply(input_all_ucla, function(x) data.frame(x))

# subset demo_mri for used scans
ucla_demo <- df_all_ucla$demo_mri %>% filter(MRI_S_ID %in% all_sessions)

# remove "FAMILY MEMBER" designation from subject identity
ucla_demo$SUBJECT_IDENTITY <- ucla_demo$SUBJECT_IDENTITY %>% sub("FAMILY MEMBER","",.) %>% sub(",","",.) %>% trimws(which="both") %>% as.factor
# change sex coding from 0/1 to F/M and set to factor
ucla_demo$SEX <- factor(ucla_demo$SEX,levels=c(0,1),labels=c("F","M"))

# TEMPORARY
# TODO: this chunk is temporary until sistat is updated 
# TODO: note: q_0526 sex was "na" in original sheet, changed to M because combat can't have NAs
# read new data
temp_demo <- read_xlsx("/u/project/cbearden/data/22q/qunex_studyfolder/analysis/behavior/demographics/temporary/sMRI_demo_info_forCharlie.xlsx", col_names=TRUE,na="",trim_ws = TRUE)

# make empty demographics data frame to add new data to
demo_add <- ucla_demo[1:nrow(temp_demo),]
demo_add[,] <- NA
demo_add$SUBJECTID <- temp_demo$`Subject ID`
demo_add$SUBJECT_IDENTITY <- temp_demo$Diagnosis
demo_add$MRI_S_ID <- temp_demo$`MRI ID`
demo_add$SEX <- as.factor(temp_demo$Sex)
demo_add$AGE <- temp_demo$Age
demo_add$AGEMONTH <- temp_demo$Age*12
demo_add$CONVERTEDVISITNUM <- 2

# append to ucla demo
ucla_demo <- rbind(ucla_demo,demo_add)


# manually fix missing sex for Q_0381_09102019
# TODO: fix in sistat and re-export
ucla_demo[which(ucla_demo$MRI_S_ID == "Q_0381_09102019"),"SEX"] <- "F"

# set race=NA to 7 (unknown)
ucla_demo$RACE[is.na(ucla_demo$RACE)] <- 7
# set race as factor 1=American Indian/Alaska Native; 2=Asian; 3=Native Hawaiian/Pacific Islander; 4=Black or African American; 5=White; 6=Multiple; 7=Unknown
ucla_demo$RACE <- factor(ucla_demo$RACE,levels=c(1:7),labels=c("1_Native_American","2_Asian","3_Pacific_Island","4_Black","5_White","6_Multiple","7_Unknown"))
# ethnicity as factor with 0=N 1=Y
ucla_demo$HISPANIC[is.na(ucla_demo$HISPANIC)] <- "Unknown"
ucla_demo$HISPANIC <- factor(ucla_demo$HISPANIC,levels=c(0,1,"Unknown"),labels=c("N","Y","Unknown"))
# get more accurate age with AGEMONTH/12
ucla_demo$AGE <- as.numeric(ucla_demo$AGEMONTH)/12 

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
  return(c(sub,visit,label,n_visits,nt_visits,np_visits,visit_index))
}

# get timepoints
timepoints <- sapply(1:nrow(ucla_demo),function(r) gettp(r,ucla_demo)) %>% t %>% as.data.frame
colnames(timepoints) <- c("SUBJECTID","CONVERTEDVISITNUM","converted_timepoint","n_timepoints","n_trio","n_prisma","visit_index")
ucla_demo_tp <- cbind(ucla_demo,timepoints[,3:7])
ucla_demo_tp$visit_index %<>% as.factor

# subset to under max age limit (22 years old)
ucla_demo_tp_agelim <- filter(ucla_demo_tp, ucla_demo_tp$AGE < 22)

# subset to hcs del
ucla_demo_hcs_del <- ucla_demo_tp_agelim %>% filter(SUBJECT_IDENTITY=="CONTROL" | SUBJECT_IDENTITY =="PATIENT-DEL")

# remove unused factor levels
ucla_demo_hcs_del %<>% droplevels

#demo_summary <- CreateTableOne(data=ucla_demo_hcs_del,vars=c("AGE","SEX"),strata="SUBJECT_IDENTITY",addOverall=F)
#print(demo_summary, showAllLevels=T)

#demo_summary_bl <- CreateTableOne(data=filter(ucla_demo_hcs_del, ucla_demo_hcs_del$visit_index == 1),vars=c("AGE","SEX"),strata="SUBJECT_IDENTITY",addOverall=F)
#print(demo_summary_bl)


# get baseline sample
ucla_demo_hcs_del_bl <- filter(ucla_demo_hcs_del, ucla_demo_hcs_del$visit_index == 1)

# filter connectivity data for baseline sample
all_bparc_gsr_bl <- filter(all_bparc_gsr, MRI_S_ID %in% ucla_demo_hcs_del_bl$MRI_S_ID)
all_bparc_nogsr_bl <- filter(all_bparc_nogsr, MRI_S_ID %in% ucla_demo_hcs_del_bl$MRI_S_ID)

# unique roi pairs
roipairs <- as.vector(unique(all_bparc_gsr$rois))

# set stuff we don't need to null
all_bparc_gsr <- NULL
all_bparc_nogsr <- NULL

# for each roi pair, compute correlation with fd_mean across subjects
qcfc_roi <- function(df, roi, movement){
  print(roi)
  merged <- merge(x=df[which(df$rois==roi),], y=movement, by="MRI_S_ID")
  out <- cor(x=merged$pearson_r_Fz, y=merged$fd_mean)
  return(out)
}


print("calculating QC-FC GSR")
qcfc_gsr_bl <- lapply(roipairs, function(r)qcfc_roi(df=all_bparc_gsr_bl, roi=r, movement=movement)) %>% do.call(rbind,.) %>% as.data.frame
colnames(qcfc_gsr_bl) <- "qcfc_gsr"
write.csv(qcfc_gsr_bl, file="/u/project/cbearden/data/22q/qunex_studyfolder/analysis/fcMRI/qcfc_22q_baseline_GSR.csv", row.names = FALSE, quote=FALSE, sep=",")

print("calculating QC-FC no GSR")
qcfc_nogsr_bl <- lapply(roipairs, function(r)qcfc_roi(df=all_bparc_nogsr_bl, roi=r, movement=movement)) %>% do.call(rbind,.) %>% as.data.frame
colnames(qcfc_nogsr_bl) <- "qcfc_nogsr"
write.csv(qcfc_nogsr_bl, file="/u/project/cbearden/data/22q/qunex_studyfolder/analysis/fcMRI/qcfc_22q_baseline_noGSR.csv", row.names = FALSE, quote=FALSE, sep=",")

qcfc <- cbind(qcfc_gsr_bl, qcfc_nogsr_bl)
qcfc$roi_pair <- roipairs
write.csv(qcfc, file="/u/project/cbearden/data/22q/qunex_studyfolder/analysis/fcMRI/qcfc_22q_baseline_all.csv", row.names = FALSE, quote=FALSE, sep=",")


#qsub -cwd -V -o /u/project/cbearden/data/22q/qunex_studyfolder/processing/logs/manual/qcfc.$(date +%s).o -e /u/project/cbearden/data/22q/qunex_studyfolder/processing/logs/manual/qcfc.$(date +%s).e  -l h_data=16G,h_rt=48:00:00,highp /u/project/cbearden/data/22q/qunex_studyfolder/analysis/scripts/submit_qcfc.sh 




