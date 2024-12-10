#!/bin/bash
# ATACseq analysis: alignment
# Matthew Spriggs 10Dec2024
# PBS directives that you should review and change if needed
#-----------------------------------------------------------

#PBS -N s02_alignment
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
echo "ATACseq analysis: alignment"
date
echo ""

# Load required modules
module load Bowtie2/2.4.5-GCC-11.3.0 # A short reads aligner
module load SAMtools/1.16.1-GCC-11.3.0 # A toolset to work with for SAM/BAM files

# Folders for input and output
base_folder="/mnt/beegfs/home/s430452/epigenetics"
resources_folder="${base_folder}/resources" # contains Bowtie2 index
samples_folder="${base_folder}/data/atac_seq" # contains samples file
trimmed_fastq_folder="${base_folder}/results/s01_trimming" # contains trimmed fastq files
bam_folder="${base_folder}/results/s02_alignment" # to store results

# Remove results, if existed
rm -fr "${bam_folder}"

# Make output folder
mkdir -p "${bam_folder}"

# Bowtie2 index (built without sequences for alternate loci)
bowtie_index="${resources_folder}/bowtie2_index/GRCh38_noalt"

# Read samples names
samples_file="${samples_folder}/samples.txt"
samples=$(awk 'NR>1 {print $1}' "${samples_file}")

# For each sample
for sample in ${samples}
do

  # Progress report to log
  echo "Aligning ${sample}"
  
  # Align with Bowtie2: generates a sam file
  # (suffixes _val_1.fq and _val_2.fq are added by are added by trim-galore)
  bowtie2 -p 12 \
    -x "${bowtie_index}" \
    -1 "${trimmed_fastq_folder}/${sample}_chr5_R1_val_1.fq" \
    -2 "${trimmed_fastq_folder}/${sample}_chr5_R2_val_2.fq" \
    -S "${bam_folder}/${sample}.sam" \
    &> "${bam_folder}/${sample}.log"

  # Convert sam to bam: bam format is nearly always preferred to sam
  samtools view -@ 12 -b \
    "${bam_folder}/${sample}.sam" > \
    "${bam_folder}/${sample}.bam"

  # Sort: sorting is always needed before indexing
  samtools sort -@ 12 \
    "${bam_folder}/${sample}.bam" \
    -o "${bam_folder}/${sample}_sort.bam" 

  # Index: indexing is often needed for bam file processing 
  samtools index -@ 12 \
    "${bam_folder}/${sample}_sort.bam"

  # Stats for the bam file
  # It is always a good idea to do a quick check 
  # after each analysis step 
  samtools flagstat -@ 12 \
    "${bam_folder}/${sample}_sort.bam" > \
    "${bam_folder}/${sample}_sort.flagstat"

done # Next sample

# Completion message
echo ""
echo "Done"
date

# Clean-up (keep it at the end of the script)
## ==========================================
rm $PBS_O_WORKDIR/$PBS_JOBID
