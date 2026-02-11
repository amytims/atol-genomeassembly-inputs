process FORMAT_CONFIG_FILE {
    publishDir "${params.outdir}/config", mode: 'copy'
    publishDir "config", mode: 'copy'

    input:
    path yaml
    val(long_reads)
    val(hic_reads)

    output:
    path "sangertol_config.yaml"

    script:
    def hic_reads_arg = (hic_reads != "") ? "-hic_reads ${hic_reads}" : ""
    """
    python scripts/format_config_file.py --config $yaml --long_reads $long_reads $hic_reads_arg
    """
}