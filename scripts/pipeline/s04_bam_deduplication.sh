#!/bin/bash
# ATACseq analysis: removing PCR duplicates
# Matthew Spriggs 10Dec2024

# PBS directives that you should review and change if needed
#-----------------------------------------------------------

#PBS -N s04_bam_deduplicated
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
echo "ATACseq analysis: removing PCR duplicates"
date
echo ""

# Load required modules
module load picard/3.0.0-Java-17 # stores path to picard jar in $EBROOTPICARD

# Folders for input and output
base_folder="/mnt/beegfs/home/s430452/epigenetics"
samples_folder="${base_folder}/data/atac_seq" # contains samples file
filtered_bam_folder="${base_folder}/results/s03_filtering" # contains filtered BAMs
dedup_bam_folder="${base_folder}/results/s04_deduplication" # for results

# Remove results, if existed
rm -fr "${dedup_bam_folder}"

# Make output folder
mkdir -p "${dedup_bam_folder}"

# Read samples names
samples_file="${samples_folder}/samples.txt"
samples=$(awk 'NR>1 {print $1}' "${samples_file}")

# For each sample
for sample in ${samples}
do

  # Progress report to log
  echo ""
  echo "Deduplicating ${sample}"
  echo ""

  # Run picard to de-duplicate
  # $EBROOTPICARD keeps the path to the picard jar file 
  java -jar "$EBROOTPICARD/picard.jar" MarkDuplicates \
    I="${filtered_bam_folder}/${sample}_chr_q20.bam" \
    O="${dedup_bam_folder}/${sample}_dedup.bam" \
    REMOVE_DUPLICATES=true \
    VALIDATION_STRINGENCY=LENIENT \
    M="${dedup_bam_folder}/${sample}_dedup.txt"

done # Next sample

# Completion message
echo ""
echo "Done"
date

# Clean-up (keep it at the end of the script)
## ==========================================
rm $PBS_O_WORKDIR/$PBS_JOBID

