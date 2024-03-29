#!/bin/bash

# This script will compute statistics in each ROI of a parcellation

# set -x
# set -e

#### parse inputs ####
# configs
cortexmap=`jq -r '.cortexmap' config.json`
lh_annot=`jq -r '.lh_annot' config.json`
rh_annot=`jq -r '.rh_annot' config.json`
lh_white=`jq -r '.lh_white_surf' config.json`
rh_white=`jq -r '.rh_white_surf' config.json`
aparc_to_use=`jq -r '.fsaparc' config.json`

# hemispheres
hemispheres="lh rh"

# filepaths
cp -R ${cortexmap} ./cortexmap/ && chmod -R +w ./cortexmap/*
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
# identify measures to loop through later
tmp_measures=(`find cortexmap/func/lh.*`)
measures=""
for i in ${tmp_measures[*]}
do
  measures=$measures" "`echo $i | grep -o -P '(?<=cortexmap/func/lh.).*(?=.func.gii)'`
done
measures=(`echo ${measures}`)
echo "measures to loop through:${measures[*]}"

# loop through hemispheres, generate appropriate files, scale tensor values if necessary
for hemi in ${hemispheres}
do
	echo "converting files for ${hemi}"
	parc=$(eval "echo \$${hemi}_annot")
	white=$(eval "echo \$${hemi}_white")

	# check if white exists
	for i in ${white}
	do
		if [[ ! "${i}" == *"inflated"* ]]; then
			white=${i}
		fi
	done

	# convert surface parcellations that came from multi atlas transfer tool
	if [[ ! ${parc} == 'null' ]]; then
		#### convert annotation files to useable label giftis ####
		[ ! -f ${hemi}.parc.label.gii ] && mris_convert --annot ${parc} \
			${white} \
			${hemi}.parc.label.gii

		#### set map names ####
		wb_command -set-map-names ${hemi}.parc.label.gii -map 1 "${hemi}_parc"

		#### convert to freesurfer .annot file ####
    [ ! -f ./${hemi}.parc.annot ] && mris_convert --annot ${hemi}.parc.label.gii ${white} ./${hemi}.parc.annot
	fi

	# loop through measures and scale values if necessary
	for (( j=0; j<${#measures[*]}; j++ ))
	do
		#echo "computing stats for measure ${measures[$j]}"
		#outname=${ecc_var_filename}"."${measures[$j]}

		# make sure ad, md, and rd are in proper scale
		if [[ ${measures[${j}]} == 'ad' ]] || [[ ${measures[${j}]} == 'md' ]] || [[ ${measures[${j}]} == 'rd' ]]; then
			avg=`wb_command -metric-stats ./cortexmap/func/${hemi}.${measures[$j]}.func.gii -reduce MEAN`
			if (( $(echo "$avg < 0.005" | bc -l) )); then
				echo "need to scale measure"
				wb_command -metric-math 'x*1000' ./cortexmap/func/${hemi}.${measures[$j]}.func.gii -var x ./cortexmap/func/${hemi}.${measures[$j]}.func.gii
			fi
		fi
	done
done
