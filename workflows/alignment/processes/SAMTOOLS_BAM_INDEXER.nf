process SAMTOOLS_BAM_INDEXER { // CURRENTLY WORKING ON THIS
    container 'community.wave.seqera.io/library/samtools:1.22--d3d0176a603eb4f8'

    input:
    tuple val(meta), path(bam)

    output:
    tuple val(meta), path("*.bai"), path("${bam}"), emit: bam_bai

    script:
    """
    samtools \\
        index \\
        --threads 4 \\
        ${bam}
    """
}
