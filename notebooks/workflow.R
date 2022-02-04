

#### import data and QC ####
data.dir <- "../data/reads/Chimera_Liver"
datasets <- list(
  "low1" = "Rod_1",
  "low2" = "Rod_2",
  "hep1" = "ROD_C2",
  "hep2" = "ROD_C3",
  "high1" = "ROD_C4",
  "high2" = "ROD_C5",
  "LK03C_REDHV1" = "Rod_ASV_3_1",
  "LK03C_REDHV2" = "Rod_ASV_3_2",  
  "LK03V_REDHC1" = "Rod_ASV_3_3",  
  "LK03V_REDHC2" = "Rod_ASV_3_4"
)

# function to import all data and apply QC (filter based on number of genes per cell and mitochondrial genes)
# but leave mouse cells and genes in

import_one <- function(name) {
  
  mat <- file.path(data.dir, datasets[[name]], "outs", "filtered_feature_bc_matrix")
  mat <- Seurat::Read10X(data.dir = mat)
  
  return(mat)
  
}

import_one_with_mouse <- function(name) {
  
  # import data
  mat <- import_one(name)
  
  cells <- Seurat::CreateSeuratObject(counts = mat,
                                         project = "liver",
                                         min.cells = 3,
                                         min.features = 2000)
  
  # filter on genes per cell
  cells <- subset(cells, subset = nFeature_RNA < 6000 & nFeature_RNA > 500)
  
  # filter on mitochondrial genes
  cells[['percent.mt.human']] <- Seurat::PercentageFeatureSet(cells, "^Homo.+MT-")
  cells[['percent.mt.mouse']] <- Seurat::PercentageFeatureSet(cells, "^Mus.+mt-")
  cells <- subset(cells, percent.mt.human < 0.5 & percent.mt.mouse < 0.5)
  
  return(cells)
  
}

import_with_mouse <- function() {
  
  data.obj <- list()
  for (d in names(datasets)) {
    data.obj[[d]] <- import_one_with_mouse(d)
  }
  
  return(data.obj)
  
} 


# function to retain only cells where the percentage of counts for genes matching regex (compared to total count for that cell) is over some fraction
remove_genes_regex_frac <- function(mat, regex, frac) {
  regex_genes <- stringr::str_detect(rownames(mat), regex)
  cell_totals <- colSums(mat)
  
  regex_genes_each_cell <- colSums(mat[regex_genes, ])
  
  percent_regex <- regex_genes_each_cell / cell_totals
  
  regex_cells <- names(percent_regex[percent_regex > frac])
  
  return(mat[,colnames(mat) %in% regex_cells])
}

# function to remove genes matching regex
remove_genes <- function(mat, regex) {
  return(
    mat[!stringr::str_detect(rownames(mat), regex),]
  )
}



import_one_without_mouse <- function(name) {
  
  # import data
  mat <- import_one(name)
  
  # remove cells with fewer than 85% human genes
  mat <- remove_genes_regex_frac(mat, "^Homo_w_AAV_", 0.85)
  # remove mouse genes
  mat <- remove_genes(mat, "^Mus")
  # rename human genes to remove 'Homo_w_AAV_"
  rownames(mat) <- stringr::str_replace(rownames(mat), "^Homo_w_AAV_", "")
  rownames(mat) <- stringr::str_replace(rownames(mat), "AAV-CERULEAN-BC-3", "CERULEAN")
  rownames(mat) <- stringr::str_replace(rownames(mat), "AAV-VENUS-BC-1", "VENUS")

  # convert to seurat object
  cells <- Seurat::CreateSeuratObject(counts = mat,
                                      project = "liver",
                                      min.cells = 3,
                                      min.features = 2000)  
  # filter on genes per cell
  cells <- subset(cells, subset = nFeature_RNA < 7000 & nFeature_RNA > 500)
  

  cells[['percent.mt']] <- Seurat::PercentageFeatureSet(cells, pattern="^MT-")
  cells <- subset(cells, subset = percent.mt < 0.3)
  
  return(cells)
  
}

import_without_mouse <- function() {
  
  data.obj <- list()
  for (d in names(datasets)) {
    data.obj[[d]] <- import_one_without_mouse(d)
  }
  
  return(data.obj)
  
} 

import_noMouse_merged <- function() {
  
  data.obj <- import_without_mouse()
  
  merged <- list(
    'hep' = merge(data.obj[['hep1']], data.obj[['hep2']]),
    'low' = merge(data.obj[['low1']], data.obj[['low2']]),
    'high' = merge(data.obj[['high1']], data.obj[['high2']]),
    'LK03C_REDHV' = merge(data.obj[['LK03C_REDHV1']], data.obj[['LK03C_REDHV2']]),
    'LK03V_REDHC' = merge(data.obj[['LK03V_REDHC1']], data.obj[['LK03V_REDHC2']])
  )
  
  return(merged)
}


import_aizarani <- function() {
  
  GEO <- readRDS("../data/GEO/GSE124395/GSE124395_Normalhumanliverdata.RData")

  aizarani <- CreateSeuratObject(GEO, project="Aizarani_Healthy", min.cells=3, min.features = 300)
  
  # get the cluster ids that correspond to each cell
  paper_clusters <- read.table("../data/GEO/GSE124395/GSE124395_clusterpartition.txt")
  
  # only keep cells which have a cluster assigned in this table
  aizarani[['in.paper.clusters']] <- case_when(
    colnames(aizarani) %in% rownames(paper_clusters) ~ TRUE,
    TRUE ~ FALSE
  )
  aizarani <- subset(aizarani, in.paper.clusters)
  
  # assign clusters from paper to metadata column
  paper_clusters_df <- tibble(
    cellname = rownames(paper_clusters),
    cluster = paper_clusters$sct.cpart
  )
  
  aizarani_cellnames <- tibble(cellname = colnames(aizarani)) %>% 
    left_join(paper_clusters_df, by="cellname") 
  
  aizarani[["paper.clusters"]] <- aizarani_cellnames$cluster
  
  aizarani <- NormalizeData(aizarani, normalization.method = "LogNormalize", scale.factor = 10000)
  
  aizarani <- FindVariableFeatures(aizarani, selection.method = "vst", nfeatures = 2000)
  
  all.genes <- rownames(aizarani)
  aizarani <- ScaleData (aizarani, features=all.genes)
  
  aizarani <- RunPCA(aizarani, features = VariableFeatures(object = aizarani))
  
  aizarani <- FindNeighbors(aizarani, dims = 1:13)

    aizarani <- FindClusters(aizarani, resolution = 0.5)
  
  aizarani<- RunUMAP(aizarani, dims = 1:30, reduction = "pca", return.model = TRUE)
  
  paper.cluster.names <- tibble(
    name = c("NK, NKT, T cells", "Kupffer cells", "NK, NKT, T cells", "EPCAM+ cells and cholangiocytes", "NK, NKT, T cells", "Kupffer cells", "EPCAM+ cells and cholangiocytes", "B cells", "Liver sinusoidal endothelial cells", "Macrovascular endothlial cells", "Hepatocytes", "NK, NKT, T cells", "Liver sinusoidal endothelial cells", "Hepatocytes", "Other endothelial cells", "Other", "Hepatocytes", "NK, NKT, T cells", "Other", "Liver sinusoidal endothelial cells", "Stellate cells and myofibroblasts", "B cells", "Kupffer cells", "EPCAM+ cells and cholangiocytes", "Kupffer cells", "Other endothelial cells", "Other", "NK, NKT, T cells", "Macrovascular endothlial cells", "Hepatocytes", "Kupffer cells", "NK, NKT, T cells", "Stellate cells and myofibroblasts", "B cells", "Other endothelial cells", "Other", "Other", "B cells", "Other"),
    cluster = seq(length(name))
  )
  
  paper_clusters_df %>% 
    count(cluster) %>% 
    left_join(paper.cluster.names, by="cluster") %>% 
    rename(n_cells = n)
  
  
  aizarani_cellnames <- aizarani_cellnames %>% 
    left_join(paper.cluster.names, by="cluster")
  
  aizarani[['paper.cluster.names']] <- aizarani_cellnames$name
  
  return(aizarani)
  
}


#import_one_without_mouse("high1")
