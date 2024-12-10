#!/bin/bash
# ATACseq analysis: joint heatmaps of ATAC and ChIP seq
# Alexey Larionov 25Nov2024

# Stop at runtime errors
set -e

# Start message
echo "ATACseq analysis: joint heatmaps of ATAC and ChIP seq"
date
echo ""

# Load required module
module load deepTools/3.5.2-foss-2022a

# Folders
base_folder="/mnt/beegfs/home/alexey.larionov/teaching_2024/epigenetics"
chipseq_bw_folder="${base_folder}/data/chip_seq" # folder with ChIPseq coverage data
atac_bw_folder="${base_folder}/results/s06_bigwigs" # folder with ATACseq coverage data
atac_summits_folder="${base_folder}/results/s07_peaks" # folder with ATACseq summits
joint_heatmaps_folder="${base_folder}/results/s14_joint_heatmaps" # for results

# Remove results, if existed
rm -fr "${joint_heatmaps_folder}"

# Make output folder
mkdir -p "${joint_heatmaps_folder}"

# Prepare data for heatmaps
computeMatrix reference-point \
-R "${atac_summits_folder}/master_summits_bl.bed" \
--skipZeros \
-S "${atac_bw_folder}/master.bw" \
   "${chipseq_bw_folder}/H3K4me3_chr5.bw" \
   "${chipseq_bw_folder}/H3K27ac_chr5.bw" \
   "${chipseq_bw_folder}/ARID2_chr5.bw" \
   "${chipseq_bw_folder}/FOSL2_chr5.bw" \
-o "${joint_heatmaps_folder}/joint_atac_chipseq.gz" \
-b 5000 -a 5000 \
--referencePoint center \
-p 4

# Plot heatmaps
plotHeatmap -m "${joint_heatmaps_folder}/joint_atac_chipseq.gz" \
--plotFileFormat pdf \
-out "${joint_heatmaps_folder}/joint_atac_chipseq.pdf" \
--dpi 720 \
--missingDataColor White \
--colorMap Reds \
--heatmapHeight 13 \
--samplesLabel ATAC H3K4me3 H3K27ac ARID2 FOSL2 \
--kmeans 3 \
--zMax 1500 800 1500 500 1000

# Completion message
echo ""
echo "Done"
date
