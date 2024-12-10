#!/bin/bash
# ATACseq analysis: peaks coverage
# Alexey Larionov 23Nov2024

# Stop at runtime errors
set -e

# Start message
echo "ATACseq analysis: peaks coverage"
date
echo ""

# Load required modules
module load Subread/2.0.4-GCC-11.3.0 # for featureCounts

# Folders
base_folder="/mnt/beegfs/home/alexey.larionov/teaching_2024/epigenetics"
samples_folder="${base_folder}/data/atac_seq" # contains samples file
final_bams_folder="${base_folder}/results/s05_final_bams" # contains  bams
peaks_folder="${base_folder}/results/s07_peaks" # contains peaks
counts_folder="${base_folder}/results/s08_counts" # for results

# Remove results, if existed
rm -fr "${counts_folder}"

# Make output folder
mkdir -p "${counts_folder}"

# Convert narrowPeak to SAF 
# SAF = Simplified Annotation Format, needed for featureCounts
# (Name Chr Start End Strand)
awk 'OFS="\t" {print $4, $1, $2, $3, "."}' \
  "${peaks_folder}/master_peaks_bl.narrowPeak" \
  > "${counts_folder}/master_peaks.saf"

# Get list of final bams for individual samples 
# (i.e. the files with suffix _final.bam)
sample_bams=$(ls ${final_bams_folder}/*final.bam)

# Run featureCounts to generate count matrix
# (counts over the master peaks using individual samples' bams)
featureCounts -p \
  -a "${counts_folder}/master_peaks.saf" \
  -F SAF \
  -o "${counts_folder}/master_peaks_counts.txt" \
  -T 6 \
  ${sample_bams}

# Completion message
echo ""
echo "Done"
date
