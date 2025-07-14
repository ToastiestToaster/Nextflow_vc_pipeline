include { BWAMEM2_IDX                     } from './processes/BWAMEM2_IDX.nf'
include { SAMTOOLS_FAIDX                  } from './processes/SAMTOOLS_FAIDX.nf'
include { GATK_PICARD_DICT                } from './processes/GATK_PICARD_DICT.nf'
include { GENERATE_INTERVALS_INPUT        } from './processes/GENERATE_INTERVALS.nf'
include { GENERATE_INTERVALS              } from './processes/GENERATE_INTERVALS.nf'

workflow INIT_GENOME {
    take:
    genome
    nucleotides_per_second
    
    main:
    // USING BWA MEM2 to index the genome as BWA MEM2 is the aligner
    BWAMEM2_IDX(genome)
    SAMTOOLS_FAIDX(genome)
    GATK_PICARD_DICT(genome)

    // Build interval (BED) files
    GENERATE_INTERVALS_INPUT(SAMTOOLS_FAIDX.out.SAMTOOLS_FAI)
    GENERATE_INTERVALS(GENERATE_INTERVALS_INPUT.out.INPUT_BED, 
                       nucleotides_per_second) // actual default value: 200000
    
    AWK_BED = GENERATE_INTERVALS.out.AWK_BED.flatten()
                                            .map { intervalFile -> def duration = 0.0
                                                                   for (line in intervalFile.readLines()) {
                                                                       final fields = line.split('\t')
                                                                       start = fields[1].toInteger()
                                                                       end = fields[2].toInteger()
                                                                       duration += (end - start) / nucleotides_per_second}
                                                                   [duration, intervalFile]}
                                            .toSortedList({ a, b -> b[0] <=> a[0] })
                                            .flatten()
                                            .collate(2)
                                            .map{ duration, intervalFile -> intervalFile }
                                            .collect()
                                            .map{ it -> [ it, it.size() ] } // .view(it -> "Before Transpose ${it}")
                                            .transpose() // .view(it -> "After Transpose ${it}")

    emit:
    // BWAMEM2 ALIGNER FILES
    INDEX_FILES     = BWAMEM2_IDX.out.BWA_MEM2_INDEX_FILES
    // SAMTOOLS FAI FILE
    SAMTOOLS_FAI    = SAMTOOLS_FAIDX.out.SAMTOOLS_FAI
    // GATK PICARD DICT FILE
    GATK_DICT       = GATK_PICARD_DICT.out.GATK_DICT
    // INTERVALS BED FILES
    INTERVALS_BED   = AWK_BED

}