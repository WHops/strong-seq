#!/bin/bash

# Command-line parameters
bam_A=$1
bam_B=$2
chr=$3
hp=$4
outfile=$5
samtools_bin=$6
bedtools_bin=$7

# Generate a unique prefix for the temporary files
prefix_A=$(basename $bam_A .bam)_${chr}_$$
prefix_B=$(basename $bam_B .bam)_${chr}_HP${hp}_$$

# Convert BAM files to BEDPE format to represent paired-end reads in A
# (And suppress warnings)
${bedtools_bin} bamtobed -bedpe -i $bam_A > "${prefix_A}_A.bedpe" 2> /dev/null

# Convert BAM file to BED format for B, filtering by chromosome and HP tag
${samtools_bin} view -d HP:$hp -b $bam_B $chr | ${bedtools_bin} bamtobed -i stdin > "${prefix_B}_B.bed"

# After converting bam_B to BED format, calculate and store the total lengths of each read
awk '{a[$4]+=($3-$2)} END{for (i in a) print i, a[i]}' "${prefix_B}_B.bed" > "${prefix_B}_read_lengths.txt"

# Create an empty output file
> ${outfile}

# Loop over each line in the A.bedpe file
while IFS=$'\t' read -r -a pair
do
    
    # Get start and end of each paired read
    start1="${pair[1]}"
    end1="${pair[2]}"
    start2="${pair[4]}"
    end2="${pair[5]}"

    # Name and strand info
    name="${pair[6]}"
    strand1="${pair[8]}"
    strand2="${pair[9]}"


    # Find overlapping reads in B for each read of the pair and sort by total length of the read, keep longest

    overlaps=$(awk -v start1="$start1" -v end1="$end1" -v start2="$start2" -v end2="$end2" 'NR==FNR{a[$1]=$2;next}{if ($2<=end1 && $3>=start1 || $2<=end2 && $3>=start2) print $0"\t"a[$4]}' "${prefix_B}_read_lengths.txt" "${prefix_B}_B.bed" | sort -k8,8nr | head -1)
    # If no overlap was found, print the first read of the pair in BEDPE format
    if [[ -z "$overlaps" ]]; then
        echo "YESSS"
        echo -e "${pair[0]}\t$start1\t$end1\t${name}\t60\t$strand1" >> ${outfile}
    else
        read_name=$(echo $overlaps | cut -f4 -d$' ')  # Get the name of the longest overlapping read
        awk -v read="$read_name" '$4 == read {print $0}' "${prefix_B}_B.bed" >> ${outfile}  # Print all alignments for that read
    fi

done < "${prefix_A}_A.bedpe"

# Clean up
rm "${prefix_A}_A.bedpe" "${prefix_B}_B.bed" "${prefix_B}_read_lengths.txt"
