#!/bin/bash

# input parameters
input_bam=$1
output_bam=$2
direction=$3

# Determine temporary file names based on output file name
readnames="${output_bam}_readnames.txt"
header="${output_bam}_header.sam"

# Determine flags based on direction
if [ "$direction" = "plus" ]
then
    include_flag=64
    exclude_flag=16
elif [ "$direction" = "minus" ]
then
    include_flag=80
    exclude_flag=4
else
    echo "Invalid direction: must be '+' or '-'"
    exit 1
fi

# Extract read names for the first-in-pair reads aligned in specified direction
samtools view -f $include_flag -F $exclude_flag $input_bam | awk '{print $1}' > $readnames

# Extract BAM header
samtools view -H $input_bam > $header

# Extract read pairs corresponding to these names and append to header
samtools view $input_bam | grep -Fwf $readnames | cat $header - | samtools view -bS - > $output_bam

# Remove temporary files
rm $readnames $header
