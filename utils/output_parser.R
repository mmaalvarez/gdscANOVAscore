library(magrittr)
library(vroom)
library(dplyr)
library(writexl)


# read table factor - dummy drug correspondences
factor_to_dummy_drug = vroom('factor_to_dummy_drug.tsv', delim = "\t") %>%
  dplyr::select(factor, DRUG_ID)

# read ANOVA results
ANOVA_results = vroom('ANOVA_results.csv', delim = ",")


## replace the factor names
ANOVA_results_fi = merge(factor_to_dummy_drug,
                         ANOVA_results) %>%
  # keep interesting columns
  dplyr::select(factor,
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


## split factor IDs based on them having consistently lower or higher score in case group (1) than in the 0 group
ANOVA_results_fi %>%
  dplyr::filter(FEATURE_delta_MEAN_IC50 < 0) %>%
  write_xlsx('factor_IDs_lower_in_cases.xlsx')

ANOVA_results_fi %>%
  dplyr::filter(FEATURE_delta_MEAN_IC50 > 0) %>%
  write_xlsx('factor_IDs_higher_in_cases.xlsx')
