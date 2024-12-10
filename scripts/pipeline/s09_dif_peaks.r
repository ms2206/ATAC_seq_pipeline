# ATACseq analysis: differential peaks coverage

# This R script should be launched on a compute node
# using a launcher shell script

# Alexey Larionov 25Nov2024

# Start message
print("Started R script")
print("ATACseq analysis: detecting peaks with differential coverage")

# Folders
base_folder <- "/mnt/beegfs/home/alexey.larionov/teaching_2024/epigenetics"
input_folder <- paste(base_folder, "/results/s08_counts", sep = "")
output_folder <- paste(base_folder, "/results/s09_dif_peaks", sep = "")

# Remove output folder, if exists
unlink(output_folder, recursive = TRUE)

# Make output folder
dir.create(output_folder)

# Read source data
source_file <- paste(input_folder, "/master_peaks_counts.txt", sep = "")
counts.df <- read.table(source_file, header = T, sep = "\t")

# Rename columns with counts
# (by default it is the full BAM file name with path)
colnames(counts.df)[7] <- "ARID2_KO_count"
colnames(counts.df)[8] <- "ARID2_WT_count"

# Get total counts per sample (for CPM normalisation)
total_KO <- sum(counts.df$ARID2_KO)
total_WT <- sum(counts.df$ARID2_WT)

# Perform CPM (Counts Per Million) normalisation
counts.df$ARID2_KO_CPM <- counts.df$ARID2_KO * 1000000 / total_KO
counts.df$ARID2_WT_CPM <- counts.df$ARID2_WT * 1000000 / total_WT

# Calculate differential accessibility
# Log fold-change: log( KO_CPM / WT_CPM )
counts.df$logFC_CPM <- log(counts.df$ARID2_KO_CPM / counts.df$ARID2_WT_CPM)

# --- Select peaks with increased coverage --- #

# Peaks with coverage increased at least 2-fold after ARID2 KO
counts_up.df <- counts.df[counts.df$logFC_CPM > 1, ]

# Print message to log
print(paste("Number of peaks with increased coverage:", nrow(counts_up.df)))

# Save peaks with increased coverage to a file
output_file <- paste(output_folder, "/master_peaks_up.txt", sep = "")

write.table(counts_up.df, file = output_file,
  quote = FALSE, row.names = FALSE, col.names = FALSE)

# --- Select peaks with decreased coverage --- #

# Peaks with coverage decreased at least 2-fold after ARID2 KO
counts_down.df <- counts.df[counts.df$logFC_CPM < -1, ]

# Print message to log
print(paste("Number of peaks with decreased coverage:", nrow(counts_down.df)))

# Save peaks with increased coverage to a file
output_file <- paste(output_folder, "/master_peaks_down.txt", sep = "")

write.table(counts_down.df, file = output_file,
  quote = FALSE, row.names = FALSE, col.names = FALSE)

# --- Select peaks with no change in coverage --- #

# Peaks with change in coverage less than 2-fold after ARID2 KO
counts_static.df <- counts.df[counts.df$logFC_CPM >= -1 &
                              counts.df$logFC_CPM <= 1, ]

# Print message to log
print(paste("Number of peaks with no change in coverage: ", nrow(counts_static.df)))

# Save peaks with increased coverage to a file
output_file <- paste(output_folder, "/master_peaks_static.txt", sep = "")

write.table(counts_static.df, file = output_file,
  quote = FALSE, row.names = FALSE, col.names = FALSE)

# Completion message
print("Completed R script")
