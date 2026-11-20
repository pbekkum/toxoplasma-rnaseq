#!/bin/bash

#SBATCH --account=class-467713-ws-2026
#SBATCH --partition=pibu_el8
#SBATCH --job-name=bam_index
#SBATCH --cpus-per-task=1
#SBATCH --mem=4000M
#SBATCH --time=01:00:00
#SBATCH --array=1-15
#SBATCH --output=logs/samtools_index/%x_%A_%a.out
#SBATCH --error=logs/samtools_index/%x_%A_%a.err

# Stop the script when errors occur
set -euo pipefail

# Set the variables
WORKDIR=/data/users/${USER}/toxoplasma_rnaseq
SORTDIR=${WORKDIR}/results/03_mapping/sorted

# Navigate to the project directory
cd "${WORKDIR}"

# Specify the container
CONTAINER=/containers/apptainer/hisat2_samtools_408dfd02f175cd88.sif

# Identify the sample
SAMPLE=$(sed -n "${SLURM_ARRAY_TASK_ID}p" samples.txt)

# Index the sorted BAM files and save the output
apptainer exec --bind /data ${CONTAINER} \
  samtools index \
  ${SORTDIR}/${SAMPLE}.sorted.bam