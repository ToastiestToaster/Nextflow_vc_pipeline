process GATK_BASERECALIBRATION { 
    container 'community.wave.seqera.io/library/gatk4:4.6.2.0--295bcaadd4b2818c'

    input:
    tuple val(meta), path(cram), path(crai), path(table), path(bed)
    path(fasta)
    path(dict)
    path(fai)

    output:
    tuple val(meta), path("*.cram"), emit: cram
    
    script:
    def prefix = { meta.num_intervals <= 1 ? "${meta.sample}" : "${meta.sample}_${bed.simpleName}" }
    def interval_command = bed ? "--intervals ${bed}" : ""
    """
    gatk --java-options "-Xmx254M -XX:-UsePerfData" \\
        ApplyBQSR \\
        --input ${cram} \\
        --output ${prefix}.${cram.getExtension()} \\
        --reference ${fasta} \\
        --bqsr-recal-file ${table} \\
        ${interval_command} \\
        --tmp-dir . \\
    """
}
