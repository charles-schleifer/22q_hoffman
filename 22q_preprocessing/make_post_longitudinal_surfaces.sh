source /opt/qunex/env/qunex_environment.sh
SUBJECTS_DIR=/u/project/cbearden/data/22q/qunex_studyfolder/post_long_sessions/${sesh}/hcp/${sesh}/T1w/
sessions=(Q_0001_09242012 Q_0001_10152010)
sge_i=$1
n=$((${sge_i} - 1))
sesh=${sesh_array[$n]}
tkregister2 --mov /u/project/cbearden/data/22q/qunex_studyfolder/post_long_sessions/${sesh}/hcp/${sesh}/T1w/${sesh}/mri/rawavg.mgz --targ /u/project/cbearden/data/22q/qunex_studyfolder/post_long_sessions/${sesh}/hcp/${sesh}/T1w/${sesh}/mri/orig.mgz --noedit --regheader --reg /u/project/cbearden/data/22q/qunex_studyfolder/post_long_sessions/${sesh}/hcp/${sesh}/T1w/${sesh}/mri/transforms/orig2rawavg.dat
mri_surf2surf --s ${sesh} --sval-xyz white --reg /u/project/cbearden/data/22q/qunex_studyfolder/post_long_sessions/${sesh}/hcp/${sesh}/T1w/${sesh}/mri/transforms/orig2rawavg.dat --tval-xyz /u/project/cbearden/data/22q/qunex_studyfolder/post_long_sessions/${sesh}/hcp/${sesh}/T1w/${sesh}/mri/rawavg.mgz --tval white.deformed --surfreg white --hemi lh
mri_surf2surf --s ${sesh} --sval-xyz white --reg /u/project/cbearden/data/22q/qunex_studyfolder/post_long_sessions/${sesh}/hcp/${sesh}/T1w/${sesh}/mri/transforms/orig2rawavg.dat --tval-xyz /u/project/cbearden/data/22q/qunex_studyfolder/post_long_sessions/${sesh}/hcp/${sesh}/T1w/${sesh}/mri/rawavg.mgz --tval white.deformed --surfreg white --hemi rh
