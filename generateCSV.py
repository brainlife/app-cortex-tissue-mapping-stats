#!/usr/bin/env python3

import json
import subprocess
import pandas as pd
import numpy as np
import os, sys, argparse
import glob

def outputProductJson(out_json_path,parcellations):
	
	out = {}
	out['meta'] = {}
	out['meta']['parcellations'] = parcellations
	
	with open(out_json_path,'w') as out_f:
		json.dump(out,out_f)

def identifyParcAtlas(provenance_data):
	atlas = ""
	for i in provenance_data["nodes"]:
		for j in i:
			if "atlas" in i[j]:
				if i[j]["atlas"]:
					atlas = atlas.join((i[j]["atlas"]))

	return atlas

def generateSummaryCsvs(subjectID,anatomical_measures,columns,hemispheres,parcellations,outdir,atlas_id):

	merged_out = pd.DataFrame(columns=columns)
	
	for i in parcellations:
		out = pd.DataFrame(columns=columns)
		for h in hemispheres:
			# anatomical
			tmp = pd.read_csv('./'+i+'.'+h+'.anatomical.csv',header=None,names=['structureID']+anatomical_measures)
			if i != 'parc':
				tmp['structureID'] = [ h+'_'+f for f in tmp['structureID'] ]
			if i == 'parc' and atlas_id:
				tmp['parcellationID'] = [ atlas_id for f in range(len(tmp['structureID'])) ]
			else:
				tmp['parcellationID'] = [ i for f in range(len(tmp['structureID'])) ]
			tmp['subjectID'] = [ str(subjectID) for f in range(len(tmp['structureID'])) ]
			tmp['hemisphere'] = [ h for f in range(len(tmp['structureID'])) ]

			# diffusion
			# tmp_names = ['Index' ,'SegId', 'StructName', 'Mean', 'StdDev', 'Min', 'Max', 'Range']
			# for m in diffusion_measures:
			# 	tmp2 = pd.read_csv('./'+i+'.'+h+'.'+m+'.csv',header=None,names=tmp_names)
			# 	tmp2 = tmp2[['StructName','Mean']]

			# 	tmp2.rename(columns={'StructName': 'structureID', 'Mean': m},inplace=True)
			# 	if i != 'parc':
			# 		tmp2['structureID'] = [ h+'_'+f for f in tmp2['structureID'] ]
			# 	if i == 'parc' and atlas_id:
			# 		tmp2['parcellationID'] = [ atlas_id for f in range(len(tmp2['structureID'])) ]
			# 	else:
			# 		tmp2['parcellationID'] = [ i for f in range(len(tmp2['structureID'])) ]

			# 	tmp2['subjectID'] = [ str(subjectID) for f in range(len(tmp2['structureID'])) ]
			# 	tmp2['hemisphere'] = [ h for f in range(len(tmp2['structureID'])) ]

			# 	tmp = pd.merge(tmp, tmp2, on=["subjectID", "structureID", "hemisphere", "parcellationID"])
			# out = out.append(tmp)

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
		# identify atlas ID
		with open('prov.json','r') as prov_f:
			prov = json.load(prov_f)
		
		atlas_id = identifyParcAtlas(prov)
	else:
		atlas_id = ''

	# identify diffusion measures
	# diffusion_measures = [  x.split(".")[3] for x in glob.glob("./aparc.lh.*.csv") if 'anatomical' not in x ]

	# anatomical measures
	anatomical_measures = ['number_of_vertices','surface_area_mm^2','gray_matter_volume_mm^3','thickness','thickness_std','mean_curv','gaus_curv','foldind','curvind']

	# set columns for pandas array
	columns = ['subjectID','structureID','parcellationID'] + anatomical_measures

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
	generateSummaryCsvs(subjectID,anatomical_measures ,columns,hemispheres,parcellations,outdir,atlas_id)
	
	#### output product.json with important information for reference dataset visualizater
	if atlas_id:
		parcellations = parcellations[:-1]+[atlas_id]
		
	outputProductJson('product.json',parcellations)

if __name__ == '__main__':
	main()
