# gdscANOVAscore
    Author miguelmartin.alvarez@irbbarcelona.org
    Version v0.0.1

Given two user-defined groups of subjects (e.g. cell lines p53mut and cell lines p53wt), compare their scores (e.g. fitness, sgRNA counts...) for a list of factors (e.g. gene knockouts, treatment...), using gdsctools ANOVA

For more info on gdsctools, check gdsctools.readthedocs.io


Procedure:
---------
1- Build the singularity container by executing the container/build_container.sh script.
If necessary, first debug the definition file container/container.def following the instructions found also in container/build_container.sh
In case you are not interested in running the pipeline in a container, just comment the following line in 'nextflow.config':

	container = "$PWD/container/container.sif"

2- Run the pipeline by executing run_nf.sh, after having edited the argument flags to suit your requirements.
You can also customize 'nextflow.config' to fit your 'executor' or 'clusterOptions'.



Pipeline input:
--------------
1- Headed .tsv with subject IDs (any format), factor ID (any format), and score columns, in long format:

	subject_ID	factor_ID	score	strat_feature	corr_factor
	ACH-000011	A1BG	0.11	p53wt	bladder
	ACH-000011	AMT1	0.23	p53wt	bladder
	...

The example 'test.tsv' is a subset of the Achilles-PScore integrated dataset from 2020/12/01, spanning 906 cell lines.
Namely, the essentiality scores for aprox. 40 genes and ALL 906 cell lines are taken from 'CERES_FC.txt'.

download:	https://www.depmap.org/broad-sanger/integrated_Sanger_Broad_essentiality_matrices_20201201.zip
info: 		https://depmap.org/broad-sanger/
paper:		https://www-nature-com.sire.ub.edu/articles/s41467-021-21898-7


2- The test_features.tsv new table is a copy of
	/g/strcombio/fsupek_data/CRISPR/4_resources/genes_info/essentiality/depmap/mutation_calls/combined_21Q1_19Q1/all_features_combined/cell_lines_mutated_features.tsv
Subject IDs from the main table (naming convention must be the same) 

feature1_anova: subject IDs that belong to the case group ('1') that we want to compare (with an ANOVA) to ALL the remaining subjects in the main table ('0'). An example of 'group 1' could be those cell lines that have a specific pathway mutated.

If there is an (optional) stratifying factor column specified, this will be renamed as "TISSUE_FACTOR", and there will be an ANOVA per level, i.e. each ANOVA will include only the subject IDs that share a level for this factor -- currently there can be only 2 levels

	subject_ID	feature_stratify	feature1_anova	feature2_anova
	ACH-000001	1	0	0
	ACH-000002	0	0	0
	ACH-000003	1	0	0
	ACH-000004	1	0	0
	ACH-000005	1	0	0
	ACH-000006	1	0	0
	ACH-000007	0	0	0
	ACH-000008	0	0	0
	ACH-000009	1	0	0



Pipeline output:
---------------
An excel sheet containing factor IDs sorted by the ANOVA's FDR (updated based on the p-values of all stratification groups, if present), and the effect size, whose sign is that of 'FEATURE_delta_MEAN_IC50'
