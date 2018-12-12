#!/usr/bin/env Rscript
library("optparse")

outputfile = '/data/tmp/Rout.log'
errorfile = '/data/tmp/Rerr.log'

option_list = list(
  make_option(c("-i", "--input"), type="character", default=NULL,
              help="input as B allele frequency file format (BAF), or genotype calling format (GC), Birdseed genotype format (BS) for SNP array data, or Variant Call Format (VCF) / gzipped VCF (GZVCF) for sequencing data.", metavar="character"),
	make_option(c("-o", "--out"), type="character", default='CONT',
              help="output file type (CONT, POP, FRAC or ALL), default is CONT, ALL includes POP and FRAC", metavar="character"),
  make_option(c("-p", "--platform"), type="character", default=NULL,
              help="SNP array platform", metavar="character")
)

opt_parser = OptionParser(option_list=option_list)
opt = parse_args(opt_parser)

if (any(is.null(opt$input),is.null(opt$platform))){
  print_help(opt_parser)
  stop("Input type and platform must be supplied. See help.", call.=FALSE)
}

if (any(!opt$input %in% c('BAF','GC','BS','VCF','GZVCF'))){
    print_help(opt_parser)
    stop('Input type must be one of the five types: BAF, GC, BS, VCF, GZVCF.')
}
accepted_platforms <- c('Mapping10K_Xba142','Mapping50K_Hind240','Mapping50K_Xba240',
                              'Mapping250K_Nsp','Mapping250K_Sty','CytoScan750K_Array',
                              'GenomeWideSNP_5','GenomeWideSNP_6','CytoScanHD_Array')

input_type = opt$input
platform = opt$platform
if (platform == 'Sequencing') platform <- 'GenomeWideSNP_6'
file_format = opt$out

if (!platform %in% accepted_platforms) stop('Platform not supported. See README.md for supported platforms.', call.=FALSE)

cat(input_type,'file chosen.\n')
dir.create('/data/tmp',showWarnings=F)
if (input_type %in% c('BAF','GC','BS')) {

    cat('Converting files to Plink formats...\n')
    source('createPedMapFile.r')
    createPedMapFile(platform,input_type)
    system('plink --file /data/tmp/plink,sample --make-bed --out /data/plink,sample')

} else {

    f <- list.files('/data')
    f <- f[!f %in% c('tmp','results')]

    if(length(f) > 1) {

        stop('There should be only one vcf file for all samples to be analyzed')

    } else if (length(grep('.vcf.gz',f))==1){

        cat('Converting files to Plink formats...\n')
        system(sprintf('vcftools --gzvcf /data/%s --snps %s --recode --out /data/tmp/plink',f,'/source/extract_snp.txt'))
        system('plink --vcf /data/tmp/plink.recode.vcf --make-bed --out /data/tmp/plink,sample')
        source('seq_check.r')

    } else if (length(grep('.vcf',f))==1){

        cat('Converting files to Plink formats...\n')
        system(sprintf('vcftools --vcf /data/%s --snps %s --recode --out /data/tmp/plink',f,'/source/extract_snp.txt'))
        system('plink --vcf /data/tmp/plink.recode.vcf --make-bed --out /data/tmp/plink,sample')
        source('seq_check.r')

    }
}

cat('Performing admixture model projection...\n')
system2("sh", c("match_admix.sh", platform),stdout = outputfile, stderr = errorfile)

cat('Performing random forest prediction...\n')
source('rf_assign.r')
rf_assign(platform,file_format)
