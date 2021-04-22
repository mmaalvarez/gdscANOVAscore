#!/bin/bash

mkdir -p log/

nextflow -log $PWD/log/nextflow.log run pipe.nf --input_table $PWD/test.tsv \
												--list_cases $PWD/test_cases.txt \
												--ID_colname BROAD_ID \
												--cases_ID_colname BROAD_ID \
												--factor_colname gene \
												--score_colname crispr_score \
											    -resume -bg
