#!/usr/bin/env Rscript

args=commandArgs(trailingOnly=TRUE)

setwd("../notebooks")

rmarkdown::render(args[2], output_dir=args[1])
