bedfiles=("cpx_invs.bed" "het_invs.bed" "hom_invs.bed" "ref_invs.bed")

for bed in ${bedfiles[@]}; do
    # remove extension to use as directory name
    dir=$(echo $bed | cut -f 1 -d '.')
    mkdir -p snapshots/$dir

    while IFS=$'\t' read -r chr start end; do
        igv_command="new\n
        genome hg19\n
        load /path/to/your/data.bam\n
        snapshotDirectory /path/to/snapshots/$dir\n
        goto ${chr}:${start}-${end}\n
        snapshot ${chr}_${start}_${end}.png"
        
        echo -e $igv_command | igvtools batch stdin
    done < $bed
done
