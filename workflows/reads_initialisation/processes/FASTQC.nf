process FASTQC {
    tag "$meta.id"
    container 'community.wave.seqera.io/library/fastqc:0.12.1--af7a5314d5015c29'

    input:
    tuple val(meta), path(fastq)

    output:
    tuple val(meta), path("*.html"), emit: html_qcreport
    tuple val(meta), path("*.zip") , emit: zip_qcreport
    
    script:
    // echo "Meta: ${meta}"
    // echo "FASTQ files: ${fastq[0]} ${fastq[1]}"
    """
    # Rename the FASTQ files so they are human readable
    # Symlinks are used to rename files to save space and avoid copying large files
    ln -s ${fastq[0]} ${meta.id}_1.fastq.gz
    ln -s ${fastq[1]} ${meta.id}_2.fastq.gz

    # Run FastQC on the renamed FASTQ files
    fastqc --threads 4 --memory 4G \
        ${meta.id}_1.fastq.gz \
        ${meta.id}_2.fastq.gz
    """
}