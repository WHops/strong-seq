#!/bin/bash

# Base directory
base_dir='/Users/hoeps/PhD/projects/strong-seq/post_analysis_igv'

# Variables
invs_noSD_bed="${base_dir}/data/invs_collapsed/invs_noSD_collapsed.bed"
mosai_het_bed="${base_dir}/data/mosaicatcher/derived/het_invs.bed"
mosai_hom_bed="${base_dir}/data/mosaicatcher/derived/hom_invs.bed"
invs_noSD_het_bed="${base_dir}/res/tmp_bedfiles/invs_noSD_het.bed"
invs_noSD_hom_bed="${base_dir}/res/tmp_bedfiles/invs_noSD_hom.bed"
igv_run_script="${base_dir}/igv_runs/run.sh"
igv_session="${base_dir}/data/igv_sessions/igv_session.xml"
screenshot_dir="${base_dir}/res/screenshots"
invs_noSD_above50_bed="${base_dir}/res/tmp_bedfiles/invs_noSD_collapsed_above50.bed"


# Execute the awk and bedtools commands
awk 'BEGIN {FS=OFS="\t"} ($3-$2 > 10000)' ${invs_noSD_bed} > ${invs_noSD_above50_bed}
bedtools intersect -a ${invs_noSD_above50_bed} -b ${mosai_het_bed} -wa -f 0.25 -r -u > ${invs_noSD_het_bed}
bedtools intersect -a ${invs_noSD_above50_bed} -b ${mosai_hom_bed} -wa -f 0.25 -r -u > ${invs_noSD_hom_bed}

# Call Python script
python3 make_igv_session.py ${invs_noSD_het_bed} ${invs_noSD_hom_bed} ${igv_run_script} ${igv_session} ${screenshot_dir}