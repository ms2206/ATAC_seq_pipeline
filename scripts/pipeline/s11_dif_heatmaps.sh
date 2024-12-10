#!/bin/bash
# ATACseq analysis: heatmaps around summits in differential peaks
# Alexey Larionov 25Nov2024

# Stop at runtime errors
set -e

# Start message
echo "ATACseq analysis: heatmaps around summits in differential peaks"
date
echo ""

# Load required module
module load deepTools/3.5.2-foss-2022a

# Folders
base_folder="/mnt/beegfs/home/alexey.larionov/teaching_2024/epigenetics"
bigwigs_folder="${base_folder}/results/s06_bigwigs" # folder with BigWig files
dif_summits_folder="${base_folder}/results/s10_dif_summits" # folder with differential summits
dif_heatmaps_folder="${base_folder}/results/s11_dif_heatmaps" # for results

# Remove results, if existed
rm -fr "${dif_heatmaps_folder}"

# Make output folder
mkdir -p "${dif_heatmaps_folder}"

# Get names of the differentail summit files
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
  echo "Plotting ${type} peaks"

  # Compute matrix for heatmap (using deeptools computeMatrix)
  computeMatrix reference-point \
    -R "${summit_file}" \
    --skipZeros \
    -S "${bigwigs_folder}/ARID2wt.bw" \
       "${bigwigs_folder}/ARID2ko.bw" \
    -o "${dif_heatmaps_folder}/${type}.gz" \
    -b 5000 -a 5000 \
    --referencePoint center \
    -p 4 \
    --samplesLabel ARID2wt ARID2ko

  # Plot heatmap (using deeptools plotHeatmap)
  plotHeatmap \
    -m "${dif_heatmaps_folder}/${type}.gz" \
    --plotFileFormat pdf \
    -out "${dif_heatmaps_folder}/${type}.pdf" \
    --dpi 720 \
    --missingDataColor White \
    --colorMap Reds \
    --plotTitle "Peaks that are ${type} after KO" \
    --regionsLabel "atac" \
    --heatmapHeight 13

done # next sample

# Completion message
echo ""
echo "Done"
date
