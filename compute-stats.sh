#!/bin/bash

# This script will compute statistics in each ROI of a parcellation

# set -x
# set -e

#### parse inputs ####
# configs
lh_annot=`jq -r '.lh_annot' config.json`
rh_annot=`jq -r '.rh_annot' config.json`
lh_white=`jq -r '.left_surf' config.json`
rh_white=`jq -r '.right_surf' config.json`
aparc_to_use=`jq -r '.fsaparc' config.json`
freesurfer=`jq -r '.freesurfer' config.json`

# hemispheres
hemispheres="lh rh"

# filepaths
[ ! -d ./output ] && cp -R ${freesurfer} ./output/ && chmod -R +w ./output/*
freesurfer="./output/"

# set subjects dir for freesurfer to pwd
export SUBJECTS_DIR=./

# identify parcellations to use
parcellations="aparc aparc.a2009s"
if [ -f ./output/mri/aparc.DKTatlas+aseg.mgz ]; then
  parcellations=${parcellations}" aparc.DKTatlas"
fi

# if additional annots, convert back to annot
if [[ ! ${lh_annot} == 'null' ]]; then
	mris_convert --annot ${lh_annot} ./output/surf/lh.white ./lh.parc.annot
fi

if [[ ! ${rh_annot} == 'null' ]]; then
	mris_convert --annot ${rh_annot} ./output/surf/rh.white ./rh.parc.annot
fi

if [ -f ./lh.parc.annot ]; then
  parcellations=${parcellations}" parc"
fi
parcellations=(`echo ${parcellations}`)

# loop through parcellations and hemispheres
for parcs in ${parcellations[*]}
do
	for hemi in ${hemispheres}
	do
	    # set variable to specific file path if parcs == parc, else just use the name of the freesurfer parcellation
		if [[ ${parcs} == "parc" ]]; then
			input=${hemi}.parc.annot
		else
			input=${parcs}
		fi

		# compute anatomical stats for parcellation
		anat_outname=${parcs}.${hemi}".anatomical"
		[ ! -f ./${anat_outname}.txt ] && mris_anatomical_stats -a ${input} -f ./${anat_outname}.txt output ${hemi}

		# convert table to csv
		# StructName NumVert SurfArea GrayVol ThickAvg ThickStd MeanCurv GausCurv FoldInd CurvInd
		[ ! -f ${anat_outname}_tailed.txt ] && tail ./${anat_outname}.txt -n +62 > ./${anat_outname}_tailed.txt
		[ ! -f ${anat_outname}.csv ] && sed 's/ *$//' ./${anat_outname}_tailed.txt > ./${anat_outname}_tailed_comma.txt && sed 's/ \+/,/g' ./${anat_outname}_tailed_comma.txt > ./${anat_outname}.csv
	done
done