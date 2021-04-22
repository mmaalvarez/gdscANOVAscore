library(vroom)
library(readr)
library(magrittr)
library(dplyr)
library(tidyr)


gene_essentiality_file = "/g/strcombio/fsupek_data/CRISPR/4_resources/genes_info/essentiality/depmap/achilles_pscore/integrated_Sanger_Broad_essentiality_matrices_20201201/CERES_FC_by_p53_status/pscore_achilles_comb_p53wt.tsv"
# column names
cell_line_ID = "BROAD_ID"
gene = "gene"
essentiality_score = "crispr_score"

special_cell_lines_file = "/g/strcombio/fsupek_data/CRISPR/4_resources/genes_info/essentiality/depmap/mutation_calls/HRmut_wt_cell_lines/cell_lines_at_least_1_mut_gene.tsv"
# column name
cell_line_name = "BROAD_ID"


## Input table (gene essentiality for each cell line)
gene_essentiality = vroom(gene_essentiality_file) %>%
  dplyr::rename("cell_line_ID" = cell_line_ID,
                "gene" = gene,
                "essentiality_score" = essentiality_score)

## Input list of cell lines to compare with the remaining cell lines in the ANOVA
special_cell_lines = read.delim(special_cell_lines_file) %>%
  dplyr::pull(cell_line_name)


## Parse table format for ANOVA
gene_essentiality_wide = gene_essentiality %>%
  # Extract cell line id, gene name, and gene essentiality score
  dplyr::select(cell_line_ID, gene, essentiality_score) %>%
  # de-duplicate cell lines (those that have more than one mutation in the same gene)
  dplyr::distinct() %>%
  # wide format (cell lines rows, genes columns, essentialities values)
  tidyr::pivot_wider(names_from = c(gene),
                     values_from = c(essentiality_score)) %>%
  # grouping: 1 if cell line is in list of special group, 0 otherwise
  dplyr::mutate(group = ifelse(cell_line_ID %in% special_cell_lines,
                               #| cell_line_ID2 %in% special_cell_lines
                               yes = 1,
                               # WARNING: this assumes that if a cell line is not in the special group list (1), belongs to the normal group (0)
                               no = 0)) %>%
  # move group column to the second column position
  relocate(group, .after = cell_line_ID) %>%
  # COSMIC_ID is the necessary header name for gdsc ANOVA to work, but the actual names can be in another system, e.g. BROAD ID
  dplyr::rename("COSMIC_ID" = cell_line_ID) %>%
  # change real ID to dummy COSMIC ID (1 to last)
  dplyr::mutate(COSMIC_ID = seq(1:length(COSMIC_ID)))

# change gene names by "drug_<num>_IC50", cause that's what the gdsc ANOVA program requires
# also keep track of the gene names - dummy drug name correspondences
gene_column_indices = 3:ncol(gene_essentiality_wide)

gene_to_dummy_drug = data.frame(gene = colnames(gene_essentiality_wide)[gene_column_indices]) %>%
  dplyr::mutate(dummy_drug = paste0('Drug_', gene_column_indices, "_IC50"),
                DRUG_ID = gene_column_indices)

colnames(gene_essentiality_wide)[gene_column_indices] = gene_to_dummy_drug$dummy_drug


## define input and output names and create folders for ANOVA
dir.create(file.path("input/"),
           recursive = TRUE)
# write input table for ANOVA
write_tsv(gene_essentiality_wide,
          'input/ANOVA_input.tsv')
# write table gene - dummy drug correspondences
write_tsv(gene_to_dummy_drug,
          'input/gene_to_dummy_drug.tsv')

dir.create(file.path("res/"),
           recursive = TRUE)
