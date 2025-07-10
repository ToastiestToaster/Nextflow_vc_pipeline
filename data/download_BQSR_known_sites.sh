#
# Downloads known sites for base quality score recalibration.
#
# Usage: bash download_BQSR_known_sites.sh /path/to/download/directory

set -e

if [[ $# -eq 0 ]]; then
    echo "Error: download directory must be provided as an input argument."
    exit 1
fi

DOWNLOAD_DIR="$1"
ROOT_DIR="${DOWNLOAD_DIR}/BWSR_KNOWN_SITES"
KNOWN_SITES_DIR="${DOWNLOAD_DIR}/BWSR_KNOWN_SITES/KNOWN_SITES"
INDEX_FILES_DIR="${DOWNLOAD_DIR}/BWSR_KNOWN_SITES/INDEX_FILES"

# ftp://ftp-trace.ncbi.nlm.nih.gov/1000genomes/ftp/technical/reference/GRCh38_reference_genome/GRCh38_full_analysis_set_plus_decoy_hla.fa
KNOWN_SITES="https://ftp.ncbi.nlm.nih.gov/1000genomes/ftp/technical/reference/GRCh38_reference_genome/GRCh38_full_analysis_set_plus_decoy_hla.fa"
KNOWN_SITES_IDX="https://ftp.ncbi.nlm.nih.gov/1000genomes/ftp/technical/reference/GRCh38_reference_genome/GRCh38_full_analysis_set_plus_decoy_hla.fa"

mkdir --parents "${ROOT_DIR}"
mkdir --parents "${KNOWN_SITES_DIR}"
mkdir --parents "${KNOWN_SITES_IDX}"


wget "${KNOWN_SITES}" -P "${KNOWN_SITES_DIR}"
wget "${KNOWN_SITES_IDX}" -P "${INDEX_FILES_DIR}"
