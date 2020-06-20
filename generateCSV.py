#!/usr/bin/env python3

import json
import subprocess
import pandas as pd
import numpy as np
import os, sys, argparse
import glob

def generateSummaryCsvs(subjectID,diffusion_measures,summary_measures,columns,hemispheres,parcellations,outdir):
	#### loop through summary measures and make csvs for each. these can be used in MLC analyses ####
	for parc in parcellations:
		print(parc)

		# identify structure names from files. because of medial wall in aparc.a2009s, have to do in this weird way
		if parc == 'aparc':
			structureList = [ x.split('/')[2].split('.shape.gii')[0] for x in glob.glob('./aparc-rois/*.aparc*') ]
		else:
			with open('parc.structurelist_lh.txt','r') as structures: 
				structuresList_lh = structures.read().split('\n')
				structuresList_lh = [ x for x in structuresList_lh if x ]

			with open('parc.structurelist_rh.txt','r') as structures: 
				structuresList_rh = structures.read().split('\n')
				structuresList_rh = [ x for x in structuresList_rh if x ]

			structureList = structuresList_lh + structuresList_rh
			print(structureList)

		# loop through summary statistic measures making one csv per parcellation and measure
		for measures in summary_measures:
			print(measures)

			# set up pandas dataframe
			df = pd.DataFrame([],columns=columns,dtype=object)
			df['subjectID'] = [ subjectID for x in range(len(structureList)) ]
			df['structureID'] = [ structureList[x] for x in range(len(structureList)) ]
			df['nodeID'] = [ 1 for x in range(len(structureList)) ]

			# loop through diffusion measures and read in diffusion measure data. each csv will contain all diffusion measures
			for metrics in diffusion_measures:
				print(metrics)
				# left hemisphere
				with open('./%s_%s_%s.%s.txt' %(parc,measures,hemispheres[0],metrics),'r') as data_f:
					if parc == 'aparc':
						data_lh = pd.read_csv(data_f,header=None)
					else:
						data_lh = data_f.read().split('\t')
						data_lh = [ x.split('\n')[0] for x in data_lh ]

				# right hemisphere
				with open('./%s_%s_%s.%s.txt' %(parc,measures,hemispheres[1],metrics),'r') as data_f:
					if parc == 'aparc':
						data_rh = pd.read_csv(data_f,header=None)
					else:
						data_rh = data_f.read().split('\t')
						data_rh = [ x.split('\n')[0] for x in data_rh ]

				# merge hemisphere data
				if parc =='aparc':
					data = data_lh[0].tolist() + data_rh[0].tolist()
				else:
					data = data_lh + data_rh
			
				# add to dataframe
				df[metrics] = data

				# sort dataframe by structureID
				df.sort_values(by=['structureID'],axis=0,ascending=True,inplace=True)

				# write out to csv
				df.to_csv('./%s/%s_%s.csv' %(outdir,parc,measures), index=False)

def main():

	print("setting up input parameters")
	#### load config ####
	with open('config.json','r') as config_f:
		config = json.load(config_f)

	#### parse inputs ####
	subjectID = config['_inputs'][0]['meta']['subject']
	nonFsurfParc = config['parc']

	#### set up other inputs ####
	# grab diffusion measures from file names
	diffusion_measures = [ x.split('.')[1] for x in glob.glob('aparc_MIN_lh.*.txt') ]

	# depending on what's in the array, rearrange in a specific order I like
	if all(x in diffusion_measures for x in ['ndi','fa']):
		diffusion_measures = ['ad','fa','md','rd','ndi','isovf','odi','snr']
	elif 'fa' in diffusion_measures:
		diffusion_measures = ['ad','fa','md','rd','snr']
	else:
		diffusion_measures = ['ndi','isovf','odi','snr']

	# summary statistics measures
	summary_measures = [ x.split('.')[0].split('aparc_')[1].split('_lh')[0] for x in glob.glob('aparc_*_lh.ad.txt') ]
	
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

	# set parcellations
	if nonFsurfParc == 'null':
		parcellations = ['aparc']
	else:
		parcellations = ['aparc','parc']

	#### run command to generate csv structures ####
	print("generating csvs")
	generateSummaryCsvs(subjectID,diffusion_measures,summary_measures,columns,hemispheres,parcellations,outdir)

if __name__ == '__main__':
	main()