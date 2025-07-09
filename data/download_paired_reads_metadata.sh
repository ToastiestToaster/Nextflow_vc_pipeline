#
# Downloads the HG004 paired reads meta data file from Genome in a bottle.
#
# Usage: bash download_paired_reads_metadata.sh /path/to/download/directory

set -e

if [[ $# -eq 0 ]]; then
    echo "Error: download directory must be provided as an input argument."
    exit 1
fi

DOWNLOAD_DIR="$1"

# ftp://ftp-trace.ncbi.nlm.nih.gov/1000genomes/ftp/technical/reference/GRCh38_reference_genome/GRCh38_full_analysis_set_plus_decoy_hla.fa
HG004_DOWNLOAD="https://ftp-trace.ncbi.nlm.nih.gov/ReferenceSamples/giab/data_indexes/AshkenazimTrio/sequence.index.AJtrio_Illumina300X_wgs_07292015_updated.HG004"

wget "${HG004_DOWNLOAD}" -P "${ROOT_DIR}"