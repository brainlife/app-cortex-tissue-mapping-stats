#!/usr/bin/env python3

def create_brainlife_readme(bl_app_number,bl_app_doi,app_title,app_description,Authors,Contributors,References,json_structure,app_output,dependencies,output_dir):
	line1="[![Abcdspec-compliant](https://img.shields.io/badge/ABCD_Spec-v1.1-green.svg)](https://github.com/brain-life/abcd-spec)"
	line2="\n[![Run on Brainlife.io](https://img.shields.io/badge/Brainlife-brainlife.app.%s-blue.svg)](https://doi.org/%s)\n" %(str(bl_app_number),bl_app_doi)
	line3="\n# %s \n" %app_title
	line4="\nThis app will %s \n" %app_description
	line5="\n### Authors \n"
	line6="\n- %s \n" %Authors
	line7="\n### Contributors \n"
	line8="\n- %s \n" %Contributors
	line9="\n### Funding \n"
	line10="\n[![NSF-BCS-1734853](https://img.shields.io/badge/NSF_BCS-1734853-blue.svg)](https://nsf.gov/awardsearch/showAward?AWD_ID=1734853)"
	line11="\n[![NSF-BCS-1636893](https://img.shields.io/badge/NSF_BCS-1636893-blue.svg)](https://nsf.gov/awardsearch/showAward?AWD_ID=1636893)"
	line12="\n[![NSF-ACI-1916518](https://img.shields.io/badge/NSF_ACI-1916518-blue.svg)](https://nsf.gov/awardsearch/showAward?AWD_ID=1916518)"
	line13="\n[![NSF-IIS-1912270](https://img.shields.io/badge/NSF_IIS-1912270-blue.svg)](https://nsf.gov/awardsearch/showAward?AWD_ID=1912270)"
	line14="\n[![NIH-NIBIB-R01EB029272](https://img.shields.io/badge/NIH_NIBIB-R01EB029272-green.svg)](https://grantome.com/grant/NIH/R01-EB029272-01)\n"
	line15="\n### Citations \n"
	line16="\nPlease cite the following articles when publishing papers that used data, code or other resources created by the brainlife.io community. \n"
	line17="\n%s \n" %References
	line18="\n## Running the App \n"
	line19="\n### On Brainlife.io \n"
	line20="\nYou can submit this App online at [https://doi.org/%s](https://doi.org/%s) via the 'Execute' tab. \n" %(bl_app_doi,bl_app_doi)
	line21="\n### Running Locally (on your machine) \n"
	line22="\n1. git clone this repo \n"
	line23="\n2. Inside the cloned directory, create `config.json` with something like the following content with paths to your input files. \n"
	line24="\n```json \n"
	line25="%s \n" %json_structure
	line26="``` \n"
	line27="\n### Sample Datasets \n"
	line28="\nYou can download sample datasets from Brainlife using [Brainlife CLI](https://github.com/brain-life/cli). \n"
	line29="\n```"
	line30="\nnpm install -g brainlife \n"
	line31="bl login \n"
	line32="mkdir input \n"
	line33="bl dataset download \n"
	line34="``` \n"
	line35="\n3. Launch the App by executing 'main' \n"
	line36="\n```bash \n"
	line37="./main \n"
	line38="``` \n"
	line39="\n## Output \n"
	line40="\nThe main output of this App is %s \n" %app_output
	line41="\n#### Product.json \n"
	line42="\nThe secondary output of this app is `product.json`. This file allows web interfaces, DB and API calls on the results of the processing. \n"
	line43="\n### Dependencies \n"
	line44="\nThis App requires the following libraries when run locally. \n"
	line45="\n- %s" %dependencies

	filename='%s/README.md' %output_dir
	with open(filename,'w') as out:
	    out.writelines([line1, line2, line3, line4,line5,line6,line7,line8,line9,line10,line11,line12,line13,line14,line15,line16,line17,line18,line19,line20,line21,line22,line23,line24,line25,line26,line27,line28,line29,line30,line31,line32,line33,line34,line35,line36,line37,line38,line39,line40,line41,line42,line43,line44,line45])


# bl_app_number="1"                                                       
# bl_app_doi="https://www.brainlife.io"                                   
# app_title="dicks in mouths"                                             
# app_description="horse dick in tiny mouth"                              
# Authors="suck a dick (suckadick@suckadick.com)"                         
# Contributors="your mothers butt"                                        
# References="yeaaaaaaaah"                                                
# json_structure="{'ass': 'suck a dick'}"                                 
# dependencies="your mothers ass"                                        
# app_output="buttttts"
