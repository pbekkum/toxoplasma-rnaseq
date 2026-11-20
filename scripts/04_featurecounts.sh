#!/usr/bin/env bash

#SBATCH --account=class-467713-ws-2026
#SBATCH --partition=pibu_el8
#SBATCH --job-name=featurecounts
#SBATCH --cpus-per-task=4
#SBATCH --mem=1000M
#SBATCH --time=02:00:00
#SBATCH --output=logs/featurecounts/featurecounts_%j.out
#SBATCH --error=logs/featurecounts/featurecounts_%j.err

# Stop the script when errors occur
set -euo pipefail

# Set the variables
WORKDIR=/data/users/${USER}/toxoplasma_rnaseq
BAM_DIR=${WORKDIR}/results/03_mapping/sorted                 
GTF=${WORKDIR}/results/reference/Mus_musculus.GRCm39.116.gtf.gz
OUT_DIR=${WORKDIR}/results/04_gene_counting
CONTAINER=/containers/apptainer/subread_2.0.6.sif
VERSIONS=${WORKDIR}/software_versions.txt

# Create output folder
mkdir -p "${OUT_DIR}"

# Navigate to the project directory
cd "${WORKDIR}"

# Collect all sorted BAM files 
BAMS=$(ls ${BAM_DIR}/*sorted.bam)
echo "Counting reads in the following BAM files:"
echo "${BAMS}"

# Record tool version for reproducibility
{
  echo "# $(date +%F) featureCounts ($(basename ${CONTAINER}))"
  apptainer exec --bind /data "${CONTAINER}" featureCounts -v 2>&1 | grep -v '^$'
} >> "${VERSIONS}"

# featureCounts options:
#   -T 4               threads (must match --cpus-per-task)
#   -p --countReadPairs  paired-end data: count fragments (read pairs), not single reads
#   -s 2               reverse-stranded library (RF), as specified in the course description
#   -t exon -g gene_id count reads overlapping exons, summarise per gene (defaults, made explicit)
#   -a                 annotation file
#   -o                 output counts table (a .summary file with assignment stats is written alongside)
apptainer exec --bind /data "${CONTAINER}" \
    featureCounts \
        -T 4 \
        -p --countReadPairs \
        -s 2 \
        -t exon \
        -g gene_id \
        -a "${GTF}" \
        -o "${OUT_DIR}/featurecounts_counts.txt" \
        ${BAMS}