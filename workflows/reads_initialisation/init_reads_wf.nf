// Initialisation script for the pipeline
// Organises the input data [Samplesheet] into a format suitable for the pipeline

// Imports necessary modules/functions
include {samplesheetToList                    } from 'plugin/nf-schema'

include { FASTP                            } from './processes/FASTP.nf'
include { FASTQC                          } from './processes/FASTQC.nf'



workflow INIT_READS {
    take:
    input
    
    main:
    // Convert the input samplesheet into inputs, a format understanable by the pipeline
    samplesheet_ch = Channel.fromList(samplesheetToList(input, "samplesheet/samplesheet_schema.json")) // Converts the input samplesheet to a channel
    inputs = samplesheet_ch.map{ meta, fastq1, fastq2 -> [meta.patient + meta.sample, [meta, fastq1, fastq2]] }                     // This block prepares the data from sample sheet into a format suitable
    num_lanes = inputs.groupTuple().map{ patient_id, lanes -> [patient_id, lanes.size()] }                                          // for the pipeline. It produces: [patient_id, num_lanes, [meta, fastq1, fastq2]]
    
    reads = inputs.combine(num_lanes, by: 0).map{ patient_id, items_ch, num_lanes ->                                               // meta = [patient:..., sample:..., lane:...], built automatically from 
                                                   (meta, fastq1, fastq2) = items_ch                                                // samplesheetToList function.
                                                   meta = meta + [id: "${meta.sample}-${meta.lane}", num_lanes: num_lanes.toInteger(), size: 1, datatype:"fastq_gz"]
                                                   [meta, [fastq1, fastq2]] }   

    // Create readgroup, add flow cell ID and add 
    reads = reads.map{ meta, reads -> add_flowcell_and_readgroup_to_meta(meta, reads) } //.view()

    // Perform Quality Control on the reads
    FASTQC(reads)
    FASTP(reads)
    ALL_REPORTS = FASTQC.out.html_qcreport
    .combine(FASTQC.out.zip_qcreport, by: 0)
    .combine(FASTP.out.json_fastpreport, by: 0)
    .combine(FASTP.out.html_fastpreport, by: 0) // .view()

    emit:
    READS = FASTP.out.reads
    ALL_REPORTS
}

// FUNCTIONS FOR TRANSFORMS 

def add_flowcell_and_readgroup_to_meta (meta, reads) {
    def flowcell_id = get_flowcell_lane(reads[0])
    def sample_lane_id = "${flowcell_id}.${meta.sample}.${meta.lane}"
    def read_group      = "\"@RG\\tID:${sample_lane_id}\\tPU:${meta.lane}\\tSM:${meta.patient}_${meta.sample}\\tLB:${meta.sample}\\tDS:${params.genome}\\tPL:Illumina\""
    meta = meta + [read_group: read_group.toString()]
    meta = meta + [flowcell_id: flowcell_id.toString()]
    meta = meta - meta.subMap('lane')
    return [meta, reads]
}

def get_flowcell_lane (fastq_path) {
    def firstline = get_first_line(fastq_path)
    def flowcell_id = null

    fields = firstline.split(":")
    flowcell_id = fields[2]

    return flowcell_id
}

def get_first_line (fastq_path) {
    def line = null

    // Fills line with the actual first line
    fastq_path.withInputStream {
        // UNZIPS THE G ZIPPED FILE (IT)
        // CONVERTS THE CONTENTS FROM BYTES TO ASCII, HUMAN READABLE
        InputStream gzipStream = new java.util.zip.GZIPInputStream(it)
        Reader decoder = new InputStreamReader(gzipStream, 'ASCII')
        BufferedReader buffered = new BufferedReader(decoder)
        line = buffered.readLine()}
    
    return line
}
