import sys
from gdsctools import ANOVA


print(f'Input file: {sys.argv[1]}\n')
print(f'Features file: {sys.argv[2]}\n')
print(f'Stratifying feature level: {sys.argv[3]}\n')
print(f'Output file: {sys.argv[4]}\n')
print(f'Num. cores: {sys.argv[5]}\n')


def run_anova(input, features, strat, output, cores):

	an = ANOVA(input, features)
	
	# perform analyses only on subjects that share a level for the stratifying feature, e.g. TP53 status level 0 (p53wt)
	an.set_cancer_type(str(strat))

	an.settings.pvalue_correction_method = "qvalue"
	an.settings.equal_var_ttest = False

	results = an.anova_all(multicore=int(cores))
	results.to_csv(output)


run_anova(sys.argv[1], sys.argv[2], sys.argv[3], sys.argv[4], sys.argv[5])
