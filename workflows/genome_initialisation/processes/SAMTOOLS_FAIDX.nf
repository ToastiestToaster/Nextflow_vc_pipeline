process SAMTOOLS_FAIDX {
    tag "$genome"
    container 'community.wave.seqera.io/library/samtools:1.22--d3d0176a603eb4f8'

    input:
    path(genome)

    output:
    path "${genome}.fai",           emit: SAMTOOLS_FAI

    script:
    """
    samtools faidx ${genome}
    """
}