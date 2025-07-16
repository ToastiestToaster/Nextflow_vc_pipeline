process SAMTOOLS_CRAM_MERGER {
    container 'community.wave.seqera.io/library/samtools:1.22--d3d0176a603eb4f8'

    input:
    tuple val(meta), path(crams)
    path(fasta)
    path(fai)


    output:
    tuple val(meta), path("*.cram")  , emit: cram

    script:
    """
    samtools \\
        merge \\
        --threads 4 \\
        -- reference ${fasta} \\
        ${meta.sample}.cram \\
        ${crams}
    """
}
