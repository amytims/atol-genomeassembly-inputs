def readYAML(yamlfile) {
    return new org.yaml.snakeyaml.Yaml().load(yamlfile.text)
}

process CREATE_CONFIG_FILE {
    publishDir "${params.outdir}/config", mode: 'copy'
    publishDir "config", mode: 'copy'

    input:
    path yaml
    //path pacbio_reads
    //path hic_reads
    
    output:
    path "sanger_tol_config.yaml"


    def yaml_data = readYAML(file(yaml))

    def id = yaml_data.dataset_id
    def species = yaml_data.scientific_name
    def mito_code = yaml_data.mito_code
    def busco_lineage = yaml_data.busco_lineage
    def mito_hmm_name = yaml_file.mito_hmm_name
    
"""
   cat <<EOF > sanger_tol_config.yaml
   {
metadata:
  id: ${id}
  species: "${species}"
  mitochondrial_code: ${mito_code}
sequencing_data:
  long_reads:
    platform: "pacbio"
    reads:
      - /scratch/pawsey1132/atims/new_pipeline_version/results/reads/hifi/PorochilusObbesi2850005_ccs_reads.fasta.gz
  hic:
    reads:
      - /scratch/pawsey1132/atims/new_pipeline_version/results/reads/hic/PorochilusObbesi2850005.cram
    hic_motif:
      - GATC
      - GANTC
      - CTNAG
      - TTAA
databases:
  busco:
    lineage: ${busco_lineage}
  oatk:
    mito_hmm: https://github.com/c-zhou/OatkDB/raw/main/v20230921/${mito_hmm_name}.fam

   EOF

"""
}