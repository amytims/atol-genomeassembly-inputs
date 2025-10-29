process CONCAT_PACBIO_BAM {
    publishDir "${params.outdir}/processed_reads/hifi", mode: 'copy'

    input:
    path files

    output:
    path "${params.sample_id}_ccs_reads.fasta.gz", emit: processed_pacbio

    script:
    """
    samtools cat *.bam | samtools fasta -@${task.cpus-1} -0 "${params.sample_id}_ccs_reads.fasta.gz"
    """
}
