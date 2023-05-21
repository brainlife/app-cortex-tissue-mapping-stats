#!/usr/bin/env python3

import glob
import os,sys
import pandas as pd
import json
import numpy as np

## define functions
# load tmp stats data
def load_tmp_stats(filepath):

    return pd.read_table(filepath,header=None)

# build an empty dataframe
def build_zeros_dataframe(column_measures,struc_name):

    df = pd.DataFrame()
    df['structureID'] = [struc_name]
    df['segID'] = [1]
    df['Index'] = [2]
    for j in column_measures:
        if j not in ['structureID','segID','Index','nodeID']:
            df[j] = [0]

    return df

# clean up and remove nan columns. freesurfer file types are annoying
def clean_up_tmp_stats(df):

    df = df.iloc[-12:].reset_index(drop=True)
    df = df[0].apply(lambda x: " ".join(x.split())).str.split(' ',expand=True)
    
    return df

# check if the structure ID had empty vertices in the tmp stats. this can be done by checking values to see if struc name is there. if not, set everything to zero
def check_if_data_is_empty(df,column_names,struc_name):

    if df['structureID'].values[0] != struc_name:
        for i in column_names:
            df[i] = 0
            df['structureID'] = struc_name

    return df

# map input columns and rename
def modify_tmp_stats(df,column_names,struc_name,hemisphere):

    current_cols = df.columns.tolist()
    current_dict = dict(zip(current_cols,column_names+['structureID']))
    df = df.rename(columns=current_dict)
    df['structureID'] = [ hemisphere+'.'+f for f in df['structureID'] ]

    return df

def tmp_stats(filepath,column_names,struc_name,hemisphere,prf_measure,min_degree,max_degree):

    df = load_tmp_stats(filepath)
    df = clean_up_tmp_stats(df)
    df = modify_tmp_stats(df,column_names,struc_name,hemisphere)
    df['prf_measure'] = prf_measure
    df['min_degree'] = min_degree
    df['max_degree'] = max_degree

    return df

## main script
def main():

    # config for subject
    with open('config.json','r') as config_f:
        config = json.load(config_f)

    # grab subject ID
    subject = config['_inputs'][0]['meta']['subject']
    prf_measure = config['prf_measure']
    
    # make parc-stats output directories
    if not os.path.isdir('parc-stats'):
        os.mkdir('parc-stats')
        os.mkdir('parc-stats/parc-stats')

    # grab stats files
    files = glob.glob('*varea*.txt')

    # remove curvature files. will grab those via loop
    files = [ f for f in files if 'curv' not in f ]

    # set up measure column names for measures and curv_measures. these are hard coded. problematic?
    measures = ['number_of_vertices','surface_area_mm^2','gray_matter_volume_mm^3','avg_thickness_mm','std_thickness_mm','integrated_rectified_mean_curvature','integrated_rectified_gaussian_curvature','folding_index','intrinsic_curvature_index']
    curv_measures = ['Index','segID','number_of_vertices','area_mm^2','structureID','mean_curvature','std_curvature','min_curvature','max_curvature','range_curvature']

    # load lut to grab appropriate node ids
    labels = pd.read_table('lut.txt')
    labels = labels.rename(columns={"#No.": 'nodeID', "Label Name:": 'structureID'})

    # double the labels dataframe for each hemisphere
    lh_labels = labels.copy()
    rh_labels = labels.copy()

    lh_labels['structureID'] = [ 'lh.'+f for f in lh_labels['structureID'] ]
    rh_labels['structureID'] = [ 'rh.'+f for f in rh_labels['structureID'] ]

    # combine the labels dataframe
    labels = pd.concat([lh_labels,rh_labels]).reset_index(drop=True)

    # build dataframes
    # df = pd.DataFrame(columns=['structureID','nodeID']+measures)
    df = pd.DataFrame(columns=['structureID']+measures)
    df_curv = pd.DataFrame(columns=curv_measures)

    # loop through files and populate dataframes
    for i in range(len(files)):
        # identify structure name. example lh.track_rh.v3_to_lh.v3a_exact_1mm_LPI_FiberEndpoint.smooth_1
        struc_name = files[i].split('.txt')[0]

        # identify hemisphere
        hemisphere = struc_name.split('.')[0]

        # identify prf measure
        prf = struc_name.split('.')[-1]

        # identify min degree
        min_degree = prf.split('to')[0].split('polarAngle')[-1]

        # identify min degree
        max_degree = prf.split('to')[1]

        # concatenate mris_anatomical_stats output to dataframe
        df = pd.concat([df,tmp_stats(files[i],measures,struc_name,hemisphere,prf_measure,min_degree,max_degree)])

        # identify curvature file based on structure name
        curv_file = struc_name+'.curv.txt'

        # if the file does not exist, this means it didn't have vertices. build fake dataframe and append
        df_curv = pd.concat([df_curv,tmp_stats(curv_file,curv_measures,struc_name,hemisphere,prf_measure,min_degree,max_degree)])

    # reset index and remove unneccesary columns
    df = df.reset_index(drop=True)
    df_curv = df_curv[[ f for f in curv_measures+['prf_measure','min_degree','max_degree'] if f not in ['Index','segID']]].reset_index(drop=True)

    # merge anatomical stats and curvature specific stats
    df = df.merge(df_curv,on=['structureID','number_of_vertices','prf_measure','min_degree','max_degree'])

    # merge labels and sort by nodeID
    final = df.merge(labels,on='structureID').reset_index(drop=True)

    # add subjectID
    final['subjectID'] = [ subject for f in final['number_of_vertices']]

    # make pretty
    final = final[['subjectID','structureID','nodeID','prf_measure','min_degree','max_degree']+[ f for f in final.columns if f not in ['subjectID','structureID','nodeID','prf_measure','min_degree','max_degree']]]

    # output csv
    final.to_csv('parc-stats/parc-stats/benson_varea-'+prf_measure+'.csv',index=False)

if __name__ == "__main__":
    main()
