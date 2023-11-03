#!/bin/sh

# C. Schleifer 9/2023
# script to copy all raw dicoms from raw folder to qunex inbox as first step for preprocessing

# raw study dir
sdir="/u/project/cbearden/data/raw/22qPrisma/"

# target dir
tdir="/u/project/cbearden/data/22qPrisma/qunex_studyfolder/sessions/inbox/MR/"

# all scans in sessions dir
pscans=/u/project/cbearden/data/22qPrisma/qunex_studyfolder/sessions/Q*

# list of scans to exclude
exclude="Q_0001_02222018 Q_0250_10242017 Q_0315_02162017 Q_0356_06052019 Q_0397_11082018 Q_0426_11262019 Q_0038_08192019 Q_0277_11302017 Q_0324_05032017 Q_0356_06062017 Q_0401_01112019 Q_0508_06232022 Q_0192_11192018 Q_0287_03212017 Q_0337_04022018 Q_0361_08212017 Q_0401_01112019_2 Q_0549_10182022 Q_0192_11202017 Q_0288_03212017 Q_0338_02162017 Q_0371_07312019 Q_0401_01112019_8 Q_0192_11252019 Q_0313_05072019 Q_0338_03292018 Q_0374_05152019 Q_0404_03162020 Q_0234_05302017 Q_0313_12132016 Q_0339_03292018 Q_0377_07242018 Q_0411_05202019 Q_0250_10232018 Q_0313_12142017 Q_0355_06052019 Q_0384_08282018 Q_0422_11262019 Q_0214_05012017 Q_0278_12132016 Q_0288_06062018 Q_0395_11062018_18 Q_0395_11062018_2 Q_0419_08132019 Q_0030_05082018 Q_0138_01082018 Q_0477_01052022 Q_0541_07182022Q_0001_02222018 Q_0250_10242017 Q_0315_02162017 Q_0356_06052019 Q_0397_11082018 Q_0426_11262019 Q_0038_08192019 Q_0277_11302017 Q_0324_05032017 Q_0356_06062017 Q_0401_01112019 Q_0508_06232022 Q_0192_11192018 Q_0287_03212017 Q_0337_04022018 Q_0361_08212017 Q_0401_01112019_2 Q_0549_10182022 Q_0192_11202017 Q_0288_03212017 Q_0338_02162017 Q_0371_07312019 Q_0401_01112019_8 Q_0192_11252019 Q_0313_05072019 Q_0338_03292018 Q_0374_05152019 Q_0404_03162020 Q_0234_05302017 Q_0313_12132016 Q_0339_03292018 Q_0377_07242018 Q_0411_05202019 Q_0250_10232018 Q_0313_12142017 Q_0355_06052019 Q_0384_08282018 Q_0422_11262019 Q_0214_05012017 Q_0278_12132016 Q_0288_06062018 Q_0395_11062018_18 Q_0395_11062018_2 Q_0419_08132019 Q_0030_05082018 Q_0138_01082018 Q_0477_01052022 Q_0541_07182022 Q_0278_12052019 Q_0537_04062023"

# copy all raw dicoms, renaming to $sesh_$run_$dicom to avoid name conflicts
for spath in ${sdir}/Q_*; do
    # get session name as the last item in the session path
    sesh=$(basename $spath)
    # skip if in pscans or excluded scans
    if echo $pscans | grep -q $sesh; then
        echo $sesh already in study folder
    elif echo $exclude | grep -q $sesh; then
        echo $sesh excluded
    else
        echo copying from $spath
        mkdir -p ${tdir}/${sesh} 
        # for each MRI run (note: path is specific to Bearden Lab hoffman Prisma data, there are definitely better ways to find all the dcms but this works)
        for rpath in ${spath}/*Prisma*/*/*/*; do
            echo $rpath
            run=$(basename $rpath)
            # loop through each individual dicom, copy and rename
            for dpath in ${rpath}/*; do
                dicom=$(basename $dpath)
                cp -v ${dpath} ${tdir}/${sesh}/${sesh}_${run}_${dicom}
            done
        done
    fi
done

