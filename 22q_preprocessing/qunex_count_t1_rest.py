#!/usr/bin/env python3

# script to read a list of qunex-generated session_hcp.txt files and produce a csv with counts for T1w and BOLD resting
# each argument after the script should be a session id (e.g. script.py sesh1 sesh2 ... seshn)

import sys
import csv
import string
import pandas as pd
from os.path import exists

fname='session_hcp.txt'
seshdir='/u/project/cbearden/data/22q/qunex_studyfolder/sessions/'
outdir='/u/project/cbearden/data/22q/qunex_studyfolder/sessions/specs/'


# get sessions from args
sessions=sys.argv
if len(sessions) < 2:
	print("Please list at least one session as arguments (e.g. script.py sesh1 sesh2). Quitting...")
	quit()

print(sessions)
dfo = pd.DataFrame()

# loop through each row in input df
for sesh in sessions:	
	
	# read qunex dicom report for session, get rest and t1 counts
	fpath=seshdir+'/'+sesh+'/'+fname
	if exists(fpath):
		print(sesh+'/session_hcp.txt exists')
		with open(fpath, 'r') as f:
			reader = f.read()
		nrest=reader.count('RESTING')
		nt1=reader.count('ADNI_MPRAGE')
		dfo = dfo.append({'session' : sesh, 'n_resting' : nrest, 'n_t1' : nt1}, ignore_index = True)
	else:
		print(sesh+'/session_hcp.txt MISSING')
		dfo = dfo.append({'session' : sesh, 'n_resting' : 'missing', 'n_t1' : 'missing'}, ignore_index = True)
		
# order output columns
dfo = dfo[['session','n_t1','n_resting']]
dfo = dfo.sort_values(by=['n_t1','n_resting'])

# save csv
ofile=outdir+'qunex_t1_rest_counts.csv'
dfo.to_csv(ofile,index=False)



