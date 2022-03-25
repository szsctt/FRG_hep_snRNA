#!/bin/bash

#SBATCH --job-name=liver_scRNA_rmarkdown
#SBATCH --nodes=1 --ntasks=1
#SBATCH --time=12:00:00
#SBATCH --mem=50gb
#SBATCH --output=../log/rmarkdown_%A_%a.out
#SBATCH --error=../log/rmarkdown_%A_%a.out
#SBATCH --array=1-5

set -euo pipefail

if [ ! -e scrna_rstudio.sif ]; then
	singularity pull ${PWD}/scrna_rstudio.sif docker://szsctt/r_scrna:5
	echo "finished pulling"
fi

cd ../notebooks
mkdir -p rendered

RSCRIPT="singularity exec ../scripts/scrna_rstudio.sif ../scripts/render.R rendered"


eval "${RSCRIPT} vector.Rmd"

eval "${RSCRIPT} aizarani.Rmd"

eval "${RSCRIPT} integration.Rmd"

eval "${RSCRIPT} figure1.Rmd"

eval "${RSCRIPT} aizarani_integration_hepatocytes.Rmd"

eval "${RSCRIPT} integrated_pseudotime.Rmd"

eval "${RSCRIPT} aizarani_integration_tests.Rmd"

