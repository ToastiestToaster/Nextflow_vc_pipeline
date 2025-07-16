process BWA_MEM2_ALIGNER {
    container 'community.wave.seqera.io/library/bwa-mem2_samtools:34483fa65c9842a5'

    input:
    tuple val(meta), path(reads)
    path(index_files)
    path (genome)

    output:
    tuple val(meta), path("*.bam")  , emit: bam

    script:
    """
    INDEX=`find -L ./ -name "*.amb" | sed 's/\\.amb\$//'`

    bwa-mem2 \\
        mem \\
        -K 100000000 -Y -R ${meta.read_group} \\
        -t 4 \\
        \$INDEX \\
        ${reads} \\
        | samtools sort -@ 4 -m 256M -o ${meta.id}.sorted.bam -
    """
}