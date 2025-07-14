process BWAMEM2_IDX {
    tag "$genome"
    container 'community.wave.seqera.io/library/bwa-mem2:2.2.1--1842774b9b0b4729'

    input:
    path(genome)

    output:
    path "index_files",           emit: BWA_MEM2_INDEX_FILES

    script:
    def refname = genome.getBaseName()
    """
    mkdir index_files
    bwa-mem2 index ${genome}
    mv ${refname}* index_files/
    """
}