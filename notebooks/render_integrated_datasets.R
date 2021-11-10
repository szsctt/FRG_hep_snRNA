
for (m in c(FALSE, TRUE)) {
    print(glue::glue("working on mouse {m}"))
    rmarkdown::render("integration.Rmd", 
                      params=list("include_mouse" = m),
                      output_file=glue::glue("../out/Seurat/integrated/integrated_mouse{m}.html"))
  }

