#!/bin/bash

source /u/local/Modules/default/init/modules.sh
module load R
Rscript /u/project/cbearden/data/22q/qunex_studyfolder/analysis/scripts/22qTrio_within_network_fullmat_fc_save_individual.R
