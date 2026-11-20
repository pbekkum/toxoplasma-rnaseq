#!/usr/bin/env bash

# Stop the script when errors occur
set -euo pipefail

# Set tissue to Lung
TISSUE="Lung"

# Create working directory 
WORKDIR=/data/users/pvbekkum/toxoplasma_rnaseq

mkdir -p "$WORKDIR"
cd "$WORKDIR"

# Create output folders, one per analysis step
mkdir -p results/02_quality_checks
mkdir -p results/03_mapping
mkdir -p results/04_gene_counting

mkdir -p scripts

mkdir -p logs/fastqc
mkdir -p logs/multiqc
mkdir -p logs/reference
mkdir -p logs/hisat2_index
mkdir -p logs/mapping
mkdir -p logs/sorting
mkdir -p logs/samtools_index
mkdir -p logs/featurecounts

# Create a symbolic link to the raw data
ln -sfn /data/courses/rnaseq_course/toxoplasma_de/reads_${TISSUE} raw_data