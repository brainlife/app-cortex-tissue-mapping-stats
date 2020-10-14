#!/usr/bin/env python3

import json
import subprocess
import pandas as pd
import numpy as np
import os, sys, argparse
import glob

def generateSummaryCsvs(subjectID,diffusion_measures,summary_measures,columns,hemispheres,outdir):

	# load structure list
	with open('endpoints_key.txt') as tract_keys:
		structureList = tract_keys.read().split()

	structureList = list(np.unique(structureList))
	print(structureList)

	# loop through summary statistic measures making one csv measure
	for measures in summary_measures:
		print(measures)

		# set up pandas dataframe
		df = pd.DataFrame([],columns=columns,dtype=object)
		df['subjectID'] = [ subjectID for x in range(len(structureList)) if not 'Medial_wall' in structureList[x] ]
		df['structureID'] = [ structureList[x] for x in range(len(structureList)) if not 'Medial_wall' in structureList[x] ]
		df['nodeID'] = [ 1 for x in range(len(structureList)) if not 'Medial_wall' in structureList[x] ]

		# loop through diffusion measures and read in diffusion measure data. each csv will contain all diffusion measures
		for metrics in diffusion_measures:
			print(metrics)
			# left hemisphere
			with open('./tmp/tracts_%s_%s.%s.txt' %(measures,hemispheres[0],metrics),'r') as data_f:
				data_lh = pd.read_csv(data_f,header=None)

			# right hemisphere
			with open('./tmp/tracts_%s_%s.%s.txt' %(measures,hemispheres[1],metrics),'r') as data_f:
				data_rh = pd.read_csv(data_f,header=None)

			# merge hemisphere data
			data = data_lh[0].tolist() + data_rh[0].tolist()
		
			# add to dataframe
			df[metrics] = data
			
			# handle scaling issues
			if np.median(df[metrics].astype(np.float)) < 0.01:
				df[metrics] = df[metrics].astype(np.float) * 1000

		# write out to csv
		df.to_csv('./%s/tracts_%s.csv' %(outdir,measures), index=False)

def main():

	print("setting up input parameters")
	#### load config ####
	with open('config.json','r') as config_f:
		config = json.load(config_f)

	#### parse inputs ####
	subjectID = config['_inputs'][0]['meta']['subject']

	#### set up other inputs ####
	# grab diffusion measures from file names
	diffusion_measures = [ x.split('.')[2] for x in glob.glob('./tmp/tracts_MIN_lh.*.txt') ]

	# depending on what's in the array, rearrange in a specific order I like
	diffusion_measures = ['volume','thickness']

	# summary statistics measures
	summary_measures = [ x.split('.')[1].split('tracts_')[1].split('_lh')[0] for x in glob.glob('./tmp/rois_*_lh.%s.txt' %diffusion_measures[0]) ]
	
	# set columns for pandas array
	columns = ['subjectID','structureID','nodeID'] + diffusion_measures
	
	# set hemispheres
	hemispheres = ['lh','rh']
	
	# set outdir
	outdir = 'parc-stats'
	
	# generate output directory if not already there
	if os.path.isdir(outdir):
		print("directory exits")
	else:
		print("making output directory")
		os.mkdir(outdir)

	#### run command to generate csv structures ####
	print("generating csvs")
	generateSummaryCsvs(subjectID,diffusion_measures,summary_measures,columns,hemispheres,outdir)

if __name__ == '__main__':
	main()
