#!/bin/sh

# script to organize NAPLS2 BOLD results into images directory for further processing

# study directory
sdir=/u/project/cbearden/data/NAPLS_BOLD/NAPLS2/sessions/S_sessions

for s in ${sdir}/*_S*; do 
  sesh=$(basename $s)
  echo $s
done
