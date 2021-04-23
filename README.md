# gdscANOVAscore
    Author miguelmartin.alvarez@irbbarcelona.org
    Version v0.0.1

Compare two user-defined groups of subjects (e.g. cell lines) based on their scores (e.g. fitness) for a list of features (e.g. gene knockouts), using gdsctools ANOVA



Procedure:
---------
1- Build the singularity container running the container/create_container.sh script. If necessary, first debug the definition file container/container.def following the instructions found also in container/build_container.sh
In case you are not interested in running the pipeline in a container, just comment the following line in 'nextflow.config':

	container = "$PWD/container/container.sif"

2- Run run_nf.sh, after editing the argument flags to match your input file paths and names, and their column names. You can also customize 'nextflow.config' to fit your 'executor' or 'clusterOptions'.



Pipeline input:
--------------
1- Headed .tsv with subject IDs (any format), factor ID (any format), and score columns, in long format, e.g.:

	BROAD_ID	gene	crispr_score
	ACH-000001	A1BG	0.11
	ACH-000001	AMT1	0.23
	...

The example 'test.tsv' is a subset of the Achilles-PScore integrated dataset from 2020/12/01, spanning 906 cell lines.
Namely, the gene essentiality scores are taken from 'CERES_FC.txt'.

download:	https://www.depmap.org/broad-sanger/integrated_Sanger_Broad_essentiality_matrices_20201201.zip
info: 		https://depmap.org/broad-sanger/
paper:		https://www-nature-com.sire.ub.edu/articles/s41467-021-21898-7


2- Headed list of subject IDs from the main table (naming must be in the same format) that belong to the case group (group 1) that we want to compare (with an ANOVA) to ALL the remaining subjects in the main table (group 0). An example of group 1 could be those cell lines that have some gene(s) considered to be inactivated by one(some) mutation(s), e.g.:

	cell_line_ID
	ACH-000004
	ACH-000010
	...



Pipeline output:
---------------
Two excel tables containing factor IDs sorted by the ANOVA's FDR, either with negative or positive FEATURE_delta_MEAN_IC50 (i.e. factor IDs for which subjects in the group 1 have consistently lower or higher score values than subjects in the group 0)
