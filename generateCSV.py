#!/usr/bin/env python3

import json
import subprocess
import pandas as pd
import numpy as np
import os, sys, argparse
import glob

def generateSummaryCsvs(subjectID,anatomical_measures,diffusion_measures,columns,hemispheres,parcellations,outdir):

	merged_out = pd.DataFrame(columns=columns)
	
	for i in parcellations:
		out = pd.DataFrame(columns=columns)
		for h in hemispheres:
			# anatomical
			tmp = pd.read_csv('./'+i+'.'+h+'.anatomical.csv',header=None,names=['structureID']+anatomical_measures)
			if i != 'parc':
				tmp['structureID'] = [ h+'_'+f for f in tmp['structureID'] ]
			tmp['parcellationID'] = [ i for f in range(len(tmp['structureID'])) ]
			tmp['subjectID'] = [ str(subjectID) for f in range(len(tmp['structureID'])) ]
			tmp['hemisphere'] = [ h for f in range(len(tmp['structureID'])) ]

			# diffusion
			tmp_names = ['Index' ,'SegId', 'StructName', 'Mean', 'StdDev', 'Min', 'Max', 'Range']
			for m in diffusion_measures:
				tmp2 = pd.read_csv('./'+i+'.'+h+'.'+m+'.csv',header=None,names=tmp_names)
				tmp2 = tmp2[['StructName','Mean']]

				tmp2.rename(columns={'StructName': 'structureID', 'Mean': m},inplace=True)
				if i != 'parc':
					tmp2['structureID'] = [ h+'_'+f for f in tmp2['structureID'] ]
				tmp2['parcellationID'] = [ i for f in range(len(tmp2['structureID'])) ]
				tmp2['subjectID'] = [ str(subjectID) for f in range(len(tmp2['structureID'])) ]
				tmp2['hemisphere'] = [ h for f in range(len(tmp2['structureID'])) ]

				tmp = pd.merge(tmp, tmp2, on=["subjectID", "structureID", "hemisphere", "parcellationID"])
			out = out.append(tmp)

		# reset index
		out.reset_index(drop=True,inplace=True)
		
		# append to final merged data structure
		merged_out = merged_out.append(out)

		# save to csv
		out.to_csv(outdir+'/'+i+'.csv',index=False)
	
	# save to csv
	merged_out.to_csv(outdir+'/merged.csv',index=False)
	
	#return out

def main():

	print("setting up input parameters")
	#### load config ####
	with open('config.json','r') as config_f:
		config = json.load(config_f)

	#### parse inputs ####
	subjectID = config['_inputs'][0]['meta']['subject']

	# set "parcellations", i.e the eccentricity binnings
	parcellations = ['aparc','aparc.a2009s']
	if os.path.isfile('./aparc.DKTatlas.lh.anatomical.csv'):
		parcellations = parcellations + ['aparc.DKTatlas']

	if os.path.isfile('./lh.parc.annot'):
		parcellations = parcellations+['parc']

	# identify diffusion measures
	diffusion_measures = [  x.split(".")[4] for x in glob.glob("./aparc.lh.*.csv") if 'anatomical' not in x ]

	# anatomical measures
	anatomical_measures = ['number_of_vertices','surface_area_mm^2','gray_matter_volume_mm^3','thickness','thickness_std','mean_curv','gaus_curv','foldind','curvind']

	# set columns for pandas array
	columns = ['subjectID','structureID','parcellationID'] + diffusion_measures + anatomical_measures

	# set hemispheres
	hemispheres = ['lh','rh']

	# set outdir
	outdir = 'parc-stats/parc-stats'

	# generate output directory if not already there
	if os.path.isdir(outdir):
		print("directory exits")
	else:
		print("making output directory")
		os.mkdir(outdir)

	#### run command to generate csv structures ####
	print("generating csvs")
	generateSummaryCsvs(subjectID,anatomical_measures, diffusion_measures,columns,hemispheres,parcellations,outdir)

if __name__ == '__main__':
	main()
