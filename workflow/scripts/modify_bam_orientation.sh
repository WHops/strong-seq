#!/bin/bash

# Check if the correct number of arguments is provided
if [ "$#" -lt 4 ]; then
    echo "Usage: bash modify_bam_orientation.sh <input.bam> <output.bam> <orientation> <samtools_path>"
    echo "Orientation options: '+' for plus orientation, '-' for minus orientation"
    exit 1
fi

# Assign command-line arguments to variables
input_bam="$1"
output_bam="$2"
orientation="$3"
samtools_path="$4"

# Determine temporary file names based on output file name
output_sam="${output_bam}_output.sam"
modified_sam="${output_bam}_modified.sam"

# Convert BAM to SAM
${samtools_path} view -h -o $output_sam "$input_bam"

# Modify read orientation based on specified orientation option
if [ "$orientation" == "plusify" ]; then
    awk -F'\t' 'BEGIN{OFS=FS}{if(!/^@/ && (and(int($2), 16)==16)){$2 = $2 - 16}; print}' $output_sam > $modified_sam
elif [ "$orientation" == "minusify" ]; then
    awk -F'\t' 'BEGIN{OFS=FS}{if(!/^@/ && (and(int($2), 16)==0)){$2 = $2 + 16}; print}' $output_sam > $modified_sam
else
    echo "Invalid orientation option. Please use 'plusify' or 'minusify'"
    exit 1
fi

# Convert modified SAM to BAM
${samtools_path} view -b -o "$output_bam" $modified_sam

# Index the modified BAM
${samtools_path} index "$output_bam"

# Clean up intermediate files
rm $output_sam $modified_sam

echo "Read orientation modification completed successfully."