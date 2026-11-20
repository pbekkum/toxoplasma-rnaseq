#!/bin/bash
#SBATCH --account=class-467713-ws-2026
#SBATCH --partition=pibu_el8
#SBATCH --job-name=hisat2_index
#SBATCH --cpus-per-task=1
#SBATCH --mem=8000M
#SBATCH --time=03:00:00
#SBATCH --output=/data/users/%u/toxoplasma_rnaseq/logs/hisat2_index/%x_%j.out
#SBATCH --error=/data/users/%u/toxoplasma_rnaseq/logs/hisat2_index/%x_%j.err

# Stop the script when errors occur
set -euo pipefail

# Set the variables
WORKDIR=/data/users/${USER}/toxoplasma_rnaseq
REFDIR=${WORKDIR}/results/reference
INDEXDIR=${WORKDIR}/results/03_mapping/hisat2_index
VERSIONS=${WORKDIR}/software_versions.txt
CONTAINER=/containers/apptainer/hisat2_samtools_408dfd02f175cd88.sif

# Create the output folder
mkdir -p "${INDEXDIR}"
cd "${WORKDIR}"

# Stop early if the genome is missing
[ -s "${REFDIR}/Mus_musculus.GRCm39.dna.primary_assembly.fa" ] || { echo "Genome fasta not found"; exit 1; }

# Record the software versions
{
  echo "# $(date +%F) hisat2 + samtools ($(basename ${CONTAINER}))"
  apptainer exec --bind /data ${CONTAINER} hisat2 --version | head -n1
  apptainer exec --bind /data ${CONTAINER} samtools --version | head -n1
} >> "${VERSIONS}"

# Build the HISAT2 index
apptainer exec --bind /data ${CONTAINER} \
  hisat2-build -p ${SLURM_CPUS_PER_TASK} \
  "${REFDIR}/Mus_musculus.GRCm39.dna.primary_assembly.fa" \
  "${INDEXDIR}/GRCm39"