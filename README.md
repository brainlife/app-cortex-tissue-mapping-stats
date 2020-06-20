[![Abcdspec-compliant](https://img.shields.io/badge/ABCD_Spec-v1.1-green.svg)](https://github.com/brain-life/abcd-spec)
[![Run on Brainlife.io](https://img.shields.io/badge/Brainlife-brainlife.app.383-blue.svg)](https://doi.org/https://doi.org/10.25663/brainlife.app.383)

# Compute summary statistics of diffusion measures mapped to cortical surface 

This app will compute multiple summary statistics from measures mapped to the cortical midthickness surface on a per-ROI basis. This app takes in a cortexmap datatype and an optional parcellation/surface datatype. This app will compute the following summary statistics: minimum, maximum, mean, median, mode, standard deviation, sample standard deviation (n-1), and nonzero vertex count. The app will output a csv for each summary measure summarizing the diffusion measures in each ROI parcellation. If no parcellation surface is inputted, the app will just compute stats from the labels file found in the cortexmap datatype (usually aparc.a2009s.labels.gii). These csvs can be used for computing group averages and for performing machine learning analyses. 

### Authors 

- Brad Caron (bacaron@iu.edu) 

### Contributors 

- Soichi Hayashi (hayashi@iu.edu)
Franco Pestilli (franpest@iu.edu) 

### Funding 

[![NSF-BCS-1734853](https://img.shields.io/badge/NSF_BCS-1734853-blue.svg)](https://nsf.gov/awardsearch/showAward?AWD_ID=1734853)
[![NSF-BCS-1636893](https://img.shields.io/badge/NSF_BCS-1636893-blue.svg)](https://nsf.gov/awardsearch/showAward?AWD_ID=1636893)
[![NSF-ACI-1916518](https://img.shields.io/badge/NSF_ACI-1916518-blue.svg)](https://nsf.gov/awardsearch/showAward?AWD_ID=1916518)
[![NSF-IIS-1912270](https://img.shields.io/badge/NSF_IIS-1912270-blue.svg)](https://nsf.gov/awardsearch/showAward?AWD_ID=1912270)
[![NIH-NIBIB-R01EB029272](https://img.shields.io/badge/NIH_NIBIB-R01EB029272-green.svg)](https://grantome.com/grant/NIH/R01-EB029272-01)

### Citations 

Please cite the following articles when publishing papers that used data, code or other resources created by the brainlife.io community. 

Fukutomi, H. et al. Neurite imaging reveals microstructural variations in human cerebral cortical gray matter. Neuroimage (2018). doi:10.1016/j.neuroimage.2018.02.017 

## Running the App 

### On Brainlife.io 

You can submit this App online at [https://doi.org/10.25663/brainlife.app.383](https://doi.org/https://doi.org/10.25663/brainlife.app.383) via the 'Execute' tab. 

### Running Locally (on your machine) 

1. git clone this repo 

2. Inside the cloned directory, create `config.json` with something like the following content with paths to your input files. 

```json 
{ 
  "cortexmap": "./inputdata/cortexmap/cortexmap"
} 
``` 

### Sample Datasets 

You can download sample datasets from Brainlife using [Brainlife CLI](https://github.com/brain-life/cli). 

```
npm install -g brainlife 
bl login 
mkdir input 
bl dataset download 
``` 

3. Launch the App by executing 'main' 

```bash 
./main 
``` 

## Output 

The main output is a folder called 'parc-stats' with csv's for each summary measure and parcellation inputted 

#### Product.json 

The secondary output of this app is `product.json`. This file allows web interfaces, DB and API calls on the results of the processing. 

### Dependencies 

This App requires the following libraries when run locally. 

- singularity: https://singularity.lbl.gov/
- FSL: https://hub.docker.com/r/brainlife/fsl/tags/5.0.9
- Freesurfer: https://hub.docker.com/r/brainlife/freesurfer/tags/6.0.0
- jsonlab: https://github.com/fangq/jsonlab.git
- python3: https://www.python.org/downloads/
- pandas: https://pandas.pydata.org/
- Connectome Workbench: https://hub.docker.com/r/brainlife/connectome_workbench
