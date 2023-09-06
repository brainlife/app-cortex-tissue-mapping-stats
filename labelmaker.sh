#!/bin/bash

# set -e
# set -x

# identify all func files in cortexmap input
files=(`ls ./cortexmap/func/`)

# loop through hemispheres and make labels
for i in ${files[*]}
do
  h=${i%%.*}
  func_file=${i#*.}
  func_file=${func_file%*.func.gii*}
  
  # set filename     
  var_filename=${h}".varea."${func_file}

  echo $h $func_file $var_filename
  
  if [[ ${func_file} != "polarAngle" ]] && [[ ${func_file} != 'eccentricity' ]] && [[ ${func_file} != 'mask' ]]; then
    # mask the visual area parcellation by the prf measure binning
    [ ! -f ./${var_filename}.func.gii ] && wb_command -metric-math 'x*y' ./${var_filename}.func.gii -var x ./${h}.varea.shape.gii -var y ./cortexmap/func/${i}

    # generate an annotation file from the prf measure-binned visual area parcellation
    [ ! -f ./${var_filename}.label.gii ] && wb_command -metric-label-import ./${var_filename}.func.gii label.txt ./${var_filename}.label.gii && wb_command -set-map-names ${var_filename}.label.gii -map 1 "${var_filename}"
  fi
done

[ ! -f ./lh.varea.label.gii ] && wb_command -metric-label-import ./lh.varea.shape.gii label.txt ./lh.varea.label.gii && wb_command -set-map-names ./lh.varea.label.gii -map 1 "varea"

[ ! -f ./rh.varea.label.gii ] && wb_command -metric-label-import ./rh.varea.shape.gii label.txt ./rh.varea.label.gii && wb_command -set-map-names ./rh.varea.label.gii -map 1 "varea"