#!/bin/bash
# ATACseq analysis: heatmaps around summits in differential peaks
# Matthew Spriggs 11Dec2024


# PBS directives that you should review and change if needed
#-----------------------------------------------------------

#PBS -N s11_diff_headmaps
#PBS -l nodes=1:ncpus=6
#PBS -l walltime=00:30:00
#PBS -q half_hour
#PBS -m abe
#PBS -M matthew.spriggs.452@cranfield.ac.uk

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
echo "ATACseq analysis: heatmaps around summits in differential peaks"
date
echo ""

# Load required module
module load deepTools/3.5.2-foss-2022a

# Folders
base_folder="/mnt/beegfs/home/s430452/epigenetics"
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


# Clean-up (keep it at the end of the script)
## ==========================================
rm $PBS_O_WORKDIR/$PBS_JOBID
