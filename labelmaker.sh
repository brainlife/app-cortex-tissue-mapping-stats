#!/bin/bash

set -e
set -x

# configurable inputs
cortexmap=`jq -r '.cortexmap' config.json`
freesurfer=`jq -r '.freesurfer' config.json`
threshold=`jq -r '.threshold' config.json`

# set current working directory
currentDir=$(pwd)

# make directories
[ ! -d ${currentDir}/tmp ] && mkdir ${currentDir}/tmp
[ ! -d ${currentDir}/tmp2 ] && mkdir ${currentDir}/tmp2

# copy over cortexmap and freesurfer
[ ! -d ./cortexmap ] && cp -RL ${cortexmap} ./cortexmap && cortexmap="./cortexmap"
[ ! -d ./output ] && cp -RL ${freesurfer} ./output

# set up other variables
topPath=${cortexmap}/func/

# indentify files
files=(`find $topPath -type f -exec basename -a {} +`)

# build label.txt
if [ ! -f label.txt ]; then
    for (( i=0; i<${#files[*]}; i++ ))
    do
        key=$((i+1))
        red_rgb=$(( $RANDOM % 255 + 1 ))
        green_rgb=$(( $RANDOM % 255 + 1 ))
        blue_rgb=$(( $RANDOM % 255 + 1 ))
        alpha=255
        label_name=${files[$i]%%.func.gii}
        out_name=${label_name}".label.gii"
        table_line="${label_name}\n${key} ${red_rgb} ${green_rgb} ${blue_rgb} ${alpha}"
        echo -e $table_line >> label.txt
    done
fi

# threshold endpoint rois and make label file
for (( i=0; i<${#files[*]}; i++ ))
do
    key=$((i+1))
    metric_string="(x>${threshold})*${key}"
    label_name=${files[$i]%%.func.gii}
    out_name=${label_name}".label.gii"

    [ ! -f ${currentDir}/tmp/${files[$i]} ] && wb_command -metric-math `echo ${metric_string}` -var x ${topPath}/${files[$i]} ${currentDir}/tmp/${files[$i]} 
    [ ! -f ${currentDir}/tmp2/${out_name} ] && wb_command -metric-label-import ${currentDir}/tmp/${files[$i]} ${currentDir}/label.txt $currentDir/tmp2/${out_name} -discard-others -drop-unused-labels && wb_command -set-map-names $currentDir/tmp2/${out_name} -map 1 ${label_name}
done

# convert white surface from cortexmap
[ ! -f ./lh.white ] && mris_convert ${cortexmap}/surf/lh.white.surf.gii ./lh.white
[ ! -f ./rh.white ] && mris_convert ${cortexmap}/surf/rh.white.surf.gii ./rh.white
