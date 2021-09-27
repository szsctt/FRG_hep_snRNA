# human
#ssh pearcey-login wget -O $(pwd)/GCA_000001405.15_GRCh38_no_alt_analysis_set.fna.gz ftp://ftp.ncbi.nlm.nih.gov/genomes/all/GCA/000/001/405/GCA_000001405.15_GRCh38/seqs_for_alignment_pipelines.ucsc_ids/GCA_000001405.15_GRCh38_no_alt_analysis_set.fna.gz
#gunzip GCA_000001405.15_GRCh38_no_alt_analysis_set.fna.gz



ssh pearcey-login wget -O "${PWD}/GRCh38.primary_assembly.genome.fa.gz" http://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_human/release_38/GRCh38.primary_assembly.genome.fa.gz
gunzip GRCh38.primary_assembly.genome.fa.gz

ssh pearcey-login wget -O "${PWD}/human.gencode.v38.annotation.gtf.gz" http://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_human/release_38/gencode.v38.annotation.gtf.gz
gunzip human.gencode.v38.annotation.gtf.gz


# mouse

ssh pearcey-login wget -O "${PWD}/GRCm39.primary_assembly.genome.fa.gz" http://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_mouse/release_M27/GRCm39.primary_assembly.genome.fa.gz
gunzip GRCm39.primary_assembly.genome.fa.gz

ssh pearcey-login wget -O "${PWD}/mouse.gencode.vM27.annotation.gtf.gz" http://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_mouse/release_M27/gencode.vM27.annotation.gtf.gz
gunzip mouse.gencode.vM27.annotation.gtf.gz

