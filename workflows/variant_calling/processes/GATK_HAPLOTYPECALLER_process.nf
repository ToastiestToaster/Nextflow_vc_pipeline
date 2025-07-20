process GATK_HAPLOTYPECALLER { 
    container 'community.wave.seqera.io/library/gatk4:4.6.2.0--295bcaadd4b2818c'

    input:
    tuple val(meta), path(cram), path(crai), path(bed)
    path(fasta)
    path(dict)
    path(fai)
    // path(dbsnp)
    // path(dbsnp_idx)


    output:
    tuple val(meta), path("*.vcf.gz")       , emit: vcf
    tuple val(meta), path("*.tbi")          , optional:true, emit: tbi


    
    script:
    def prefix = { meta.num_intervals <= 1 ? "${meta.sample}.haplotypecaller" : "${meta.sample}_${bed.simpleName}.haplotypecaller" }
    def interval_command = bed ? "--intervals ${bed}" : ""
    // def dbsnp_command = dbsnp ? "--dbsnp ${dbsnp}" : ""
    """
    gatk --java-options "-Xmx254M -XX:-UsePerfData" \\
        HaplotypeCaller \\
        --input ${cram} \\
        --output ${prefix}.vcf.gz \\
        --reference ${fasta} \\
        --native-pair-hmm-threads 4 \\
        ${interval_command} \\
        --tmp-dir . \\
    """
    // ${dbsnp_command} ADD THIS BACK IN WHEN IMPLEMENTED

}
