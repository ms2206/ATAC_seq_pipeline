#!/bin/bash
# ATACseq analysis: detecting DNA motifs associated with differential summits
# This script takes about 1hr to run
# Alexey Larionov 25Nov2024

# Stop at runtime errors
set -e

# Start message
echo "ATACseq analysis: detecting DNA motifs associated with differential summits"
date
echo ""

# Load required module
module load Singularity/3.11.0-1-system
singularity --version

# Folders
base_folder="/mnt/beegfs/home/alexey.larionov/teaching_2024/epigenetics"
containers_folder="${base_folder}/containers" 
dif_summits_folder="${base_folder}/results/s10_dif_summits" # folder with differential summits
dif_motifs_folder="${base_folder}/results/s13_dif_motifs" # for results

# Remove results, if existed
rm -fr "${dif_motifs_folder}"

# Make output folder
mkdir -p "${dif_motifs_folder}"

# Sub-folder for internmediate files
preparsedDir=${dif_motifs_folder}/preparsed_dir

# Get names of the summit files in the folder
summit_files=$(ls ${dif_summits_folder}/*.bed)

# Loop through the summits bed files
# There are three types of summit files: up, down, and static summits
for summit_file in ${summit_files}
do

  # Extract the type of data (up, down, or static) from the file name
  # Example of a file name: .../master_summits_up.bed
  type="${summit_file#*_summits_}" # remove everything up to and including "_summits_" 
  type="${type%.bed}" # remove ".bed" from the end

  # Progress report to log
  echo "Processing ${type} summits"

  # Make output folder for the sample
  output_dir="${dif_motifs_folder}/$type"
  mkdir -p "${output_dir}"

  # Run homer in container
  singularity exec "${containers_folder}/homer_v4.11_hg38.sif" \
    findMotifsGenome.pl "${summit_file}" \
      hg38 \
      "${output_dir}" \
      -preparsedDir "${preparsedDir}" \
      -size 200 \
      -p 12

done # next sample

# Completion message
echo ""
echo "Done"
date
