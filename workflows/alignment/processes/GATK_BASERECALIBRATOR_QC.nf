process GATK_BASERECALIBRATOR_QC { 
    container 'community.wave.seqera.io/library/gatk4:4.6.2.0--295bcaadd4b2818c'

    input:
    tuple val(meta), path(cram), path(crai), path(bed)
    path(fasta)
    path(dict)
    path(fai)
    path(known_sites)
    path(known_sites_idx)


    output:
    tuple val(meta), path("*.table"), emit: table
    
    script:
    def prefix = { meta.num_intervals <= 1 ? "${meta.sample}" : "${meta.sample}_${bed.simpleName}" }
    def interval_command = bed ? "--intervals ${bed}" : ""
    def sites_command = known_sites.collect{"--known-sites $it"}.join(' ')
    """
    gatk --java-options "-Xmx254M -XX:-UsePerfData" \\
        BaseRecalibrator  \\
        --input ${cram} \\
        --output ${prefix}.recal.table \\
        --reference ${fasta} \\
        ${intervals} \\
        ${sites_command}
        --tmp-dir .
    """
}
