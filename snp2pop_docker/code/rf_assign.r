rf_assign <- function(platform,file_format){
  # args = commandArgs(trailingOnly = TRUE)
  # platform = args[1]
    targetdir = '/data'
    dir.create(file.path(targetdir,'results'),showWarnings=F)

    library(randomForest)
    if (file_format == 'CONT'){
      pop <- read.table('/source/2492pop.tsv',stringsAsFactors = F)
    }else {
      pop <- read.table('/source/2492pop26.tsv',stringsAsFactors = F)
    }

    reference <- read.table(sprintf('/source/plink_%s_v2.9.Q',platform))
    reference$pop <- factor(pop$V1)
    gr = length(levels(reference$pop))
    rf <- randomForest(pop ~ ., data = reference,ntree=50,proximity=T)
    study <- read.table(file.path(targetdir,'tmp','plink,sample.9.Q'))
    result <- predict(rf, newdata = study)
    prob <- matrix(predict(rf, newdata = study,type = "prob"),ncol=gr,byrow=F)
    prob <- as.data.frame(prob)
    colnames(prob)[1:gr] <- names(predict(rf, newdata = study,type = "vote")[1,])

    marg <- apply(prob,1,function(x) {
    od <- order(x,decreasing = T)
        x[od[1]] - x[od[2]]
        })
    prob$result <- as.character(result)
    prob$score <- marg

    sampleID <- read.table(file.path(targetdir,'tmp','plink,sample.fam'),stringsAsFactors = F)[,1]
    prob <- cbind(ID = sampleID,prob)
    if (file_format == "CONT"){
        write.table(prob,file.path(targetdir,'results','cont.tsv'),append = F,sep = '\t',quote = F,row.names = F)
        }
    if (file_format == "POP"){
        write.table(prob,file.path(targetdir,'results','pop.tsv'),append = F,sep = '\t',quote = F,row.names = F)
    }
    if (file_format == "ALL"){
        pop_match <- read.table('/source/pop_cont_match.tsv',stringsAsFactors = F,header=T)
        prob <- cbind(prob,sapply(unique(pop_match$Superpopulation.code), function(x){
          cols <- colnames(prob) %in% pop_match$Population.code[pop_match$Superpopulation.code %in% x]
          apply(prob[,cols],1,sum)
        }))
        prob$superpopulation <- unique(pop_match$Superpopulation.code)[apply(prob[,unique(pop_match$Superpopulation.code)],1, which.max)]
        prob$superpop_score <- apply(prob[,unique(pop_match$Superpopulation.code)],1,function(x) max(x) - max(x[-which.max(x)]))
        write.table(prob,file.path(targetdir,'results','all.tsv'),append = F,sep = '\t',quote = F,row.names = F)
    }
    if (file_format %in% c("FRAC", "ALL")){
        file.copy(file.path(targetdir,'tmp','plink,sample.9.Q'),file.path(targetdir,'results','frac.tsv'))
  }
}
