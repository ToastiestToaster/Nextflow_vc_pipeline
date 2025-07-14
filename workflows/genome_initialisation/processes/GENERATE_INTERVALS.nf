process GENERATE_INTERVALS_INPUT {
    tag "$genome"
    container 'community.wave.seqera.io/library/gawk:5.3.1--e09efb5dfc4b8156'

    input:
    path(fai_file)

    output:
    path "${fai_file}.bed",           emit: INPUT_BED

    script:
    """
    awk \
        -v FS='\t' -v OFS='\t' '{ print \$1, \"0\", \$2 }' \
        ${fai_file} \
        > ${fai_file}.bed
    """
}

process GENERATE_INTERVALS {
    tag "$genome"
    container 'community.wave.seqera.io/library/gawk:5.3.1--e09efb5dfc4b8156'

    input:
    path(input_bed_file)
    val(nucleotides_per_second)

    output:
    path("*.bed"),           emit: AWK_BED

    script:
    def nucleotides_per_second = 20
        """
        awk -vFS="\t" '{
            t = \$5  # runtime estimate
            if (t == "") {
                # no runtime estimate in this row, assume default value
                t = (\$3 - \$2) / ${nucleotides_per_second}
                print t
            }
            if (name == "" || (chunk > 50 && (chunk + t) > longest * 1.05)) {   # Changing chunk to 50 temporarily, originally 600
                # start a new chunk
                name = sprintf("%s_%d-%d.bed", \$1, \$2+1, \$3)
                chunk = 0
                longest = 0
                print name
            }
            if (t > longest)
                longest = t
            chunk += t
            print \$0 > name
        }' ${input_bed_file}
        """
}