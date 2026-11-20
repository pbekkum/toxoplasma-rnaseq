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
RELEASE=116
FA_URL=https://ftp.ensembl.org/pub/release-${RELEASE}/fasta/mus_musculus/dna
GTF_URL=https://ftp.ensembl.org/pub/release-${RELEASE}/gtf/mus_musculus
FA=Mus_musculus.GRCm39.dna.primary_assembly.fa.gz
GTF=Mus_musculus.GRCm39.${RELEASE}.gtf.gz

# Download the reference genome and its checksums
wget ${FA_URL}/${FA}
wget ${FA_URL}/CHECKSUMS -O CHECKSUMS_fasta

# Download the gene annotation and its checksums
wget ${GTF_URL}/${GTF}
wget ${GTF_URL}/CHECKSUMS -O CHECKSUMS_gtf

# Check the downloaded files against the Ensembl checksums
check_sum () {
  local file=$1 sumfile=$2
  local computed expected
  computed=$(sum "${file}" | awk '{print $1, $2}')
  expected=$(grep "${file}" "${sumfile}" | awk '{print $1, $2}')
  echo "${file}: computed=${computed} expected=${expected}"
  [ "${computed}" = "${expected}" ] || { echo "Checksum mismatch for ${file}"; exit 1; }
}

# Unzip the reference genome (keep the .gz)
gunzip -k "${FA}"

# Record the reference in the versions file
{
  echo "# $(date +%F) reference (Ensembl release ${RELEASE})"
  echo "${FA}"
  echo "${GTF}"
} >> "${VERSIONS}"