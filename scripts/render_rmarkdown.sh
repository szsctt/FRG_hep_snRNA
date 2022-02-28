#!/bin/bash

#SBATCH --job-name=liver_scRNA_rmarkdown
#SBATCH --nodes=1 --ntasks=1
#SBATCH --time=12:00:00
#SBATCH --mem=50gb
#SBATCH --output=../log/rmarkdown_%A_%a.out
#SBATCH --error=../log/rmarkdown_%A_%a.out
#SBATCH --array=1-5

set -euo pipefail

module load singularity/3.7.3

if [ ! -e scrna_rstudio.sif ]; then
	singularity pull ${PWD}/scrna_rstudio.sif docker://szsctt/r_scrna:5
	echo "finished pulling"
fi

mkdir -p rendered

RSCRIPT="singularity exec ../scripts/scrna_rstudio.sif ../scripts/render.R rendered"

if [[ ${SLURM_ARRAY_TASK_ID} -eq 1 ]]; then

eval "${RSCRIPT} aizarani.Rmd"

elif [[ ${SLURM_ARRAY_TASK_ID} -eq 2 ]]; then

eval "${RSCRIPT} aizarani_integration_hepatocytes.Rmd"

elif [[ ${SLURM_ARRAY_TASK_ID} -eq 3 ]]; then

eval "${RSCRIPT} integrated_pseudotime.Rmd"

elif [[ ${SLURM_ARRAY_TASK_ID} -eq 4 ]]; then

eval "${RSCRIPT} integration.Rmd"

elif [[ ${SLURM_ARRAY_TASK_ID} -eq 5 ]]; then

eval "${RSCRIPT} aizarani_integration_tests.Rmd"

fi
