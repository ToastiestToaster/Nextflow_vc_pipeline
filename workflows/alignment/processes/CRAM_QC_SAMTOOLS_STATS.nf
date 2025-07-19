process CRAM_QC_SAMTOOLS_STATS { 
    container 'community.wave.seqera.io/library/samtools:1.22--d3d0176a603eb4f8'

    input:
    tuple val(meta), path(cram), path(crai)
    path (fasta)


    output:
    tuple val(meta), path("*.stats"), emit: CRAM_STATS

    script:
    """
    samtools stats --threads 4 --reference ${fasta} ${cram} > ${meta.sample}.stats
    """
}
