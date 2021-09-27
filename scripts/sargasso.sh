#!/bin/bash
set -euo pipefail

module load singularity

cd ..

if [ ! -e sargasso_1.sif ]; then
singularity pull docker://szsctt/sargasso:1
fi

rm -rf out/sargasso/Batch1
mkdir -p out/sargasso

# batch 1 - create makefile
singularity exec sargasso_1.sif \
species_separator rnaseq \
    --reads-base-dir="${PWD}/data/reads/Batch1/FASTQ" \
    --best \
    --sambamba-sort-tmp-dir="${PWD}/out" \
    --num-threads 10 \
    "${PWD}/config/sargasso/test_batch1.txt" "${PWD}/out/sargasso/Batch1" \
    human "${PWD}/data/references/star_hg38_index" \
    mouse "${PWD}/data/references/star_GRCm39_index"
    
cd "${PWD}/out/sargasso/Batch1"

srun --time 24:00:00 --mem 100gb -c10 \
singularity exec -B$(realpath ../../../) \
../../../sargasso_1.sif \
make
