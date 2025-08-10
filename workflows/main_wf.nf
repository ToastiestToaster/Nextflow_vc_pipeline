include { INIT_READS                          } from 'reads_initialisation/init_reads_wf.nf'
include { INIT_GENOME                         } from 'genome_initialisation/genome_init_wf.nf'
include { ALIGNMENT                           } from 'alignment/alignment_wf.nf'
include { VARIANT_CALLING                     } from 'variant_calling/variant_calling_wf.nf'

// Run main pipeline
workflow {
    
    main:
    // Generate the necassary files from the genome
    INIT_GENOME(params.genome, params.nucleotides_per_second)

    // Prepare reads from the samplesheet for the pipeline and perform QC
    INIT_READS(params.input)
    alignment_reads = INIT_READS.out.READS

    // ALIGN
    ALIGN(alignment_reads,
          INIT_GENOME.out.INDEX_FILES,
          params.genome,
          INIT_GENOME.out.INTERVALS_BED,
          INIT_GENOME.out.GATK_DICT,
          INIT_GENOME.out.SAMTOOLS_FAI,
          known_sites,
          known_sites_idx)

    // VARIANT CALLING
    VARIANT_CALLING(ALIGN.out.CRAM_CRAI_BED,
                    params.genome,
                    INIT_GENOME.out.GATK_DICT,
                    INIT_GENOME.out.SAMTOOLS_FAI)

    // Need to write a file saving line
}