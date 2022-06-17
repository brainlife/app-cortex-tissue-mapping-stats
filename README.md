[![Abcdspec-compliant](https://img.shields.io/badge/ABCD_Spec-v1.1-green.svg)](https://github.com/brain-life/abcd-spec)
[![Run on Brainlife.io](https://img.shields.io/badge/Brainlife-brainlife.app.383-blue.svg)](https://doi.org/https://doi.org/10.25663/brainlife.app.383)

# Compute summary statistics of diffusion measures mapped to visual regions binned by eccentricity - Benson14

This app will compute the average diffusion metrics, and anatomical measures from Freesurfer including thickness, surface area, and volume, within the visual areas returned by the prf - Benson14 app. Will return a parc-stats datatype for each eccentricity-binned visual area parcellation. These csvs can be used for computing group averages and for performing machine learning analyses.

### Authors

- Brad Caron (bacaron@iu.edu)

### Contributors

- Soichi Hayashi (hayashi@iu.edu)
- Franco Pestilli (frakkopesto@gmail.com)

### Funding

[![NSF-BCS-1734853](https://img.shields.io/badge/NSF_BCS-1734853-blue.svg)](https://nsf.gov/awardsearch/showAward?AWD_ID=1734853)
[![NSF-BCS-1636893](https://img.shields.io/badge/NSF_BCS-1636893-blue.svg)](https://nsf.gov/awardsearch/showAward?AWD_ID=1636893)
[![NSF-ACI-1916518](https://img.shields.io/badge/NSF_ACI-1916518-blue.svg)](https://nsf.gov/awardsearch/showAward?AWD_ID=1916518)
[![NSF-IIS-1912270](https://img.shields.io/badge/NSF_IIS-1912270-blue.svg)](https://nsf.gov/awardsearch/showAward?AWD_ID=1912270)
[![NIH-NIBIB-R01EB029272](https://img.shields.io/badge/NIH_NIBIB-R01EB029272-green.svg)](https://grantome.com/grant/NIH/R01-EB029272-01)

### Citations

Please cite the following articles when publishing papers that used data, code or other resources created by the brainlife.io community.

Fukutomi, H. et al. Neurite imaging reveals microstructural variations in human cerebral cortical gray matter. Neuroimage (2018). doi:10.1016/j.neuroimage.2018.02.017

Avesani, P., McPherson, B., Hayashi, S. et al. The open diffusion data derivatives, brain data upcycling via integrated publishing of derivatives and reproducible open cloud services. Sci Data 6, 69 (2019). https://doi.org/10.1038/s41597-019-0073-y

Benson NC, Butt OH, Datta R, Radoeva PD, Brainard DH, Aguirre GK. The retinotopic organization of striate cortex is well predicted by surface topology.

Benson NC, Butt OH, Brainard DH, Aguirre GK. Correction of distortion in flattened representations of the cortical surface allows prediction of V1-V3 functional organization from anatomy. PLoS Computational Biology. 2014;10:e1003538. doi: 10.1371/journal.pcbi.1003538.

Benson NC, Winawer J. Bayesian analysis of retinotopic maps. Elife. 2018;7:e40224. Published 2018 Dec 6. doi:10.7554/eLife.40224

Avesani, P., McPherson, B., Hayashi, S. et al. The open diffusion data derivatives, brain data upcycling via integrated publishing of derivatives and reproducible open cloud services. Sci Data 6, 69 (2019). https://doi.org/10.1038/s41597-019-0073-y

## Running the App

### On Brainlife.io

You can submit this App online at [https://doi.org/10.25663/brainlife.app.383](https://doi.org/https://doi.org/10.25663/brainlife.app.383) via the 'Execute' tab.

### Running Locally (on your machine)

1. git clone this repo

2. Inside the cloned directory, create `config.json` with something like the following content with paths to your input files.

```json
{
  "cortexmap": "./inputdata/cortexmap",
  "freesurfer": "./inputdata/freesurfer/output",
  "prf_surfaces": "./inputdata/prf/prf_surfaces",
  "minDegree":  "0 7",
  "maxDegree":  "5 90",
  "_inputs": [
        {
            "id": "cortexmap",
            "meta": {
                "subject": "subj001",
                "session": "1"
                    }
        }
    ]
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
- Freesurfer: https://hub.docker.com/r/brainlife/freesurfer/tags/7.2.0
- jsonlab: https://github.com/fangq/jsonlab.git
- python3: https://www.python.org/downloads/
- pandas: https://pandas.pydata.org/
- Connectome Workbench: https://hub.docker.com/r/brainlife/connectome_workbench
