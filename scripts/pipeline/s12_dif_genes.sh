#!/bin/bash
# ATACseq analysis: annotate differential summits with HOMER (including nearest gene)
# This script takes < 3 min to run
# Matthew Spriggs 11Dec2024

# Crescent2 script
# Note: this script should be run on a compute node
# qsub s12_dif_genes.sh

# PBS directives
#---------------

#PBS -N s12_dif_genes
#PBS -l nodes=1:ncpus=6
#PBS -l walltime=00:30:00
#PBS -q half_hour
#PBS -m abe
#PBS -M matthew.spriggs.452@cranfield.ac.uk

#===============
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
echo "ATACseq analysis: annotate differential summits with HOMER (including nearest gene)"
date
echo ""

# Load required module
module load Singularity/3.11.0-1-system
singularity --version

# Folders
base_folder="/mnt/beegfs/home/s430452/epigenetics"
containers_folder="${base_folder}/containers" # folder with HOMER Singularity container
dif_summits_folder="${base_folder}/results/s10_dif_summits" # folder with differential summits
dif_genes_folder="${base_folder}/results/s12_dif_genes" # for results

# Remove results, if existed
rm -fr "${dif_genes_folder}"

# Make output folder
mkdir -p "${dif_genes_folder}"

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
  echo "Annotating ${type} summits"

  # Run homer in container (annotate peaks)
  singularity exec "${containers_folder}/homer_v4.11_hg38.sif" \
    annotatePeaks.pl "${summit_file}" \
      hg38 \
      -size 200,200 \
      > "${dif_genes_folder}/${type}_annotated_summits.txt"

  # Extract gene names from the Homer annotations
  awk 'NR > 1 {print $16}' \
    "${dif_genes_folder}/${type}_annotated_summits.txt" \
    | sort | uniq > "${dif_genes_folder}/${type}_genes.txt"

done # next sample

# Combine changed genes
# (removing synonims in records like MIR548F-3|MIRN548F3|hsa-mir-548f-3)
echo "Merging Up- and Down- genes"

cat "${dif_genes_folder}/up_genes.txt" \
  "${dif_genes_folder}/down_genes.txt" \
  | sort | uniq | awk 'FS="|" {print $1}' \
  > "${dif_genes_folder}/changed_genes.txt"

# Completion message
echo ""
echo "Done"
date

# Clean-up
## =========================
rm $PBS_O_WORKDIR/$PBS_JOBID
