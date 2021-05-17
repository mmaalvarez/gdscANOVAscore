#!/bin/bash

mkdir -p log/

nextflow -log $PWD/log/nextflow.log run pipe.nf --input_table $PWD/test.tsv \
												--features $PWD/test_features.tsv \
												--ID_colname BROAD_ID \
												--features_ID_colname BROAD_ID \
												--factor_colname gene \
												--score_colname crispr_score \
												--feature_stratify TP53mut_corrected \
												--features_anovas HRmut MMRmut \
											    #-resume -bg
