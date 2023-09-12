#!/bin/bash

# Set up freesurfer. Use CCN install, version 7.3.2
export FREESURFER_HOME=/u/project/CCN/apps/freesurfer/rh7/7.3.2/
export SUBJECTS_DIR=$FREESURFER_HOME/subjects
source $FREESURFER_HOME/SetUpFreeSurfer.sh

# study directory
studydir="/u/project/cbearden/data/22q_T1w_all/sessions_recon-all"

subjects="Q_0001 Q_0003 Q_0005 Q_0007 Q_0009 Q_0011 Q_0014 Q_0016 Q_0017 Q_0019 Q_0020 Q_0021 Q_0022 Q_0024 Q_0026 Q_0028 Q_0030 Q_0033 Q_0036 Q_0037 Q_0038 Q_0039 Q_0041 Q_0043 Q_0045 Q_0051 Q_0052 Q_0053 Q_0054 Q_0056 Q_0059 Q_0060 Q_0062 Q_0064 Q_0067 Q_0069 Q_0076 Q_0077 Q_0078 Q_0080 Q_0081 Q_0082 Q_0085 Q_0091 Q_0092 Q_0093 Q_0098 Q_0099 Q_0100 Q_0101 Q_0102 Q_0103 Q_0105 Q_0109 Q_0112 Q_0114 Q_0117 Q_0118 Q_0124 Q_0127 Q_0130 Q_0132 Q_0135 Q_0136 Q_0137 Q_0138 Q_0141 Q_0146 Q_0147 Q_0149 Q_0150 Q_0151 Q_0153 Q_0156 Q_0157 Q_0159 Q_0161 Q_0162 Q_0163 Q_0166 Q_0168 Q_0169 Q_0170 Q_0171 Q_0172 Q_0173 Q_0174 Q_0176 Q_0177 Q_0178 Q_0182 Q_0184 Q_0185 Q_0186 Q_0188 Q_0189 Q_0190 Q_0192 Q_0196 Q_0200 Q_0206 Q_0208 Q_0213 Q_0214 Q_0215 Q_0216 Q_0217 Q_0219 Q_0222 Q_0223 Q_0227 Q_0228 Q_0229 Q_0232 Q_0234 Q_0235 Q_0236 Q_0238 Q_0240 Q_0242 Q_0244 Q_0246 Q_0252 Q_0255 Q_0257 Q_0260 Q_0263 Q_0266 Q_0268 Q_0269 Q_0271 Q_0277 Q_0278 Q_0279 Q_0284 Q_0285 Q_0286 Q_0287 Q_0288 Q_0289 Q_0291 Q_0297 Q_0300 Q_0304 Q_0307 Q_0310 Q_0311 Q_0313 Q_0315 Q_0319 Q_0321 Q_0322 Q_0324 Q_0326 Q_0327 Q_0328 Q_0331 Q_0333 Q_0334 Q_0336 Q_0337 Q_0338 Q_0339 Q_0345 Q_0346 Q_0348 Q_0350 Q_0353 Q_0355 Q_0356 Q_0361 Q_0369 Q_0371 Q_0374 Q_0377 Q_0381 Q_0382 Q_0383 Q_0384 Q_0387 Q_0390 Q_0391 Q_0395 Q_0397 Q_0401 Q_0402 Q_0404 Q_0407 Q_0408 Q_0411 Q_0414 Q_0415 Q_0416 Q_0422 Q_0425 Q_0426 Q_0429 Q_0432 Q_0433 Q_0443 Q_0446 Q_0459 Q_0461 Q_0484 Q_0508 Q_0519 Q_0520 Q_0521 Q_0525 Q_0526 Q_0527 Q_0528 Q_0529 Q_0561 Q_0568"

# loop through list of sessions and run thalamic and hipp/amygdala segmentation
for base in $subjects; do 
	echo "...submitting subject: ${base}"
	# write temp file with command to submit to scheduler
	tmpfile1="${studydir}/commands/${base}_segment_thal.sh"
	tmpfile2="${studydir}/commands/${base}_segment_hip_amy.sh"
	echo '#!/bin/bash' > $tmpfile1
	echo 'export FREESURFER_HOME=/u/project/CCN/apps/freesurfer/rh7/7.3.2/' >> $tmpfile1
	echo 'export SUBJECTS_DIR=$FREESURFER_HOME/subjects' >> $tmpfile1
	echo 'source $FREESURFER_HOME/SetUpFreeSurfer.sh' >> $tmpfile1
	cp $tmpfile1 $tmpfile2
	echo "segment_subregions thalamus --long-base ${base} --sd ${studydir}" >> $tmpfile1
	echo "segment_subregions hippo-amygdala --long-base ${base} --sd ${studydir}" >> $tmpfile2
	qsub -cwd -V -o ${studydir}/logs/22q_freesurfer_thal.${base}.$(date +%s).o -e ${studydir}/logs/22q_freesurfer_thal.${base}.$(date +%s).e -l h_data=32G,h_rt=24:00:00,arch=intel* $tmpfile1
	qsub -cwd -V -o ${studydir}/logs/22q_freesurfer_hip.${base}.$(date +%s).o -e ${studydir}/logs/22q_freesurfer_hip.${base}.$(date +%s).e -l h_data=32G,h_rt=24:00:00,arch=intel* $tmpfile2
done


