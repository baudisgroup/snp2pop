convertXto23 <- function(chr){
    if (chr == 'X') {
        return (23)
    } else {
        return(chr)
    }
}
createPedMapFile <- function(platform,file_format){

    targetdir <- '/data'
    input_files <- list.files(targetdir)
    input_files <- input_files[!input_files %in% c('tmp','results')]

    options(stringsAsFactors = F)

    anno <- read.table(sprintf('/source/%s_anno.tsv',platform),header=T,stringsAsFactors = F)
    anno[,3] <- sapply(anno[,3],convertXto23)
    anno$chr_pos <- paste(anno[,3],anno[,4],sep = '_')


    ### check missingID
    missingID <- c()
    for (f in input_files){
        sample_name <- unlist(strsplit(f,split = '.tsv',fixed = T))[1]
        fracb <- read.table(file.path(targetdir,f),header = T,stringsAsFactors = F)
        fracb$chr_pos <- paste(fracb[,2],fracb[,3],sep = '_')

        if (sum(!anno$chr_pos %in% fracb$chr_pos) > 0) {
            warning(sprintf('For %s: fracB file incomplete.',sample_name))
            missingID <- union(missingID, which(!anno$chr_pos %in% fracb$chr_pos))

            }
        fracb <- fracb[which(fracb$chr_pos %in% anno$chr_pos),]
        write.table(fracb,file.path(targetdir,f),sep='\t',row.names = F, quote = F)
    }

    if (length(missingID)>0) {
        write.table(anno[missingID,2],file.path(targetdir,"tmp","missingID.txt"),quote=F,row.names=F)
        anno <- anno[-missingID,]
        warning(sprintf('%i (%.3f%% of) probes are missing!',length(missingID),length(missingID)/nrow(anno)*100))
        originalP <- readLines(sprintf('/source/plink_%s_v2.9.P',platform))
        newP <- originalP[-missingID]
        writeLines(newP, file.path(targetdir,"tmp",'plink,sample.9.P.in'))
        # bim <- read.table(sprintf('/source/plink_%s_v2.bim',platform),stringsAsFactors = F)
        # newbim <- bim[which(bim$V2 %in% anno[missingID,2]),]
        # write.table(newbim, file.path(targetdir,"tmp",'plink,sample.bim'),sep='\t',row.names = F, quote = F)
    }

    ### create ped file
    pedfile <-file.path(targetdir, 'tmp', 'plink,sample.ped')
    sink(file = pedfile)

    totalCount <- length(input_files)
    count <- 0
    for (f in input_files){
        count <- count+1
        sample_name <- unlist(strsplit(f,split = '.tsv',fixed = T))[1]

        print(paste(sprintf('(%s/%s) Currently processing',count,totalCount), sample_name, '...')

        fracb <- read.table(file.path(targetdir,f),header = T,stringsAsFactors = F)

        idx <-  match(anno$chr_pos, fracb$chr_pos)
        fracb <- fracb[idx,]
        val <- fracb[,4]

        if (file_format == "GC") {
            map<- c('AA' = 0 , 'AB' = 0.5, 'BB' = 1)
            val <- map[val]
        }

        if (file_format == "BS") {
            val <- val/2
        }

        oneliner <- unlist(sapply(1:nrow(fracb),function(x){

            if (val[x] <0.15){
              rep(anno$Allele.A[x],2)
            } else if (val[x] >= 0.15 & val[x] <= 0.85) {
              c(anno$Allele.A[x],anno$Allele.B[x])
            }else if (val[x] > 0.85){
              rep(anno$Allele.B[x],2)
            }else{
              rep(0,2)
            }

        }))
        oneliner <- as.vector(oneliner)

        cat(sample_name,sample_name,rep("0",3), "-9",oneliner,"\n",sep=" ")
    }
    sink()

    ### create map file
    mapfile <-file.path(targetdir, 'tmp', 'plink,sample.map')
    writedata <- cbind(anno[,c(3,2)],rep(0,length(idx)),anno[,4])
    write.table(writedata,mapfile,quote = F,row.names = F,col.names = F,sep='\t')
}
