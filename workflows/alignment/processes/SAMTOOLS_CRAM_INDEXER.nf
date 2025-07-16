process SAMTOOLS_CRAM_INDEXER {
    container 'community.wave.seqera.io/library/samtools:1.22--d3d0176a603eb4f8'

    input:
    tuple val(meta), path(cram)

    output:
    tuple val(meta), path("*.crai"), path("${cram}"), emit: cram_crai

    script:
    """
    samtools \\
        index \\
        --threads 4 \\
        ${cram}
    """
}
