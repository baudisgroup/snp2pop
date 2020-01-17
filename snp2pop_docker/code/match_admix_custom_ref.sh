#! /bin/sh
sampledir=/data/tmp/
map1=/data/tmp/plink,reference.bim
map2=plink,sample.map
bim2=plink,sample.bim
ped=plink,sample
bed=plink,sample.bed

cd $sampledir
cut -f2 $map1 > extract_snp2.txt
plink --bfile $ped --extract extract_snp2.txt --a1-allele $map1 5 2 0 --make-bed --out $ped
diff -s $bim2 $map1 >> diff.txt ## check if SNP ID annotations are the same.
cp plink,reference.9.P plink,sample.9.P.in
admixture -P $bed 9
