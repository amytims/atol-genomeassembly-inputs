def readYAML(yamlfile) {
    return new org.yaml.snakeyaml.Yaml().load(yamlfile.text)
}

process CREATE_CONFIG_FILE {
    publishDir "${params.outdir}/config", mode: 'copy'
    publishDir "config", mode: 'copy'

    input:
    val(yaml)
    path pacbio_reads
    path hic_reads
    
    output:
    path "sanger_tol_config.yaml"

    exec:
    def yaml_data = readYAML(yaml)

    def id = yaml_data.dataset_id
    def species = yaml_data.scientific_name
    def mito_code = yaml_data.mito_code
    def busco_lineage = yaml_data.busco_lineage
    def mito_hmm_name = yaml_file.mito_hmm_name

    long_reads = yaml_data.reads?.PACBIO_SMRT ? "pacbio" : "ont"


    def motifs = yaml_data?.hic_motif
        ?.split(',')
        *.trim()
        findAll { it }

    def motifs_yaml = motifs && motifs.size() > 0 \
        ? "hic_motif:\n" + motifs.collect { "      - ${it}" }.join('\n') + '\n'
        : ""

    """
    cat <<EOF > sanger_tol_config.yaml
    metadata:
    id: ${id}
    species: "${species}"
    mitochondrial_code: ${mito_code}
    sequencing_data:
    long_reads:
      platform: "${long_reads}"
      reads:
        - ${pacbio_reads}
    hic:
      reads:
        - ${hic_reads}
    EOF

    if [ -n "${motifs_yaml}" ]; then
    cat <<EOF >> sanger_tol_config.yaml
        ${motifs_yaml}
    EOF
    fi

    cat <<EOF >> sanger_tol_config.yaml
    databases:
    busco:
        lineage: ${busco_lineage}
    oatk:
        mito_hmm: https://github.com/c-zhou/OatkDB/raw/main/v20230921/${mito_hmm_name}.fam
    EOF

"""
}