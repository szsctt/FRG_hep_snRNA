
source("workflow.R")

for (d in names(datasets)) {
  for (m in c(TRUE, FALSE)) {
    print(glue::glue("working on datset {d}, mouse {m}"))
    rmarkdown::render("single_sample.Rmd", 
                      params=list("include_mouse" = m, "dataset" = d),
                      output_file=glue::glue("../out/Seurat/single_datasets/{d}_mouse{m}.html"))
  }
}