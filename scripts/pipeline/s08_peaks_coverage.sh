#!/bin/bash
# ATACseq analysis: peaks coverage
# Matthew Spriggs 11Dec2024

 PBS directives that you should review and change if needed
#-----------------------------------------------------------

#PBS -N s08_peaks_coverage <--- CHANGE THIS LINE
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
echo "ATACseq analysis: peaks coverage"
date
echo ""

# Load required modules
module load Subread/2.0.4-GCC-11.3.0 # for featureCounts

# Folders
base_folder="/mnt/beegfs/home/s430452/epigenetics"
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

# Clean-up (keep it at the end of the script)
## ==========================================
rm $PBS_O_WORKDIR/$PBS_JOBID
