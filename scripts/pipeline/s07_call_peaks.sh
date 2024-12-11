#!/bin/bash
# ATACseq analysis: calling peaks
# Matthew Spriggs 11Dec2024


# PBS directives that you should review and change if needed
#-----------------------------------------------------------

#PBS -N s07_call_peaks
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
echo "ATACseq analysis: calling peaks"
date
echo ""

# Load required modules
module load MACS2/2.2.9.1-foss-2022b # for peak calling
module load BEDTools/2.30.0-GCC-12.2.0 # for removing blacklisted regions

# Folders
base_folder="/mnt/beegfs/home/s430452/epigenetics"
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

# Clean-up (keep it at the end of the script)
## ==========================================
rm $PBS_O_WORKDIR/$PBS_JOBID
