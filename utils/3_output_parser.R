library(vroom)
library(readr)
library(writexl)


# read table gene - dummy drug correspondences
gene_to_dummy_drug = vroom('input/gene_to_dummy_drug.tsv') %>%
  dplyr::select(gene, DRUG_ID)

# read ANOVA results
mdrug = vroom('res/ANOVA_results.csv')

# return the gene names
mdrug_fi = merge(gene_to_dummy_drug,
                 mdrug) %>%
  # keep interesting columns
  dplyr::select(gene,
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

## split based on negative or positive selection in special group
mdrug_fi %>%
  dplyr::filter(FEATURE_delta_MEAN_IC50 < 0) %>%
  write_xlsx('res/genes_negatively_selected_in_case_cell_lines.xlsx')

mdrug_fi %>%
  dplyr::filter(FEATURE_delta_MEAN_IC50 > 0) %>%
  write_xlsx('res/genes_positively_selected_in_case_cell_lines.xlsx')
