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
    path 'table' from params.input_table
    path 'cases' from params.list_cases
    // column names
    val ID_colname from params.ID_colname
    val cases_ID_colname from params.cases_ID_colname
    val factor_colname from params.factor_colname
    val score_colname from params.score_colname

    output:
    file 'ANOVA_input.tsv' into ANOVA_input
    file 'factor_to_dummy_drug.tsv' into factor_to_dummy_drug

    """
    #!/usr/bin/env bash

    Rscript $PWD/utils/input_parser.R ${table} ${cases} ${ID_colname} ${cases_ID_colname} ${factor_colname} ${score_colname}
    """
}


// Run gdsc ANOVA
process gdsc_anova {

    input:
    path 'ANOVA_input.tsv' from ANOVA_input

    output:
    file 'ANOVA_results.csv' into ANOVA_results

    """
    #!/usr/bin/env bash

    python3 $PWD/utils/gdsc_anova.py ANOVA_input.tsv ANOVA_results.csv
    """
}


// Parse ANOVA output
process output_parser {
    
    input:
    path 'factor_to_dummy_drug.tsv' from factor_to_dummy_drug
    path 'ANOVA_results.csv' from ANOVA_results

    output:
    file 'factor_IDs_lower_in_cases.xlsx' into factor_IDs_lower_in_cases
    file 'factor_IDs_higher_in_cases.xlsx' into factor_IDs_higher_in_cases

    """
    #!/usr/bin/env bash

    Rscript $PWD/utils/output_parser.R
    """
}


/*/ Collect all the parsed files into a single file and print the resulting file content when complete
NOT IMPLEMENTED
results
    .collectFile(name: params.out, keepHeader: true)
    .println { "Results saved to file: $it" }
*/
