#!/bin/bash
# ATACseq analysis: selecting summits for peaks with differential coverage
# Alexey Larionov 25Nov2024

# Stop at runtime errors
set -e

# Start message
echo "ATACseq analysis: selecting summits for peaks with differential coverage"
date
echo ""

# Folders
base_folder="/mnt/beegfs/home/alexey.larionov/teaching_2024/epigenetics"
peaks_folder="${base_folder}/results/s07_peaks" # contains master_summits_bl.bed
dif_peaks_folder="${base_folder}/results/s09_dif_peaks" # files with dif peaks
dif_summits_folder="${base_folder}/results/s10_dif_summits" # for results

# Remove results, if existed
rm -fr "${dif_summits_folder}"

# Make output folder
mkdir -p "${dif_summits_folder}"

# Note that the peak IDs are in
#   1st column of the master_peaks_up/down/static.txt
#   4th column of the master_summits_bl.bed

# Summits for peaks with increased coverage 
# (i.e. more open chromatin after KO)
awk 'FNR==NR {a[$1]; next} $4 in a' \
  "${dif_peaks_folder}/master_peaks_up.txt" \
  "${peaks_folder}/master_summits_bl.bed" \
  > "${dif_summits_folder}/master_summits_up.bed"

# Summits for peaks with decreased coverage 
# (i.e. less open chromatin after KO)
awk 'FNR==NR {a[$1]; next} $4 in a' \
  "${dif_peaks_folder}/master_peaks_down.txt" \
  "${peaks_folder}/master_summits_bl.bed" \
  > "${dif_summits_folder}/master_summits_down.bed"

# Summits for peaks with static coverage 
# (i.e. no change in chromatin accessibility after KO)
awk 'FNR==NR {a[$1]; next} $4 in a' \
  "${dif_peaks_folder}/master_peaks_static.txt" \
  "${peaks_folder}/master_summits_bl.bed" \
  > "${dif_summits_folder}/master_summits_static.bed"

# Completion message
echo ""
echo "Done"
date
