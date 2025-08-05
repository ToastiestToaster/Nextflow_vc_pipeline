include { INIT_READS                          } from 'reads_initialisation/init_reads_wf.nf'
include { INIT_GENOME                         } from 'genome_initialisation/genome_init_wf.nf'
include { ALIGNMENT                           } from 'alignment/alignment_wf.nf'
include { VARIANT_CALLING                     } from 'variant_calling/variant_calling_wf.nf'
