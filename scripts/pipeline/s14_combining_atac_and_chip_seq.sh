#!/bin/bash
# ATACseq analysis: joint heatmaps of ATAC and ChIP seq
# Matthew Spriggs 11Dec2024


# PBS directives that you should review and change if needed
#-----------------------------------------------------------

#PBS -N s14_combining_atac_and_chip_seq
#PBS -l nodes=1:ncpus=6
#PBS -l walltime=00:30:00
#PBS -q half_hour
#PBS -m abe
#PBS -M matthew.spriggs.453@cranfield.ac.uk

# PBS directives and code that you should not change
#===================================================
#PBS -j oe
#PBS -v "CUDA_VISIBLE_DEVICES="
#PBS -W sandbox=PRIVATE
#PBS -k n
ln -s $PWD $PBS_O_WORKDIR/$PBS_JOBID
## Change to working directory
cd $PBS_O_WORKDIR
## Calculate number of CPUs and GPUs
export cpus=`cat $PBS_NODEFILE | wc -l`
## Load production modules
module use /apps2/modules/all
## =============


# Stop at runtime errors
set -e

# Start message
echo "ATACseq analysis: joint heatmaps of ATAC and ChIP seq"
date
echo ""

# Load required module
module load deepTools/3.5.2-foss-2022a

# Folders
base_folder="/mnt/beegfs/home/s430452/epigenetics"
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

# Clean-up (keep it at the end of the script)
## ==========================================
rm $PBS_O_WORKDIR/$PBS_JOBID
