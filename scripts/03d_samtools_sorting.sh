#!/bin/bash

#SBATCH --account=class-467713-ws-2026
#SBATCH --partition=pibu_el8
#SBATCH --job-name=sort
#SBATCH --cpus-per-task=4
#SBATCH --mem=25000M
#SBATCH --time=01:00:00
#SBATCH --array=1-15
#SBATCH --output=logs/sorting/%x_%A_%a.out
#SBATCH --error=logs/sorting/%x_%A_%a.err

# Stop the script when errors occur
set -euo pipefail

# Set the variables
WORKDIR=/data/users/${USER}/toxoplasma_rnaseq
BAMDIR=${WORKDIR}/results/03_mapping/bam
SORTDIR=${WORKDIR}/results/03_mapping/sorted

# Create output folder
mkdir -p "${SORTDIR}"
cd "${WORKDIR}"

# Specify the container
CONTAINER=/containers/apptainer/hisat2_samtools_408dfd02f175cd88.sif

# Identify the sample
SAMPLE=$(sed -n "${SLURM_ARRAY_TASK_ID}p" samples.txt)

# Sort the BAM files and save the output
apptainer exec --bind /data ${CONTAINER} \
  samtools sort -@ 4 -m 4G \
  -o ${SORTDIR}/${SAMPLE}.sorted.bam \
  ${BAMDIR}/${SAMPLE}.bam