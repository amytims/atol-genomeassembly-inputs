process CREATE_CONFIG_FILE {
    publishDir "${params.outdir}/config", mode: 'copy'
    publishDir "config", mode: 'copy'

    input:
    path pacbio_reads
    path hic_reads
    
    output:
    path "config_file.yaml"

"""
echo "dataset:" >> config_file.yaml
echo "  id: ${params.sample_id}"  >> config_file.yaml
echo "  pacbio:" >> config_file.yaml
echo "    reads:" >> config_file.yaml
echo "        - reads: ${params.outdir}/reads/hifi/${pacbio_reads}" >> config_file.yaml
echo "  HiC:" >> config_file.yaml
echo "    reads:" >> config_file.yaml
if [ "${hic_reads}" != "dummy_hic" ]
then
echo "        - reads: ${params.outdir}/reads/hic/${hic_reads}" >> config_file.yaml
fi
echo "hic_motif: ${params.hic_motif}" >> config_file.yaml
echo "hic_aligner: ${params.hic_aligner}" >> config_file.yaml
echo "busco:" >> config_file.yaml
echo "  lineage: ${params.busco_lineage}_${params.busco_version}" >> config_file.yaml
echo "mito:" >> config_file.yaml
echo "  species: ${params.scientific_name}" >> config_file.yaml
echo "  min_length: ${params.mito_min_length}" >> config_file.yaml
echo "  code: ${params.mito_code}" >> config_file.yaml

"""
}