#!/usr/bin/env python3

# script to read session_info_22q_raw.csv and check trio runs against what is in qunex_studyfolder
# some sessions (e.g. Q_0266_08122014) have runs in the raw directory that didn't make it into qunex
# or some sessions (e.g. Q_0328_04262016 weren't processed at all)
# need to systematically find what subjects/runs aren't in the qunex_studyfolder so they can be added
# this script runs on the output of the bash script check_raw_files.sh which generated a csv with run counts from the raw dir

import sys
import csv
import string
import pandas as pd
from os.path import exists

# file created by check_raw_files.sh 
fpath='/u/project/cbearden/data/raw/22q/session_info_22q_raw.csv'
sdir='/u/project/cbearden/data/22q/qunex_studyfolder/sessions/'

# read csv into data frame
dfa=pd.read_csv(fpath)

# subset trio scans
dft=dfa[dfa['scanner']=='Trio']

# create empty df to add to 
dfo = pd.DataFrame()

# loop through each row in input df
for i in range(0,len(dft.index)):
	
	# get info from input df
	sesh=dft.iloc[i]['session']
	nrest_raw=dft.iloc[i]['n_RESTING']
	nt1_raw=dft.iloc[i]['n_ADNI_MPRAGE']
	print(sesh)
	
	# read qunex dicom report for session, get rest and t1 counts
	sfile=sdir+'/'+sesh+'/'+'session.txt'
	if exists(sfile):
		with open(sfile, 'r') as f:
			reader = f.read()
		nrest_qx=reader.count('RESTING')
		nt1_qx=reader.count('ADNI_MPRAGE')
		rest_dif=nrest_qx-nrest_raw
		t1_dif=nt1_qx-nt1_raw
		dfo = dfo.append({'sesh' : sesh, 'n_resting_raw' : nrest_raw, 'n_resting_qunex' : nrest_qx, 'n_t1_raw' : nt1_raw, 'n_t1_qunex' : nt1_qx, 'resting_dif' : rest_dif, 't1_dif' : t1_dif}, ignore_index = True)
	else:
		dfo = dfo.append({'sesh' : sesh, 'n_resting_raw' : nrest_raw, 'n_resting_qunex' : 'missing', 'n_t1_raw' : nt1_raw, 'n_t1_qunex' : 'missing', 'resting_dif' : 'missing', 't1_dif' : 'missing'}, ignore_index = True)
		
# order output columns
dfo = dfo[['sesh','n_t1_raw','n_t1_qunex','n_resting_raw','n_resting_qunex','t1_dif','resting_dif']]

# save csv
ofile=sdir+'/'+'specs/'+'raw_qunex_runs_compare_093021.csv'
dfo.to_csv(ofile,index=False)

