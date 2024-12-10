#!/bin/bash
# Playing with file names in Bash
# AL03Dec2024

# We can add sffix to a sample (file) name
x="my_sample"
echo $x
echo $x.fastq # my_sample.fastq
echo ${x}.bam # my_sample.bam
echo "${x}.vcf" # my_sample.vcf

# Bash parameter expansion (prefix or suffix removal)
x="my_file.bam"
echo ${x}
echo ${x#my_} # file.bam
echo ${x%.bam} # my_file

# Removing prefix may also include path
x="data_folder/my_file.bam"
echo ${x}
echo ${x#data_folder/my_} # file.bam

# Bash parameter expansion + globbing (wildcard expansion)
x=".../very_long_path_to_data_folder/my_file.bam"
echo ${x}
echo ${x#*my_} # file.bam

# Capturing the output of a command
x=$(ls)
echo $x # data_folder s01_tokenizing_in_for_loop.sh s02_playing_with_file_names.sh

x=$(ls data_folder)
echo $x #my_sample1.bam my_sample1.fastq my_sample2.bam my_sample2.fastq

# Another example of Bash globbing (wildcard expansion)
x=$(ls data_folder/*.bam)
echo $x # data_folder/my_sample1.bam data_folder/my_sample2.bam

# Extract sample names from bam files in a folder
files=$(ls data_folder/*.bam)
for file in $files
do
    x=${file#*my_}
    x=${x%.bam}
    echo $x
done # sample1 sample2

# Completion message
echo "Done"
date