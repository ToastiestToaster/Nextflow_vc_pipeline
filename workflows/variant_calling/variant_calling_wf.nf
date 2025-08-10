include { GATK_HAPLOTYPECALLER                     } from './processes/BWAMEM2_IDX.nf'

// Quite small for now - Plan to add more tools for variant calling here
// 

workflow VARIANT_CALLING {
    take:
    CRAM_CRAI_BED
    genome
    dict
    fai
    
    main:
    // JUST VARIANT CALLING
    GATK_HAPLOTYPECALLER(CRAM_CRAI_BED, genome, dict, fai)
    
    // NEED TO SAVE THE VARIANT CALLING FILES TO A LOCAL DIRECTORY
    emit:
    vcf_file = GATK_HAPLOTYPECALLER.out.vcf

}