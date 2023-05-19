#!/bin/bash

# set -e 
# set -x

# configurable inputs
cortexmap=./cortexmap

# set up other variables
topPath=${cortexmap}/func/
currentDir=$(pwd)

# export subjects dir
export SUBJECTS_DIR=${currentDir}

# indentify files
files=(`find $topPath -type f -exec basename -a {} +`)

# convert white surface from cortexmap
[ ! -f ./lh.white ] && mris_convert ${cortexmap}/surf/lh.white.surf.gii ./lh.white
[ ! -f ./rh.white ] && mris_convert ${cortexmap}/surf/rh.white.surf.gii ./rh.white

# going to identify which are left hemisphere and which are right hemisphere
lh_files=""
rh_files=""

# loop through all files, look at the prefix (either lh or rh), and add to hemisphere strings list
for (( i=0; i<${#files[*]}; i++ ))
do
    hemisphere=${files[$i]%%.*}
    if [[ ${hemisphere} == 'lh' ]]; then
        lh_files=${lh_files}" "${currentDir}/tmp2/${files[$i]}
    else
        rh_files=${rh_files}" "${currentDir}/tmp2/${files[$i]}
    fi
done

# make easier to count/index
lh_files=($lh_files)
rh_files=($rh_files)

# loop through lh files and perform stats
for (( i=0; i<${#lh_files[*]}; i++ ))
do
    # set some useful variables
    label_name=${lh_files[$i]%%.func.gii}
    map_name=${label_name##${currentDir}/}
    out_name=${label_name}".label.gii"

    # convert to annotation
    [ ! -f ./output/label/${label_name##${currentDir}/tmp2/}.annot ] && mris_convert --annot ${out_name} ./lh.white ./output/label/${label_name##${currentDir}/tmp2/}.annot

    # perform anatomcial statistics. give 90% of final measures
    [ ! -f ./${label_name##${currentDir}/tmp2/}.txt ] && mris_anatomical_stats -a ./output/label/${label_name##${currentDir}/tmp2/}.annot -b output lh > ./${label_name##${currentDir}/tmp2/}.txt
    
    # compute curvature specific measures
    [ ! -f ./${label_name##${currentDir}/tmp2/}.curv.txt ] && mri_segstats --annot output lh ${label_name##${currentDir}/tmp2/lh.} --i ./output/surf/lh.curv --sum ./${label_name##${currentDir}/tmp2/}.curv.txt
done

# loop through rh files and perform stats
for (( i=0; i<${#rh_files[*]}; i++ ))
do
    # set some useful variables
    label_name=${rh_files[$i]%%.func.gii}
    map_name=${label_name##${currentDir}/}
    out_name=${label_name}".label.gii"

    # convert to annotation
    [ ! -f ./output/label/${label_name##${currentDir}/tmp2/}.annot ] &&  mris_convert --annot ${out_name} ./rh.white ./output/label/${label_name##${currentDir}/tmp2/}.annot

    # perform anatomcial statistics. give 90% of final measures
    [ ! -f ./${label_name##${currentDir}/tmp2/}.txt ] && mris_anatomical_stats -a ./output/label/${label_name##${currentDir}/tmp2/}.annot -b output rh > ./${label_name##${currentDir}/tmp2/}.txt
    
    # compute curvature specific measures
    [ ! -f ./${label_name##${currentDir}/tmp2/}.curv.txt ] && mri_segstats --annot output rh ${label_name##${currentDir}/tmp2/rh.} --i ./output/surf/rh.curv --sum ./${label_name##${currentDir}/tmp2/}.curv.txt
done
