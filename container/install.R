#!/usr/bin/env R

install.packages(c("cowplot", "writexl", "wesanderson", "ggrepel", "DT", "devtools", "sf", "Seurat", "markdown", "rmarkdown", "plotly", "remotes", "R.utils", "ggplotify"))

if (!requireNamespace("BiocManager", quietly = TRUE))
    install.packages("BiocManager")

BiocManager::install(version = "3.13", ask=FALSE)

BiocManager::install(c("BiocGenerics", "DelayedArray", "DelayedMatrixStats", "limma", "S4Vectors", "SingleCellExperiment", "SummarizedExperiment", "batchelor", "Matrix.utils", "multtest"))

install.packages('metap')

devtools::install_github("cole-trapnell-lab/leidenbase")

devtools::install_github("cole-trapnell-lab/monocle3")

remotes::install_github('satijalab/seurat-wrappers')
