#!/bin/bash

set -euo pipefail

if [ ! -e scrna_rstudio.sif ]; then
	singularity pull ${PWD}/scrna_rstudio.sif docker://szsctt/r_scrna:5
	echo "finished pulling"
fi

cd ../notebooks
mkdir -p rendered

RSCRIPT="singularity exec -B$(realpath ..):$(realpath ..) ../scripts/scrna_rstudio.sif ../scripts/render.R rendered"


eval "${RSCRIPT} figure1.Rmd"

eval "${RSCRIPT} extra_figures_for_reviewers.Rmd"

eval "${RSCRIPT} vector.Rmd"

eval "${RSCRIPT} aizarani.Rmd"

eval "${RSCRIPT} integration.Rmd"

eval "${RSCRIPT} aizarani_integration_hepatocytes.Rmd"

eval "${RSCRIPT} integrated_pseudotime.Rmd"

eval "${RSCRIPT} aizarani_integration_tests.Rmd"


