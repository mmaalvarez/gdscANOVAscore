library(vroom)
library(readr)
library(writexl)


## pass factor_colname as argument
args = commandArgs(trailingOnly = TRUE)
# defaults = list("gene"))
factor_colname = args[1]


# read table factor - dummy drug correspondences
factor_to_dummy_drug = vroom('factor_to_dummy_drug.tsv') %>%
  dplyr::select(factor_colname, DRUG_ID)

# read ANOVA results
ANOVA_results = vroom('ANOVA_results.csv')

# replace the factor names
ANOVA_results_fi = merge(factor_to_dummy_drug,
                         ANOVA_results) %>%
  # keep interesting columns
  dplyr::select(factor_colname,
                N_FEATURE_pos,
                N_FEATURE_neg,
                FEATURE_pos_logIC50_MEAN,
                FEATURE_neg_logIC50_MEAN,
                FEATURE_delta_MEAN_IC50,
                FEATURE_IC50_effect_size,
                FEATURE_pos_Glass_delta,
                FEATURE_neg_Glass_delta,
                FEATURE_pos_IC50_sd,
                FEATURE_neg_IC50_sd,
                FEATURE_IC50_T_pval,
                ANOVA_FEATURE_pval,
                ANOVA_FEATURE_FDR) %>%
  # sort based on FDR
  dplyr::arrange(ANOVA_FEATURE_FDR)

## split based on negative or positive selection in case group
ANOVA_results_fi %>%
  dplyr::filter(FEATURE_delta_MEAN_IC50 < 0) %>%
  write_xlsx('factors_negatively_selected_in_cases.xlsx')

ANOVA_results_fi %>%
  dplyr::filter(FEATURE_delta_MEAN_IC50 > 0) %>%
  write_xlsx('factors_positively_selected_in_cases.xlsx')
