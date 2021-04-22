library(vroom)
library(readr)
library(magrittr)
library(dplyr)
library(tidyr)


## pass input files path and name as arguments
args = commandArgs(trailingOnly = TRUE)
input_table = args[1] # "test.tsv"
list_cases = args[2] # "test_cases.txt"
ID_colname = args[3] # "BROAD_ID"
cases_ID_colname = args[4] # "cases_ID"
factor_colname = args[5] # "gene"
score_colname = args[6] # "crispr_score"


## Input table (factor-specific scores for each subject)
input_table = vroom(input_table, delim = "\t")

## Input list of cases to compare with the remaining subjects, in the ANOVA
list_cases = read.delim(list_cases) %>%
  dplyr::pull(cases_ID_colname)


## Parse table format for ANOVA
input_table_wide = input_table %>%
  # Extract subject IDs, factor IDs, and scores
  dplyr::select(ID_colname, factor_colname, score_colname) %>%
  # de-duplicate subjects (e.g. those cell lines that have more than one mutation in the same gene)
  dplyr::distinct() %>%
  # wide format (subjects to rows, factor IDs to columns, score to values)
  tidyr::pivot_wider(names_from = c(factor_colname),
                     values_from = c(score_colname)) %>%
  # grouping: 1 if subject is in list of case group, 0 otherwise
  dplyr::mutate(group := ifelse(!!sym(ID_colname) %in% list_cases,
                                yes = 1,
                                # WARNING: this assumes that if a subject is not in the case group list (1), belongs to the normal group (0)
                                no = 0)) %>%
  # move group column to the second column position
  relocate(group, .after = ID_colname) %>%
  # COSMIC_ID is the necessary header name for gdsc ANOVA to work, but the actual names can be in any format
  dplyr::rename("COSMIC_ID" = ID_colname) %>%
  # change real ID to dummy COSMIC ID (1 to last)
  dplyr::mutate(COSMIC_ID = seq(1:length(COSMIC_ID)))

# change factor names by "drug_<num>_IC50", cause that's what the gdsc ANOVA program requires
# also keep track of the factor names - dummy drug name correspondences
factor_column_indices = 3:ncol(input_table_wide)

factor_to_dummy_drug = data.frame(factor = colnames(input_table_wide)[factor_column_indices]) %>%
  dplyr::mutate(dummy_drug = paste0('Drug_', factor_column_indices, "_IC50"),
                DRUG_ID = factor_column_indices)

colnames(input_table_wide)[factor_column_indices] = factor_to_dummy_drug$dummy_drug


# write input table for ANOVA
write_tsv(input_table_wide,
          'ANOVA_input.tsv')
# write table factor - dummy drug correspondences
write_tsv(factor_to_dummy_drug,
          'factor_to_dummy_drug.tsv')
