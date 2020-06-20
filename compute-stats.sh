#!/bin/bash

# This script will compute statistics in each ROI of a parcellation

set -x
set -e

#### parse inputs ####
# configs
cortexmap=`jq -r '.cortexmap' config.json`
lh_annot=`jq -r '.lh_annot' config.json`
rh_annot=`jq -r '.rh_annot' config.json`
lh_pial=`jq -r '.lh_pial_surf' config.json`
rh_pial=`jq -r '.rh_pial_surf' config.json`

# filepaths
cp -R ${cortexmap} ./cortexmap/
cortexmap="./cortexmap/"
funcdir="${cortexmap}/func"
surfdir="${cortexmap}/surf"
labeldir="${cortexmap}/label"
roidir="./aparc-rois/"

# make directories
mkdir -p ${roidir}

# hemispheres
hemispheres="lh rh"

# metrics
METRICS=($(ls ${funcdir}))

# summary measures
MEASURES="MIN MAX MEAN MEDIAN MODE STDEV SAMPSTDEV COUNT_NONZERO"

for hemi in ${hemispheres}
do
	echo "converting files for ${hemi}"
	parc=$(eval "echo \$${hemi}_annot")
	pial=$(eval "echo \$${hemi}_pial")
	# convert surface parcellations that came from multi atlas transfer tool
	if [[ ! ${parc} == 'null' ]]; then
		#### convert annotation files to useable label giftis ####
		[ ! -f ${hemi}.parc.label.gii ] && mris_convert --annot ${parc} \
			${pial} \
			${hemi}.parc.label.gii

		#### convert gifti labels to rois ####
		[ ! -f ${hemi}.parc.shape.gii ] && wb_command -gifti-all-labels-to-rois ${hemi}.parc.label.gii \
			1 \
			${hemi}.parc.shape.gii

		# print structure list for inputted parcellation
		[ ! -f 'parc.structurelist_${hemi}.txt' ] && wb_command -file-information ${hemi}.parc.shape.gii -only-map-names > parc.structurelist_"${hemi}".txt
	fi

	# convert freesurfer aparc labels from cortexmapping app
	[ ! -f ${hemi}.aparc.shape.gii ] && wb_command -gifti-all-labels-to-rois ${labeldir}/${hemi}.aparc.*.native.label.gii \
		1 \
		${hemi}.aparc.shape.gii
done

#### medial wall parcellation in aparc.a2009s is troublesome. need to loop through number of maps to skip this, or else the metric-stats function fails
roi_keys_lh=$(wb_command -file-information lh.aparc.shape.gii -only-map-names)
roi_keys_rh=$(wb_command -file-information rh.aparc.shape.gii -only-map-names)

#### compute MIN MAX MEAN MEDIAN MODE STDEV SAMPSTDEV COUNT_NONZERO of each metric per roi: diffusion measures ####
for metrics in ${METRICS[*]}
do
	hemi="${metrics::2}"
	keys=$(eval "echo \$roi_keys_${hemi}")

	if [[ ! ${metrics:3} == 'goodvertex.func.gii' ]]; then
		echo "computing measures for ${metrics}"
		for measures in ${MEASURES}
		do
			echo ${measures}
			for KEYS in ${keys}
			do
				if [[ ! ${KEYS:3} == 'Medial_wall' ]]; then
					[ ! -f ./aparc-rois/${hemi}.aparc.${KEYS:3}.shape.gii ] && wb_command -gifti-label-to-roi ${labeldir}/${hemi}.aparc.*.native.label.gii \
						./aparc-rois/${hemi}.aparc.${KEYS:3}.shape.gii -name "${KEYS}" -map "${hemi}_aparc.a2009s"

					# compute in freesurfer parcellation
					wb_command -metric-stats ${funcdir}/${metrics} \
						-reduce ${measures} \
						-roi ./aparc-rois/${hemi}.aparc.${KEYS:3}.shape.gii >> aparc_${measures}_"${metrics::-9}".txt
				fi
			done

			# if parcellation inputted, compute stats in parcellation as well
			if [[ ! ${parc} == 'null' ]]; then
				[ ! -f parc_${measures}_"${metrics::-9}".txt ] && wb_command -metric-stats ${funcdir}/${metrics} \
					-reduce ${measures} \
					-roi ${hemi}.parc.shape.gii \
					>> parc_${measures}_"${metrics::-9}".txt
			fi
		done
	fi
done

#### compute MIN MAX MEAN MEDIAN MODE STDEV SAMPSTDEV COUNT_NONZERO of each metric per roi: volume and thickness ####
METRICS="volume thickness"
for metrics in ${METRICS}
do
	echo "computing statistics for ${metrics}"
	for hemi in ${hemispheres}
	do
		for measures in ${MEASURES}
		do
			echo ${measures}
			for KEYS in ${keys}
			do
				if [[ ! ${KEYS:3} == 'Medial_wall' ]]; then
					# compute in freesurfer parcellation
					wb_command -metric-stats ${surfdir}/${hemi}.${metrics}.shape.gii \
						-reduce ${measures} \
						-roi ./aparc-rois/${hemi}.aparc.${KEYS:3}.shape.gii >> aparc_${measures}_"${metrics}".txt
				fi
			done

			# if parcellation inputted, compute stats in parcellation as well
			if [[ ! ${parc} == 'null' ]]; then
				[ ! -f parc_${measures}_"${metrics}".txt ] && wb_command -metric-stats ${surfdir}/${hemi}.${metrics}.shape.gii \
					-reduce ${measures} \
					-roi ${hemi}.parc.shape.gii \
					>> parc_${measures}_"${metrics}".txt
			fi
		done
	done
done
