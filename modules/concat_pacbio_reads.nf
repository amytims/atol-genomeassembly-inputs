process CONCAT_PACBIO_READS {
    publishDir "${params.outdir}/processed_reads/hifi", mode: 'copy'

    input:
    path files

    container = (files.every { it.name.endsWith('.fastq.gz') } ? 'quay.io/biocontainers/seqkit:2.10.1--he881be0_0':'quay.io/biocontainers/samtools:1.22.1--h96c455f_0')

    output:
    path "ccs_reads.fasta.gz", emit: filtered_pacbio

    script:
    def all_bam   = files.every { it.name.endsWith('.bam') }
    def all_fastq = files.every { it.name.endsWith('.fastq.gz') }
  
    if ( all_fastq )
        """
        zcat $files | seqkit fq2fa -j ${task.cpus} -o ccs_reads.fasta.gz
        """
    else
        """
        samtools cat *.bam | samtools fasta -@${task.cpus-1} -0 "${params.sample_id}_ccs_reads.fasta.gz"
        """
}
