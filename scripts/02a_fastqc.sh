#!/bin/bash

#SBATCH --account=class-467713-ws-2026
#SBATCH --partition=pibu_el8
#SBATCH --job-name=fastqc
#SBATCH --cpus-per-task=1
#SBATCH --mem=1000M
#SBATCH --time=01:00:00
#SBATCH --output=logs/fastqc/fastqc_%A_%a.out
#SBATCH --error=logs/fastqc/fastqc_%A_%a.err
#SBATCH --array=1-30

# Stop the script when errors occur
set -euo pipefail

# Set the variables
WORKDIR=/data/users/${USER}/toxoplasma_rnaseq
RAW=${WORKDIR}/raw_data
OUTDIR=${WORKDIR}/results/02_quality_checks/fastqc
CONTAINER=/containers/apptainer/fastqc-0.12.1.sif
VERSIONS=${WORKDIR}/software_versions.txt

# Create output folder
mkdir -p "${OUTDIR}"
cd "${WORKDIR}"

FILES=( $(ls -1 ${RAW}/*.fastq.gz) )
FILE=${FILES[$((SLURM_ARRAY_TASK_ID - 1))]}

# Which file task handles into the log
echo "Task ${SLURM_ARRAY_TASK_ID}: processing ${FILE}"

# Running FastQC inside the container

## Print timestamp into log
date

# Store the FastQC version into a software version txt file
if [ "${SLURM_ARRAY_TASK_ID}" -eq 1 ]; then
    echo "# $(date +%F) fastqc ($(basename ${CONTAINER}))" >> "${VERSIONS}"
    apptainer exec "${CONTAINER}" fastqc --version >> "${VERSIONS}"
fi

# Run command in the container
apptainer exec --bind /data "${CONTAINER}" \
    fastqc \
        --threads 1 \
        --outdir "${OUTDIR}" \
        "${FILE}"

date
echo "Done."