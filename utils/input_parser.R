library(vroom)
library(readr)
library(magrittr)
library(dplyr)
library(tidyr)


## pass input files path and name as arguments
args = commandArgs(trailingOnly = TRUE)
                    # defaults = list("test.tsv",
                    #                 "test_cases.txt",
                    #                 "BROAD_ID",
                    #                 "BROAD_ID",
                    #                 "gene",
                    #                 "crispr_score"))
input_table = args[1]
list_cases = args[2]
ID_colname = args[3]
cases_ID_colname = args[4]
factor_colname = args[5]
score_colname = args[6]


## Input table (factor essentiality for each cell line)
input_table = vroom(input_table) %>%
  dplyr::rename("ID_colname" = ID_colname,
                "factor_colname" = factor_colname,
                "score_colname" = score_colname)

## Input list of cell lines to compare with the remaining cell lines in the ANOVA
list_cases = read.delim(list_cases) %>%
  dplyr::pull(cases_ID_colname)


## Parse table format for ANOVA
input_table_wide = input_table %>%
  # Extract cell line id, factor name, and factor essentiality score
  dplyr::select(ID_colname, factor_colname, score_colname) %>%
  # de-duplicate cell lines (e.g. those that have more than one mutation in the same gene)
  dplyr::distinct() %>%
  # wide format (cell lines to rows, factors to columns, score are the values)
  tidyr::pivot_wider(names_from = c(factor_colname),
                     values_from = c(score_colname)) %>%
  # grouping: 1 if cell line is in list of special group, 0 otherwise
  dplyr::mutate(group = ifelse(ID_colname %in% list_cases,
                               yes = 1,
                               # WARNING: this assumes that if a cell line is not in the special group list (1), belongs to the normal group (0)
                               no = 0)) %>%
  # move group column to the second column position
  relocate(group, .after = ID_colname) %>%
  # COSMIC_ID is the necessary header name for gdsc ANOVA to work, but the actual names can be in another system, e.g. BROAD ID
  dplyr::rename("COSMIC_ID" = ID_colname) %>%
  # change real ID to dummy COSMIC ID (1 to last)
  dplyr::mutate(COSMIC_ID = seq(1:length(COSMIC_ID)))

# change factor names by "drug_<num>_IC50", cause that's what the gdsc ANOVA program requires
# also keep track of the factor names - dummy drug name correspondences
factor_column_indices = 3:ncol(input_table_wide)

factor_to_dummy_drug = data.frame(factor_colname = colnames(input_table_wide)[factor_column_indices]) %>%
  dplyr::mutate(dummy_drug = paste0('Drug_', factor_column_indices, "_IC50"),
                DRUG_ID = factor_column_indices)

colnames(input_table_wide)[factor_column_indices] = factor_to_dummy_drug$dummy_drug


# write input table for ANOVA
write_tsv(input_table_wide,
          'ANOVA_input.tsv')
# write table factor - dummy drug correspondences
write_tsv(factor_to_dummy_drug,
          'factor_to_dummy_drug.tsv')
