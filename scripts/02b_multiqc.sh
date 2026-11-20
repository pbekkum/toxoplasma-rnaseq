#!/bin/bash

#SBATCH --account=class-467713-ws-2026
#SBATCH --partition=pibu_el8
#SBATCH --job-name=multiqc
#SBATCH --cpus-per-task=1
#SBATCH --mem=2000M
#SBATCH --time=00:30:00
#SBATCH --output=logs/multiqc/multiqc_%j.out
#SBATCH --error=logs/multiqc/multiqc_%j.err

# Stop the script when errors occur
set -euo pipefail

# Set the variables
WORKDIR=/data/users/${USER}/toxoplasma_rnaseq
INDIR=${WORKDIR}/results/02_quality_checks/fastqc
OUTDIR=${WORKDIR}/results/02_quality_checks/multiqc
CONTAINER=/containers/apptainer/multiqc-1.33.sif
VERSIONS=${WORKDIR}/software_versions.txt

# Create output folders
mkdir -p "${OUTDIR}"
cd "${WORKDIR}"

# Store software version and run
echo "# $(date +%F) multiqc ($(basename ${CONTAINER}))" >> "${VERSIONS}"
apptainer exec "${CONTAINER}" multiqc --version >> "${VERSIONS}"

apptainer exec --bind /data "${CONTAINER}" \
    multiqc \
        "${INDIR}" \
        --outdir "${OUTDIR}" \
        --filename multiqc_report_raw_reads \
        --force

echo "Done."