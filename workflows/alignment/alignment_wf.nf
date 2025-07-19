include { BWA_MEM2_ALIGNER                  } from './processes/BWA_MEM2_ALIGNER.nf'
include { SAMTOOLS_BAM_MERGER               } from './processes/SAMTOOLS_BAM_MERGER.nf'
include { SAMTOOLS_CRAM_MERGER              } from './processes/SAMTOOLS_CRAM_MERGER.nf'
include { GATK_MARKDUPLICATES               } from './processes/GATK_MARKDUPLICATES.nf'
include { SAMTOOLS_BAM_INDEXER              } from './processes/SAMTOOLS_BAM_INDEXER.nf'
include { SAMTOOLS_CRAM_INDEXER             } from './processes/SAMTOOLS_CRAM_INDEXER.nf'
include { SAMTOOLS_BAM_TO_CRAM_AND_CRAI     } from './processes/SAMTOOLS_BAM_TO_CRAM_AND_CRAI.nf'
include { CRAM_QC_SAMTOOLS_STATS            } from './processes/CRAM_QC_SAMTOOLS_STATS.nf'
include { MOSDEPTH                          } from './processes/MOSDEPTH.nf'
include { GATK_BASERECALIBRATOR_QC          } from './processes/GATK_BASERECALIBRATOR_QC.nf'
include { GATK_BASERECALIBRATOR_QC_COMBINE  } from './processes/GATK_BASERECALIBRATOR_QC_COMBINE.nf'
include { GATK_BASERECALIBRATION            } from './processes/GATK_BASERECALIBRATION.nf'


workflow ALIGNMENT {
    take:
    reads
    index_files
    genome
    bed_files
    dict
    fai
    known_sites
    known_sites_tbi
    
    main:
    // Align
    BWA_MEM2_ALIGNER(reads, index_files, genome)

    // This will create a grouping key to organise the BAM files
    // later produced depending on the contents in the grouping key.
    reads.map{ meta, fastqs -> [meta.subMap('patient', 'sample'), fastqs]}
                   .groupTuple()
                   .map{ meta, fastqs -> meta + [n_fastq : fastqs.size()]}
                   .set{reads_grouping_key}

    // Grouping the bam files
    bams_grouped = BWA_MEM2_ALIGNER.out.bam.combine(reads_grouping_key)                                    //.view { it -> ">>> FIRST: ${it}" }
                                           .filter{meta, bam, key -> meta.sample == key.sample}
                                           .map{meta, bam, key -> [meta + key, bam]}                       // .view(it -> ">>> FIRST ${it}")
                                           .map{meta, bam -> [meta - meta.subMap('id', 'read_group', 'data_type', 'num_lanes', 'size'), bam]}
                                           .map{meta, bam -> [groupKey(meta, meta.n_fastq), bam]}
                                           .groupTuple()

    bams_to_merge = bams_grouped.branch{meta, bams -> single:   bams.size()   <= 1  ? [meta, bams[0]] : null
                                                      multiple: bams.size()    > 1  ? [meta, bams]    : null}
    SAMTOOLS_BAM_MERGER(bams_to_merge.multiple)
    bam_all = SAMTOOLS_BAM_MERGER.out.bam.mix(bams_to_merge.single)
    GATK_MARKDUPLICATES(bam_all)

    // CONVERT BAM TO CRAM HERE THEN GET CRAI INSTEAD OF BAI
    SAMTOOLS_BAM_TO_CRAM_AND_CRAI(GATK_MARKDUPLICATES.out.bam, genome)
    CRAM_CRAI_FILES = SAMTOOLS_BAM_TO_CRAM_AND_CRAI.out.CRAM_CRAI

    // MODIFY CRAM_CRAI TO INCLUDE BED FILES
    // BED FILES ARE IN SEPERATE CHANNELS TO ALLOW PARALLELISATION
    CRAM_CRAI_BED = CRAM_CRAI_FILES.combine(bed_files)
                                   .map{ meta, cram, crai, intervals, num_intervals -> [ meta + [ num_intervals:num_intervals ], cram, crai, intervals ] }

    // QUALITY CONTROL
    CRAM_QC_SAMTOOLS_STATS(CRAM_CRAI_FILES, genome)
    MOSDEPTH(CRAM_CRAI_BED, genome)
    mosdepth_reports = MOSDEPTH.out.MOSDEPTH_REPORTS.map{ meta, reports -> [[meta] + reports]}

    // BASE QUALITY SCORE RECALIBRATION
    GATK_BASERECALIBRATOR_QC(CRAM_CRAI_BED, genome, dict, fai, known_sites, known_sites_tbi)
    tables_to_merge = GATK_BASERECALIBRATOR_QC.out.table.map{meta, table -> [ groupKey(meta, meta.num_intervals), table ]}
                                                     .groupTuple()
                                                     .branch{single:   it[0].num_intervals <= 1
                                                             multiple: it[0].num_intervals  > 1}

    tables_merged = GATK_BASERECALIBRATOR_QC_COMBINE(tables_to_merge)
    table_bqsr = GATK_BASERECALIBRATOR_QC_COMBINE.out.table.mix(table_to_merge.single.map{ meta, table -> [ meta, table[0] ] })

    CRAM_CRAI_TABLE = CRAM_CRAI_FILES.join(table_bqsr, failOnDuplicate: true, failOnMismatch: true)
    CRAM_CRAI_TABLE_BED = CRAM_CRAI_FILES.combine(bed_files)
                                   .map{ meta, cram, crai, table, intervals, num_intervals -> [ meta + [ num_intervals:num_intervals ], cram, crai, table, intervals ] }

    GATK_BASERECALIBRATION(CRAM_CRAI_TABLE_BED, genome, dict, fai)
    RECALIBRATED_CRAMS_TO_MERGE = GATK_BASERECALIBRATION.out.cram.map{meta, cram -> [groupKey(meta, meta.num_intervals), cram ]}
                                                                 .groupTuple()
                                                                 .branch{meta, cram -> single:   cram.size() <= 1
                                                                                           return [meta, cram[0]]
                                                                                       multiple: cram.size()  > 1}

    SAMTOOLS_CRAM_MERGER(RECALIBRATED_CRAMS_TO_MERGE.multiple, genome, fai)
    cram_all = SAMTOOLS_CRAM_MERGER.out.cram.mix(RECALIBRATED_CRAMS_TO_MERGE.single)
    SAMTOOLS_CRAM_INDEXER(cram_all)

    CRAM_CRAI_RECALIB = SAMTOOLS_CRAM_INDEXER.out.cram_crai.map{meta, crai, cram -> [ meta - meta.subMap('num_intervals'), cram, crai]}
    CRAM_CRAI_RECALIB_BED = CRAM_CRAI_FILES.combine(bed_files)
                                   .map{ meta, cram, crai, intervals, num_intervals -> [ meta + [ num_intervals:num_intervals ], cram, crai, intervals ] }

    emit:
    CRAM_CRAI_BED = CRAM_CRAI_RECALIB_BED // EMIT THE RECALIBRATED CRAM AND CRAI FILES WITH THE INTERVALS

}