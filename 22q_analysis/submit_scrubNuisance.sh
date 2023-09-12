#!/bin/bash

source /u/local/Modules/default/init/modules.sh
module load R/4.0.2
Rscript /u/project/cbearden/data/22q/qunex_studyfolder/analysis/scripts/22q_multisite_scrubNuisanceFile.R
