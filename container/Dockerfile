## NOTE: need to have ~3Gb memory when building this container


FROM rocker/verse:4.1.1

#  $ docker build . -t szsctt/r_scrna:latest -t szsctt/r_scrna:5
#  $ docker run --rm -it szsctt/r_scrna:latest /bin/bash
#  $ docker push szsctt/r_scrna:latest
#  $ docker push szsctt/r_scrna:5

ENV DEBIAN_FRONTEND noninteractive

# requirements
RUN apt-get update &&\
    apt-get install -y tmux git nano wget build-essential \
    libmysqlclient-dev libgdal-dev \
     libglpk-dev markdown libboost-all-dev gfortran \
     libudunits2-dev  &&\
    rm -rf /var/lib/apt/lists/* 

ADD install.R /tmp/install.R

RUN Rscript /tmp/install.R

RUN mkdir -p /var/run/rstudio-server &&\
 mkdir -p /var/lib/rstudio-server &&\
 mkdir -p /etc/rstudio/
