# ATACseq analysis: ATACseq vs RNAseq

# This R script should be launched on a compute node
# using a launcher shell script

# Matthew Spriggs 11Dec2024

# Start message
print("Started R script")
print("ATACseq analysis: ATACseq vs RNAseq")

# Folders
base_folder <- "/mnt/beegfs/home/s430452/epigenetics"
rnaseq_data_folder <- paste(base_folder, "/data/rna_seq", sep = "")
atac_data_folder <- paste(base_folder, "/results/s12_dif_genes", sep = "")
output_folder <- paste(base_folder, "/results/s15_atac_vs_rna_seq", sep = "")

# Remove output folder, if exists
unlink(output_folder, recursive = TRUE)

# Make output folder
dir.create(output_folder)

# Read source data
print("Reading ATACseq and RNAseq gene lists")

# Read ATAC down gene list
ATAC_down_genes_file <- paste(atac_data_folder, "/down_genes.txt", sep = "")
ATAC_down_genes.df <- read.csv(ATAC_down_genes_file, sep = "\t")
ATAC_down_genes <- ATAC_down_genes.df[, 1]

# Read ATAC up gene list
ATAC_up_genes_file <- paste(atac_data_folder, "/up_genes.txt", sep = "")
ATAC_up_genes.df <- read.csv(ATAC_up_genes_file, sep = "\t")
ATAC_up_genes <- ATAC_up_genes.df[, 1]

# Read RNAseq DEGs gene list
RNAseq_DEGs_file <- paste(rnaseq_data_folder,
                          "/DESeq_ARID2Ko_v_ARID2wt_chr5.csv", sep = "")
RNAseq_DEGs.df <- read.csv(RNAseq_DEGs_file)

# Keep only significant DEGs
RNAseq_DEGs.df <- RNAseq_DEGs.df[RNAseq_DEGs.df$padj <= 0.05, ]

# Extract gene names
RNAseq_DEGs <- unique(RNAseq_DEGs.df$Gene_name)

# Make Venn diagram
print("Making Venn diagram")

# Load package (should alredy be installed)
library(VennDiagram)

# Make plot
venn <- venn.diagram(
  x = list(ATAC_down_genes, ATAC_up_genes, RNAseq_DEGs),
  category.names = c("ATAC_DN", "ATAC_UP", "RNAseq_DEGs"),
  filename = paste(output_folder, "/venn.png", sep = ""))

# Save genes of interst to text files
print("Saving overlapping genes to text files")

ATAC_down_DEGs <- intersect(ATAC_down_genes, RNAseq_DEGs)
write.table(ATAC_down_DEGs,
  file = paste(output_folder, "/ATAC_down_DEGs.txt", sep = ""),
  row.names = FALSE, col.names = FALSE, quote = FALSE)

ATAC_up_DEGs <- intersect(ATAC_up_genes, RNAseq_DEGs)
write.table(ATAC_up_DEGs,
  file = paste(output_folder, "/ATAC_up_DEGs.txt", sep = ""),
  row.names = FALSE, col.names = FALSE, quote = FALSE)

# Completion message
print("Completed R script")
