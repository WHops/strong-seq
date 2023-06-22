#!/bin/bash

# input parameters
input_bam=$1
output_prefix=$2
direction=$3

# Determine flags based on direction
if [ "$direction" = "+" ]
then
    include_flag=64
    exclude_flag=16
elif [ "$direction" = "-" ]
then
    include_flag=80
    exclude_flag=4
else
    echo "Invalid direction: must be '+' or '-'"
    exit 1
fi

# Extract read names for the first-in-pair reads aligned in specified direction
samtools view -f $include_flag -F $exclude_flag $input_bam | awk '{print $1}' > ${output_prefix}_readnames.txt

# Extract BAM header
samtools view -H $input_bam > ${output_prefix}_header.sam

# Extract read pairs corresponding to these names and append to header
samtools view $input_bam | grep -Fwf ${output_prefix}_readnames.txt | cat ${output_prefix}_header.sam - | samtools view -bS - > ${output_prefix}_output.bam

# Remove temporary files
rm ${output_prefix}_readnames.txt ${output_prefix}_header.sam
