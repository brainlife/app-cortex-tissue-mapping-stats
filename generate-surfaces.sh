#!/bin/bash

set -x
set -e

# configs and variables
cortexmap=`jq -r '.cortexmap' config.json`
freesurfer=`jq -r '.freesurfer' config.json`
prf_surfaces=`jq -r '.prf_surfaces' config.json`
MinDegree=`jq -r '.minDegree' config.json`
MinDegree=(`echo ${MinDegree}`)
MaxDegree=`jq -r '.maxDegree' config.json`
MaxDegree=(`echo ${MaxDegree}`)
hemispheres="lh rh"

# copy over important variables
[ ! -d ./cortexmap ] && cp -R ${cortexmap} ./cortexmap && chmod -R +w ./cortexmap/*
[ ! -d ./output ] && cp -R ${freesurfer} ./output && chmod -R +w ./output/*
[ ! -d ./prf_surfaces ] && cp -R ${prf_surfaces} ./prf_surfaces && chmod -R +w ./prf_surfaces/*

# identify measures to loop through later
tmp_measures=(`find cortexmap/func/lh.*`)
measures=""
for i in ${tmp_measures[*]}
do
  measures=$measures" "`echo $i | grep -o -P '(?<=cortexmap/func/lh.).*(?=.func.gii)'`
done
measures=(`echo ${measures}`)
echo "measures to loop through:${measures[*]}"

# set subjects_dir path for freesurfer
export SUBJECTS_DIR=./

# loop through hemispheres
for h in ${hemispheres}
do
  echo "hemisphere == $h"
  # set the filename for the eccentricity file
  ecc_file=${h}".eccentricity"

  # convert the eccentricity surface file to a .func.gii file for wb_command
  [ ! -f ./${h}.eccentricity.func.gii ] && mris_convert -c ./prf_surfaces/${h}.eccentricity ./output/surf/${h}.white ./${h}.eccentricity.func.gii

  # convert the visual area parcellation to a file format wb_command likes
  [ ! -f ./${h}.varea.shape.gii ] && mris_convert -c ./prf_surfaces/${h}.varea ./output/surf/${h}.white ./${h}.varea.shape.gii

  # loop through degree bins
  for (( i=0; i<${#MinDegree[*]}; i++ ))
  do
    echo "generating surface files for eccentricities between ${MinDegree[$i]} degrees and ${MaxDegree[$i]} degrees"
    ecc_var_filename=${h}".varea.Ecc"${MinDegree[$i]}"to"${MaxDegree[$i]}
    # generate the binarized eccentricity surface
    [ ! -f ./${h}.Ecc${MinDegree[$i]}to${MaxDegree[$i]}.func.gii ] && mri_binarize --i ./${h}.eccentricity.func.gii --min ${MinDegree[$i]} --max ${MaxDegree[$i]} --o ./${h}.Ecc${MinDegree[$i]}to${MaxDegree[$i]}.func.gii

    # mask the visual area parcellation by the eccentricity binning
    [ ! -f ./${ecc_var_filename}.func.gii ] && wb_command -metric-math 'x*y' ./${ecc_var_filename}.func.gii -var x ./${h}.varea.shape.gii -var y ./${h}.Ecc${MinDegree[$i]}to${MaxDegree[$i]}.func.gii

    # generate an annotation file from the eccentricity-binned visual area parcellation
    [ ! -f ./${ecc_var_filename}.label.gii ] && wb_command -metric-label-import ./${ecc_var_filename}.func.gii label.txt ./${ecc_var_filename}.label.gii -discard-others && wb_command -set-map-names ${ecc_var_filename}.label.gii -map 1 "${ecc_var_filename}"
    #wb_command -gifti-all-labels-to-rois ${ecc_var_filename}.label.gii 1 ${ecc_var_filename}.shape.gii
    [ ! -f ./${ecc_var_filename}.annot ] && mris_convert --annot ${ecc_var_filename}.label.gii ./output/surf/${h}.white ./${ecc_var_filename}.annot

    # loop through measures in cortexmap and compute average
    for (( j=0; j<${#measures[*]}; j++ ))
    do
      #echo "computing stats for measure ${measures[$j]}"
      #outname=${ecc_var_filename}"."${measures[$j]}

      # make sure ad, md, and rd are in proper scale
      if [[ ${measures[${j}]} == 'ad' ]] || [[ ${measures[${j}]} == 'md' ]] || [[ ${measures[${j}]} == 'rd' ]]; then
        avg=`wb_command -metric-stats ./cortexmap/func/${h}.${measures[$j]}.func.gii -reduce MEAN`
        if (( $(echo "$avg < 0.005" |bc -l) )); then
          echo "need to scale measure"
          wb_command -metric-math 'x*1000' ./cortexmap/func/${h}.${measures[$j]}.func.gii -var x ./cortexmap/func/${h}.${measures[$j]}.func.gii
        fi
      fi
    done
    #
    #   [ ! -f ./${outname}.txt ] && mri_segstats --annot ./output/ ${h} ./${ecc_var_filename}.annot --i ./cortexmap/func/${h}.${measures[$j]}.func.gii --surf white --excludeid 0 --o ./${outname}.txt
    #
    #   # convert table to csv
    #   [ ! -f ./${outname}_tailed.txt ] && tail ./${outname}.txt -n +56 > ./${outname}_tailed.txt
    #   # Index SegId NVertices StructName Mean StdDev Min Max Range
    #   [ ! -f ./${outname}_tailed_subselected.txt ] && awk '{print $2,$3,$5,$6,$7,$8,$9,$10,$11,$12,$13}' ./${outname}_tailed.txt > ./${outname}_tailed_subselected.txt
    #   [ ! -f ./${outname}.csv ] && sed 's/ *$//' ./${outname}_tailed_subselected.txt > ./${outname}_tailed_subselected_comma.txt && sed 's/ \+/,/g' ./${outname}_tailed_subselected_comma.txt > ./${outname}.csv
    # done

    # compute anatomical stats for eccentricity binned visual area parcellation
    # anat_outname=${ecc_var_filename}".anatomical"
    # [ ! -f ./${anat_outname}.txt ] && mris_anatomical_stats -a ./${ecc_var_filename}.annot -f ./${anat_outname}.txt output ${h}
    #
    # # convert table to csv
    # # StructName NumVert SurfArea GrayVol ThickAvg ThickStd MeanCurv GausCurv FoldInd CurvInd
    # [ ! -f ${anat_outname}_tailed.txt ] && tail ./${anat_outname}.txt -n +62 > ./${anat_outname}_tailed.txt
    # [ ! -f ${anat_outname}.csv ] && sed 's/ *$//' ./${anat_outname}_tailed.txt > ./${anat_outname}_tailed_comma.txt && sed 's/ \+/,/g' ./${anat_outname}_tailed_comma.txt > ./${anat_outname}.csv

    echo "finished generating surface files for eccentricities between ${MinDegree[$i]} degrees and ${MaxDegree[$i]} degrees"
  done
done

echo "Finished generating surface files! Now onto stats computation!"
