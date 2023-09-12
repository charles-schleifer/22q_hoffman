#!/bin/sh

# C. Schleifer 5/20/21
# script to copy 22q dicoms into qunex inbox structure $studyfolder/sessions/inbox/MR/$session/<all dicoms>

# space delimited list of subjects to copy
list="Q_0001_09242012 Q_0001_10152010 Q_0001_12022008 Q_0003_12222008 Q_0005_02092009 Q_0005_04182011 Q_0007_03162009 Q_0007_04012011 Q_0009_01262009 Q_0009_08112010 Q_0009_09292011 Q_0011_02242009 Q_0013_04012009 Q_0014_04012009 Q_0016_03292011 Q_0016_04172009 Q_0016_10082012 Q_0017_03192014 Q_0017_05012015 Q_0017_06152009 Q_0018_06232009 Q_0019_05052011 Q_0019_08112009 Q_0020_03262012 Q_0020_05052011 Q_0020_08112009 Q_0021_01132011 Q_0021_08172009 Q_0021_11052012 Q_0022_08212009 Q_0024_04152011 Q_0024_09212012 Q_0026_03232012 Q_0026_05032013 Q_0028_02022010 Q_0030_02092010 Q_0033_03192010 Q_0036_03302010 Q_0036_06212012 Q_0036_06282011 Q_0037_04202011 Q_0037_04272010 Q_0038_06042010 Q_0039_04132010 Q_0039_06012011 Q_0040_05142010 Q_0040_06272011 Q_0041_05232011 Q_0041_09262012 Q_0043_06012010 Q_0045_07132010 Q_0045_08302011 Q_0045_10052012 Q_0051_01302012 Q_0051_07232010 Q_0052_07302010 Q_0053_08022010 Q_0053_12212012 Q_0054_08062010 Q_0056_08252010 Q_0056_09102012 Q_0059_08032011 Q_0059_08272010 Q_0060_09012010 Q_0062_09082010 Q_0062_11302011 Q_0064_09162010 Q_0067_04012009 Q_0069_04282009 Q_0070_06232009 Q_0071_03022010 Q_0072_01102013 Q_0072_10052010 Q_0072_11032011 Q_0076_10212010 Q_0077_02292012 Q_0077_03112013 Q_0077_10252010 Q_0078_11102011 Q_0078_11192010 Q_0080_11222010 Q_0081_11242010 Q_0082_01062012 Q_0082_01112013 Q_0082_12162010 Q_0085_02242012 Q_0091_03052012 Q_0091_03072011 Q_0092_03102011 Q_0093_03082011 Q_0093_03122012 Q_0093_03122013 Q_0093_03312012 Q_0094_03172011 Q_0098_04012011 Q_0099_04012011 Q_0100_04082011 Q_0101_01032013 Q_0101_04122011 Q_0102_01032013 Q_0102_04122011 Q_0103_04182011 Q_0103_08272012 Q_0105_05022011 Q_0109_05262011 Q_0112_06072011 Q_0112_11142012 Q_0114_02062014 Q_0114_06292011 Q_0114_11092012 Q_0117_07062011 Q_0117_08312012 Q_0118_07072011 Q_0120_06182014 Q_0124_07292011 Q_0124_09172012 Q_0126_08012011 Q_0127_03052013 Q_0127_08012014 Q_0127_08082011 Q_0130_08132012 Q_0130_08162011 Q_0130_11042014 Q_0132_08222011 Q_0135_09012011 Q_0136_09012011 Q_0137_09022011 Q_0138_09032013 Q_0138_09042012 Q_0138_09062011 Q_0141_10072013 Q_0141_10072013_old Q_0141_10092012 Q_0146_11082012 Q_0146_12072011 Q_0147_08112015 Q_0147_08142014 Q_0147_12122011 Q_0149_11192012 Q_0149_12192011 Q_0150_11192012 Q_0150_12202011 Q_0151_01122012 Q_0153_01202012 Q_0156_01312012 Q_0156_12102013 Q_0156_12102013_old Q_0157_01312012 Q_0159_02122013 Q_0161_03012012 Q_0161_04192013 Q_0162_03202012 Q_0163_03262012 Q_0166_01092014 Q_0166_04052012 Q_0167_04052012 Q_0168_04052012 Q_0169_04062012 Q_0170_04102012 Q_0170_11252014 Q_0171_04102012 Q_0171_11252014 Q_0172_04122012 Q_0172_04172014 Q_0172_04262013 Q_0173_04122012 Q_0173_04172014 Q_0173_04262013 Q_0174_04182012 Q_0174_04272015 Q_0176_04242012 Q_0176_05072013 Q_0177_05012012 Q_0178_05012012 Q_0182_05182012 Q_0184_05242012 Q_0185_05242012 Q_0186_04092015 Q_0188_05242012 Q_0189_05242012 Q_0190_06012012 Q_0190_08132013 Q_0190_08292014 Q_0192_06112013 Q_0192_06142012_1 Q_0192_06172014 Q_0196_06192015 Q_0196_06202012 Q_0196_09122013 Q_0200_04032015 Q_0200_04032015_2 Q_0200_07092012 Q_0200_08052013 Q_0206_07172012 Q_0206_12022014 Q_0208_07232012 Q_0213_08032012 Q_0213_09262014 Q_0215_08062012 Q_0215_08172015 Q_0216_08062012 Q_0216_08172015 Q_0217_02042015 Q_0217_08092012 Q_0219_08122014 Q_0219_08162012 Q_0219_09012015 Q_0222_08212012 Q_0223_08212012 Q_0225_09042012 Q_0227_10032012 Q_0228_01292014 Q_0228_09272012 Q_0229_10022012 Q_0230_11012012 Q_0232_12122012 Q_0234_03252014 Q_0234_12132012 Q_0236_03072013 Q_0238_03202013 Q_0238_08042014 Q_0238_11132015 Q_0240_03232015_2 Q_0240_03272013 Q_0240_06262014 Q_0242_03272013 Q_0244_09162013 Q_0244_09232014 Q_0246_09242013 Q_0250_09302013 Q_0250_09302014 Q_0250_10062015 Q_0252_12102013 Q_0255_10212014 Q_0257_06042014 Q_0258_06062014 Q_0260_06092014 Q_0263_09152014 Q_0266_02292016 Q_0266_08122014 Q_0268_10132014 Q_0269_10142014 Q_0277_12082014 Q_0278_12092014 Q_0279_12092014 Q_0284_03182015 Q_0285_03182015 Q_0286_03182015 Q_0287_03182015 Q_0291_04172015 Q_0297_05052015 Q_0298_05052015 Q_0298_05052015_2 Q_0300_05052015 Q_0307_10132015 Q_0310_11182015 Q_0311_12082015 Q_0313_12102015 Q_0315_01262016 Q_0319_03232016 Q_0321_03232016 Q_0322_03312016 Q_0326_04142016 Q_0327_04142016"

indir=/u/project/cbearden/data/22q/
#outdir=/u/project/cbearden/data/22q/qunex_studyfolder/sessions/
outdir=/u/project/cbearden/data/22q/qunex_studyfolder/sessions/inbox/MR


for case in $list; do
	if [[ -d ${indir}/${case}/dicom ]]; then
		echo "processing dicoms from ${case}"
		mkdir -p ${outdir}/${case}/inbox
		for dcmdir in $(ls ${indir}/${case}/dicom); do
			# only get dicoms from folders named TRIOTIM_UCLABMTRIO or TrioTim_MEDPC
			if [[ "$dcmdir" =~ ^(TRIOTIM_UCLABMTRIO|TrioTim_MEDPC)$ ]];then
				runs=$(ls ${indir}/${case}/dicom/${dcmdir}/*/*/)
				for run in $runs; do
					files=$(ls ${indir}/${case}/dicom/${dcmdir}/*/*/${run})
					for file in $files; do
						# hacky way to check if file is a dicom based on dicom_hdr output
						if [[ ! -z $(dicom_hdr ${indir}/${case}/dicom/${dcmdir}/*/*/${run}/${file} | grep "DCM Dump Elements Complete") ]]; then
							# copy dicoms to inbox, add .dcm extension if missing
							if [[ "$file" == *.dcm ]]; then
								#cp -v ${indir}/${case}/dicom/${dcmdir}/*/*/${run}/${file} ${outdir}/${case}/inbox/${run}.${file}
								cp -v ${indir}/${case}/dicom/${dcmdir}/*/*/${run}/${file} ${outdir}/${case}/${run}.${file}
							else
								#cp -v ${indir}/${case}/dicom/${dcmdir}/*/*/${run}/${file} ${outdir}/${case}/inbox/${run}.${file}.dcm
								cp -v ${indir}/${case}/dicom/${dcmdir}/*/*/${run}/${file} ${outdir}/${case}/${run}.${file}.dcm
							fi
						else
							echo "Not a DICOM: ${indir}/${case}/dicom/${dcmdir}/<placeholder>/<placeholder>/${run}/${file}" 
						fi	
					done		
				done
			fi 
		done
	else
		echo "Skipped: ${case} missing dicom dir"
	fi
done