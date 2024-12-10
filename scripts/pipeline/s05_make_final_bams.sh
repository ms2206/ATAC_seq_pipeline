#!/bin/bash
# ATACseq analysis: make final BAMs
# Alexey Larionov 25Nov2024

# Stop at runtime errors
set -e

# Start message
echo "ATACseq analysis: make final BAMs"
date
echo ""

# Load required modules
module load SAMtools/1.16.1-GCC-11.3.0 # for sorting, indexing and merging BAMs

# Folders for input and output
base_folder="/mnt/beegfs/home/alexey.larionov/teaching_2024/epigenetics"
samples_folder="${base_folder}/data/atac_seq" # contains samples file
dedup_bam_folder="${base_folder}/results/s04_deduplication" # contains deduplicated bams
final_bam_folder="${base_folder}/results/s05_final_bams" # for results

# Remove results, if existed
rm -fr "${final_bam_folder}"

# Make output folder
mkdir -p "${final_bam_folder}"

# Read samples names
samples_file="${samples_folder}/samples.txt"
samples=$(awk 'NR>1 {print $1}' "${samples_file}")

# For each sample
for sample in ${samples}
do

  # Progress report to log
  echo "Sorting and indexing ${sample}"
  
  # Sort de-duplicated bam
  samtools sort -@ 6 \
    "${dedup_bam_folder}/${sample}_dedup.bam" \
    -o "${final_bam_folder}/${sample}_final.bam" 

  # Index final bam
  samtools index -@ 6 \
    "${final_bam_folder}/${sample}_final.bam"
  
  # Flagstat final bam
  samtools flagstat -@ 6 \
    "${final_bam_folder}/${sample}_final.bam" > \
    "${final_bam_folder}/${sample}_final.flagstat"

done # Next sample

# Merge final bams
echo "Merging bams"

# Get list of individual samples bams
samples_bams=$(ls ${final_bam_folder}/*_final.bam)

# Merge the individual bams
samtools merge -@ 6 \
  "${final_bam_folder}/master_before_sort.bam" \
  ${samples_bams}

# Sort merged bam
samtools sort -@ 6 \
  "${final_bam_folder}/master_before_sort.bam" \
  -o "${final_bam_folder}/master.bam" 

# Index merged bam
samtools index -@ 6 \
  "${final_bam_folder}/master.bam"

# Flagstat merged bam
samtools flagstat -@ 6 \
  "${final_bam_folder}/master.bam" > \
  "${final_bam_folder}/master.flagstat"

# Completion message
echo ""
echo "Done"
date
