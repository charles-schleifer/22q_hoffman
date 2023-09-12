#!/usr/bin/env python3

# script to get lists of sessions in qunex_studyfolder and in raw directory and check for missing data
# updated version of 22q trio check_qunex_against_raw.py that gets the total list of unique ids in raw dir and qunex_studyfolder session_hcp.txt
# then checks for missing sessions/runs and outputs a csv with details
# need to systematically find what subjects/runs aren't in the qunex_studyfolder so they can be added

import sys
import csv
import glob
import string
import pandas as pd
import os.path
from os.path import exists

# paths to qunex sesh dir and raw dir
sdir='/u/project/cbearden/data/22qPrisma/qunex_studyfolder/sessions/'
rdir='/u/project/cbearden/data/raw/22qPrisma/'

# get paths for sessions in both dirs
spaths=glob.glob(sdir+'/Q_*')
rpaths=glob.glob(rdir+'/Q_*')

# get session ids
sids=list(map(os.path.basename, spaths))
rids=list(map(os.path.basename, rpaths))

# sorted list of total unique ids
tids=sorted(list(set(sids+rids)))

# create empty df to add to 
dfo = pd.DataFrame()

# loop through each row in input df
for sesh in tids:
	
	# count run directories in raw if the session exists
	seshrawpath=rdir+'/'+sesh
	if exists(seshrawpath):
		print(seshrawpath+' exists')
		exist_raw='Y'
		# get runs in raw
		runpaths=glob.glob(rdir+'/'+sesh+'/*/*/*/*/')
		# normpath removes trailing slash so basename will work
		normpaths=list(map(os.path.normpath, runpaths))
		runs=list(map(os.path.basename, normpaths))
		rstring=' '.join(runs)
		# get raw run counts
		n_t1_raw=rstring.count('T1w')
		n_t2_raw=rstring.count('T2w')
		n_restAP_raw=rstring.count('rfMRI_REST_AP') - rstring.count('rfMRI_REST_AP_SBRef')
		n_restPA_raw= rstring.count('rfMRI_REST_PA') - rstring.count('rfMRI_REST_PA_SBRef')
		n_sefmAP_raw=rstring.count('SpinEchoFieldMap_AP')
		n_sefmPA_raw=rstring.count('SpinEchoFieldMap_PA')
	else:
		print(seshrawpath+' MISSING')
		exist_raw='N'
		n_t1_raw='NA'
		n_t2_raw='NA'
		n_restAP_raw='NA'
		n_restPA_raw='NA'
		n_sefmAP_raw='NA'
		n_sefmPA_raw='NA'

	# read qunex nifti report for session, get run counts
	sfile=sdir+'/'+sesh+'/'+'session.txt'
	if exists(sfile):
		print(sfile+' exists')
		exist_qx='Y'
		with open(sfile, 'r') as f:
			reader = f.read()
		n_t1_qx=reader.count('T1w')
		n_t2_qx=reader.count('T2w')
		n_restAP_qx= reader.count('rfMRI_REST_AP')-rstring.count('rfMRI_REST_AP_SBRef')
		n_restPA_qx=reader.count('rfMRI_REST_PA')-rstring.count('rfMRI_REST_PA_SBRef')
		n_sefmAP_qx=reader.count('SpinEchoFieldMap_AP')
		n_sefmPA_qx=reader.count('SpinEchoFieldMap_PA')
		
		# differences between raw and qunex counts
		n_t1_dif=n_t1_qx-n_t1_raw
		n_t2_dif=n_t2_qx-n_t2_raw
		n_restAP_dif=n_restAP_qx-n_restAP_raw
		n_restPA_dif=n_restPA_qx-n_restPA_raw
		n_sefmAP_dif=n_sefmAP_qx-n_sefmAP_raw
		n_sefmPA_dif=n_sefmPA_qx-n_sefmPA_raw	
	else:
		print(sfile+' MISSING')
		exist_qx='N'
		n_t1_qx='NA'
		n_t2_qx='NA'
		n_restAP_qx='NA'
		n_restPA_qx='NA'
		n_sefmAP_qx='NA'
		n_sefmPA_qx='NA'
		n_t1_dif='NA'
		n_t2_dif='NA'
		n_restAP_dif='NA'
		n_restPA_dif='NA'
		n_sefmAP_dif='NA'
		n_sefmPA_dif='NA'
	
	# add counts to data frame	
	dfo = dfo.append({'session':sesh, 'exist_raw':exist_raw,'exist_qx':exist_qx,'n_t1_raw':n_t1_raw,'n_t1_qx':n_t1_qx,'n_t2_raw':n_t2_raw,'n_t2_qx':n_t2_qx,'n_restAP_raw':n_restAP_raw,'n_restAP_qx':n_restAP_qx,'n_restPA_raw':n_restPA_raw,'n_restPA_qx':n_restPA_qx,'n_sefmAP_raw':n_sefmAP_raw,'n_sefmAP_qx':n_sefmAP_qx,'n_sefmPA_raw':n_sefmPA_raw,'n_sefmPA_qx':n_sefmPA_qx,'n_t1_dif':n_t1_dif,'n_t2_dif':n_t2_dif,'n_restAP_dif':n_restAP_dif,'n_restPA_dif':n_restPA_dif,'n_sefmAP_dif':n_sefmAP_dif,'n_sefmPA_dif':n_sefmPA_dif}, ignore_index = True)
		
	         
# order output columns
dfo = dfo[['session','exist_raw','exist_qx','n_t1_raw','n_t1_qx','n_t2_raw','n_t2_qx','n_restAP_raw','n_restAP_qx','n_restPA_raw','n_restPA_qx','n_sefmAP_raw','n_sefmAP_qx','n_sefmPA_raw','n_sefmPA_qx','n_t1_dif','n_t2_dif','n_restAP_dif','n_restPA_dif','n_sefmAP_dif','n_sefmPA_dif']]

# save csv
ofile=sdir+'/'+'specs/'+'prisma_raw_qunex_runs_compare_100321.csv'
dfo.to_csv(ofile,index=False)

