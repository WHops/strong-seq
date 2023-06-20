library(breakpointR)

files2sync = list.files(path = 'data/', full.names=TRUE)
gr = synchronizeReadDir(files2sync=files2sync)

df <- data.frame(seqnames=seqnames(gr),
starts=start(gr)-1,
ends=end(gr),
names=c(rep(".", length(gr))),
    scores=elementMetadata(gr)$mapq,
    strands=strand(gr))

write.table(df, file="foo.bed", quote=F, sep="\t", row.names=F, col.names=F)

