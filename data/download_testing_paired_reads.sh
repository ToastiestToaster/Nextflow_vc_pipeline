#
# Downloads the HG004 paired reads used for testing the pipeline.
#
# Usage: bash download_testing_paired_reads.sh /path/to/directory/with/metadata

set -e

if [[ $# -eq 0 ]]; then
    echo "Error: provide path to metadata file. Ensure the metadata file is located in the download directory."
    exit 1
fi

PREFIX="ftp://ftp-trace.ncbi.nlm.nih.gov/ReferenceSamples/giab/data/AshkenazimTrio/HG004_NA24143_mother/NIST_HiSeq_HG004_Homogeneity-14572558/HG004_HiSeq300x_fastq/"

METADATA_FILE="$1"
DOWNLOAD_DIR="$(dirname "${METADATA_FILE}")"

READ1_L1="ftp://ftp-trace.ncbi.nlm.nih.gov/ReferenceSamples/giab/data/AshkenazimTrio/HG004_NA24143_mother/NIST_HiSeq_HG004_Homogeneity-14572558/HG004_HiSeq300x_fastq/140818_D00360_0046_AHA5R5ADXX/Project_RM8392/Sample_4A1/4A1_CGATGT_L001_R1_001.fastq.gz"
READ2_L1="ftp://ftp-trace.ncbi.nlm.nih.gov/ReferenceSamples/giab/data/AshkenazimTrio/HG004_NA24143_mother/NIST_HiSeq_HG004_Homogeneity-14572558/HG004_HiSeq300x_fastq/140818_D00360_0046_AHA5R5ADXX/Project_RM8392/Sample_4A1/4A1_CGATGT_L001_R2_001.fastq.gz"
READ1_L2="ftp://ftp-trace.ncbi.nlm.nih.gov/ReferenceSamples/giab/data/AshkenazimTrio/HG004_NA24143_mother/NIST_HiSeq_HG004_Homogeneity-14572558/HG004_HiSeq300x_fastq/140818_D00360_0046_AHA5R5ADXX/Project_RM8392/Sample_4A1/4A1_CGATGT_L002_R1_001.fastq.gz"
READ2_L2="ftp://ftp-trace.ncbi.nlm.nih.gov/ReferenceSamples/giab/data/AshkenazimTrio/HG004_NA24143_mother/NIST_HiSeq_HG004_Homogeneity-14572558/HG004_HiSeq300x_fastq/140818_D00360_0046_AHA5R5ADXX/Project_RM8392/Sample_4A1/4A1_CGATGT_L002_R2_001.fastq.gz"

wget "${READ1_L1}" -P "${DOWNLOAD_DIR}"
wget "${READ2_L1}" -P "${DOWNLOAD_DIR}"
wget "${READ1_L2}" -P "${DOWNLOAD_DIR}"
wget "${READ2_L2}" -P "${DOWNLOAD_DIR}"