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
aparc_to_use=`jq -r '.fsaparc' config.json`
freesurfer=`jq -r '.freesurfer' config.json`

# hemispheres
hemispheres="lh rh"

# filepaths
[ ! -d ./cortexmap ] && cp -R ${cortexmap} ./cortexmap/ && chmod -R +w ./cortexmap/*
[ ! -d ./output ] && cp -R ${freesurfer} ./output/ && chmod -R +w ./output/*
cortexmap="./cortexmap/"
funcdir="${cortexmap}/func"
surfdir="${cortexmap}/surf"
labeldir="${cortexmap}/label"
freesurfer="./output/"

# set subjects dir for freesurfer to pwd
export SUBJECTS_DIR=./

# identify measures to loop through later
tmp_measures=(`find cortexmap/func/lh.*`)
measures=""
for i in ${tmp_measures[*]}
do
  measures=$measures" "`echo $i | grep -o -P '(?<=cortexmap/func/lh.).*(?=.func.gii)'`
done
measures=(`echo ${measures}`)
echo "measures to loop through:${measures[*]}"

# if parcellation exists, generate annot files
for hemi in $hemispheres
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
done

# identify parcellations to use
parcellations="${aparc_to_use}"
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

		# loop through measures
		for (( j=0; j<${#measures[*]}; j++ ))
		do
      # set variable outname to make easier to write out
      outname=${parcs}.${hemi}.${measures[$j]}

      # this compute the statistics within each parcel of the parcellation for the measure. it will exclude the 0 parcel, which should always be excluded vertices
		  [ ! -f ./${outname}.txt ] && mri_segstats --annot ./output/ ${hemi} ${input} --i ./cortexmap/func/${hemi}.${measures[$j]}.func.gii --surf white --excludeid 0 --o ./${outname}.txt

		  # convert table to csv
		  [ ! -f ./${outname}_tailed.txt ] && tail ./${outname}.txt -n +56 > ./${outname}_tailed.txt
		  # Index SegId NVertices StructName Mean StdDev Min Max Range
		  [ ! -f ./${outname}_tailed_subselected.txt ] && awk '{print $2,$3,$5,$6,$7,$8,$9,$10,$11,$12,$13}' ./${outname}_tailed.txt > ./${outname}_tailed_subselected.txt
		  [ ! -f ./${outname}.csv ] && sed 's/ *$//' ./${outname}_tailed_subselected.txt > ./${outname}_tailed_subselected_comma.txt && sed 's/ \+/,/g' ./${outname}_tailed_subselected_comma.txt > ./${outname}.csv
		done

		# compute anatomical stats for parcellation
		anat_outname=${parcs}.${hemi}".anatomical"
		[ ! -f ./${anat_outname}.txt ] && mris_anatomical_stats -a ${input} -f ./${anat_outname}.txt output ${hemi}

		# convert table to csv
		# StructName NumVert SurfArea GrayVol ThickAvg ThickStd MeanCurv GausCurv FoldInd CurvInd
		[ ! -f ${anat_outname}_tailed.txt ] && tail ./${anat_outname}.txt -n +62 > ./${anat_outname}_tailed.txt
		[ ! -f ${anat_outname}.csv ] && sed 's/ *$//' ./${anat_outname}_tailed.txt > ./${anat_outname}_tailed_comma.txt && sed 's/ \+/,/g' ./${anat_outname}_tailed_comma.txt > ./${anat_outname}.csv
	done
done
