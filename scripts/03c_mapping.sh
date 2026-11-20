#!/bin/bash

#SBATCH --account=class-467713-ws-2026
#SBATCH --partition=pibu_el8
#SBATCH --job-name=hisat2_map
#SBATCH --cpus-per-task=4
#SBATCH --mem=8000M
#SBATCH --time=02:00:00
#SBATCH --array=1-15
#SBATCH --output=logs/mapping/%x_%A_%a.out
#SBATCH --error=logs/mapping/%x_%A_%a.err

# Stop the script when errors occur
set -euo pipefail

# Set the variables
WORKDIR=/data/users/${USER}/toxoplasma_rnaseq
INDEX=${WORKDIR}/results/03_mapping/hisat2_index
BAMDIR=${WORKDIR}/results/03_mapping/bam
SUMMARYDIR=${WORKDIR}/results/03_mapping/hisat2_summaries

# Create output folders
mkdir -p "${BAMDIR}" "${SUMMARYDIR}"
cd "${WORKDIR}"

# Specify the container
CONTAINER=/containers/apptainer/hisat2_samtools_408dfd02f175cd88.sif

# Identify the sample
SAMPLE=$(sed -n "${SLURM_ARRAY_TASK_ID}p" samples.txt)

# Perform read alignment and convert the output
apptainer exec --bind /data ${CONTAINER} bash -c "
  set -euo pipefail
  hisat2 -p ${SLURM_CPUS_PER_TASK} \
    -x ${INDEX}/GRCm39 \
    -1 raw_data/${SAMPLE}_1.fastq.gz \
    -2 raw_data/${SAMPLE}_2.fastq.gz \
    --rna-strandness RF \
    2> ${SUMMARYDIR}/${SAMPLE}.hisat2_summary.txt \
  | samtools view -b -o ${BAMDIR}/${SAMPLE}.bam -
"