### sanity check of converted sequencing data
### check the snps
map <- read.table('/data/tmp/plink,reference.bim',stringsAsFactors = F)
bim <- read.table('/source/plink_GenomeWideSNP_6_v2.bim',stringsAsFactors = F)
originalP <- readLines('/source/plink_GenomeWideSNP_6_v2.9.P')
newP <- originalP[match(map$V2,bim$V2)]
writeLines(newP, '/data/tmp/plink,sample.9.P.in')
