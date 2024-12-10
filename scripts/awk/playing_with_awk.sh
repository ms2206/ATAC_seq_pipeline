#!/bin/bash
# Playing with awk
# AL03Dec2024

# --- Simple AWK syntax --- #

# Input text file
cat genes.txt

# Print selected columns
awk '{print $1,$3}' genes.txt

# Use OFS to change the output field separator
awk 'OFS="\t" {print $1,$3}' genes.txt

# Use NR to skip the header
awk 'NR>1 {print}' genes.txt

# Filter rows based on a condition
awk '$2=="Fish" {print}' genes.txt

# Do not mix-up "=" and "==" !!!
awk '$2="Fish" {print}' genes.txt

# Using default command {print} to print the whole line
awk '$2=="Fish"' genes.txt

# Redirecting the output to a file
awk '$2=="Fish"' genes.txt > fish_genes.txt

# --- AWK with two input files --- #

cat fish_genes.txt
cat promoters.txt

# Note that the gene names are in
#  3rd column of the fish_genes.txt
#  2nd column of the promoters.txt

awk 'FNR==NR {a[$3]; next} $1 in a {print}' fish_genes.txt promoters.txt

# Save the output to a file 
# splitting command to several lines for readability
awk 'FNR==NR {a[$3]; next} $1 in a {print}' \
  fish_genes.txt promoters.txt \
  > fish_promoters.txt
