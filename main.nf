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

include { CONCAT_PACBIO_FASTQ } from './modules/concat_pacbio_fastq.nf'
include { CONCAT_PACBIO_BAM } from './modules/concat_pacbio_bam.nf'
include { CONCAT_HIC_READS } from './modules/concat_hic_reads.nf'
include { CREATE_CONFIG_FILE } from './modules/create_config_file.nf'


// check pacbio reads are all the same file type
def pacbio_reads = file(params.pacbio_reads)
def input_pacbio = pacbio_reads.listFiles().findAll { it.name.endsWith('.bam') || it.name.endsWith('.fastq.gz') }

if (!input_pacbio) {
    throw new IllegalArgumentException("❌ No pacbio input files found!")
}

// --- get extensions ---
def unique_exts = input_pacbio.collect { f ->
    f.name.endsWith('.fastq.gz') ? 'fastq.gz' :
    f.name.endsWith('.bam')      ? 'bam' :
    f.extension
}.unique()

if (unique_exts.size() > 1) {
    throw new IllegalArgumentException("❌ Multiple file types detected in pacbio inputs: ${unique_exts.join(', ')}")
}

println "✅ Detected file type: ${unique_exts[0]}"


// see whether hi-c reads exist
def hic_reads = file(params.pacbio_reads)
def input_hic = hic_reads.listFiles().findAll

if (!input_hic) {
    log.warn("No hi-c input files found. Are you running an assembly without them?")
}

workflow {
    pacbio_reads_ch = Channel.fromPath("${params.pacbio_reads}/*.{fastq.gz,bam}")

    if (unique_exts[0] == 'bam') {

        CONCAT_PACBIO_READS(pacbio_reads_ch.collect())

    } else if (unique_exts[0] == 'fastq.gz') {

        CONCAT_PACBIO_FASTQ(pacbio_reads_ch.collect())

    } else {

        error("unrecognised file type: ${unique_exts[0]}. How did you even get here?")

    }

}
