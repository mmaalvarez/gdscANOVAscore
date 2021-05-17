# gdscANOVAscore
    Author miguelmartin.alvarez@irbbarcelona.org
    Version v0.0.1

Compare two user-defined groups of subjects (e.g. cell lines) based on their scores (e.g. fitness) for a list of features (e.g. gene knockouts), using gdsctools ANOVA



Procedure:
---------
1- Build the singularity container by executing the container/build_container.sh script.
If necessary, first debug the definition file container/container.def following the instructions found also in container/build_container.sh
In case you are not interested in running the pipeline in a container, just comment the following line in 'nextflow.config':

	container = "$PWD/container/container.sif"

2- Run the pipeline by executing run_nf.sh, after having edited the argument flags to match your input files names (full path) and their column names.
You can also customize 'nextflow.config' to fit your 'executor' or 'clusterOptions'.



Pipeline input:
--------------
1- Headed .tsv with subject IDs (any format), factor ID (any format), and score columns, in long format:

	subject_ID	factor_ID	score	strat_feature	corr_factor
	ACH-000011	A1BG	0.11	p53wt	bladder
	ACH-000011	AMT1	0.23	p53wt	bladder
	...

The example 'test.tsv' is a subset of the Achilles-PScore integrated dataset from 2020/12/01, spanning 906 cell lines.
Namely, the essentiality scores for 2 genes and ALL 906 cell lines are taken from 'CERES_FC.txt'.

download:	https://www.depmap.org/broad-sanger/integrated_Sanger_Broad_essentiality_matrices_20201201.zip
info: 		https://depmap.org/broad-sanger/
paper:		https://www-nature-com.sire.ub.edu/articles/s41467-021-21898-7


2- ***UPDATE THIS***
The test_features.tsv new table is a copy of
	/g/strcombio/fsupek_data/CRISPR/4_resources/genes_info/essentiality/depmap/mutation_calls/combined_21Q1_19Q1/all_features_combined/cell_lines_mutated_features.tsv
Headed list of subject IDs from the main table (naming must be in the same format) that belong to the case group ('group 1') that we want to compare (with an ANOVA) to ALL the remaining subjects in the main table ('group 0').
An example of 'group 1' could be those cell lines that have at least one gene from GO:0000724 (DSB repair via HR) with at least one frameshifting/splicing/nonsense mutation, e.g.:

If there is a stratifying factor column specified, this is renamed as "TISSUE_FACTOR", and there will be an ANOVA per level, i.e. each ANOVA will include only the subject IDs that share a level for this factor -- there can be >2 levels

(optional: stratifying feature and correcting factor columns)

	cell_line_ID



Pipeline output:
---------------
Two excel tables containing factor IDs sorted by the ANOVA's FDR, either with negative or positive FEATURE_delta_MEAN_IC50 (i.e. factor IDs for which subjects in the group 1 have consistently lower or higher score values than subjects in the group 0).
UPDATE:
- Output 1 excel file sorted by FDR, but with both neg and pos effects
	- if there was split by factor, e.g. p53 status, then there will be 2 excels
	