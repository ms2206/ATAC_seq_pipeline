#!/bin/bash
# ATACseq analysis: calling peaks
# Alexey Larionov 25Nov2024

# Stop at runtime errors
set -e

# Start message
echo "ATACseq analysis: calling peaks"
date
echo ""

# Load required modules
module load MACS2/2.2.9.1-foss-2022b # for peak calling
module load BEDTools/2.30.0-GCC-12.2.0 # for removing blacklisted regions

# Folders
base_folder="/mnt/beegfs/home/alexey.larionov/teaching_2024/epigenetics"
resources_folder="${base_folder}/resources" # contains blacklisted regions
samples_folder="${base_folder}/data/atac_seq" # contains samples file
final_bams_folder="${base_folder}/results/s05_final_bams" # contains master bam file
peaks_folder="${base_folder}/results/s07_peaks" # for results

# Remove results, if existed
rm -fr "${peaks_folder}"

# Make output folder
mkdir -p "${peaks_folder}"

# --- Call peaks in the atac-seq master bam file --- #
echo "Caling peaks"

# Run macs2 to call peaks
macs2 callpeak --nomodel \
  -t "${final_bams_folder}/master.bam" \
  --outdir "${peaks_folder}" \
  -n master \
  -f BAMPE \
  -g hs \
  --keep-dup all \
  &> "${peaks_folder}/master_macs2.log"

# --- Remove blacklisted regions --- #
echo "Removing blacklisted regions"

# Blacklisted regions
bl_regions="${resources_folder}/hg38-blacklist.bed"

# Remove blacklisted regions from narrowPeak file
bedtools intersect \
  -a "${peaks_folder}/master_peaks.narrowPeak" \
  -b "${bl_regions}" \
  -v \
  > "${peaks_folder}/master_peaks_bl.narrowPeak"

# Synchronise summits file with the peaks file w/o blacklisted regions
# Note that in both input files the peak name is in the 4th column
awk 'FNR==NR {a[$4]; next} $4 in a' \
  "${peaks_folder}/master_peaks_bl.narrowPeak" \
  "${peaks_folder}/master_summits.bed" \
  > "${peaks_folder}/master_summits_bl.bed"

# Completion message
echo ""
echo "Done"
date
