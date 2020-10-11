#!/bin/bash

# parse inputs
weight=`jq -r '.weight' config.json`
weighting_alg=`jq -r '.weighting_alg' config.json`

# make output directory
resliced="./resliced/"
tmpdir="./tmp/"
freesurfer="./output"
rois="./rois/"
cortexmap="./cortexmap/"
funcdir="${cortexmap}/func"
surfdir="${cortexmap}/surf"

# export subjects dir for mri_vol2surf call
export SUBJECTS_DIR="./"

# metrics
METRICS_lh=($(ls ${funcdir}/*lh*))
METRICS_rh=($(ls ${funcdir}/*rh*))

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
		metrics=($(eval "echo \${METRICS_${hemi}[*]}"))
		for METRICS in ${metrics[*]}
		do
			metrics_name=${METRICS##*/}
			echo ${metrics_name}
			for measures in ${MEASURES}
			do
				if [[ ${weight} == 'false' ]]; then
					value=`eval 'wb_command -metric-stats ${funcdir}/${metrics_name} -reduce ${measures} -roi ./parcellation-surface/${hemi}.${name::-7}.func.gii'`
				fi
				if [ $? -eq 0 ]; then
					echo ${value} >> ${tmpdir}/tracts_${measures}_"${metrics_name::-9}".txt
				else
					echo "NaN" >> ${tmpdir}/tracts_${measures}_"${metrics_name::-9}".txt
				fi
			done
		done

		# thickness and volume
		metrics="volume thickness"
		for METRICS in ${metrics}
		do
			for measures in ${MEASURES}
			do
				if [[ ${weight} == 'false' ]]; then
					value=`eval 'wb_command -metric-stats ${surfdir}/${hemi}.${METRICS}.shape.gii -reduce ${measures} -roi ./parcellation-surface/${hemi}.${name::-7}.func.gii'`
				fi
				if [ $? -eq 0 ]; then
					echo ${value} >> ${tmpdir}/tracts_${measures}_${hemi}."${METRICS}".txt
				else
					echo "NaN" >> ${tmpdir}/tracts_${measures}_${hemi}."${METRICS}".txt
				fi
			done
		done
	done
done