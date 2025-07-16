process GATK_MARKDUPLICATES { 
    container 'community.wave.seqera.io/library/gatk4:4.6.2.0--295bcaadd4b2818c'

    input:
    tuple val(meta), path(bam)

    output:
    tuple val(meta), path("*.bam"),      emit: bam   
    tuple val(meta), path("*.metrics"),  emit: metrics


    script:
    """
    gatk --java-options "-Xmx256M -XX:-UsePerfData" \\
        MarkDuplicates \\
        --INPUT ${bam} \\
        --OUTPUT ${meta.sample}.md.bam \\
        --METRICS_FILE ${meta.sample}.metrics \\
        --TMP_DIR . \\
        --VALIDATION_STRINGENCY LENIENT
    """
}
