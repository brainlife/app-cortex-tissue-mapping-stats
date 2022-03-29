#!/bin/bash

# parse inputs
aparc=`jq -r '.aparc' config.json`
rois=`jq -r '.rois' config.json`
freesurfer=`jq -r '.freesurfer' config.json`
reslice=`jq -r '.reslice' config.json`
cortexmap=`jq -r '.cortexmap' config.json`
weight=`jq -r '.weight' config.json`
weighting_alg=`jq -r '.weighting_alg' config.json`
hemi="lh rh"

# make output directory
mkdir -p resliced tmp parc-stats parcellation-surface
resliced="./resliced/"
tmpdir="./tmp/"

# copy freesurfer directory here
[ ! -d ./output/ ] && cp -RL ${freesurfer} ./output && chmod -R +w ./output
freesurfer="./output"

# export subjects dir for mri_vol2surf call
export SUBJECTS_DIR="./"

# copy rois directory
[ ! -d ./rois/ ] && cp -R ${rois} ./rois/ && chmod -R +w ./rois/
rois="./rois/"

# copy cortexmap
[ ! -d ./cortexmap/ ] && cp -R ${cortexmap} ./cortexmap/ && chmod -R +w ./cortexmap/
cortexmap="./cortexmap/"
funcdir="${cortexmap}/func"

# convert aparc
[ ! -f ./${aparc}+aseg.nii.gz ] && mri_convert ${freesurfer}/mri/${aparc}+aseg.mgz ./${aparc}+aseg.nii.gz

# convert surfaces
for HEMI in ${hemi}
do
	[ ! -f ${freesurfer}/surf/${HEMI}.pial.surf.gii ] && cp ${cortexmap}/surf/${HEMI}.pial.surf.gii ${freesurfer}/surf/
	[ ! -f ${freesurfer}/surf/${HEMI}.white.surf.gii ] && cp ${cortexmap}/surf/${HEMI}.white.surf.gii ${freesurfer}/surf/
done

# reslice rois
if [[ ${reslice} == 'true' ]]; then
	for ROIS in `ls ${rois}`
	do
		[ ! -f ${resliced}/${ROIS} ] && mri_vol2vol --mov ${rois}/${ROIS} --targ ${aparc}+aseg.nii.gz --regheader --interp nearest --o ${resliced}/${ROIS}
	done
else
	for ROIS in `ls ${rois}`
	do
		[ ! -f ${resliced}/${ROIS} ] && cp -v ${rois}/${ROIS} ${resliced}/${ROIS}
	done
fi

# map parcellation to surface
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
		echo ${hemi}
		[ ! -f ./parcellation-surface/${hemi}.${name::-7}.func.gii ] && mri_vol2surf --src ${resliced}/${name} --hemi ${hemi} --surf white.surf.gii --regheader output --out ./parcellation-surface/${hemi}.${name::-7}.func.gii --projdist-max 0 6 .1
	done
done
