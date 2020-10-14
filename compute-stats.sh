#!/bin/bash

# make output directory
resliced="./resliced/"
tmpdir="./tmp/"
freesurfer="./output"
rois="./rois/"

# export subjects dir for mri_vol2surf call
export SUBJECTS_DIR="./"

# summary measures
MEASURES="MIN MAX MEAN MEDIAN MODE STDEV COUNT_NONZERO"

# compute stats
for ROIS in `ls ${resliced}/*.nii.gz`
do
	name=${ROIS##*/}
	if [[ ${name} == *"Contra"* ]]; then
		HEMI="lh rh"
	elif [[ ${name} == *"left"* ]] || [[ ${name} == *"lh"* ]] || [[ ${name} == *"L" ]]; then
		HEMI="lh"
	elif [[ ${name} == *"right"* ]] || [[ ${name} == *"rh"* ]] || [[ ${name} == *"R" ]]; then
		HEMI="rh"
	else
		HEMI="lh rh"
	fi
	
	for hemi in ${HEMI}
	do
		echo ${hemi}.${name::-7} >> endpoints_key.txt

		# thickness and volume
		metrics="volume thickness"
		for METRICS in ${metrics}
		do
			for measures in ${MEASURES}
			do
				value=`eval 'wb_command -metric-stats ${surfdir}/${hemi}.${METRICS}.shape.gii -reduce ${measures} -roi ./parcellation-surface/${hemi}.${name::-7}.func.gii'`
				if [ $? -eq 0 ]; then
					echo ${value} >> ${tmpdir}/rois_${measures}_${hemi}."${METRICS}".txt
				else
					echo "NaN" >> ${tmpdir}/rois_${measures}_${hemi}."${METRICS}".txt
				fi
			done
		done
	done
done
