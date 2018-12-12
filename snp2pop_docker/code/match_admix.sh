#! /bin/sh
platform=$1
sampledir=/data/tmp/
map1=/source/plink_$platform'_v2.bim'
map2=plink,sample.map
bim2=plink,sample.bim
ped=plink,sample
bed=plink,sample.bed

cd $sampledir
plink --bfile $ped --a1-allele $map1 5 2 0 --make-bed --out $ped
diff -s plink,sample.bim /source/plink_$platform'_v2.bim' >> diff.txt ## check if SNP ID annotations are the same.
#  cp $map1 $bim2

if [ ! -e plink,sample.9.P.in ]
then
cp /source/plink_$platform'_v2.9.P' plink,sample.9.P.in
fi
admixture -P $bed 9
