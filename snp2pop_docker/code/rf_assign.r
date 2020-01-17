rf_assign <- function(platform,file_format){
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
        }
    )

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
        popfive = unique(pop_match$Superpopulation.code)
        if (nrow(prob) == 1) {
            df = data.frame(t(sapply(popfive, function(x) {
                cols <- colnames(prob) %in% pop_match$Population.code[pop_match$Superpopulation.code %in% x]
          
                sum(prob[1,cols])
                })))
            prob <- cbind(prob, df)
            } else {
                prob <- cbind(prob,sapply(popfive, function(x){

                cols <- colnames(prob) %in% pop_match$Population.code[pop_match$Superpopulation.code %in% x]
              
                apply(prob[,cols],1,sum)
            }
          
        ))}
        print(prob)
        prob$superpopulation <- popfive[apply(prob[,popfive],1, which.max)]
        prob$superpop_score <- apply(prob[,popfive],1,function(x) max(x) - max(x[-which.max(x)]))
        write.table(prob,file.path(targetdir,'results','all.tsv'),append = F,sep = '\t',quote = F,row.names = F)
    }
    if (file_format %in% c("FRAC", "ALL")){
        file.copy(file.path(targetdir,'tmp','plink,sample.9.Q'),file.path(targetdir,'results','frac.tsv'))
    }
}

rf_assign_custom <- function(label){
  
    targetdir = '/data'
    dir.create(file.path(targetdir,'results'),showWarnings=F)

    library(randomForest)
    pop <- read.table(file.path(targetdir,'reference',label), header = TRUE, stringsAsFactors = F)

    reference <- read.table('/data/tmp/plink,reference.9.Q')
    refID <- read.table('/data/tmp/plink,reference.fam',stringsAsFactors = F)[,1]
    reference <- reference[which(refID %in% pop[,1]),]
    reference$pop <- factor(pop[match(refID, pop[,1]),2])
    gr = length(levels(reference$pop))
    rf <- randomForest(pop ~ ., data = reference,ntree=50,proximity=T)
    study <- read.table('/data/tmp/plink,sample.9.Q')
    result <- predict(rf, newdata = study)
    prob <- matrix(predict(rf, newdata = study,type = "prob"),ncol=gr,byrow=F)
    prob <- as.data.frame(prob)
    colnames(prob)[1:gr] <- names(predict(rf, newdata = study,type = "vote")[1,])

    marg <- apply(prob,1,function(x) {

        od <- order(x,decreasing = T)
            x[od[1]] - x[od[2]]
        }
    )

    prob$result <- as.character(result)
    prob$score <- marg

    sampleID <- read.table('/data/tmp/plink,sample.fam',stringsAsFactors = F)[,1]
    prob <- cbind(ID = sampleID,prob)
    write.table(prob,file.path(targetdir,'results','group.tsv'),append = F,sep = '\t',quote = F,row.names = F)
    
}

