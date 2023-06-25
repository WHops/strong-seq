#!/bin/bash

# Check if the correct number of arguments is provided
if [ "$#" -lt 5 ]; then
    echo "Usage: bash filter_bam.sh <input.bam> <output.bam> <tagged_ont_reads.tsv> <samedir> <samtools_path>"
    echo "<samedir>: true for same strand, false for opposite strand"
    exit 1
fi

# Assign command-line arguments to variables
input_bam="$1"
output_bam="$2"
tagged_ont_reads="$3"
samedir="$4"
samtools_path="$5"

# Generate unique filenames based on output file
input_sam="${output_bam%.*}_input.sam"
readnames_txt="${output_bam%.*}_readnames.txt"
output_sam="${output_bam%.*}_output.sam"

# Convert BAM to SAM
${samtools_path} view -h "$input_bam" > "$input_sam"

# Create an awk array with the readnames and orientation
awk '{a[$1]=$2} END{for(i in a){print i,a[i]}}' "$tagged_ont_reads" > "$readnames_txt"

# Filter SAM based on samedir
if [ "$samedir" = "true" ]; then
    awk 'NR==FNR{reads[$1]=$2; next} /^@/ || ($1 in reads && ((and($2, 16) && reads[$1]=="-") || (!and($2, 16) && reads[$1]=="+")))' "$readnames_txt" "$input_sam" > "$output_sam"
elif [ "$samedir" = "false" ]; then
    awk 'NR==FNR{reads[$1]=$2; next} /^@/ || ($1 in reads && ((and($2, 16) && reads[$1]=="+") || (!and($2, 16) && reads[$1]=="-")))' "$readnames_txt" "$input_sam" > "$output_sam"
else
    echo "Invalid samedir option. Please use 'true' or 'false'"
    exit 1
fi

# Convert SAM to BAM
${samtools_path} view -b -o "$output_bam" "$output_sam"

# Index the modified BAM
${samtools_path} index "$output_bam"

# Clean up intermediate files
rm "$input_sam" "$output_sam" "$readnames_txt"

echo "BAM filter operation completed successfully."