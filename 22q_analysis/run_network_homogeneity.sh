#!/bin/sh

source /u/local/Modules/default/init/modules.sh
module load R 

# run R script with all arguments received by this script
Rscript /u/project/cbearden/data/22q/qunex_studyfolder/analysis/scripts/parcellated_network_homogeneity.R "$@"