#
# Downloads the GRCh38 reference genome from the 1000 Genomes Project.
# The downloaded file is unzipped and stored in the specified directory.
#
# Usage: bash download_GRCh38.sh

set -e

DOWNLOAD_DIR="./.."
ROOT_DIR="${DOWNLOAD_DIR}/ref_genome"
# ftp://ftp-trace.ncbi.nlm.nih.gov/1000genomes/ftp/technical/reference/GRCh38_reference_genome/GRCh38_full_analysis_set_plus_decoy_hla.fa
GRCh38_DOWNLOAD="https://ftp.ncbi.nlm.nih.gov/1000genomes/ftp/technical/reference/GRCh38_reference_genome/GRCh38_full_analysis_set_plus_decoy_hla.fa"

mkdir --parents "${ROOT_DIR}"

wget "${GRCh38_DOWNLOAD}" -P "${ROOT_DIR}"
