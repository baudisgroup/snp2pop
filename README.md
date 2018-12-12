# snp2pop

Population origin mapping from cancer SNP profile into 5 continental groups as defined in 1000 Genomes Project. This tool supports mapping from B-allele frequency data generated with 9 Affymetrix SNP array platforms as well as whole-genome sequencing data as input and a population assignment to one of the five continental groups (with 98.7% accuracy, benchmarked with paired TCGA data)-- AFR(_Africa_), EUR (_Europe_), AMR(_Admixed America_), EAS (_East Asia_), SAS (_South Asia_) or one of the 26 population groups (with ?% accuracy, benchmarked with paired TCGA data) --  ACB (_African Caribbeans in Barbados_), ASW (_Americans of African Ancestry in SW USA_), BEB (_Bengali from Bangladesh_), CDX (_Chinese Dai in Xishuangbanna, China_), CEU (_Utah Residents (CEPH) with Northern and Western European Ancestry_), CHB (_Han Chinese in Beijing, China_), CHS (_Southern Han Chinese_), CLM (_Colombians from Medellin, Colombia_), ESN (_Esan in Nigeria_), FIN (_Finnish in Finland_), GBR (_British in England and Scotland_), GIH (_Gujarati Indian from Houston, Texas_), GWD (_Gambian in Western Divisions in the Gambia_), IBS (_Iberian Population in Spain_), ITU (_Indian Telugu from the UK_), JPT (_Japanese in Tokyo, Japan_), KHV (_Kinh in Ho Chi Minh City, Vietnam_), LWK (_Luhya in Webuye, Kenya_), MSL (_Mende in Sierra Leone_), MXL (_Mexican Ancestry from Los Angeles USA_), PEL (_Peruvians from Lima, Peru_), PJL (_Punjabi from Lahore, Pakistan_), PUR (_Puerto Ricans from Puerto Rico_), STU (_Sri Lankan Tamil from the UK_), TSI (_Toscani in Italia_), YRI (_Yoruba in Ibadan, Nigeria_). The currently supported genome version is GRCh37 (hg19). A mapping to other genome versions is planned.

## Docker version installation
The easiest way is to use docker application. First, install [Docker application](https://docs.docker.com/install/), then:
```
docker pull baudisgroup/snp2pop
```

## Usage
First, you need to create a working directory `$hostdir` (use absolute path) to copy your input files and to receive the output from the pipeline. (file will be modified, so please only copy your original file into this folder.)
```
docker run -it --rm --mount type=bind,source=$hostdir,target=/data baudisgroup/snp2pop
```
After entering the interactive mode of the container, you can place your input files in `$hostdir/input` directory. Then:
```
Rscript --vanilla run_pop.r <parameters>
```
Then you will receive in the `/results` folder under `$hostdir` your mapping results.

### Demo Example with test data
You need to download the `/test_SNP` folder from [here](https://github.com/baudisgroup/snp2pop/tree/master/test_SNP) and copy the absolute path as `$test_dir`. These 2 files are processed BAF files from GEO repository with genotyping platform "Mapping250K_Nsp".
```
docker run -it --rm --mount type=bind,source=$test_dir,target=/data baudisgroup/snp2pop
```

If you use the `/test_SNP`, run the following command:
```
Rscript --vanilla run_pop.r -i BAF -o CONT -p Mapping250K_Nsp
```

For testing sequencing data, you can download the 1000Genomes phase3 version 5 data from [1000Genomes project FTP site](ftp://ftp.1000genomes.ebi.ac.uk/vol1/ftp/release/20130502/).
If you use sequencing data, run the following command:

```
Rscript --vanilla run_pop.r -i GZVCF -p Sequencing -o ALL
```



## Options
  -i --input TEXT         input as B allele frequency file format (BAF), or genotype calling format (GC), Birdseed genotype format (BS) for SNP array data, or Variant Call Format (VCF) / gzipped VCF (GZVCF) for sequencing data.

  -p --platform  TEXT     SNP array platform; omitted for sequencing data.

  -o --output TEXT        output as 9 theoretical fractions (FRAC), or output as ratio of 5 continental groups with a voting result (CONT) or ratio of 26 population groups with a voting result.

The input file can be SNP array output or sequencing data. In case of sequencing data, vcf or vcf.gz file formats are supported as input for sequencing data. Only one vcf file should be placed in the dicrectory.

In case of SNP array output, the current pipeline supports 9 array platforms from Affymetrix:

- Mapping10K_Xba142

- Mapping50K_Hind240

- Mapping50K_Xba240

- Mapping250K_Nsp

- Mapping250K_Sty

- GenomeWideSNP_5

- GenomeWideSNP_6

- CytoScan750K_Array

- CytoScanHD_Array

The input file should be *tab separated*. There should be 4 columns: ID (SNP ID or simply indicating row number), chromosome (1-23), nucleotide base position, and a value column (a number within 0-1 if **BAF** format, or AA/AB/BB if **GC** format).

Example for **BAF** input format:

ID	CHRO	BASEPOS	VALUE

SNP_A-2131660	1	1220751	0.3487

SNP_A-1967418	1	2302812	0.9451

SNP_A-1969580	1	2398125	1.0000

SNP_A-4263484	1	2622185	0.4612

.

.

.

Example for **GC** input format:

ID	CHRO	BASEPOS	VALUE

SNP_1	1	1220751	AB

SNP_2	1	2302812	BB

SNP_3	1	2398125	BB

SNP_4	1	2622185	AB

.

.

.

Example for **BS** input format:

ID    CHRO    BASEPOS    VALUE

SNP_1    1    1220751    1

SNP_2    1    2302812    2

SNP_3    1    2398125    2

SNP_4    1    2622185    1

.

.

.
