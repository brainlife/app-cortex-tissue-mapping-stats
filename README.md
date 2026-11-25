<h1 align="center">Cortex mapping statistics</h1>

<p align="center">
  Per-region summary tables of diffusion and anatomical measures on the cortical surface, for FreeSurfer parcels, tract endpoints or pRF-defined visual areas.
</p>

<p align="center">
  <a href="https://github.com/brainlife/abcd-spec"><img src="https://img.shields.io/badge/ABCD_Spec-v1.1-green.svg" alt="ABCD Spec v1.1"></a>
  <a href="https://doi.org/10.25663/brainlife.app.789"><img src="https://img.shields.io/badge/Brainlife-brainlife.app.789-blue.svg" alt="Run on brainlife.io"></a>
  <a href="LICENSE"><img src="https://img.shields.io/badge/License-MIT-lightgrey.svg" alt="MIT license"></a>
</p>

> 📍 **This branch, `updated-surface-dtype-anatomical-v1.2`, is the brainlife.io App Compute Anatomical Statistics** ([doi:10.25663/brainlife.app.789](https://doi.org/10.25663/brainlife.app.789)). The other Apps in this repository are listed under **Versions on brainlife.io** below.

## 🧠 At a glance

<!-- brainlife-app:begin (generated from the App manifest; edit the manifest, not this block) -->

> **Computes FreeSurfer anatomical statistics (thickness, surface area, volume, curvature) with mris_anatomical_stats for each parcel of the FreeSurfer aparc and an optional surface parcellation, and outputs merged CSVs.**

Runs FreeSurfer mris_anatomical_stats per hemisphere on the subject's aparc annotation and, if provided, on a surface parcellation converted onto the FreeSurfer white surface; the per-parcel tables are merged into one CSV (also saved as cortex.csv). Use it to obtain parcel-wise cortical morphometry for group analyses. Needs the FreeSurfer subject directory; a surface parcellation also needs its left and right white surfaces.

| | |
|---|---|
| 📥 **Inputs** | `neuro/surface/data` (optional) · `neuro/surface/vertices` (optional) · `neuro/freesurfer` |
| 📤 **Outputs** | `neuro/parc-stats` · `raw` |
| 🐳 **Container** | `brainlife/freesurfer:7.2.0` |
| ⚙️ **Resources** | 1 CPUs |
| 🔑 **Requires** | `FREESURFER_LICENSE` |
| 🔗 **Run it** | [doi.org/10.25663/brainlife.app.789](https://doi.org/10.25663/brainlife.app.789) |

#### 📥 Inputs

| Input | Datatype | Required | Description |
|---|---|---|---|
| `parc_surface` | `neuro/surface/data` | no | Optional surface parcellation (left and right .annot files with a label table) to summarise in addition to the FreeSurfer aparc. |
| `parc_surf_vertices` | `neuro/surface/vertices` | no | Optional left and right white surface meshes on which the surface parcellation is defined; required with parc_surface. |
| `freesurfer` | `neuro/freesurfer` | yes | FreeSurfer subject directory; supplies surfaces and aparc annotations. |

#### 📤 Outputs

| Output | Datatype | Description |
|---|---|---|
| `parc-stats` | `neuro/parc-stats` | Per-parcel anatomical statistics CSVs and a merged CSV (merged.csv, copied to cortex.csv). |
| `raw` | `raw` | Intermediate statistics files kept for debugging. |

<!-- brainlife-app:end -->

## 🏷️ Versions on brainlife.io

This repository hosts a family of Apps, each built from its own branch. All of them start from measures mapped to the cortical midthickness surface (a `neuro/cortexmap` dataset, for example from the cortex tissue mapping Apps) and/or a FreeSurfer output, and summarise them per region into `neuro/parc-stats` tables that can be used for group averages and machine learning analyses. They differ in the regions they use and the statistics they compute.

| App | FreeSurfer | Branch | Run it | Status |
|---|---|---|---|---|
| Compute summary statistics of visual regions binned by pRF - Benson14 - Anatomical Stats | 7.3.2 | [`benson-prf-endpoints-v1.3-anatomical`](https://github.com/brainlife/app-cortex-tissue-mapping-stats/tree/benson-prf-endpoints-v1.3-anatomical) | [doi:10.25663/brainlife.app.797](https://doi.org/10.25663/brainlife.app.797) | current |
| **Compute Anatomical Statistics** (this branch) | 7.2.0 | [`updated-surface-dtype-anatomical-v1.2`](https://github.com/brainlife/app-cortex-tissue-mapping-stats/tree/updated-surface-dtype-anatomical-v1.2) | [doi:10.25663/brainlife.app.789](https://doi.org/10.25663/brainlife.app.789) | available |
| Extract anatomical statistics inside data mapped to cortical surface | 7.3.2 | [`anatomical-stats-v1.2`](https://github.com/brainlife/app-cortex-tissue-mapping-stats/tree/anatomical-stats-v1.2) | [doi:10.25663/brainlife.app.782](https://doi.org/10.25663/brainlife.app.782) | available |
| Extract anatomical statistics inside tract endpoints mapped to cortical surface | 7.3.2 | [`endpoints-v1.2`](https://github.com/brainlife/app-cortex-tissue-mapping-stats/tree/endpoints-v1.2) | [doi:10.25663/brainlife.app.776](https://doi.org/10.25663/brainlife.app.776) | available |
| Compute summary statistics of diffusion measures mapped to cortical surface - Freesurfer computations | 7.2.0 | [`updated-surface-dtype-v1.2`](https://github.com/brainlife/app-cortex-tissue-mapping-stats/tree/updated-surface-dtype-v1.2) | [doi:10.25663/brainlife.app.656](https://doi.org/10.25663/brainlife.app.656) | available |
| Compute summary statistics of diffusion measures mapped to visual regions binned by eccentricity - Benson14 | 7.2.0 | [`benson14-prf-eccentricity-stats`](https://github.com/brainlife/app-cortex-tissue-mapping-stats/tree/benson14-prf-eccentricity-stats) | [doi:10.25663/brainlife.app.651](https://doi.org/10.25663/brainlife.app.651) | available |
| Compute summary statistics of diffusion measures mapped to cortical surface | | [`updated-surface-dtype-v1.1`](https://github.com/brainlife/app-cortex-tissue-mapping-stats/tree/updated-surface-dtype-v1.1) | [doi:10.25663/brainlife.app.483](https://doi.org/10.25663/brainlife.app.483) | available |
| Extract summary statistics of diffusion measures mapped to cortical surface inside tract endpoints | 7.0.0 | [`endpoints-v1.1`](https://github.com/brainlife/app-cortex-tissue-mapping-stats/tree/endpoints-v1.1) | [doi:10.25663/brainlife.app.437](https://doi.org/10.25663/brainlife.app.437) | available |
| Compute summary statistics of visual regions binned by pRF - Benson14 - Anatomical Stats | | [`benson-prf-endpoints-v1.2-anatomical`](https://github.com/brainlife/app-cortex-tissue-mapping-stats/tree/benson-prf-endpoints-v1.2-anatomical) | [doi:10.25663/brainlife.app.777](https://doi.org/10.25663/brainlife.app.777) | deprecated |
| Compute summary statistics of diffusion measures mapped to cortical surface - Freesurfer stats - Deprecated Surface | | [`v1.3`](https://github.com/brainlife/app-cortex-tissue-mapping-stats/tree/v1.3) | [doi:10.25663/brainlife.app.657](https://doi.org/10.25663/brainlife.app.657) | deprecated |
| Compute summary statistics of diffusion measures mapped to cortical surface - Deprecated Surface | | [`v1.1`](https://github.com/brainlife/app-cortex-tissue-mapping-stats/tree/v1.1) | [doi:10.25663/brainlife.app.383](https://doi.org/10.25663/brainlife.app.383) | deprecated |

What each group of Apps computes:

- **Diffusion measures per parcel** (`updated-surface-dtype-v1.1`, `updated-surface-dtype-v1.2`): minimum, maximum, mean, median, mode, standard deviation, sample standard deviation (n-1) and nonzero vertex count of each cortex-mapped measure in each parcel of a FreeSurfer aparc (default `aparc.a2009s`) or of an optional surface parcellation. The v1.1 App computes the statistics with Connectome Workbench; the v1.2 App uses FreeSurfer `mri_segstats` and adds `mris_anatomical_stats` measures.
- **Anatomical measures per parcel** (`updated-surface-dtype-anatomical-v1.2`): thickness, surface area, volume and curvature with `mris_anatomical_stats` for the FreeSurfer aparc and an optional surface parcellation.
- **Tract endpoints** (`endpoints-v1.1`, `endpoints-v1.2`): the same kind of statistics inside tract-endpoint regions projected to the cortical surface. v1.1 takes the endpoint ROIs and reports diffusion measures, thickness and volume; v1.2 thresholds the endpoint maps in the cortexmap (`threshold`) into labels and reports vertex count, surface area, gray matter volume, thickness and curvature.
- **Maps on the surface** (`anatomical-stats-v1.2`): anatomical statistics inside any thresholded maps carried by a cortexmap.
- **pRF visual areas** (`benson14-prf-eccentricity-stats`, `benson-prf-endpoints-v1.3-anatomical`): measures inside the Benson14 visual areas from a `neuro/prf` dataset. The eccentricity App bins the areas by the eccentricity ranges in `minDegree`/`maxDegree` and reports mean diffusion and anatomical measures; the current App reports vertex count, surface area, gray matter volume, thickness and curvature for each visual area, overall and restricted to the maps in the cortexmap.

## 🚀 Running the App

### ☁️ On brainlife.io

Open the App at [doi.org/10.25663/brainlife.app.797](https://doi.org/10.25663/brainlife.app.797), or another App from the table above, choose the inputs it asks for (a FreeSurfer output, a `neuro/cortexmap` dataset and, depending on the App, a `neuro/prf` dataset, tract-endpoint ROIs or a surface parcellation) and press **Execute**. The App writes a `neuro/parc-stats` dataset with the tables and a `raw` dataset with intermediate files; the current App also writes an updated `neuro/cortexmap` with the visual-area labels.

### 💻 Locally

You need [Singularity/Apptainer](https://apptainer.org/), [`jq`](https://jqlang.github.io/jq/) and a [FreeSurfer license](https://surfer.nmr.mgh.harvard.edu/registration.html). `main` runs each step in the `brainlife/freesurfer`, `brainlife/connectome_workbench` and `brainlife/freesurfer-stats` containers.

1. Clone this repository and check out the branch of the App you want, for example `git checkout benson-prf-endpoints-v1.3-anatomical`.
2. Create `config.json` with the paths to your inputs. For the current App:

   ```json
   {
       "cortexmap": "/input/cortexmap",
       "freesurfer": "/input/freesurfer/output",
       "prf_surfaces": "/input/prf/prf_surfaces",
       "_inputs": [
           { "id": "cortexmap", "meta": { "subject": "subj001", "session": "1" } }
       ]
   }
   ```

   The subject ID written into the tables is read from the `_inputs` list that brainlife.io adds to `config.json`, so keep it when running locally. Each branch includes a `config.json.sample` with the keys that App expects.

3. Export your FreeSurfer license and run the App:

   ```bash
   export FREESURFER_LICENSE="$(cat ~/freesurfer/license.txt)"
   ./main
   ```

### 🧪 Sample data

Download sample datasets from brainlife.io with the [brainlife CLI](https://github.com/brainlife/cli):

```bash
npm install -g brainlife
bl login
mkdir input
bl dataset download <dataset id>
```

## 📦 Outputs

```text
parc-stats/
└── parc-stats/     one csv per summary measure and parcellation
                    (current App: benson_varea_prf_anatomical.csv)
raw/                intermediate files (per-region text outputs, colour lookup table, …)
cortexmap/          current App only: the cortexmap with the visual-area labels added
```

## 🩺 Troubleshooting

- **`Please set FREESURFER_LICENSE in .bashrc`**: no FreeSurfer license in the environment. Set `FREESURFER_LICENSE` on the compute resource, or export it before running `./main`.
- **`something went wrong. check logs and derivatives`** or **`stats computations failed somewhere. please check logs and derivatives`**: the final csv was not produced. Check the job log and the intermediate files for the failing step.
- **Eccentricity App fails**: make sure `minDegree` and `maxDegree` have the same number of values.

## 📚 Citing

> [!TIP]
> If you use this App in your work, please cite the App, the software it builds on and brainlife.io (below). GitHub's **Cite this repository** button gives the App citation in APA and BibTeX.

If you use these Apps, please cite the work they build on and brainlife.io:

- Fukutomi H, et al. Neurite imaging reveals microstructural variations in human cerebral cortical gray matter. *NeuroImage* (2018). [doi:10.1016/j.neuroimage.2018.02.017](https://doi.org/10.1016/j.neuroimage.2018.02.017)
- Compute Anatomical Statistics. brainlife.io App. [doi:10.25663/brainlife.app.789](https://doi.org/10.25663/brainlife.app.789)
- Fischl. FreeSurfer. *NeuroImage* 62:774-781 (2012). [doi:10.1016/j.neuroimage.2012.01.021](https://doi.org/10.1016/j.neuroimage.2012.01.021)
- Marcus et al. Informatics and Data Mining Tools and Strategies for the Human Connectome Project. *Frontiers in Neuroinformatics* 5 (2011). [doi:10.3389/fninf.2011.00004](https://doi.org/10.3389/fninf.2011.00004)
- Hayashi S, Caron BA, Heinsfeld AS, et al. brainlife.io: a decentralized and open-source cloud platform to support neuroscience research. *Nature Methods* 21:809–813 (2024). [doi:10.1038/s41592-024-02237-2](https://doi.org/10.1038/s41592-024-02237-2)
- Avesani P, McPherson B, Hayashi S, et al. The open diffusion data derivatives, brain data upcycling via integrated publishing of derivatives and reproducible open cloud services. *Scientific Data* 6:69 (2019). [doi:10.1038/s41597-019-0073-y](https://doi.org/10.1038/s41597-019-0073-y)

## 👥 Authors

- Franco Pestilli (project director)
- Brad Caron

**Contributors:** Soichi Hayashi

## 💰 Funding

[![Wellcome-226486/Z/22/Z](https://img.shields.io/badge/Wellcome-226486%2FZ%2F22%2FZ-purple.svg)](https://wellcome.org/)
[![NIH-NINDS-U24NS140384](https://img.shields.io/badge/NIH_NINDS-U24NS140384-green.svg)](https://reporter.nih.gov/project-details/11261037)
[![NIH-NINDS-UM1NS132207](https://img.shields.io/badge/NIH_NINDS-UM1NS132207-green.svg)](https://reporter.nih.gov/project-details/11411328)
[![NIH-NIBIB-R01EB029272](https://img.shields.io/badge/NIH_NIBIB-R01EB029272-green.svg)](https://reporter.nih.gov/project-details/10262925)
[![NIH-NIBIB-R01EB030896](https://img.shields.io/badge/NIH_NIBIB-R01EB030896-green.svg)](https://reporter.nih.gov/project-details/10428625)
[![NIH-NIMH-R01MH126699](https://img.shields.io/badge/NIH_NIMH-R01MH126699-green.svg)](https://reporter.nih.gov/project-details/10460628)
[![NIH-NIDCD-R01DC020088](https://img.shields.io/badge/NIH_NIDCD-R01DC020088-green.svg)](https://reporter.nih.gov/project-details/11140284)
[![NSF-BCS-1734853](https://img.shields.io/badge/NSF_BCS-1734853-blue.svg)](https://www.nsf.gov/awardsearch/showAward?AWD_ID=1734853)
[![NSF-BCS-2203524](https://img.shields.io/badge/NSF_BCS-2203524-blue.svg)](https://www.nsf.gov/awardsearch/showAward?AWD_ID=2203524)
[![NSF-IIS-1636893](https://img.shields.io/badge/NSF_IIS-1636893-blue.svg)](https://www.nsf.gov/awardsearch/showAward?AWD_ID=1636893)
[![NSF-OAC-2148729](https://img.shields.io/badge/NSF_OAC-2148729-blue.svg)](https://www.nsf.gov/awardsearch/showAward?AWD_ID=2148729)
[![NSF-IIS-1912270](https://img.shields.io/badge/NSF_IIS-1912270-blue.svg)](https://www.nsf.gov/awardsearch/showAward?AWD_ID=1912270)
[![NSF-IIS-2148700](https://img.shields.io/badge/NSF_IIS-2148700-blue.svg)](https://www.nsf.gov/awardsearch/showAward?AWD_ID=2148700)
[![NSF-OAC-1916518](https://img.shields.io/badge/NSF_OAC-1916518-blue.svg)](https://www.nsf.gov/awardsearch/showAward?AWD_ID=1916518)

<sub>brainlife.io is publicly funded, and acknowledging that support helps keep it running. This App was developed with support from Wellcome, the U.S. National Institutes of Health (including the BRAIN Initiative BRAIN CONNECTS program: The Axonal Projectome EXchange, U24NS140384, and the Center for Mesoscale Connectomics, UM1NS132207) and the U.S. National Science Foundation.</sub>

## ⚖️ License

[MIT](LICENSE). FreeSurfer and Connectome Workbench are distributed under their own licenses.
