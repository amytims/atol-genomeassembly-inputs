process CONCAT_PACBIO_FASTQ {
    publishDir "${params.outdir}/processed_reads/hifi", mode: 'copy'

    input:
    path files

    output:
    path "ccs_reads.fasta.gz", emit: filtered_pacbio

    script:
    """
    zcat $files | seqkit fq2fa -j ${task.cpus} -o ccs_reads.fasta.gz
    """

}
