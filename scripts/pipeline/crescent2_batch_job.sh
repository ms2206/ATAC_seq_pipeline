#!/bin/bash
# ATACseq analysis: QC and Preprocessing
# Alexey Larionov 23Nov2024

# PBS directives that you should review and change if needed
#-----------------------------------------------------------

#PBS -N s01_qc_and_preprocessing
#PBS -l nodes=1:ncpus=6
#PBS -l walltime=00:30:00
#PBS -q half_hour
#PBS -m abe
#PBS -M alexey.larionov@cranfield.ac.uk

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

# *** Your code goes here *** #

# Clean-up (keep it at the end of the script)
## ==========================================
rm $PBS_O_WORKDIR/$PBS_JOBID
