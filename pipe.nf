#!/usr/bin/env nextflow


/*/ Input table is splitted by (sets of N) factor ID(s), and each sub-table is then passed as an independent channel to the pipeline, so each (set of) ANOVA(s) is executed in parallel
NOT IMPLEMENTED
Channel
    .fromPath(params.input_table)
    .splitText(LOOK UP HOW TO DO IT BY (set of N) FACTOR ID(s) (e.g. sets of 100 genes, so 170 channels with 100 ANOVAs per channel))
    .set { subtables_by_factor }
*/


// Parse input for ANOVA
// test.tsv to wide format (factors as columns, subjects as rows) ; factors names to dummy drug names, and create reference table to rename afterwards ; subjects id column name renamed to COSMIC_ID, and ids changed to 1,2,3.. ; features.tsv keep only subjects id (renamed as COSMIC_ID, and 1,2,3...),  if requested, stratifying factor column as TISSUE_FACTOR, and requested (or all) feature columns for each ANOVA
process input_parser {

    input:
    // files paths and names
    path 'table' from params.input_table //subtables_by_factor
    path 'features' from params.features
    // column names
    val ID_colname from params.ID_colname
    val features_ID_colname from params.features_ID_colname
    val factor_colname from params.factor_colname
    val score_colname from params.score_colname
    val feature_stratify from params.feature_stratify
    val features_anovas from params.features_anovas

    output:
    file 'ANOVA_input.tsv' into ANOVA_input
    file 'features.tsv' into features_table
    file 'subject_to_dummy_id.tsv' into subject_to_dummy_id
    file 'factor_to_dummy_drug.tsv' into factor_to_dummy_drug

    """
    #!/usr/bin/env bash

    Rscript $PWD/utils/input_parser.R ${table} ${features} ${ID_colname} ${features_ID_colname} ${factor_colname} ${score_colname} ${feature_stratify} ${features_anovas}
    """
}


// the 2 processes below should go in a single process that allows to have >2 stratifying levels (or none)

// Run gdsc ANOVA (strat zero = p53wt)
process gdsc_anova_zero {

    input:
    path 'ANOVA_input.tsv' from ANOVA_input
    path 'features.tsv' from features_table
    val cores from params.cores

    output:
    file 'ANOVA_res_strat_zero.csv' into ANOVA_results_zero

    """
    #!/usr/bin/env bash

    // this is not used when run in container
    conda activate gdsctools

    python3 $PWD/utils/gdsc_anova.py ANOVA_input.tsv \
                                     features.tsv \
                                     zero \
                                     ANOVA_res_strat_zero.csv \
                                     ${cores}
    """
}

// Run gdsc ANOVA (strat a = p53mut)
process gdsc_anova_a {

    input:
    path 'ANOVA_input.tsv' from ANOVA_input
    path 'features.tsv' from features_table
    val cores from params.cores

    output:
    file 'ANOVA_res_strat_a.csv' into ANOVA_results_a

    """
    #!/usr/bin/env bash

    // this is not used when run in container
    conda activate gdsctools
    
    python3 $PWD/utils/gdsc_anova.py ANOVA_input.tsv \
                                     features.tsv \
                                     a \
                                     ANOVA_res_strat_a.csv \
                                     ${cores}
    """
}


// Parse ANOVA output
// This should change accordingly if I implement the sub-table parallelization, namely it should replace the dummy drug names by the original factor IDs in each subtable's ANOVA results (as it is done now), gather and merge all subtables into a single table ¿ANOVA_results\n\t.collectFile(name: '...', keepHeader: true)?, recalculate the FDR, and split them by the direction of delta (as it is done now). Maybe these are 2 or 3 processes
process output_parser {
    
    // Copy the resulting excel file(s) to a results folder
    publishDir 'res/'

    input:
    path 'subject_to_dummy_id.tsv' from subject_to_dummy_id
    path 'factor_to_dummy_drug.tsv' from factor_to_dummy_drug
    path 'ANOVA_res_strat_zero.csv' from ANOVA_results_zero
    path 'ANOVA_res_strat_a.csv' from ANOVA_results_a
    val 'output_name' from params.output_name

    output:
    file '*.xlsx' into parsed_results

    """
    #!/usr/bin/env bash

    Rscript $PWD/utils/output_parser.R ${output_name}
    """
}

parsed_results
    .println { "Finished! Results saved in res/" }
