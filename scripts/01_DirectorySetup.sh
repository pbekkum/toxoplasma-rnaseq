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
mkdir -p scripts logs 01_fastqc 02_reference 03_mapping 04_counts

# Create a symbolic link to the raw data
ln -sfn /data/courses/rnaseq_course/toxoplasma_de/reads_${TISSUE} raw_data