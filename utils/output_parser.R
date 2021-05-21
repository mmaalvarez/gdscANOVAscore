library(magrittr)
library(vroom)
library(dplyr)
library(stats)
library(writexl)


args = commandArgs(trailingOnly = TRUE)
output_name = args[1]


# read table factor - dummy drug correspondences
factor_to_dummy_drug = vroom('factor_to_dummy_drug.tsv', delim = "\t") %>%
  select(factor, DRUG_ID)

## read results
list_tables = list()
for (strat in c("zero", "a")){
  ## e.g. ('zero' = '0' = p53wt ; 'a' = '1' = p53mut)
  strat_meaning = ifelse(strat == "zero",
                         yes = "strat_wt",
                         no = ifelse(strat == "a",
                                     yes = "strat_-/-",
                                     no = "ERROR: more than 2 stratification levels"))
  # read ANOVA results
  ANOVA_results = vroom(paste0('ANOVA_res_strat_',
                              strat,
                              '.csv'),
                       delim = ",")
  
  ## replace the factor names
  ANOVA_results_fi = merge(factor_to_dummy_drug,
                           ANOVA_results) %>%
    # keep interesting columns
    select(FEATURE,
           factor,
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
    # create "signed_effect_size" column: add the delta mean sign to the effect size values
    mutate(signed_effect_size = ifelse(FEATURE_delta_MEAN_IC50 < 0,
                                       yes = -FEATURE_IC50_effect_size,
                                       no = FEATURE_IC50_effect_size)) %>%
    relocate(signed_effect_size, .before = FEATURE_pos_Glass_delta) %>%
    # append column indicating stratification group (level)
    mutate(strat_group = strat_meaning) %>%
    relocate(strat_group, .before = FEATURE)
  
  # append to list
  list_tables[[strat_meaning]] = ANOVA_results_fi
}

## merge stratified tables
bound_tables = rbind(list_tables$strat_wt,
                     list_tables$`strat_-/-`) %>%
  # recalculate FDR using BH based on BOTH stratification levels' pvalues
  mutate(updated_FDR = p.adjust(.$ANOVA_FEATURE_pval, method="BH")) %>%
  # rename FEATURE
  mutate(FEATURE = gsub("_mut", "", FEATURE)) %>%
  # sort based on updated_FDR
  arrange(updated_FDR)

# write
write_xlsx(bound_tables,
           paste0(output_name, '.xlsx'))
