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
			with open('aparc_keys.txt') as aparc_keys:
				structureList = aparc_keys.read().split()
		else:
			with open('parc_keys.txt') as parc_keys:
				structureList = parc_keys.read().split()			
			# with open('parc.structurelist_lh.txt','r') as structures: 
			# 	structuresList_lh = structures.read().split('\n')
			# 	structuresList_lh = [ x for x in structuresList_lh if x ]

			# with open('parc.structurelist_rh.txt','r') as structures: 
			# 	structuresList_rh = structures.read().split('\n')
			# 	structuresList_rh = [ x for x in structuresList_rh if x ]

			#structureList = structuresList_lh + structuresList_rh
		print(structureList)

		# loop through summary statistic measures making one csv per parcellation and measure
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
				with open('./tmp/%s_%s_%s.%s.txt' %(parc,measures,hemispheres[0],metrics),'r') as data_f:
					#if parc == 'aparc':
					data_lh = pd.read_csv(data_f,header=None)
					#else:
						# data_lh = data_f.read().split('\t')
						# data_lh = [ x.split('\n')[0] for x in data_lh ]

				# right hemisphere
				with open('./tmp/%s_%s_%s.%s.txt' %(parc,measures,hemispheres[1],metrics),'r') as data_f:
					#if parc == 'aparc':
					data_rh = pd.read_csv(data_f,header=None)
					#else:
					#	data_rh = data_f.read().split('\t')
					#	data_rh = [ x.split('\n')[0] for x in data_rh ]

				# merge hemisphere data
				#if parc =='aparc':
				data = data_lh[0].tolist() + data_rh[0].tolist()
				# else:
				# 	data = data_lh + data_rh
			
				# add to dataframe
				df[metrics] = data
				
				# handle scaling issues
				if np.median(df[metrics].astype(np.float)) < 0.01:
					df[metrics] = df[metrics].astype(np.float) * 1000

			# sort dataframe by structureID
			#df.sort_values(by=['structureID'],axis=0,ascending=True,inplace=True)

			# write out to csv
			df.to_csv('./%s/%s_%s.csv' %(outdir,parc,measures), index=False)

def main():

	print("setting up input parameters")
	#### load config ####
	with open('config.json','r') as config_f:
		config = json.load(config_f)

	#### parse inputs ####
	subjectID = config['_inputs'][0]['meta']['subject']
  
	# set parcellations
	if 'lh_annot' in list(config.keys()):
		parcellations = ['aparc','parc']
	else:
		parcellations = ['aparc']

	#### set up other inputs ####
	# grab diffusion measures from file names
	diffusion_measures = [ x.split('.')[2] for x in glob.glob('./tmp/aparc_MIN_lh.*.txt') ]

	# depending on what's in the array, rearrange in a specific order I like
	if all(x in diffusion_measures for x in ['noddi_kappa','ga']):
		diffusion_measures = ['ad','fa','md','rd','ga','ak','mk','rk','ndi','isovf','odi','noddi_kappa','snr','volume','thickness']
	elif all(x in diffusion_measures for x in ['noddi_kappa','fa']):
		diffusion_measures = ['ad','fa','md','rd','ndi','isovf','odi','noddi_kappa','snr','volume','thickness']
	elif all(x in diffusion_measures for x in ['ndi','ga']):
		diffusion_measures = ['ad','fa','md','rd','ga','ak','mk','rk','ndi','isovf','odi','snr','volume','thickness']
	elif all(x in diffusion_measures for x in ['ndi','fa']):
		diffusion_measures = ['ad','fa','md','rd','ndi','isovf','odi','snr','volume','thickness']
	elif 'ga' in diffusion_measures:
		diffusion_measures = ['ad','fa','md','rd','ga','ak','mk','rk','snr','volume','thickness']
	elif 'fa' in diffusion_measures:
		diffusion_measures = ['ad','fa','md','rd','snr','volume','thickness']
	elif 'gmd' in diffusion_measures:
		diffusion_measures = ['gmd','snr','volume','thickness']
	elif 'noddi_kappa' in diffusion_measures:
		diffusion_measures = ['ndi','isovf','odi','noddi_kappa','snr','volume','thickness']
	else:
		diffusion_measures = ['ndi','isovf','odi','snr','volume','thickness']

	# summary statistics measures
	summary_measures = [ x.split('.')[1].split('aparc_')[1].split('_lh')[0] for x in glob.glob('./tmp/aparc_*_lh.%s.txt' %diffusion_measures[0]) ]
	
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
	generateSummaryCsvs(subjectID,diffusion_measures,summary_measures,columns,hemispheres,parcellations,outdir)

if __name__ == '__main__':
	main()
