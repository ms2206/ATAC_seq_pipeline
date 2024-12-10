#!/bin/bash
# ATACseq analysis: QC and Preprocessing
# Matthew Spriggs 10Dec2024

# PBS directives that you should review and change if needed
#-----------------------------------------------------------

#PBS -N s05_make_final_bams
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
echo "ATACseq analysis: make final BAMs"
date
echo ""

# Load required modules
module load SAMtools/1.16.1-GCC-11.3.0 # for sorting, indexing and merging BAMs

# Folders for input and output
base_folder="/mnt/beegfs/home/s430452/epigenetics/"
samples_folder="${base_folder}/data/atac_seq" # contains samples file
dedup_bam_folder="${base_folder}/results/s04_deduplication" # contains deduplicated bams
final_bam_folder="${base_folder}/results/s05_final_bams" # for results

# Remove results, if existed
rm -fr "${final_bam_folder}"

# Make output folder
mkdir -p "${final_bam_folder}"

# Read samples names
samples_file="${samples_folder}/samples.txt"
samples=$(awk 'NR>1 {print $1}' "${samples_file}")

# For each sample
for sample in ${samples}
do

  # Progress report to log
  echo "Sorting and indexing ${sample}"
  
  # Sort de-duplicated bam
  samtools sort -@ 6 \
    "${dedup_bam_folder}/${sample}_dedup.bam" \
    -o "${final_bam_folder}/${sample}_final.bam" 

  # Index final bam
  samtools index -@ 6 \
    "${final_bam_folder}/${sample}_final.bam"
  
  # Flagstat final bam
  samtools flagstat -@ 6 \
    "${final_bam_folder}/${sample}_final.bam" > \
    "${final_bam_folder}/${sample}_final.flagstat"

done # Next sample

# Merge final bams
echo "Merging bams"

# Get list of individual samples bams
samples_bams=$(ls ${final_bam_folder}/*_final.bam)

# Merge the individual bams
samtools merge -@ 6 \
  "${final_bam_folder}/master_before_sort.bam" \
  ${samples_bams}

# Sort merged bam
samtools sort -@ 6 \
  "${final_bam_folder}/master_before_sort.bam" \
  -o "${final_bam_folder}/master.bam" 

# Index merged bam
samtools index -@ 6 \
  "${final_bam_folder}/master.bam"

# Flagstat merged bam
samtools flagstat -@ 6 \
  "${final_bam_folder}/master.bam" > \
  "${final_bam_folder}/master.flagstat"

# Completion message
echo ""
echo "Done"
date

# Clean-up (keep it at the end of the script)
## ==========================================
rm $PBS_O_WORKDIR/$PBS_JOBID
