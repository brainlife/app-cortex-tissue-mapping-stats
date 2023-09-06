#!/bin/bash

# set -x
# set -e

# configs and variables
freesurfer=`jq -r '.freesurfer' config.json`
prf_surfaces=`jq -r '.prf_surfaces' config.json`
cortexmap=`jq -r '.cortexmap' config.json`
hemispheres="lh rh"

# copy over important variables
[ ! -d ./output ] && cp -R ${freesurfer} ./output && chmod -R +w ./output/*
[ ! -d ./prf_surfaces ] && cp -R ${prf_surfaces} ./prf_surfaces && chmod -R +w ./prf_surfaces/*
[ ! -d ./cortexmap ] && cp -R ${cortexmap} ./cortexmap && chmod -R +w ./cortexmap/*

# set subjects_dir path for freesurfer
export SUBJECTS_DIR=./

# loop through hemispheres
for h in ${hemispheres}
do
  echo "hemisphere == $h"

  # convert the visual area parcellation to a file format wb_command likes
  [ ! -f ./${h}.varea.shape.gii ] && mris_convert -c ./prf_surfaces/${h}.varea ./output/surf/${h}.white ./${h}.varea.shape.gii
done
