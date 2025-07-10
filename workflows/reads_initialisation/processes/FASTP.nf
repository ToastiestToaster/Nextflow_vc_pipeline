process FASTP {
    tag "$meta.id"
    container 'community.wave.seqera.io/library/fastp:1.0.1--c8b87fe62dcc103c'

    input:
    tuple val(meta), path(fastq)

    output:
    tuple val(meta), path('*.fastp.fastq.gz') , optional:true, emit: reads
    tuple val(meta), path('*.json')           , emit: json_fastpreport
    tuple val(meta), path('*.html')           , emit: html_fastpreport
    
    script:
    """
    # Rename the FASTQ files so they are human readable
    # Symlinks are used to rename files to save space and avoid copying large files
    ln -s ${fastq[0]} ${meta.id}_1.fastq.gz
    ln -s ${fastq[1]} ${meta.id}_2.fastq.gz

    fastp \\
        --in1 ${meta.id}_1.fastq.gz \\
        --in2 ${meta.id}_2.fastq.gz \\
        --out1 ${meta.id}_1.fastp.fastq.gz \\
        --out2 ${meta.id}_2.fastp.fastq.gz \\
        --html ${meta.id}.fastp.html \\
        --json ${meta.id}.fastp.json \\
        --thread 4 \\
        --disable_adapter_trimming
    """
}