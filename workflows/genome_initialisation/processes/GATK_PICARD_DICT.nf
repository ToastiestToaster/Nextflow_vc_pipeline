process GATK_PICARD_DICT {
    tag "$genome"
    container 'community.wave.seqera.io/library/gatk4:4.6.2.0--295bcaadd4b2818c'

    input:
    path(genome)

    output:
    path "${genome.getBaseName()}.dict",           emit: GATK_DICT

    script:
    """
    gatk CreateSequenceDictionary \
        R=${genome} \
        O=${genome.getBaseName()}.dict
    """
}