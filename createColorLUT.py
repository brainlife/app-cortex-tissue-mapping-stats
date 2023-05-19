#!/usr/bin/env python3

import json
import pandas as pd
import numpy as np

def createColorLUT(keyfile,outfile):
	
    # load key.txt file from parcellation datatype
    df = pd.read_table(keyfile,header=None)

    # reshape dataframe
    df = pd.DataFrame(df.values.reshape(-1,2),columns=['Label Name:','color'])

    # grab index numbers
    df['#No.'] = [ int(f.split(' ')[0]) for f in df['color'] ]

    # set r, g, b, and alpha
    df['R'] = [ int(f.split(' ')[1]) for f in df['color'] ]
    df['G'] = [ int(f.split(' ')[2]) for f in df['color'] ]
    df['B'] = [ int(f.split(' ')[3]) for f in df['color'] ]
    df['A'] = [ 0 for f in df['color'] ]

    # reorder columns
    df = df[["#No.",'Label Name:','R','G','B','A']]

    # write out colorlut file
    df.to_csv(outfile,sep='\t',index=False)

def main():

    # grab color lut table
    labelfile = 'label.txt'

    # outfile for color lut
    outfile = 'lut.txt'

    # create color lut
    createColorLUT(labelfile,outfile)

if __name__ == '__main__':
    main()