#!/bin/sh

source /u/local/Modules/default/init/modules.sh
module load R 

# run R script with all arguments received by this script
Rscript /u/project/cbearden/data/22q/qunex_studyfolder/analysis/scripts/22q_multisite_bparcel_fc_arg_input.R "$@"