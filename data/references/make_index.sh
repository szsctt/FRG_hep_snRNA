#!/bin/bash
set -euo pipefail

module load singularity

if [ ! -e sargasso_1.sif ]; then
singularity pull docker://szsctt/sargasso:1
fi

mkdir -p star_hg38_index
srun --time 4:00:00 --mem 100gb -c6 \
singularity exec sargasso_1.sif \
	STAR --runThreadN 6 \
	--runMode genomeGenerate \
	--genomeDir star_hg38_index \
	--genomeFastaFiles GRCh38.primary_assembly.genome.fa \
	--sjdbGTFfile human.gencode.v38.annotation.gtf \
	--sjdbOverhang 99 
	
mkdir -p star_GRCm39_index
srun --time 4:00:00 --mem 100gb -c6 \
singularity exec sargasso_1.sif \
	STAR --runThreadN 6 \
	--runMode genomeGenerate \
	--genomeDir star_GRCm39_index \
	--genomeFastaFiles GRCm39.primary_assembly.genome.fa \
	--sjdbGTFfile mouse.gencode.vM27.annotation.gtf \
	--sjdbOverhang 99 
