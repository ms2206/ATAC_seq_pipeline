#!/bin/bash
# ATACseq analysis: ATAC-seq vs DEGs
# Laucher for R script s15_combining_atac_and_rna_seq.r
# This script takes < 1 min to run
# Alexey Larionov 11Dec2024

# Crescent2 script
# Note: this script should be run on a compute node
# qsub s15_combining_atac_and_rna_seq.sh

# PBS directives
#---------------

#PBS -N s15_combining_atac_and_rna_seq
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
echo "Started launcher shell script"
date
echo ""

# Load required module
module load R/4.2.1-foss-2022a

# Launch R script
Rscript s15_combining_atac_and_rna_seq.r

# Completion message
echo ""
echo "Completed launcher shell script"
date

# Clean-up
## =========================
rm $PBS_O_WORKDIR/$PBS_JOBID
