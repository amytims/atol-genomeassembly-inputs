process CONVERT_PACBIO {
    publishDir "${params.outdir}/reads/hifi", mode: 'copy'

    input:
    path file
 
    output:
    path "${basename}.trim.fasta.gz", emit: pacbio_fa

    script:
    basename=input_file.getBaseName(input_file.name.endsWith('.trim.fastq.gz')? 2: 1)
    """
    seqkit fq2fa $file -j ${task.cpus} -o "${basename}.trim.fasta.gz"
    """

}