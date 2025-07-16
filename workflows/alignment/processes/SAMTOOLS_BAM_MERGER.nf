process SAMTOOLS_BAM_MERGER {
    container 'community.wave.seqera.io/library/samtools:1.22--d3d0176a603eb4f8'

    input:
    tuple val(meta), path(bams)

    output:
    tuple val(meta), path("*.bam")  , emit: bam

    script:
    """
    samtools \\
        merge \\
        --threads 4 \\
        ${meta.sample}.sorted.bam \\
        ${bams}
    """
}
