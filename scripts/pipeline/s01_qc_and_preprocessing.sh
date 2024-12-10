#!/bin/bash
# ATACseq analysis: QC and Preprocessing
# Alexey Larionov 25Nov2024

# Stop at runtime errors
set -e

# Start message
echo "ATACseq analysis: QC and Preprocessing"
date
echo ""

# Load required module
# Trim Galore is a wrupper around Cutadapt and FastQC
module load Trim_Galore/0.6.10-GCCcore-11.3.0

# Folders for input and output
# should exist before running the script
base_folder="/mnt/beegfs/home/alexey.larionov/teaching_2024/epigenetics"
raw_fastq_folder="${base_folder}/data/atac_seq" # Contains source files
trimmed_fastq_folder="${base_folder}/results/s01_trimming" # for results

# Remove results, if existed
rm -fr "${trimmed_fastq_folder}"

# Make output folder
mkdir -p "${trimmed_fastq_folder}"

# --- FastQC and Multiqc before trimming ---#

fastq_files=$(ls ${raw_fastq_folder}/*.fastq)

fastqc \
  --threads 6 \
  --quiet \
  ${fastq_files}

# --- Trim_galore --- #
# Trim adapters and run FastQC after trimming

# Read samples file
samples_file="${raw_fastq_folder}/samples.txt"
samples=$(awk 'NR>1 {print $1}' "${samples_file}")

# For each sample
for sample in ${samples}
do

  # Progress report to log
  echo "Trimming ${sample}"
  echo ""
  
  # Run Trim Galore
  # If the adapters are not specified explicitly, 
  # the first 13 bp of the Illumina adapter 'AGATCGGAAGAGC' are used by default
  trim_galore \
    --cores 6 \
    --fastqc \
    --paired \
    --output_dir "${trimmed_fastq_folder}" \
    "${raw_fastq_folder}/${sample}_chr5_R1.fastq" \
    "${raw_fastq_folder}/${sample}_chr5_R2.fastq"

done # Next sample

# Unload Trim_Galore module: it is not fully compartible with MultiQC module
module unload Trim_Galore/0.6.10-GCCcore-11.3.0

# --- MultiQC --- #

# Load MultiQC module
module load MultiQC/1.14-foss-2022b

# MultiQC before trimming
cd "${raw_fastq_folder}"
multiqc .

# MultiQC after trimming
cd "${trimmed_fastq_folder}"
multiqc .

# Completion message
echo "Done"
date
