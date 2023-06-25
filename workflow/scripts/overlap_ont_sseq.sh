#!/bin/bash

# Check if the correct number of arguments is provided
if [ "$#" -ne 4 ]; then
    echo "Usage: bash script_name.sh <h1_ont.bam> <h1_sseq_plus_output.bam> <output_file> <bedtools_path>"
    exit 1
fi

# input parameters
h1_ont_bam=$1
h1_sseq_plus_output_bam=$2
output_file=$3
bedtools_path=$4

# Determine temporary file names based on output file name
raw_bed="${output_file}_raw.bed"
raw_uniq_bed="${output_file}_raw_uniq.bed"

# Perform intersection of the two BAM files
${bedtools_path} intersect -a $h1_ont_bam -b $h1_sseq_plus_output_bam -wa -bed | cut -f 4,6 > $raw_bed

# Filter for unique lines
cat $raw_bed | uniq > $raw_uniq_bed

# Filter for unique read names
awk '{print $1}' $raw_uniq_bed | sort | uniq -u | grep -wFf - $raw_uniq_bed > $output_file

# Remove temporary files
rm $raw_bed $raw_uniq_bed

echo "Operation completed successfully."