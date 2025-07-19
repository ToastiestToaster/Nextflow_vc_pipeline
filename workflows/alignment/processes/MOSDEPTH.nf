process MOSDEPTH { 
    container 'community.wave.seqera.io/library/mosdepth:0.3.10--259732f342cfce27'

    input:
    tuple val(meta), path(cram), path(crai), path(bed)
    path (fasta)


    output:
    tuple val(meta), path("4A1.md.cram*"), emit: MOSDEPTH_REPORTS

    script:
    """
    mosdepth \\
        --threads 4 \\
        --by ${bed} \\
        --fasta ${fasta} \\
        ${meta.sample}.md.cram \\
        ${cram}
    """
}
