

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
  
  # add numbers to cell barcodes to prevent conflicts after merging
  data.obj <- make_cell_barcodes_distinct(data.obj)
  
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
  
  # add numbers to cell barcodes to prevent conflicts after merging
  data.obj <- make_cell_barcodes_distinct(data.obj)
  
  return(data.obj)
  
} 

make_cell_barcodes_distinct <- function(data.obj) {
  # add numbers to cell barcodes to prevent conflicts after merging
  j <- 1
  for (dset in names(data.obj)) {
    data.obj[[dset]]  <- RenameCells(data.obj[[dset]], new.names = paste0(colnames(data.obj[[dset]]), glue::glue("_{j}")))
    j <- j + 1
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
    name = c("NK, NKT, T cells", "Kupffer cells", "NK, NKT, T cells", "EPCAM+ cells and cholangiocytes", "NK, NKT, T cells", "Kupffer cells", "EPCAM+ cells and cholangiocytes", "B cells", "Liver sinusoidal endothelial cells", "Macrovascular endothelial cells", "Hepatocytes", "NK, NKT, T cells", "Liver sinusoidal endothelial cells", "Hepatocytes", "Other endothelial cells", "Other", "Hepatocytes", "NK, NKT, T cells", "Other", "Liver sinusoidal endothelial cells", "Stellate cells and myofibroblasts", "B cells", "Kupffer cells", "EPCAM+ cells and cholangiocytes", "Kupffer cells", "Other endothelial cells", "Other", "NK, NKT, T cells", "Macrovascular endothelial cells", "Hepatocytes", "Kupffer cells", "NK, NKT, T cells", "Stellate cells and myofibroblasts", "B cells", "Other endothelial cells", "Other", "Other", "B cells", "Other"),
    cluster = seq(length(name))
  )
  
  paper_clusters_df %>% 
    count(cluster) %>% 
    left_join(paper.cluster.names, by="cluster") %>% 
    rename(n_cells = n)
  
  
  aizarani_cellnames <- aizarani_cellnames %>% 
    left_join(paper.cluster.names, by="cluster")
  
  aizarani[['paper.cluster.names']] <- aizarani_cellnames$name
  
  aizarani$cell.types <- case_when(
    aizarani$seurat_clusters %in% c(0, 6, 14) ~ "NK, NKT, T cells",
    aizarani$seurat_clusters == 1 ~ "Liver sinusoidal endothelial cells",
    aizarani$seurat_clusters %in% c(2, 13) ~ "EPCAM+ cells and cholangiocytes",
    aizarani$seurat_clusters %in% c(3, 5, 7, 9, 16) ~ "Hepatocytes",
    aizarani$seurat_clusters %in% c(4, 10) ~ "Kupffer cells",
    aizarani$seurat_clusters == 8 ~ "Macrovascular endothelial cells",
    aizarani$seurat_clusters %in% c(11, 12) ~ "B cells",
    aizarani$seurat_clusters == 15 ~ "Stellate cells and myofibroblasts"
  )
  
  return(aizarani)
  
}


integrated_with_aizarani <- function() {
  aizarani <- import_aizarani()
  merged <- import_noMouse_merged()
  
  mapHepQuery <- function(query_name, k.filter=200) {
    print(glue::glue("working on {query_name}"))
    query <- merged[[query_name]]
    
    query <- NormalizeData(query, normalization.method = "LogNormalize", scale.factor = 10000)
    query <- FindVariableFeatures(query, selection.method = "vst", nfeatures = 2000)
    anchors <-  FindTransferAnchors(reference=aizarani, query=query,
                                    dims = 1:30, reference.reduction = "pca",
                                    k.filter=k.filter)
    query <-  MapQuery(anchorset = anchors, 
                       reference=aizarani,
                       query=query, 
                       refdata = list(paper.cluster.names="paper.cluster.names",
                                      paper.cluster="paper.clusters",
                                      cell.type="cell.types",
                                      seurat.cluster="seurat_clusters"), 
                       reference.reduction="pca",
                       reduction.model = "umap")
    p <- DimPlot(query, reduction="ref.umap", group.by="predicted.paper.cluster.names") + ggtitle(glue::glue("{query_name}, k.filter = {k.filter}"))
    return(list(p, query))
  }
  
  return(list(
    "aizarani" = aizarani,
    "hep.filt.200" = mapHepQuery("hep", k.filter=200)[[2]],
    "low.filt.200" =  mapHepQuery("low", k.filter=200)[[2]],
    "high.filt.NA" = mapHepQuery("high", k.filter=NA)[[2]],
    "LK03C_REDHV.filt.NA" = mapHepQuery("LK03C_REDHV", k.filter=NA)[[2]],
    "LK03V_REDHC.filt.NA" =  mapHepQuery("LK03V_REDHC", k.filter=NA)[[2]]
  ))
}

#import_one_without_mouse("high1")

integrated_together_no_mouse <- function() {
  
  
  data.obj <- import_without_mouse()
  
  ## add column names for later
  for (i in seq_along(names(data.obj))) {
    name <- names(data.obj)[i]
    type <- stringr::str_replace(name, "\\d+$", "")
    data.obj[[name]]$dataset.ind <- rep(i, length(colnames(data.obj[[name]])))
    data.obj[[name]]$dataset.name <-  rep(name, length(colnames(data.obj[[name]])))
    data.obj[[name]]$dataset.type <- rep(type, length(colnames(data.obj[[name]])))
    
    data.obj[[name]] <- NormalizeData(data.obj[[name]], normalization.method = "LogNormalize", scale.factor = 10000)
    data.obj[[name]] <- FindVariableFeatures(data.obj[[name]], selection.method = "vst", nfeatures = 2000)
  }
  
  # do integration
  features <- SelectIntegrationFeatures(object.list = data.obj)
  anchors <- FindIntegrationAnchors(object.list = data.obj, anchor.features = features, dims=1:30)
  cells <- IntegrateData(anchorset = anchors, dims=1:30)
  DefaultAssay(cells) <- "integrated"
  
  # Run the standard workflow for visualization and clustering in the integrated data
  cells <- ScaleData(cells, verbose = FALSE)
  cells <- RunPCA(cells, npcs = 30, verbose = FALSE)
  cells <- RunUMAP(cells, dims = 1:30, reduction.name = "UMAP")
  cells <- FindNeighbors(cells, reduction = "pca", dims = 1:30)
  cells <- FindClusters(cells, resolution = 0.5)
  
  cells$cell.type <- case_when(
    cells$seurat_clusters == 0 ~ "Portal hepatoctyes (0)",
    cells$seurat_clusters == 1 ~ "Mid-zonal hepatocytes (1)",  
    cells$seurat_clusters == 2 ~ "Mid-zonal hepatocytes (2)",
    cells$seurat_clusters == 3 ~ "Central hepatocytes (3)",
    cells$seurat_clusters == 4 ~ "Portal hepatocytes (4)",
    cells$seurat_clusters == 5 ~ "Mid-zonal hepatocytes (5)",
    cells$seurat_clusters == 6 ~ "Endothelial cells (6)"
  )
  
  cells$cell.type.shorter <- case_when(
    cells$seurat_clusters == 0 ~ "Portal 0",
    cells$seurat_clusters == 1 ~ "Mid-zonal 1",  
    cells$seurat_clusters == 2 ~ "Mid-zonal 2",
    cells$seurat_clusters == 3 ~ "Central 3",
    cells$seurat_clusters == 4 ~ "Portal 4",
    cells$seurat_clusters == 5 ~ "Mid-zonal 5",
    cells$seurat_clusters == 6 ~ "Endothelial"
  )
  
  cells$cell.type.shortest <- case_when(
    cells$seurat_clusters == 0 ~ "Portal",
    cells$seurat_clusters == 1 ~ "Mid-zonal",  
    cells$seurat_clusters == 2 ~ "Mid-zonal",
    cells$seurat_clusters == 3 ~ "Central",
    cells$seurat_clusters == 4 ~ "Portal",
    cells$seurat_clusters == 5 ~ "Mid-zonal",
    cells$seurat_clusters == 6 ~ "Endothelial"
  )
  
  
  return(cells)
  
}

plot_feature <- function(cells.plot, feature_name) {
  # get list of plots for this feature
  plots <- FeaturePlot(cells.plot, split.by="dataset.type", features=feature_name, keep.scale="all", order=TRUE)
  
  max_expr <- max(cells.plot@assays$RNA[feature_name])
  min_expr <- min(cells.plot@assays$RNA[feature_name])
  
  # add custom titles
  plots[[1]] <- plots[[1]] + ggtitle("Pre-engraftment") +
    scale_color_gradientn(colors=CustomPalette(low="#d2d1d3ff",
                                               mid="#9871edff",
                                               high="#0902ffff",
                                               k=50), limits=c(min_expr,max_expr)) 
  plots[[2]] <- plots[[2]] + ggtitle("hFRG hepatocytes") +
    scale_color_gradientn(colors=CustomPalette(low="#d2d1d3ff",
                                               mid="#9871edff",
                                               high="#0902ffff",
                                               k=50), limits=c(min_expr,max_expr)) 
  
  plots
  
  # hack to get scale bar
  plots.legend <- cowplot::get_legend(FeaturePlot(cells.plot, features= feature_name) + 
                                        theme(legend.position = "bottom", legend.text = element_text(size=8)) )
  
  wrap_plots(plots.legend)
  
  layout <- "
AAA
AAA
AAA
AAA
AAA
AAA
AAA
AAA
AAA
AAA
AAA
#B#
"
  
  return(wrap_plots(plots, plots.legend, design=layout))
  
}
