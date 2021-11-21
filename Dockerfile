# Dockerfile for cDNA-cupckae
# https://github.com/Magdoll/cDNA_Cupcake

FROM python:3

MAINTAINER Anne Deslattes Mays adeslat@scitechcon.org

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update

ENV MINICONDA_VERSION py37_4.9.2
ENV CONDA_DIR /miniconda3

RUN wget https://repo.anaconda.com/miniconda/Miniconda3-$MINICONDA_VERSION-Linux-x86_64.sh -O ~/miniconda.sh && \
    chmod +x ~/miniconda.sh && \
    ~/miniconda.sh -b -p $CONDA_DIR && \
    rm ~/miniconda.sh

# make non-activate conda commands available
ENV PATH=$CONDA_DIR/bin:$PATH

# make conda activate command available from /bin/bash --login shells
RUN echo ". $CONDA_DIR/etc/profile.d/conda.sh" >> ~/.profile

# make conda activate command available from /bin/bash --interative shells
RUN conda init bash

#############################################
### build conda environment: cDNA-cupcake ###
#############################################
# Clone cDNA_Cupcake repo
ENV APPSUBNAME singlecell
ENV APPNAME cDNA_Cupcake
ENV APPS_HOME /apps
RUN mkdir $APPS_HOME
WORKDIR $APPS_HOME

# Build cDNA_Cupcake  conda environment
# there wasn't a conda_env.yml file in the repos - so we made one and are copying it from this
# repos to where it can be found
#
COPY $APPNAME.conda_env.yml $APPS_HOME/$APPNAME/$APPNAME.conda_env.yml

ENV ENV_PREFIX /env/$APPNAME
RUN conda update --name base --channel defaults conda && \
    conda env create --prefix $ENV_PREFIX --file $APPS_HOME/$APPNAME/$APPNAME.conda_env.yml --force && \
    conda clean --all --yes
    
###########################################################################
# need to switch shell from default /sh to /bash so that `source` works   #
# install an editor so emacs can be used if the image needs debugging!    #
# Make shell scripts to run conda apps in conda environment               #
# make python scripts executable.                                         #
# cluster_by_UMI_mapping.py lacks a shebang.  Add it here for now but     #
#    remove it if it is fixed in the future                               #
###########################################################################
SHELL ["/bin/bash", "-c"]
RUN source $CONDA_DIR/etc/profile.d/conda.sh && \
  conda activate /env/$APPNAME && \
  conda install -c conda-forge emacs -y && \
  conda install -c conda-forge numpy -y && \
  conda install -c conda-forge cython -y && \
  git clone https://github.com/Magdoll/cDNA_Cupcake.git && \
  cd cDNA_Cupcake && \
  git checkout v28.0.0 && \
  sed -i '1s/^/#!\/usr\/bin\/env python\n/' singlecell/cluster_by_UMI_mapping.py && \
  chmod +x singlecell/cluster_by_UMI_mapping.py && \
  chmod +x singlecell/UMI_BC_error_correct.py && \
  chmod +x singlecell/clip_out_UMI_cellBC.py && \
  chmod +x singlecell/collate_FLNC_gene_info.py && \
  chmod +x singlecell/dedup_FLNC_per_cluster.py && \
  chmod +x singlecell/make_csv_for_dedup.py && \
  python setup.py install && \
  conda deactivate
SHELL ["/bin/sh", "-c"]

###########################################################################
# Make wrappers for each of the functions so it is clear how to call each #
###########################################################################
# This version is making all the singlecell functions available           #
###########################################################################
# Make wrapper for cDNA_Cupcake/singlecell/clip_out_UMI_cellBC.py         #
###########################################################################
ENV TOOLNAME clip_out_UMI_cellBC.py
RUN echo '#!/bin/bash' >> /usr/local/bin/$TOOLNAME && \
  echo "source $CONDA_DIR/etc/profile.d/conda.sh" >> /usr/local/bin/$TOOLNAME && \
  echo "conda activate /env/$APPNAME" >> /usr/local/bin/$TOOLNAME  && \
  echo "$APPS_HOME/$APPNAME/$APPSUBNAME/$TOOLNAME \"\$@\"" >> /usr/local/bin/$TOOLNAME  && \
  chmod 755 -R /usr/local/bin/$TOOLNAME

###########################################################################
# Make wrapper for cDNA_Cupcake/singlecell/UMI_BC_error_correct.py        #
###########################################################################
ENV TOOLNAME UMI_BC_error_correct.py
RUN echo '#!/bin/bash' >> /usr/local/bin/$TOOLNAME && \
  echo "source $CONDA_DIR/etc/profile.d/conda.sh" >> /usr/local/bin/$TOOLNAME && \
  echo "conda activate /env/$APPNAME" >> /usr/local/bin/$TOOLNAME  && \
  echo "$APPS_HOME/$APPNAME/$APPSUBNAME/$TOOLNAME \"\$@\"" >> /usr/local/bin/$TOOLNAME  && \
  chmod 755 /usr/local/bin/$TOOLNAME

###########################################################################
# Make wrapper for cDNA_Cupcake/singlecell/cluster_by_UMI_mapping.py      #
###########################################################################
ENV TOOLNAME cluster_by_UMI_mapping.py
RUN echo '#!/bin/bash' >> /usr/local/bin/$TOOLNAME && \
  echo "source $CONDA_DIR/etc/profile.d/conda.sh" >> /usr/local/bin/$TOOLNAME && \
  echo "conda activate /env/$APPNAME" >> /usr/local/bin/$TOOLNAME  && \
  echo "$APPS_HOME/$APPNAME/$APPSUBNAME/$TOOLNAME \"\$@\"" >> /usr/local/bin/$TOOLNAME  && \
  chmod 755 /usr/local/bin/$TOOLNAME

###########################################################################
# Make wrapper for cDNA_Cupcake/singlecell/collate_FLNC_gene_info.py      #
###########################################################################
ENV TOOLNAME collate_FLNC_gene_info.py
RUN echo '#!/bin/bash' >> /usr/local/bin/$TOOLNAME && \
  echo "source $CONDA_DIR/etc/profile.d/conda.sh" >> /usr/local/bin/$TOOLNAME && \
  echo "conda activate /env/$APPNAME" >> /usr/local/bin/$TOOLNAME  && \
  echo "$APPS_HOME/$APPNAME/$APPSUBNAME/$TOOLNAME \"\$@\"" >> /usr/local/bin/$TOOLNAME  && \
  chmod 755 /usr/local/bin/$TOOLNAME

###########################################################################
# Make wrapper for cDNA_Cupcake/singlecell/dedup_FLNC_per_cluster.py      #
###########################################################################
ENV TOOLNAME dedup_FLNC_per_cluster.py
RUN echo '#!/bin/bash' >> /usr/local/bin/$TOOLNAME && \
  echo "source $CONDA_DIR/etc/profile.d/conda.sh" >> /usr/local/bin/$TOOLNAME && \
  echo "conda activate /env/$APPNAME" >> /usr/local/bin/$TOOLNAME  && \
  echo "$APPS_HOME/$APPNAME/$APPSUBNAME/$TOOLNAME \"\$@\"" >> /usr/local/bin/$TOOLNAME  && \
  chmod 755 /usr/local/bin/$TOOLNAME

###########################################################################
# Make wrapper for cDNA_Cupcake/singlecell/make_csv_for_dedup.py          #
###########################################################################
ENV TOOLNAME make_csv_for_dedup.py
RUN echo '#!/bin/bash' >> /usr/local/bin/$TOOLNAME && \
  echo "source $CONDA_DIR/etc/profile.d/conda.sh" >> /usr/local/bin/$TOOLNAME && \
  echo "conda activate /env/$APPNAME" >> /usr/local/bin/$TOOLNAME  && \
  echo "$APPS_HOME/$APPNAME/$APPSUBNAME/$TOOLNAME \"\$@\"" >> /usr/local/bin/$TOOLNAME  && \
  chmod 755 /usr/local/bin/$TOOLNAME

WORKDIR /root
