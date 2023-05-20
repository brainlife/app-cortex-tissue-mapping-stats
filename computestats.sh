#!/bin/bash

set -e
set -x

MinDegree=`jq -r '.minDegree' config.json`
MinDegree=(`echo ${MinDegree}`)
MaxDegree=`jq -r '.maxDegree' config.json`
MaxDegree=(`echo ${MaxDegree}`)
hemispheres="lh rh"
prf_measure=`jq -r '.prf_measure' config.json`

export SUBJECTS_DIR=./

# loop through hemispheres
for h in ${hemispheres}
do
  echo "hemisphere == $h"

  # loop through degree bins
  for (( i=0; i<${#MinDegree[*]}; i++ ))
  do
    echo "generating surface files for ${prf_measure} between ${MinDegree[$i]} degrees and ${MaxDegree[$i]} degrees"
    var_filename=${h}".varea.${prf_measure}"${MinDegree[$i]}"to"${MaxDegree[$i]}

    [ ! -f ./output/label/${var_filename}.annot ] && mris_convert --annot ./${var_filename}.label.gii ./output/surf/${h}.white ./output/label/${var_filename}.annot
    
    # perform anatomcial statistics. give 90% of final measures
    [ ! -f ./${var_filename}.txt ] && mris_anatomical_stats -a ./output/label/${var_filename}.annot -b output ${h} > ${var_filename}.txt
    
    # compute curvature specific measures
    [ ! -f ./${var_filename}.curv.txt ] && mri_segstats --annot output ${h} ${var_filename##${h}.} --i ./output/surf/${h}.curv --sum ./${var_filename}.curv.txt
    done
done
