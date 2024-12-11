#!/bin/bash
# ATACseq analysis: making BigWigs
# Matthew Spriggs 10Dec2024

# PBS directives that you should review and change if needed
#-----------------------------------------------------------

#PBS -N s06_make_bigwigs
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
echo "ATACseq analysis: making BigWigs"
date
echo ""

# Load required modules
module load deepTools/3.5.2-foss-2022a # for bamCoverage

# Folders
base_folder="/mnt/beegfs/home/s430452/epigenetics"
samples_folder="${base_folder}/data/atac_seq" # contains samples file
final_bams_folder="${base_folder}/results/s05_final_bams" # contains BAMs
bigwigs_folder="${base_folder}/results/s06_bigwigs" # for results

# Remove results, if existed
rm -fr "${bigwigs_folder}"

# Make output folder
mkdir -p "${bigwigs_folder}"

# Read samples names
samples_file="${samples_folder}/samples.txt"
samples=$(awk 'NR>1 {print $1}' "${samples_file}")

# For each sample
for sample in ${samples}
do

  # Progress report to log
  echo ""
  echo "Processing ${sample}"
  echo ""
  
  # Make bigwigs for the final bam
  bamCoverage --bam "${final_bams_folder}/${sample}_final.bam" \
    --outFileName "${bigwigs_folder}/${sample}.bw" \
    --outFileFormat bigwig \
    --binSize=10 \
    --normalizeUsing RPKM \
    --extendReads=200 \
    --numberOfProcessors 6

done # Next sample

# Make bigwig for the master bam
echo ""
echo "Merged"
echo ""

bamCoverage --bam "${final_bams_folder}/master.bam" \
  --outFileName "${bigwigs_folder}/master.bw" \
  --outFileFormat bigwig \
  --binSize=10 \
  --normalizeUsing RPKM \
  --extendReads=200 \
  --numberOfProcessors 6

# Completion message
echo ""
echo "Done"
date

# Clean-up (keep it at the end of the script)
## ==========================================
rm $PBS_O_WORKDIR/$PBS_JOBID
