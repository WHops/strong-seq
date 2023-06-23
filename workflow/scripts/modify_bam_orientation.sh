#!/bin/bash

# Check if the correct number of arguments is provided
if [ "$#" -lt 3 ]; then
    echo "Usage: bash modify_bam_orientation.sh <input.bam> <output.bam> <orientation>"
    echo "Orientation options: '+' for plus orientation, '-' for minus orientation"
    exit 1
fi

# Assign command-line arguments to variables
input_bam="$1"
output_bam="$2"
orientation="$3"

# Convert BAM to SAM
samtools view -h -o output.sam "$input_bam"

# Modify read orientation based on specified orientation option
if [ "$orientation" == "plusify" ]; then
    awk -F'\t' 'BEGIN{OFS=FS}{if(!/^@/ && (and(int($2), 16)==16)){$2 = $2 - 16}; print}' output.sam > modified.sam
elif [ "$orientation" == "minusify" ]; then
    awk -F'\t' 'BEGIN{OFS=FS}{if(!/^@/ && (and(int($2), 16)==0)){$2 = $2 + 16}; print}' output.sam > modified.sam
else
    echo "Invalid orientation option. Please use 'plusify' or 'minusify'"
    exit 1
fi

# Convert modified SAM to BAM
samtools view -b -o "$output_bam" modified.sam

# Index the modified BAM
samtools index "$output_bam"

# Clean up intermediate files
rm output.sam modified.sam

echo "Read orientation modification completed successfully."
