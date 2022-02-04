#!/bin/bash
set -euo pipefail

mkdir -p ../data/GEO/GSE124395

cd ../data/GEO/GSE124395

wget ftp://ftp.ncbi.nlm.nih.gov/geo/series/GSE124nnn/GSE124395/suppl/GSE124395%5FFile%5FDescriptions%2Etxt%2Egz
wget ftp://ftp.ncbi.nlm.nih.gov/geo/series/GSE124nnn/GSE124395/suppl/GSE124395%5FNormalhumanlivercellatlasdata%2Etxt%2Egz
wget ftp://ftp.ncbi.nlm.nih.gov/geo/series/GSE124nnn/GSE124395/suppl/GSE124395%5FNormalhumanliverdata%2ERData%2Egz
wget ftp://ftp.ncbi.nlm.nih.gov/geo/series/GSE124nnn/GSE124395/suppl/GSE124395%5Fclusterpartition%2Etxt%2Egz

gunzip *
