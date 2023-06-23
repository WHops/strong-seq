#!/bin/bash

# Check if the correct number of arguments is provided
if [ "$#" -ne 3 ]; then
    echo "Usage: bash script_name.sh <lr_bam> <sseq_bam> <output_file>"
    exit 1
fi


# input parameters

lr_bam=$1
sseq_bam=$2
output_file=$3


# Determine temporary file names based on output file name
readnames="${output_file}_readnames.txt"
header="${output_file}_header.sam"

# extract read names from original bam file
samtools view $lr_bam | awk '{print $1}' | sort | uniq > $readnames

# extract read names from second bam file
samtools view $sseq_bam | awk '{print $1}' | sort | uniq > $header

# extract common read names
comm -12 $readnames $header > ${output_file}_common_readnames.txt

# Extract the BAM header
samtools view -H $lr_bam > ${output_file}_header.sam

# Extract the common read alignments and append to the header
grep -Fwf ${output_file}_common_readnames.txt $lr_bam | cat ${output_file}_header.sam - | samtools view -bS - > $output_file

# Remove temporary files
rm $readnames $header ${output_file}_common_readnames.txt ${output_file}_header.sam

echo "Operation completed successfully."
