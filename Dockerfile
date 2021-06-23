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
ENV APPNAME cDNACupcake
ENV APPS_HOME /apps
RUN mkdir $APPS_HOME
WORKDIR $APPS_HOME

# Install C-DNA cupcake
# checkout the specific version 4eee00d tag'd version v24.3.0
ENV ENV_PREFIX /env/$APPNAME
RUN conda update --name base --channel defaults conda && \
    conda create --prefix $ENV_PREFIX --force && \
    conda clean --all --yes

# need to switch shell from default /sh to /bash so that `source` works
SHELL ["/bin/bash", "-c"]
RUN source $CONDA_DIR/etc/profile.d/conda.sh && \
  conda activate /env/$APPNAME && \
  conda install -c conda-forge numpy -y && \
  conda install -c conda-forge cython -y && \
  git clone https://github.com/Magdoll/cDNA_Cupcake.git && \
  cd cDNA_Cupcake && \
  git checkout 4eee00da3257c7d474de0bf0019973ba326dae4f && \
  python setup.py build && \
  python setup.py install && \
  conda deactivate
SHELL ["/bin/sh", "-c"]

###########################################################################
# Make wrappers for each of the functions so it is clear how to call each #
###########################################################################
# This version is making all the singlecell functions available           #
###########################################################################
RUN mkdir /usr/local/bin/singlecell
###########################################################################
# Make wrapper for cDNA_Cupcake/singlecell/clip_out_UMI_cellBC.py         #
###########################################################################
ENV TOOLNAME singlecell/clip_out_UMI_cellBC.py
RUN echo '#!/bin/bash' >> /usr/local/bin/$TOOLNAME && \
  echo "source $CONDA_DIR/etc/profile.d/conda.sh" >> /usr/local/bin/$TOOLNAME && \
  echo "conda activate /env/$APPNAME" >> /usr/local/bin/$TOOLNAME  && \
  echo "export PYTHONPATH=$PYTHONPATH:$APPS_HOME/$APPNAME/cDNA_Cupcake/sequence/" >> /usr/local/bin/$TOOLNAME  && \
  echo "$APPS_HOME/$APPNAME/$TOOLNAME \"\$@\"" >> /usr/local/bin/$TOOLNAME  && \
  chmod 755 /usr/local/bin/$TOOLNAME

###########################################################################
# Make wrapper for cDNA_Cupcake/singlecell/UMI_BC_error_correct.py        #
###########################################################################
ENV TOOLNAME singlecell/UMI_BC_error_correct.py
RUN echo '#!/bin/bash' >> /usr/local/bin/$TOOLNAME && \
  echo "source $CONDA_DIR/etc/profile.d/conda.sh" >> /usr/local/bin/$TOOLNAME && \
  echo "conda activate /env/$APPNAME" >> /usr/local/bin/$TOOLNAME  && \
  echo "export PYTHONPATH=$PYTHONPATH:$APPS_HOME/$APPNAME/cDNA_Cupcake/sequence/" >> /usr/local/bin/$TOOLNAME  && \
  echo "$APPS_HOME/$APPNAME/$TOOLNAME \"\$@\"" >> /usr/local/bin/$TOOLNAME  && \
  chmod 755 /usr/local/bin/$TOOLNAME

###########################################################################
# Make wrapper for cDNA_Cupcake/singlecell/cluster_by_UMI_mapping.py      #
###########################################################################
ENV TOOLNAME singlecell/cluster_by_UMI_mapping.py
RUN echo '#!/bin/bash' >> /usr/local/bin/$TOOLNAME && \
  echo "source $CONDA_DIR/etc/profile.d/conda.sh" >> /usr/local/bin/$TOOLNAME && \
  echo "conda activate /env/$APPNAME" >> /usr/local/bin/$TOOLNAME  && \
  echo "export PYTHONPATH=$PYTHONPATH:$APPS_HOME/$APPNAME/cDNA_Cupcake/sequence/" >> /usr/local/bin/$TOOLNAME  && \
  echo "$APPS_HOME/$APPNAME/$TOOLNAME \"\$@\"" >> /usr/local/bin/$TOOLNAME  && \
  chmod 755 /usr/local/bin/$TOOLNAME

###########################################################################
# Make wrapper for cDNA_Cupcake/singlecell/collate_FLNC_gene_info.py      #
###########################################################################
ENV TOOLNAME singlecell/collate_FLNC_gene_info.py
RUN echo '#!/bin/bash' >> /usr/local/bin/$TOOLNAME && \
  echo "source $CONDA_DIR/etc/profile.d/conda.sh" >> /usr/local/bin/$TOOLNAME && \
  echo "conda activate /env/$APPNAME" >> /usr/local/bin/$TOOLNAME  && \
  echo "export PYTHONPATH=$PYTHONPATH:$APPS_HOME/$APPNAME/cDNA_Cupcake/sequence/" >> /usr/local/bin/$TOOLNAME  && \
  echo "$APPS_HOME/$APPNAME/$TOOLNAME \"\$@\"" >> /usr/local/bin/$TOOLNAME  && \
  chmod 755 /usr/local/bin/$TOOLNAME

###########################################################################
# Make wrapper for cDNA_Cupcake/singlecell/dedup_FLNC_per_cluster.py      #
###########################################################################
ENV TOOLNAME singlecell/dedup_FLNC_per_cluster.py
RUN echo '#!/bin/bash' >> /usr/local/bin/$TOOLNAME && \
  echo "source $CONDA_DIR/etc/profile.d/conda.sh" >> /usr/local/bin/$TOOLNAME && \
  echo "conda activate /env/$APPNAME" >> /usr/local/bin/$TOOLNAME  && \
  echo "export PYTHONPATH=$PYTHONPATH:$APPS_HOME/$APPNAME/cDNA_Cupcake/sequence/" >> /usr/local/bin/$TOOLNAME  && \
  echo "$APPS_HOME/$APPNAME/$TOOLNAME \"\$@\"" >> /usr/local/bin/$TOOLNAME  && \
  chmod 755 /usr/local/bin/$TOOLNAME

###########################################################################
# Make wrapper for cDNA_Cupcake/singlecell/make_csv_for_dedup.py          #
###########################################################################
ENV TOOLNAME singlecell/make_csv_for_dedup.py
RUN echo '#!/bin/bash' >> /usr/local/bin/$TOOLNAME && \
  echo "source $CONDA_DIR/etc/profile.d/conda.sh" >> /usr/local/bin/$TOOLNAME && \
  echo "conda activate /env/$APPNAME" >> /usr/local/bin/$TOOLNAME  && \
  echo "export PYTHONPATH=$PYTHONPATH:$APPS_HOME/$APPNAME/cDNA_Cupcake/sequence/" >> /usr/local/bin/$TOOLNAME  && \
  echo "$APPS_HOME/$APPNAME/$TOOLNAME \"\$@\"" >> /usr/local/bin/$TOOLNAME  && \
  chmod 755 /usr/local/bin/$TOOLNAME

WORKDIR /root
