process CONVERT_PACBIO {
    publishDir "${params.outdir}/reads/hifi", mode: 'copy'

    input:
    tuple val(pkg), val(file_name), val(url), val(md5sum), val(lane), val(read), path(input_file), path(publish_dir)

    output:
    path "${basename}.fasta.gz", emit: pacbio_fa

    script:
    basename=input_file.getBaseName(input_file.name.endsWith('.gz')? 2: 1)
    """
    seqkit fq2fa $input_file -j ${task.cpus} -o "${basename}.fasta.gz"
    """
}