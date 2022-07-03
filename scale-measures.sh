#!/bin/bash

# This script will scale tensor measures if they need to be rescaled

# set -x
# set -e

#### parse inputs ####
# configs
cortexmap=`jq -r '.cortexmap' config.json`

# hemispheres
hemispheres="lh rh"

# filepaths
cp -R ${cortexmap} ./cortexmap/ && chmod -R +w ./cortexmap/*
cortexmap="./cortexmap/"
funcdir="${cortexmap}/func"
surfdir="${cortexmap}/surf"
labeldir="${cortexmap}/label"

# metrics
# identify measures to loop through later
tmp_measures=(`find cortexmap/func/lh.*`)
measures=""
for i in ${tmp_measures[*]}
do
  measures=$measures" "`echo $i | grep -o -P '(?<=cortexmap/func/lh.).*(?=.func.gii)'`
done
measures=(`echo ${measures}`)
echo "measures to loop through:${measures[*]}"

# loop through hemispheres, generate appropriate files, scale tensor values if necessary
for hemi in ${hemispheres}
do
	# loop through measures and scale values if necessary
	for (( j=0; j<${#measures[*]}; j++ ))
	do
		# make sure ad, md, and rd are in proper scale
		if [[ ${measures[${j}]} == 'ad' ]] || [[ ${measures[${j}]} == 'md' ]] || [[ ${measures[${j}]} == 'rd' ]]; then
			avg=`wb_command -metric-stats ./cortexmap/func/${hemi}.${measures[$j]}.func.gii -reduce MEAN`
			if (( $(echo "$avg < 0.005" | bc -l) )); then
				echo "need to scale measure"
				wb_command -metric-math 'x*1000' ./cortexmap/func/${hemi}.${measures[$j]}.func.gii -var x ./cortexmap/func/${hemi}.${measures[$j]}.func.gii
			fi
		fi
	done
done
