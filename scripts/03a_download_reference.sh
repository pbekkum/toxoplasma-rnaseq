#!/bin/bash

#SBATCH --account=class-467713-ws-2026
#SBATCH --partition=pibu_el8
#SBATCH --job-name=reference
#SBATCH --cpus-per-task=1
#SBATCH --mem=2000M
#SBATCH --time=01:00:00
#SBATCH --output=logs/reference/reference_%j.out
#SBATCH --error=logs/reference/reference_%j.err

# Stop the script when errors occur
set -euo pipefail

# Set the variables
WORKDIR=/data/users/${USER}/toxoplasma_rnaseq
REFDIR=${WORKDIR}/results/reference
VERSIONS=${WORKDIR}/software_versions.txt

# Create the output folder
mkdir -p "${REFDIR}"
cd "${REFDIR}"

# Define the download locations
FA_URL=https://ftp.ensembl.org/pub/current_fasta/mus_musculus/dna
GTF_URL=https://ftp.ensembl.org/pub/current_gtf/mus_musculus

# Download the reference genome and its checksums
wget ${FA_URL}/Mus_musculus.GRCm39.dna.primary_assembly.fa.gz
wget ${FA_URL}/CHECKSUMS -O CHECKSUMS_fasta

# Download the gene annotation and its checksums
wget -r -np -nd -A "Mus_musculus.GRCm39.*.gtf.gz" ${GTF_URL}/
wget ${GTF_URL}/CHECKSUMS -O CHECKSUMS_gtf

# Remove unnecessary annotation files
rm -f *abinitio* *chr_patch* *chr.gtf.gz

# Define the file names
FA=Mus_musculus.GRCm39.dna.primary_assembly.fa.gz
GTF=$(ls Mus_musculus.GRCm39.*.gtf.gz)

# Check the downloaded files
echo "--- Computed ---"
sum "${FA}"
sum "${GTF}"
echo "--- Expected ---"
grep "primary_assembly.fa.gz" CHECKSUMS_fasta
grep "${GTF}" CHECKSUMS_gtf

# Unzip the reference genome (keep the .gz)
gunzip -k "${FA}"

# Record the reference in the versions file
{
  echo "# $(date +%F) reference (Ensembl, ftp.ensembl.org/pub/current_*)"
  echo "${FA}"
  echo "${GTF}"
} >> "${VERSIONS}"