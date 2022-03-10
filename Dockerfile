# Initially found here: https://github.com/mlorthiois/bioinformatics-docker/tree/e9141202b407ea420a4213840a425f7031a7cd47/SQANTI3
FROM continuumio/miniconda3
LABEL description="Basic docker image for cDNA-cupcake"
ENV CONDA_ENV="cdnacupcake"

COPY environment.yml /opt/environment.yml

RUN conda env create -f /opt/environment.yml && conda clean -a

# Add conda installation dir to PATH (instead of doing 'conda activate')
ENV PATH /opt/conda/envs/${CONDA_ENV}/bin:$PATH

# Clone cDNA_Cupcake v15.1.0 from release tag using the --branch flag into new folder /opt/cDNA_Cupcake
RUN git clone https://github.com/Magdoll/cDNA_Cupcake.git --branch v15.1.0 /opt/cDNA_Cupcake && \
    cd /opt/cDNA_Cupcake && \
    python setup.py build && \
    python setup.py install && \
    rm -rf /opt/cDNA_Cupcake/.git && \
    rm -rf /opt/cDNA_Cupcake/.git

ENV PYTHONPATH /opt/cDNA_Cupcake/sequence/
ENV PATH "$PATH:/opt/cDNA_Cupcake/cupcake/tofu/"

CMD [ "collapse_isoforms_by_sam.py" ]
CMD [ "color_bed12_post_sqanti.py" ]
CMD [ "compare_junctions.py" ]
CMD [ "filter_away_subset.py" ]
CMD [ "filter_by_count.py" ]
CMD [ "filter_monoexon.py" ]
CMD [ "fusion_collate_info.py" ]
CMD [ "fusion_finder.py" ]
CMD [ "get_counts_by_barcode.py" ]
CMD [ "simple_stats_post_collapse.py" ]
CMD [ "utils.py" ]
