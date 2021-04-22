from gdsctools import ANOVA
import sys

def run_anova(file1, file2):

	print(sys.argv[1])
	print(sys.argv[2])

	an = ANOVA(file1, 
		  file1)

	an.settings.pvalue_correction_method = "qvalue"
	an.settings.equal_var_ttest = False

	results = an.anova_all()
	results.to_csv(file2)

run_anova(sys.argv[1], sys.argv[2])
