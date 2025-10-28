def help_file() {
    log.info """
    #######################################################################################
    ########### MERGE AND REFORMAT INPUT FILES; CREATE CONFIG FOR DToL PIPELINE ###########
    #######################################################################################

        --outdir <PATH/TO/OUTPUT/DIRECTORY>
                File path to where reads and config file should be stored

        --pacbio_reads
                Path to directory containing PacBio read files for DToL's genomeassembly
                pipeline.
                Default is './results/processed_reads/hifi'

        --hic_reads
                Path to directory containing Hi-C read files for DToL's genomeassembly
                pipeline.
                Default is './results/processed_reads/hic'
        
    #######################################################################################
    """.stripIndent()
}

if (params.remove('help')) {
    help_file()
    exit 0
}

// check no unexpected parameters were specified
allowed_params = [
    // pipeline inputs
    "outdir",
    "pacbio_reads",
    "hic_reads",

    // Pawsey options
    "max_cpus",
    "max_memory"
]

params.each { entry ->
    if ( !allowed_params.contains(entry.key) ) {
        println("The parameter <${entry.key}> is not known");
        exit 0;
    }
}

include { CONCAT_PACBIO_READS } from './modules/concat_pacbio_reads.nf'
include { CONCAT_HIC_READS } from './modules/concat_hic_reads.nf'

include { CREATE_CONFIG_FILE } from './modules/create_config_file.nf'

workflow {

    // getting input files

    pacbio_reads_ch = Channel.fromPath(params.pacbio_reads)
    pacbio_reads_ch.view()
}