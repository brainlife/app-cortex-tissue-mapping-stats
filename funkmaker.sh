#!/bin/bash

set -x
set -e

# configs and variables
freesurfer=`jq -r '.freesurfer' config.json`
prf_surfaces=`jq -r '.prf_surfaces' config.json`
MinDegree=`jq -r '.minDegree' config.json`
MinDegree=(`echo ${MinDegree}`)
MaxDegree=`jq -r '.maxDegree' config.json`
MaxDegree=(`echo ${MaxDegree}`)
hemispheres="lh rh"
prf_measure=`jq -r '.prf_measure' config.json`

# copy over important variables
[ ! -d ./output ] && cp -R ${freesurfer} ./output && chmod -R +w ./output/*
[ ! -d ./prf_surfaces ] && cp -R ${prf_surfaces} ./prf_surfaces && chmod -R +w ./prf_surfaces/*

# set subjects_dir path for freesurfer
export SUBJECTS_DIR=./

# loop through hemispheres
for h in ${hemispheres}
do
  echo "hemisphere == $h"

  # convert the eccentricity surface file to a .func.gii file for wb_command
  [ ! -f ./${h}.${prf_measure}.func.gii ] && mris_convert -c ./prf_surfaces/${h}.${prf_measure} ./output/surf/${h}.white ./${h}.${prf_measure}.func.gii

  # convert the visual area parcellation to a file format wb_command likes
  [ ! -f ./${h}.varea.shape.gii ] && mris_convert -c ./prf_surfaces/${h}.varea ./output/surf/${h}.white ./${h}.varea.shape.gii

  # loop through degree bins
  for (( i=0; i<${#MinDegree[*]}; i++ ))
  do
    echo "generating surface files for ${prf_measure} between ${MinDegree[$i]} degrees and ${MaxDegree[$i]} degrees"
    var_filename=${h}".${prf_measure}"${MinDegree[$i]}"to"${MaxDegree[$i]}
    [ ! -f ./${var_filename}.func.gii ] && mri_binarize --i ./${h}.${prf_measure}.func.gii --min ${MinDegree[$i]} --max ${MaxDegree[$i]} --o ./${var_filename}.func.gii
    done
done
