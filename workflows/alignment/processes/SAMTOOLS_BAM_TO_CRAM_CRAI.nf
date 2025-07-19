process SAMTOOLS_BAM_TO_CRAM_AND_CRAI { 
    container 'community.wave.seqera.io/library/samtools:1.22--d3d0176a603eb4f8'

    input:
    tuple val(meta), path(bam)
    path (fasta)

    output:
    tuple val(meta), path("*.cram"), path("*.crai"), emit: CRAM_CRAI

    script:
    """
    samtools view -Ch \\
    -T ${fasta} \\
    -O cram,version=3.0 \\
    -o ${meta.sample}.md.cram \\
    ${bam}
    samtools index ${meta.sample}.md.cram
    """
}
