library(readr)
library(Rcpp)
sourceCpp('code.cpp')
options(readr.num_columns = 0)
options(stringsAsFactors = F)

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
    input_files <- input_files[!input_files %in% c('tmp','results', 'reference')]

    anno <- read.table(sprintf('/source/%s_anno.tsv',platform),header=T,stringsAsFactors = F)
    anno[,3] <- sapply(anno[,3],convertXto23)
    anno$chr_pos <- paste(anno[,3],anno[,4],sep = '_')


    ### check missingID
    missingID <- c()
    for (f in input_files){
        sample_name <- unlist(strsplit(f,split = '.tsv',fixed = T))[1]
        fracb <- read_delim(file.path(targetdir,f), "\t", escape_double = FALSE, trim_ws = TRUE)
        fracb$chr_pos <- paste(fracb[[2]],fracb[[3]],sep = '_')

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
    if (file.exists(pedfile)) file.remove(pedfile)

    totalCount <- length(input_files)
    count <- 0
    for (f in input_files){
        count <- count+1
        sample_name <- unlist(strsplit(f,split = '.tsv',fixed = T))[1]

        message(paste(sprintf('(%s/%s) Currently processing',count,totalCount), sample_name, '...'))

        fracb <- read_delim(file.path(targetdir,f), "\t", escape_double = FALSE, trim_ws = TRUE)

        idx <-  match(anno$chr_pos, fracb$chr_pos)
        fracb <- fracb[idx,]

        if (file_format == "GC") {
            map<- c('AA' = 0 , 'AB' = 0.5, 'BB' = 1)
            fracb[[4]] <- map[fracb[[4]]]
        }

        if (file_format == "BS") {
            fracb[[4]] <- fracb[[4]]/2
        }

        oneliner <- onelinerCpp(fracb, anno)

        write_output_Cpp(c(sample_name,sample_name,rep("0",3), "-9",oneliner), pedfile)
    }

    ### create map file
    mapfile <-file.path(targetdir, 'tmp', 'plink,sample.map')
    writedata <- cbind(anno[,c(3,2)],rep(0,length(idx)),anno[,4])
    write.table(writedata,mapfile,quote = F,row.names = F,col.names = F,sep='\t')
}
