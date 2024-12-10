#!/bin/bash
# ATACseq analysis: making BigWigs
# Alexey Larionov 25Nov2024

# Stop at runtime errors
set -e

# Start message
echo "ATACseq analysis: making BigWigs"
date
echo ""

# Load required modules
module load deepTools/3.5.2-foss-2022a # for bamCoverage

# Folders
base_folder="/mnt/beegfs/home/alexey.larionov/teaching_2024/epigenetics"
samples_folder="${base_folder}/data/atac_seq" # contains samples file
final_bams_folder="${base_folder}/results/s05_final_bams" # contains BAMs
bigwigs_folder="${base_folder}/results/s06_bigwigs" # for results

# Remove results, if existed
rm -fr "${bigwigs_folder}"

# Make output folder
mkdir -p "${bigwigs_folder}"

# Read samples names
samples_file="${samples_folder}/samples.txt"
samples=$(awk 'NR>1 {print $1}' "${samples_file}")

# For each sample
for sample in ${samples}
do

  # Progress report to log
  echo ""
  echo "Processing ${sample}"
  echo ""
  
  # Make bigwigs for the final bam
  bamCoverage --bam "${final_bams_folder}/${sample}_final.bam" \
    --outFileName "${bigwigs_folder}/${sample}.bw" \
    --outFileFormat bigwig \
    --binSize=10 \
    --normalizeUsing RPKM \
    --extendReads=200 \
    --numberOfProcessors 6

done # Next sample

# Make bigwig for the master bam
echo ""
echo "Merged"
echo ""

bamCoverage --bam "${final_bams_folder}/master.bam" \
  --outFileName "${bigwigs_folder}/master.bw" \
  --outFileFormat bigwig \
  --binSize=10 \
  --normalizeUsing RPKM \
  --extendReads=200 \
  --numberOfProcessors 6

# Completion message
echo ""
echo "Done"
date
