process CONCAT_PACBIO_FASTQ {
    publishDir "${params.outdir}/processed_reads/hifi", mode: 'copy'

    input:
    path files

    output:
    path "${params.sample_id}_ccs_reads.fasta.gz", emit: processed_pacbio

    script:
    """
    zcat $files | seqkit fq2fa -j ${task.cpus} -o "${params.sample_id}_ccs_reads.fasta.gz"
    """

}
