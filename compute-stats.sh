#!/bin/bash

# This script will compute statistics in each ROI of a parcellation

set -x
set -e

#### parse inputs ####
# configs
cortexmap=`jq -r '.cortexmap' config.json`
lh_annot=`jq -r '.lh_annot' config.json`
rh_annot=`jq -r '.rh_annot' config.json`
lh_vertices=`jq -r '.left' config.json`
rh_vertices=`jq -r '.right' config.json`
lh_pial=${lh_vertices}/lh.pial*.gii
rh_pial=${rh_vertices}/rh.pial*.gii

# hemispheres
hemispheres="lh rh"

# filepaths
cp -R ${cortexmap} ./cortexmap/
cortexmap="./cortexmap/"
funcdir="${cortexmap}/func"
surfdir="${cortexmap}/surf"
labeldir="${cortexmap}/label"
roidir="./aparc-rois/"
roidir_parc="./parc-rois/"
tmpdir="./tmp/"

# make directories
mkdir -p ${roidir} ${tmpdir} ${roidir_parc}

# metrics
METRICS=($(ls ${funcdir}))

# summary measures
MEASURES="MIN MAX MEAN MEDIAN MODE STDEV SAMPSTDEV COUNT_NONZERO"

for hemi in ${hemispheres}
do
	echo "converting files for ${hemi}"
	parc=$(eval "echo \$${hemi}_annot")
	pial=$(eval "echo \$${hemi}_pial")
	
	# check if inflated pial exists
	for i in ${pial}
	do
		if [[ ! "${i}" == *"inflated"* ]]; then
			pial=${i}
		fi
	done

	# convert surface parcellations that came from multi atlas transfer tool
	if [[ ! ${parc} == 'null' ]]; then
		#### convert annotation files to useable label giftis ####
		[ ! -f ${hemi}.parc.label.gii ] && mris_convert --annot ${parc} \
			${pial} \
			${hemi}.parc.label.gii

		#### set map names ####
		wb_command -set-map-names ${hemi}.parc.label.gii -map 1 "${hemi}_parc"

		#### convert gifti labels to rois ####
		[ ! -f ${hemi}.parc.shape.gii ] && wb_command -gifti-all-labels-to-rois ${hemi}.parc.label.gii \
			1 \
			${hemi}.parc.shape.gii

		# add parc keyes to text file
		roi_keys=$(wb_command -file-information ${hemi}.parc.shape.gii -only-map-names)
		for KEYS in ${roi_keys}
		do
			if [[ ! ${KEYS} == 'unknown_0' ]]; then
				if [[ ${KEYS::1} == 'L' ]] || [[ ${KEYS::1} == 'R' ]]; then
					keyname=${KEYS:2}
				else
					keyname=${KEYS:3}
				fi

				if [[ "${keyname}" == *"_ROI"* ]]; then
					keyname=`echo ${keyname%"_ROI"*}`
				fi

				if [[ ! ${keyname} == 'H' ]]; then
					echo ${KEYS} >> parc_keys.txt
				fi
			fi
		done
	fi

	# convert freesurfer aparc labels from cortexmapping app
	[ ! -f ${hemi}.aparc.shape.gii ] && wb_command -gifti-all-labels-to-rois ${labeldir}/${hemi}.aparc.*.native.label.gii \
		1 \
		${hemi}.aparc.shape.gii

	# add aparc keyes to text file
	roi_keys=$(wb_command -file-information ${hemi}.aparc.shape.gii -only-map-names)
	for KEYS in ${roi_keys}
	do
		if [[ ${KEYS::1} == 'L' ]] || [[ ${KEYS::1} == 'R' ]]; then
			keyname=${KEYS:2}
		else
			keyname=${KEYS:3}
		fi

		if [[ ! ${keyname} == 'Medial_wall' ]]; then
			echo ${KEYS} >> aparc_keys.txt
		fi
	done
done

#### medial wall parcellation in aparc.a2009s is troublesome. need to loop through number of maps to skip this, or else the metric-stats function fails
roi_keys_lh=$(wb_command -file-information lh.aparc.shape.gii -only-map-names)
roi_keys_rh=$(wb_command -file-information rh.aparc.shape.gii -only-map-names)

#### hippocampus parcellation in glasser atlas (hcp-mmp-b) is troublesome. need to loop through number of maps to skip this, or else the metric-stats function fails
if [[ ${parc} == 'null' ]]; then
	roi_keys_lh_parc=""
	roi_keys_rh_parc=""
else
	roi_keys_lh_parc=$(wb_command -file-information lh.parc.shape.gii -only-map-names)
	roi_keys_rh_parc=$(wb_command -file-information rh.parc.shape.gii -only-map-names)
fi

#### compute MIN MAX MEAN MEDIAN MODE STDEV SAMPSTDEV COUNT_NONZERO of each metric per roi: diffusion measures ####
for metrics in ${METRICS[*]}
do
	hemi="${metrics::2}"
	keys=$(eval "echo \$roi_keys_${hemi}")
	keys_parc=$(eval "echo \$roi_keys_${hemi}_parc")

	if [[ ! ${metrics:3} == 'goodvertex.func.gii' ]]; then
		echo "computing measures for ${metrics}"
		for measures in ${MEASURES}
		do
			echo ${measures}
			for KEYS in ${keys}
			do
				if [[ ${KEYS::1} == 'L' ]] || [[ ${KEYS::1} == 'R' ]]; then
					HEMI=${KEYS::1}
					keyname=${KEYS:2}
				else
					HEMI=${hemi}
					keyname=${KEYS:3}
				fi

				if [[ ! ${keyname} == 'Medial_wall' ]]; then
					[ ! -f ./aparc-rois/${HEMI}.aparc.${keyname}.shape.gii ] && wb_command -gifti-label-to-roi ${labeldir}/${hemi}.aparc.*.native.label.gii \
						./aparc-rois/${HEMI}.aparc.${keyname}.shape.gii -name "${KEYS}" -map "${hemi}_aparc.a2009s"

					# compute in freesurfer parcellation
					wb_command -metric-stats ${funcdir}/${metrics} \
						-reduce ${measures} \
						-roi ./aparc-rois/${HEMI}.aparc.${keyname}.shape.gii >> ${tmpdir}/aparc_${measures}_"${metrics::-9}".txt
				fi
			done

			# if parcellation inputted, compute stats in parcellation as well
			if [[ ! ${parc} == 'null' ]]; then
				for KEYS in ${keys_parc}
				do
					if [[ ! ${KEYS} == 'unknown_0' ]]; then
						if [[ ${KEYS::1} == 'L' ]] || [[ ${KEYS::1} == 'R' ]]; then
							HEMI=${KEYS::1}
							keyname=${KEYS:2}
						else
							HEMI=${hemi}
							keyname=${KEYS:3}
						fi

						if [[ "${keyname}" == *"_ROI"* ]]; then
							keyname=`echo ${keyname%"_ROI"*}`
						fi

						if [[ ! ${keyname} == 'H' ]]; then
							[ ! -f ${roidir_parc}/${HEMI}.parc.${keyname}.shape.gii ] && wb_command -gifti-label-to-roi ${hemi}.parc.label.gii \
								${roidir_parc}/${HEMI}.parc.${keyname}.shape.gii -name "${KEYS}" -map "${hemi}_parc"

							# compute in freesurfer parcellation
							wb_command -metric-stats ${funcdir}/${metrics} \
								-reduce ${measures} \
								-roi ${roidir_parc}/${HEMI}.parc.${keyname}.shape.gii >> ${tmpdir}/parc_${measures}_"${metrics::-9}".txt
						fi
					fi
				done
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
		keys=$(eval "echo \$roi_keys_${hemi}")
		keys_parc=$(eval "echo \$roi_keys_${hemi}_parc")

		for measures in ${MEASURES}
		do
			echo ${measures}
			for KEYS in ${keys}
			do
				if [[ ${KEYS::1} == 'L' ]] || [[ ${KEYS::1} == 'R' ]]; then
					HEMI=${KEYS::1}
					keyname=${KEYS:2}
				else
					HEMI=${hemi}
					keyname=${KEYS:3}
				fi

				if [[ ! ${keyname} == 'Medial_wall' ]]; then
					# compute in freesurfer parcellation
					wb_command -metric-stats ${surfdir}/${hemi}.${metrics}.shape.gii \
						-reduce ${measures} \
						-roi ./aparc-rois/${HEMI}.aparc.${keyname}.shape.gii >> ${tmpdir}/aparc_${measures}_${hemi}."${metrics}".txt
				fi
			done

			# if parcellation inputted, compute stats in parcellation as well
			if [[ ! ${parc} == 'null' ]]; then
				for KEYS in ${keys_parc}
				do
					if [[ ! ${KEYS} == 'unknown_0' ]]; then
						if [[ ${KEYS::1} == 'L' ]] || [[ ${KEYS::1} == 'R' ]]; then
							HEMI=${KEYS::1}
							keyname=${KEYS:2}
						else
							HEMI=${hemi}
							keyname=${KEYS:3}
						fi

						if [[ "${keyname}" == *"_ROI"* ]]; then
							keyname=`echo ${keyname%"_ROI"*}`
						fi

						if [[ ! ${keyname} == 'H' ]]; then
							# compute in parcellation
							wb_command -metric-stats ${surfdir}/${hemi}.${metrics}.shape.gii \
								-reduce ${measures} \
								-roi ${roidir_parc}/${HEMI}.parc.${keyname}.shape.gii >> ${tmpdir}/parc_${measures}_${hemi}."${metrics}".txt
						fi
					fi
				done
			fi
		done
	done
done
