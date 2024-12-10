#!/bin/bash
# ATACseq analysis: BAMs filtering
# Matthew Spriggs 10Dec2024

# PBS directives that you should review and change if needed
#-----------------------------------------------------------

#PBS -N s01_qc_and_preprocessing
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
echo "ATACseq analysis: BAMs filtering"
date
echo ""

# Load required modules
module load SAMtools/1.16.1-GCC-11.3.0

# Folders for input and output
base_folder="/mnt/beegfs/home/s430452/epigenetics"
samples_folder="${base_folder}/data/atac_seq" # contains samples file
raw_bam_folder="${base_folder}/results/s02_alignment" # contains raw bam files
filtered_bam_folder="${base_folder}/results/s03_filtering" # for results

# Remove results, if existed
rm -fr "${filtered_bam_folder}"

# Make output folder
mkdir -p "${filtered_bam_folder}"

# Read samples names
samples_file="${samples_folder}/samples.txt"
samples=$(awk 'NR>1 {print $1}' "${samples_file}")

# For each sample
for sample in ${samples}
do

  # Progress report to log
  echo "Filtering ${sample}"
  
  # Keep only reads aligned to canomical chromosmes, except for mitochondrial DNA.  
  # The mitochondrial DNA ("chrM") should be removed because it doesnt have histones, so is not relevant to ATAC-seq.  
  # The other removed reads could be aligned to unassigned or unplaced contigs (such as "chrUn" or "chr1_KI270706v1_random") etc.  
  # Such reads could not be interpreted here because the downstream scripts will only consider genes annotated to canonical chromosomes.     
  samtools view -@ 6 -h \
  "${raw_bam_folder}/${sample}_sort.bam" \
    chr1 chr2 chr3 chr4 chr5 chr6 chr7 chr8 chr9 chr10 chr11 chr12 chr13 \
    chr14 chr15 chr16 chr17 chr18 chr19 chr20 chr21 chr22 chrX chrY \
    -o "${filtered_bam_folder}/${sample}_chr.bam"
  
  # Index after filtering
  samtools index -@ 6 \
    "${filtered_bam_folder}/${sample}_chr.bam"

  # Keep only reads with mapping quality > 20
  samtools view -@ 6 -h -q 20 \
    "${filtered_bam_folder}/${sample}_chr.bam" \
    -o "${filtered_bam_folder}/${sample}_chr_q20.bam"
  
  # Index after filtering
  samtools index -@ 6 \
    "${filtered_bam_folder}/${sample}_chr_q20.bam"

  # Flagstat filtered bam
  samtools flagstat -@ 6 \
    "${filtered_bam_folder}/${sample}_chr_q20.bam" > \
    "${filtered_bam_folder}/${sample}_chr_q20.flagstat"

done # Next sample

# Completion message
echo ""
echo "Done"
date

# Clean-up
## =========================
rm $PBS_O_WORKDIR/$PBS_JOBID
