#!/bin/bash

# set -e
# set -x

# inputs
MinDegree=`jq -r '.minDegree' config.json`
MinDegree=(`echo ${MinDegree}`)
MaxDegree=`jq -r '.maxDegree' config.json`
MaxDegree=(`echo ${MaxDegree}`)
hemispheres="lh rh"
prf_measure=`jq -r '.prf_measure' config.json`

# loop through hemispheres and make labels
for h in ${hemispheres}
do
  for (( i=0; i<${#MinDegree[*]}; i++ ))
  do
    # set filename   
    var_filename=${h}".varea."${prf_measure}${MinDegree[$i]}"to"${MaxDegree[$i]}
    
    # mask the visual area parcellation by the prf measure binning
    [ ! -f ./${var_filename}.func.gii ] && wb_command -metric-math 'x*y' ./${var_filename}.func.gii -var x ./${h}.varea.shape.gii -var y ./${h}.${prf_measure}${MinDegree[$i]}to${MaxDegree[$i]}.func.gii

    # generate an annotation file from the prf measure-binned visual area parcellation
    [ ! -f ./${var_filename}.label.gii ] && wb_command -metric-label-import ./${var_filename}.func.gii label.txt ./${var_filename}.label.gii -discard-others && wb_command -set-map-names ${var_filename}.label.gii -map 1 "${var_filename}"
    done
done