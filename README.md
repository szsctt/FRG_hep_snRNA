## Info from Marti

Anyway, the nuclei samples are as follows, each as replicates. 

- Low engrafted hFRG 1 - #589 - Batch3/Rerun_of_Prev_batches/Rod_1 
- Low engrafted hFRG 2 - #602 - Batch3/Rerun_of_Prev_batches/Rod_2 
- Hepatocytes pellet #1 - Batch3/Rerun_of_Prev_batches/ROD_C2 
- Hepatocytes pellet #2 - Batch3/Rerun_of_Prev_batches/ROD_C3 
- Highly Engrafted hFRG 1 #265 - Batch3/Rerun_of_Prev_batches/ROD_C4 
- Highly Engrafted hFRG 2 #266 -Batch3/Rerun_of_Prev_batches/ROD_C5 
- #210 LK03 Cerulean + REDH Venus - Batch3/Rod_ASV_3_1 
- #233 LK03 Cerulean + REDH Venus - Batch3/Rod_ASV_3_2 
- #193 LK03 Venus + REDH Cerulean - Batch3/Rod_ASV_3_3 
- #224 LK03 Venus + REDH Cerulean - Batch3/Rod_ASV_3_4 

I attach the maps of the transgenes in case you need them for anything. 

Genes of interest related to zonation: 

- Glul 
- Cyp2e1 
- Ass1 
- Asl 
- Alb 
- Cyp2f2 
- Cyp1a2 
- Gstm3 
- Arg1 
- Pck1 
- Sdhd 

Genes of interest related to proliferation: 

- Axin2
- Lgr5

Genes of interest related to AAV transduction. I think here it would be cool if possible to check if they correlate with AAV transduction. Also cool to check if any other gene correlates with AAV transduction (not sure if possible). 

- AAVR (KIIAA0319L)
- GPR108

Genes related to response to AAV: 

- p53 
- p21
- IFI16 
- TLR2

And then AAV transduction / correlation with zonation. 

## Container

I tried installing Seurat and Monocle3 with conda, but ran into some issues.  Instead, I made a docker container with them inside, which seems to work (`container` has the `Dockerfile`).  I run this with `singularity` since it allows the user to be the same inside and outside the container, but it's probably possible to run with `Docker` as well.

To run the container, use the `scripts/run_rstudio` scripts.  The `run_rstudio.sh` script will work on `petrichor`, and the `run_rstudio_gcp.sh` script will work with a local installation of `singularity`. 

## Aizarani data

Download from the GEO with the script `download_GEO.sh`

## Notebooks

The analysis notebooks are in `notebooks`.  Paths in the notebooks are relative to this directory, so the `RStudio` project should be in that directory.  
