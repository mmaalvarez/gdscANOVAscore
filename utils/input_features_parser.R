library(vroom)
library(readr)
library(magrittr)
library(dplyr)
library(tidyr)
library(purrr)
library(conflicted)
conflict_prefer("filter", "dplyr")
conflict_prefer("rename", "dplyr")
conflict_prefer("select", "dplyr")
conflict_prefer("map", "purrr")


## pass input files path and name as arguments
args = commandArgs(trailingOnly = TRUE)
input_features_filename = args[1] # "../test_features.tsv"
ID_colname = args[2] # "BROAD_ID"
features_ID_colname = args[3] # "BROAD_ID"
feature_stratify = args[4] # "TP53mut_corrected"
features_anovas = args[5] # c("HRmut","MMRmut")
features_anovas = strsplit(features_anovas,
                           split=",", fixed=TRUE)[[1]]

subject_to_dummy_id = vroom("subject_to_dummy_id.tsv")


## Parse input features table (1 column subject IDs ("features_ID_colname"), possibly other column used to stratify analyses in 2 groups ("feature_stratify"), and other(s) to define which subject IDs are cases (1) (and which controls (0)) for each factor's ANOVA ("features_anovas"))
input_features = vroom(input_features_filename) %>%
  # Extract subject IDs, stratifying factor, and case/control factor(s) (and correcting factor)
  select(features_ID_colname, feature_stratify, features_anovas) %>%
  # COSMIC_ID is the necessary header name for gdsc ANOVA to work, but the actual names can be in any format
  rename("COSMIC_ID" = features_ID_colname,
         "TISSUE_FACTOR" = feature_stratify) %>% # ,"MEDIA_FACTOR" = correcting_factor
  #relocate(MEDIA_FACTOR, .after = TISSUE_FACTOR) %>%
  ## add dummy MSI_FACTOR column (only level 0) because otherwise the MEDIA_FACTOR is not included
  #mutate(MSI_FACTOR = "0") %>%
  #relocate(MSI_FACTOR, .after = TISSUE_FACTOR) %>%
  # change real ID to dummy COSMIC ID (1 to last) in features table
  merge(subject_to_dummy_id) %>%
  relocate(dummy_ID_name, .before = COSMIC_ID) %>%
  select(-COSMIC_ID) %>%
  rename("COSMIC_ID" = "dummy_ID_name") %>%
  # remove NA rows
  drop_na()
# convert 1, 2... feature levels into letters (a, b...)
input_features$TISSUE_FACTOR = sapply(input_features$TISSUE_FACTOR, function(i) letters[i])
# convert "0" feature level, if existing, into "zero"
input_features %<>%
  mutate(TISSUE_FACTOR = gsub("character\\(0\\)", "zero", TISSUE_FACTOR))

# features must have the format "*_mut"
names(input_features)[names(input_features) %in% features_anovas] = names(input_features)[names(input_features) %in% features_anovas] %>%
  gsub("$", "_mut", .) %>%
  # in case they already had that ending, or similar
  gsub("_mut_mut", "_mut", .) %>%
  gsub("mut_mut", "_mut", .)
  
# write features table
write_tsv(input_features,
          'features.tsv')

