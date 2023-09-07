#!/bin/bash

set -e
set -x

files=(`ls *.label.gii`)

export SUBJECTS_DIR=./

# loop through files
for i in ${files[*]}
do
  h=${i%%.*}
  echo "hemisphere == $h"

  var_filename=${i%*.label.gii*}

  [ ! -f ./output/label/${var_filename}.annot ] && mris_convert --annot ./${i} ./output/surf/${h}.white ./output/label/${var_filename}.annot
  
  # perform anatomcial statistics. give 90% of final measures
  [ ! -f ./${var_filename}.txt ] && mris_anatomical_stats -a ./output/label/${var_filename}.annot -b output ${h} > ${var_filename}.txt
  
  # compute curvature specific measures
  [ ! -f ./${var_filename}.curv.txt ] && mri_segstats --annot output ${h} ${var_filename##${h}.} --i ./output/surf/${h}.curv --sum ./${var_filename}.curv.txt
  
  # move to cortexmap for output
  [ ! -f ./cortexmap/func/${var_filename}.func.gii ] && mv ${var_filename}.func.gii ./cortexmap/func/
  [ ! -f ./cortexmap/label/$i ] && mv ${i} ./cortexmap/label/
  [ ! -f ./cortexmap/surf/${h}.varea.shape.gii ] && mv ${h}.varea.shape.gii ./cortexmap/surf/
done

mv *.label.gii ./cortexmap/label/
mv *.func.gii ./cortexmap/func/
