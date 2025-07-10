#
# Downloads the HG004 paired reads FROM the meta data file. Seperating each run into its own directory.
#
# Usage: bash download_all_HG004_paired_reads.sh /path/to/directory/with/metadata

set -e

if [[ $# -eq 0 ]]; then
    echo "Error: provide path to metadata file. Ensure the metadata file is located in the download directory."
    exit 1
fi

PREFIX="ftp://ftp-trace.ncbi.nlm.nih.gov/ReferenceSamples/giab/data/AshkenazimTrio/HG004_NA24143_mother/NIST_HiSeq_HG004_Homogeneity-14572558/HG004_HiSeq300x_fastq/"

METADATA_FILE="$1"
METADATA_DIR="$(dirname "${METADATA_FILE}")"
DOWNLOAD_DIR="${METADATA_DIR}/reads"

tail -n +2 "${METADATA_FILE}" | while IFS=$'\t' read -r fastq1 md5_1 fastq2 md5_2 sample_name; do

    RUN_NAME="${fastq1#$PREFIX}"
    RUN_NAME="${RUN_NAME%%/*}"

    ROOT_DIR="${DOWNLOAD_DIR}/${sample_name}/${RUN_NAME}"
    mkdir --parents "${ROOT_DIR}"

    FASTQ1_NAME=$(basename "${fastq1}")
    FASTQ2_NAME=$(basename "${fastq2}")

    FASTQ1_PATH="${ROOT_DIR}/${FASTQ1_NAME}"
    FASTQ2_PATH="${ROOT_DIR}/${FASTQ2_NAME}"


    # Download the FASTQ files
    if [[ -f "${FASTQ1_PATH}" ]]; then
        echo "Skipping download: ${FASTQ1_NAME} already exists."
    else
        wget "${fastq1}" -P "${ROOT_DIR}"
    fi

    if [[ -f "${FASTQ2_PATH}" ]]; then
        echo "Skipping download: ${FASTQ2_NAME} already exists."
    else
        wget "${fastq2}" -P "${ROOT_DIR}"
    fi
    
    echo "Downloaded: ${FASTQ1_NAME} and ${FASTQ2_NAME}"
done
