#!/bin/sh

# script to rsync contents of this github repo to their respective directories on hoffman
# edit scripts in this repo, then run this script to sync with other hoffman locations

# NAPLS2
rsync -aWH /u/project/cbearden/data/scripts/charlie/22q_hoffman/NAPLS_preprocessing/ /u/project/cbearden/data/NAPLS_BOLD/NAPLS2/processing/scripts/

# 22q T1w ADNI
rsync -aWH /u/project/cbearden/data/scripts/charlie/22q_hoffman/22q_T1w_ADNI/ /u/project/cbearden/data/22q_T1w_all/scripts/

# ENIGMA IoP
rsync -aWH /u/project/cbearden/data/scripts/charlie/22q_hoffman/22qENIGMA_preprocessing/IoP/ /u/project/cbearden/data/Enigma/IoP/qunex_studyfolder/processing/scripts/

# ENIGMA Rome
rsync -aWH /u/project/cbearden/data/scripts/charlie/22q_hoffman/22qENIGMA_preprocessing/Rome/ /u/project/cbearden/data/Enigma/Rome/qunex_studyfolder/processing/scripts/

# ENIGMA SUNY
rsync -aWH /u/project/cbearden/data/scripts/charlie/22q_hoffman/22qENIGMA_preprocessing/SUNY/ /u/project/cbearden/data/Enigma/SUNY/qunex_studyfolder/processing/scripts/

# 22q Trio preproc
rsync -aWH /u/project/cbearden/data/scripts/charlie/22q_hoffman/22q_preprocessing/ /u/project/cbearden/data/22q/qunex_studyfolder/processing/scripts/

# 22q Prisma preproc
rsync -aWH /u/project/cbearden/data/scripts/charlie/22q_hoffman/22qPrisma_preprocessing/ /u/project/cbearden/data/22qPrisma/qunex_studyfolder/processing/scripts/

# 22q analysis
rsync -aWH /u/project/cbearden/data/scripts/charlie/22q_hoffman/22q_analysis/ /u/project/cbearden/data/22q/qunex_studyfolder/analysis/scripts/


###
echo "Done syncing scripts from 22q_hoffman repo"
