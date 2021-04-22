#!/usr/bin/env nextflow


/*/ Input list_tables is splitted into lines, each passed as an independent channel to the pipeline, so executed in parallel
NOT IMPLEMENTED
Channel
    .fromPath(params.list_tables)
    .splitText()
    .set { list_tables }
*/


// Parse input for ANOVA
process input_parser {

    input:
    // files paths and names
    file 'table' from input_table
    file 'cases' from list_cases
    // column names
    val ID_colname_str from ID_colname
    val cases_ID_colname_str from cases_ID_colname
    val factor_colname_str from factor_colname
    val score_colname_str from score_colname

    output:
    file 'ANOVA_input.tsv' into ANOVA_input
    file 'factor_to_dummy_drug.tsv' into factor_to_dummy_drug

    """
    #!/usr/bin/env bash

    Rscript $PWD/utils/input_parser.R table cases ID_colname_str cases_ID_colname_str factor_colname_str score_colname_str
    """
}


// run gdsc ANOVA
process gdsc_anova {

    input:
    path 'ANOVA_input.tsv' from ANOVA_input

    output:
    file 'ANOVA_results.csv' into ANOVA_results

    """
    #!/usr/bin/env bash

    conda activate gdsctools
    
    python gdsc_anova.py ANOVA_input.tsv ANOVA_results.csv
    """
}


// parse ANOVA output
process output_parser {
    
    input:
    path 'factor_to_dummy_drug.tsv' from factor_to_dummy_drug
    val factor_colname_str from factor_colname
    path 'ANOVA_results.csv' from ANOVA_results

    output:
    file 'factors_negatively_selected_in_cases.xlsx' into factors_negatively_selected_in_cases
    file 'factors_positively_selected_in_cases.xlsx' into factors_positively_selected_in_cases

    """
    #!/usr/bin/env bash

    Rscript $PWD/utils/output_parser.R factor_colname_str
    """
}


/*/ Collect all the parsed files into a single file and print the resulting file content when complete
NOT IMPLEMENTED
results
    .collectFile(name: params.out, keepHeader: true)
    .println { "Results saved to file: $it" }
*/
