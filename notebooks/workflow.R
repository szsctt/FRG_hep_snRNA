

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


#import_one_without_mouse("high1")
