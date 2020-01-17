FROM ubuntu:16.04
MAINTAINER Qingyao Huang (qingyao.huang@uzh.ch)

# System requirements

RUN apt-get update --fix-missing &&\
apt-get install -y wget bzip2 unzip gcc g++ pkg-config make zlib1g-dev libncurses5-dev libncursesw5-dev libbz2-dev liblzma-dev htop &&\
apt-get clean

# Create and a directory to deploy and build, set it as ENV
RUN mkdir /build && mkdir /source && mkdir /code
WORKDIR /build
ENV BUILD /build

# Install plink and admixture
RUN mkdir plink_linux_x86_64 && \
cd plink_linux_x86_64 && \
wget http://s3.amazonaws.com/plink1-assets/plink_linux_x86_64_20181202.zip && \
unzip plink_linux_x86_64_20181202.zip

ENV BUILD /build
RUN wget http://software.genetics.ucla.edu/admixture/binaries/admixture_linux-1.3.0.tar.gz &&\
tar -xvzf admixture_linux-1.3.0.tar.gz

RUN ln -s /build/plink_linux_x86_64/plink /usr/bin/plink &&\
ln -s /build/admixture_linux-1.3.0/admixture /usr/bin/admixture

# Cleanup
RUN rm plink_linux_x86_64/plink_linux_x86_64_20181202.zip &&\
rm admixture_linux-1.3.0.tar.gz

# Install vcftools
ENV ZIP=vcftools-0.1.15.tar.gz
ENV URL=https://github.com/vcftools/vcftools/releases/download/v0.1.15/
ENV FOLDER=vcftools-0.1.15
ENV DST=/tmp

RUN apt-get update && apt-get install -y tabix

RUN wget $URL/$ZIP -O $DST/$ZIP && \
  tar xvf $DST/$ZIP -C $DST && \
  rm $DST/$ZIP && \
  cd $DST/$FOLDER && \
  ./configure && \
  make && \
  make install && \
  ln -s $DST/$FOLDER/vcftools /usr/bin/vcftools

# Install R and dependency
RUN apt-get install -y r-base &&\
R -e "install.packages('randomForest',repos='http://cran.r-project.org')" &&\
R -e "install.packages('optparse',repos='http://cran.r-project.org')" &&\
R -e "install.packages('Rcpp',repos='http://cran.r-project.org')" &&\
R -e "install.packages('readr',repos='http://cran.r-project.org')" 



# Add reference and annotations to image
ADD /source/* /source/
ADD /code/* /code/

# Initiate
WORKDIR /code
CMD tail -f /dev/null
CMD /bin/bash
