#!/usr/bin/env python3

# script to read a list of qunex-generated session_hcp.txt files and produce a csv matching boldn to bold names for listed sessions
# each argument after the script should be a session id (e.g. script.py sesh1 sesh2 ... seshn)


#sessions=['Q_0001_09242012']
fname='session_hcp.txt'
seshdir='/u/project/cbearden/data/22q/qunex_studyfolder/sessions/'
outdir='/u/project/cbearden/data/22q/qunex_studyfolder/processing/scripts/'

import sys
import csv
import string
import pandas as pd

# get sessions from args
sessions=sys.argv
if len(sessions) < 2:
	print("Please list at least one session as arguments (e.g. script.py sesh1 sesh2). Quitting...")
	quit()

print(sessions)

# for each session, read session as ':' delimited file create data frame with bold runs
df = pd.DataFrame()
for sesh in sessions:
	if sesh != sessions[0]:
		fpath=seshdir+'/'+sesh+'/'+fname
		print(fpath)
		with open(fpath, 'r') as f:
		    reader = csv.reader(f, delimiter=':')
		    for row in reader:
		    	if len(row) > 0:
		    		if row[0] == 'id':
		    			id=row[1].strip()
		    		elif row[0][0].isdigit() and 'bold' in row[1]:
		    			boldn=row[1].strip()
		    			boldname=row[2].strip()
		    			df = df.append({'id' : id, 'bold_name' : boldname, 'boldn' : boldn}, ignore_index = True)
	
# reorder columns
df = df[['id','bold_name','boldn']]

# save csv	    		
ofile=outdir+'/'+'22qTrio_boldn_names.csv'
df.to_csv(ofile,index=False)

# subset only resting and save
dfr = df[df['bold_name']=='resting']
ofile2=outdir+'/'+'22qTrio_boldn_resting.csv'
dfr.to_csv(ofile2,index=False)
