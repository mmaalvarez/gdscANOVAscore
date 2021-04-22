# gdscANOVAscore

Compare two user-defined groups (of e.g. cell lines) based on their scores (of e.g. fitness) for a list of features (e.g. gene knockouts), using gdsctools ANOVA


Pipeline input:
--------------
1- Headed .tsv with cell line ID (any format), gene ID (any format), and essentiality score columns, in long format, e.g.:

	BROAD_ID	gene	crispr_score
	ACH-000001	A1BG	0.11
	ACH-000001	AMT1	0.23
	...

2- Headed list of cell line IDs from the main table (naming must be in the same format) that belong to a special group (group 1) that we want to compare (with an ANOVA) to ALL the remaining cell lines in the main table (group 0). An example of group 1 could be those that have some gene(s) considered to be inactivated by mutation(s), e.g.:

	cell_line_ID
	ACH-000004
	ACH-000010
	...


Pipeline output:
---------------
Two excel tables containing genes sorted by the ANOVA's FDR, either with negative or positive FEATURE_delta_MEAN_IC50 (i.e. genes potentially consistently negatively or positively selected in the group 1 vs. group 0)
