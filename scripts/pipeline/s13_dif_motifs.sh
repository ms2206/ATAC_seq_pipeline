#!/bin/bash
# ATACseq analysis: detecting DNA motifs associated with differential summits
# This script takes about 1hr to run
# Matthew Spriggs 10Dec2024


# PBS directives that you should review and change if needed
#-----------------------------------------------------------

#PBS -N s13_dif_motifs
#PBS -l nodes=1:ncpus=12
#PBS -l walltime=03:00:00
#PBS -q three_hour
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
echo "ATACseq analysis: detecting DNA motifs associated with differential summits"
date
echo ""

# Load required module
module load Singularity/3.11.0-1-system
singularity --version

# Folders
base_folder="/mnt/beegfs/home/s430452/epigenetics"
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

# Clean-up (keep it at the end of the script)
## ==========================================
rm $PBS_O_WORKDIR/$PBS_JOBID
