process GATK_BASERECALIBRATOR_QC_COMBINE { 
    container 'community.wave.seqera.io/library/gatk4:4.6.2.0--295bcaadd4b2818c'

    input:
    tuple val(meta), path(tables)

    output:
    tuple val(meta), path("*.table"), emit: table
    
    script:
    def tables = table.collect{"--input $it"}.join(' ')
    """
    gatk --java-options "-Xmx254M -XX:-UsePerfData" \\
        GatherBQSRReports \\
        ${tables} \\
        --output ${meta.sample}.table \\
        --tmp-dir . \\
    """
}
