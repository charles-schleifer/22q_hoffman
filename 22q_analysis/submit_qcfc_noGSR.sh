#!/bin/bash
source /u/local/Modules/default/init/modules.sh
module load R
Rscript /u/project/cbearden/data/22q/qunex_studyfolder/analysis/scripts/qcfc_hoffman_noGSR.R
