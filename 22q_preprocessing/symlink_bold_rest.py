#!/usr/bin/env python3

# read 22qTrio_boldn_resting_use.csv and for each BOLD resting run, symlink boldn_* to REST_* in /images/functional/
# this allows qunex fc_compute_wrapper to use a single consistent --inputfiles when the desired run has variable boldn


import os
import sys
import csv
import glob
import string
import pandas as pd

dfu=pd.read_csv('/u/project/cbearden/data/22q/qunex_studyfolder/processing/scripts/22qTrio_boldn_resting_use.csv')

sdir='/u/project/cbearden/data/22q/qunex_studyfolder/sessions'
tdir='/images/functional/'
#bold_GSR='_Atlas_s_hpss_res-mVWM1d_lpss.dtseries.nii'
#bold_noGSR='_Atlas_s_hpss_res-mVWMWB1d_lpss.dtseries.nii'

for i in range(0,len(dfu)):
	sesh=dfu.iloc[i]['id']
	boldn=dfu.iloc[i]['boldn']
	
	print(sesh)
	print(boldn)
	
	bolds=glob.glob(sdir+'/'+sesh+'/'+tdir+'/'+boldn+'*')
	
	print('...symlinking '+sesh+' '+boldn+' to REST')
	for bold in bolds:
		target=bold.replace(boldn,'REST')
		print(target)
		os.symlink(bold,target)