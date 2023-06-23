

cut -f 4,6 <(bedtools intersect -a h1_ont.bam -b h1_sseq_plus_output.bam -wa -bed) > raw.bed
cat raw.bed | uniq > raw_uniq.bed
awk '{print $1}' raw_uniq.bed | sort | uniq -u | grep -wFf - raw_uniq.bed > tagged_reads.tsv
